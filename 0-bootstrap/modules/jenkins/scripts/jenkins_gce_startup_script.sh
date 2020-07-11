#! /bin/bash

echo "**** Startup Step 1/9: Update apt-get repositories. ****"
sudo apt-get update

echo "**** Startup Step 2/9: Install Java. ****"
sudo apt-get install -y default-jdk

echo "**** Startup Step 3/9: Set variables. ****"
export TERRAFORM_DIR="/opt/terraform/"
export TERRAFORM_VERSION="0.12.24"

echo "**** Startup Step 4/9: Create tahe directory for Terraform in /opt. ****"
mkdir $TERRAFORM_DIR && cd $TERRAFORM_DIR || exit

echo "**** Startup Step 5/9: Download Terraform. ****"
wget "https://releases.hashicorp.com/terraform/{$TERRAFORM_DIR}terraform_{$TERRAFORM_VERSION}_linux_amd64.zip"

echo "**** Startup Step 6/9: Install unzip. ****"
sudo apt-get install -y unzip

echo "**** Startup Step 7/9: Unzip the Terraform download. ****"
unzip "terraform_{$TERRAFORM_VERSION}_linux_amd64.zip"
chmod 755 $TERRAFORM_DIR/terraform

echo "**** Startup Step 8/9: Download and install the Terraform validator ****"
gsutil cp gs://terraform-validator/releases/2019-04-04/terraform-validator-linux-amd64 .
chmod 755 $TERRAFORM_DIR/terraform-validator-linux-amd64

echo "**** Startup Step 9/9: Set the Linux PATH to point to the Terraform directory. ****"
export PATH=$PATH:$TERRAFORM_DIR
