#!/bin/bash
# Copyright 2020 Google LLC
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

echo "**** Startup Step 1/6: Update apt-get repositories. ****"
apt-get update

echo "**** Startup Step 2/6: Install Java. Needed to accept jobs from Jenkins Master. ****"
apt-get install -y default-jdk

echo "**** Startup Step 3/6: Install tools needed to run pipeline commands. ****"
apt-get install -y git jq unzip google-cloud-sdk google-cloud-sdk

echo "**** Startup Step 4/6: Create a directory to locate Terraform binaries. ****"
# shellcheck disable=SC2154
mkdir -p "${tpl_TERRAFORM_DIR}" && cd "${tpl_TERRAFORM_DIR}" || exit

echo "**** Startup Step 5/6: Download, verify and unzip Terraform binaries. ****"
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

echo "**** Startup Step 6/6: Download and install the Terraform validator ****"
gsutil cp gs://terraform-validator/releases/2019-04-04/terraform-validator-linux-amd64 .
chmod 755 "${tpl_TERRAFORM_DIR}terraform-validator-linux-amd64"
mv "${tpl_TERRAFORM_DIR}terraform-validator-linux-amd64" "${tpl_TERRAFORM_DIR}terraform-validator"
