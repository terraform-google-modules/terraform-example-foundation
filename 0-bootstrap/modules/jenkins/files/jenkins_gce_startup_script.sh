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

echo "**** Startup Step 1/8: Update apt-get repositories. ****"
sudo apt-get update

echo "**** Startup Step 2/8: Install Java. Needed to accept jobs from Jenkins Master. ****"
sudo apt-get install -y default-jdk

echo "**** Startup Step 3/8: Create the directory for Terraform in /opt. ****"
# shellcheck disable=SC2154
mkdir "${tpl_TERRAFORM_DIR}" && cd "${tpl_TERRAFORM_DIR}" || exit

echo "**** Startup Step 4/8: Download Terraform. ****"
# shellcheck disable=SC2154
wget "https://releases.hashicorp.com/terraform/${tpl_TERRAFORM_VERSION}/terraform_${tpl_TERRAFORM_VERSION}_linux_amd64.zip"

echo "**** Startup Step 5/8: Install git and unzip. Needed to run pipeline commands. ****"
sudo apt-get install -y git unzip

echo "**** Startup Step 6/8: Unzip the Terraform download. ****"
unzip "terraform_${tpl_TERRAFORM_VERSION}_linux_amd64.zip"
chmod 755" ${tpl_TERRAFORM_DIR}"/terraform

echo "**** Startup Step 7/8: Download and install the Terraform validator ****"
gsutil cp gs://terraform-validator/releases/2019-04-04/terraform-validator-linux-amd64 .
chmod 755 "${tpl_TERRAFORM_DIR}"/terraform-validator-linux-amd64
mv "${tpl_TERRAFORM_DIR}"/terraform-validator-linux-amd64 "${tpl_TERRAFORM_DIR}"/terraform-validator

echo "**** Startup Step 8/8: Set the Linux PATH to point to the Terraform directory. ****"
export PATH=$PATH:${tpl_TERRAFORM_DIR}
