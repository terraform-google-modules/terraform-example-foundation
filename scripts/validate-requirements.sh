#!/bin/bash
# -------------------------- Variables --------------------------
# Versions of the installators
# TODO
# Must obtain the correct required versions
TF_VERSION="v1.2.1"
GCLOUD_SDK_VERSION="380.0.0"
GIT_VERSION="2.25.1"
# -------------------------- Funcions ---------------------------
# TODO
# Must update this comparission mechanism to compare if version is HIGHER not only EQUAL
# ref: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
# Function to validate the Terraform installation and version
function validate_terraform(){
    which terraform
    if [ $? -ne 0 ]; then
        echo "Terraform not found."
        echo "Visit https://learn.hashicorp.com/tutorials/terraform/install-cli and follow the instructions to install Terraform."
        exit 1
    else
        terraform version | grep -e $TF_VERSION
        if [ $? -ne 0 ]; then
            echo "An error was found with the Terraform installation."
            echo "Version required is $TF_VERSION"
            echo "Visit https://learn.hashicorp.com/tutorials/terraform/install-cli and follow the instructions to install Terraform."
            exit 1
        fi
    fi
}
# Function to validate the Google Cloud SDK installation and version
function validate_gcloud(){
    which gcloud
    if [ $? -ne 0 ]; then
        echo "Gcloud not found."
        echo "Visit https://cloud.google.com/sdk/docs/install and follow the instructions to install gcloud CLI."
        exit 1
    else
        gcloud version | grep -e $GCLOUD_SDK_VERSION
        if [ $? -ne 0 ]; then
            echo "An error was found with the Google Cloud SDK installation."
            echo "Version required is $GCLOUD_SDK_VERSION"
            echo "Visit https://cloud.google.com/sdk/docs/install and follow the instructions to install gcloud CLI."
            exit 1
        fi
    fi
}
# Function to validate the Git installation and version
function validate_git(){
    which git
    if [ $? -ne 0 ]; then
        echo "git not found."
        echo "Visit https://git-scm.com/book/en/v2/Getting-Started-Installing-Git and follow the instructions to install Git."
        exit 1
    else
        git version | grep -e $GIT_VERSION
        if [ $? -ne 0 ]; then
            echo "An error was found with the git installation."
            echo "Version required is $GIT_VERSION"
            echo "Visit https://git-scm.com/book/en/v2/Getting-Started-Installing-Git and follow the instructions to install Git."
            exit 1
        fi
    fi
}
echo "Validating Terraform installation..."
validate_terraform
echo "Validating Google Cloud SDK installation..."
validate_gcloud
echo "Validating GIT installation..."
validate_git