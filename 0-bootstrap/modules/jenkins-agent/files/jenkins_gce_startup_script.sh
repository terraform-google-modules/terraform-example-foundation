#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/sh

echo "**** Startup Step 1/8: Update apt-get repositories. ****"
apt-get update

echo "**** Startup Step 2/8: Install Java. Needed to accept jobs from Jenkins Controller. ****"
apt-get install -y default-jdk

echo "**** Startup Step 3/8: Install tools needed to run pipeline commands. ****"
apt-get install -y git jq unzip wget google-cloud-sdk google-cloud-sdk-terraform-tools

echo "**** Startup Step 4/8: Create a directory to locate Terraform binaries. ****"
# shellcheck disable=SC2154
mkdir -p "${tpl_TERRAFORM_DIR}" && cd "${tpl_TERRAFORM_DIR}" || exit

echo "**** Startup Step 5/8: Download, verify and unzip Terraform binaries. ****"
# shellcheck disable=SC2154
wget "https://releases.hashicorp.com/terraform/${tpl_TERRAFORM_VERSION}/terraform_${tpl_TERRAFORM_VERSION}_linux_amd64.zip" && \
    echo "${tpl_TERRAFORM_VERSION_SHA256SUM} terraform_${tpl_TERRAFORM_VERSION}_linux_amd64.zip" > terraform_SHA256SUMS && \
    sha256sum -c terraform_SHA256SUMS --status && \
    unzip "terraform_${tpl_TERRAFORM_VERSION}_linux_amd64.zip" -d "${tpl_TERRAFORM_DIR}" && \
    chmod 755 terraform && \
    rm -f "${tpl_TERRAFORM_DIR}terraform_${tpl_TERRAFORM_VERSION}_linux_amd64.zip" && \
    apt-get remove --purge -y curl unzip && \
    apt-get --purge -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

echo "**** Startup Step 6/8: Verify that the tool is installed.  ****"
gcloud beta terraform vet --help

echo "**** Startup Step 7/8: Create jenkins user. ****"
# Home directory for the jenkins user
JENKINS_HOME_DIR="/home/jenkins"

# The "Remote Jenkins directory" is used to store Jenkins Agent logs
JENKINS_AGENT_REMOTE_DIR="$JENKINS_HOME_DIR/jenkins_agent_dir"

# Create  and set the jenkins user as owner
mkdir -p "$JENKINS_AGENT_REMOTE_DIR" && \
  chmod 766 "$JENKINS_AGENT_REMOTE_DIR" && \

useradd -d /home/jenkins jenkins
chown -R jenkins:jenkins /home/jenkins/

echo "**** Startup Step 8/8: Add public SSH key to the list of authorized keys. ****"

USER_SSH_DIR="$JENKINS_HOME_DIR/.ssh"

mkdir -p "$USER_SSH_DIR" && \
  chmod 766 "$USER_SSH_DIR"

# shellcheck disable=SC2154
cat > $USER_SSH_DIR/authorized_keys <<-EOT
${tpl_SSH_PUB_KEY}
EOT

chown -R jenkins "$USER_SSH_DIR"

chmod 755 $USER_SSH_DIR && \
 chmod 655 $USER_SSH_DIR/authorized_keys

# Global
SSHD_CONFIG_DIR="/etc/ssh"

# Setting up the sshd_config file
sed -i'' -e $SSHD_CONFIG_DIR/sshd_config \
        -e 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' \
        -e 's/#AuthorizedKeysFile.*/AuthorizedKeysFile    \/etc\/ssh\/authorized_keys/'

# The Jenkins Agent needs the Controller public key. This can be in your github repo
# shellcheck disable=SC2154
cat > $SSHD_CONFIG_DIR/authorized_keys <<-EOT
${tpl_SSH_PUB_KEY}
EOT

# Configure secure permissions on SSHD_CONFIG_DIR
chmod 755 $SSHD_CONFIG_DIR && \
 chmod 655 $SSHD_CONFIG_DIR/authorized_keys

systemctl restart sshd
