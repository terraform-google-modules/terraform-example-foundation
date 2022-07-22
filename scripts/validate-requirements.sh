#!/bin/bash

# Usage:
# bash scripts/validate-requirements.sh "END_USER_EMAIL" "ORGANIZATION_ID" "BILLING_ACCOUNT_ID"

# -------------------------- Variables --------------------------
# Expected versions of the installers
TF_VERSION="0.13.7"
GCLOUD_SDK_VERSION="319.0.0"
GIT_VERSION="2.25.1"
# User Inputs
END_USER_CREDENTIAL="$1"
ORGANIZATION_ID="$2"
BILLING_ACCOUNT="$3"

# -------------------------- Funcions ---------------------------

# Compare the two float numbers
function compare_version(){
    echo "comparing versions $1 and $2"

    if [[ $1 == $2 ]]; then
        return 0
    fi

    local IFS=.
    local i version1=($1) version2=($2)
    for ((i=${#version1[@]}; i<${#version2[@]}; i++))
    do
        version1[i]=0
    done
    for ((i=0; i<${#version1[@]}; i++))
    do
        if [[ -z ${version2[i]} ]]
        then
            version2[i]=0
        fi
        if ((${version1[i]} > ${version2[i]}))
        then
            return 1
        fi
        if ((${version1[i]} < ${version2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# Validate the Terraform installation and version
function validate_terraform(){
    which terraform
    if [ $? -ne 0 ]; then
        echo "Terraform not found."
        echo "Visit https://learn.hashicorp.com/tutorials/terraform/install-cli and follow the instructions to install Terraform."
        exit 1
    else
        TERRAFORM_CURRENT_VERSION=$(terraform version -json | jq -r .terraform_version)
        compare_version $TERRAFORM_CURRENT_VERSION $TF_VERSION
        if [ $? -eq 2 ]; then
            echo "An error was found with the Terraform installation."
            echo "Terraform version $TF_VERSION is required."
            echo "Visit https://learn.hashicorp.com/tutorials/terraform/install-cli and follow the instructions to install Terraform."
            exit 1
        fi
    fi
}

# Validate the Google Cloud SDK installation and version
function validate_gcloud(){
    which gcloud
    if [ $? -ne 0 ]; then
        echo "Gcloud not found."
        echo "Visit https://cloud.google.com/sdk/docs/install and follow the instructions to install gcloud CLI."
        exit 1
    else
        GCLOUD_CURRENT_VERSION=$(gcloud version --format=json | jq -r '."Google Cloud SDK"')
        compare_version $GCLOUD_CURRENT_VERSION $GCLOUD_SDK_VERSION
        if [ $? -eq 2 ]; then
            echo "Gcloud version $GCLOUD_SDK_VERSION is required."
            echo "Visit https://cloud.google.com/sdk/docs/install and follow the instructions to install gcloud CLI."
            exit 1
        fi
    fi
}
# Validate the Git installation and version
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

# Validate the Configuration of the Gcloud CLI
function validate_gcloud_configuration(){
    gcloud config get-value account 2> end-user-credential-output.txt
    cat end-user-credential-output.txt | grep "unset"
    if [ $? -eq 0 ]; then
        echo "You must configure an End User Credential."
        echo "Visit https://cloud.google.com/sdk/gcloud/reference/auth/login and follow the instructions to authorize gcloud to access the Cloud Platform with Google user credentials."
        rm -Rf end-user-credential-output.txt
        exit 1
    fi
    rm -Rf end-user-credential-output.txt

    gcloud auth application-default print-access-token 2> application-default-credential-output.txt
    cat application-default-credential-output.txt | grep "Could not automatically determine credentials"
    if [ $? -eq 0 ]; then
        echo "You must configure an Application Default Credential."
        echo "Visit https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login and follow the instructions to authorize gcloud to access the Cloud Platform with Google user credentials."
        rm -Rf application-default-credential-output.txt
        exit 1
    fi
    rm -Rf application-default-credential-output.txt
}

# Function to validate the Configuration of the Gcloud CLI
function validate_credential_roles(){
    check_org_level_roles $END_USER_CREDENTIAL $ORGANIZATION_ID
    check_billing_account_roles $END_USER_CREDENTIAL $BILLING_ACCOUNT
}

# Verifies wheter a user is assigned to the expected Orgzanization Level roles
function check_org_level_roles(){
    echo "Checking org level roles for $1 at organization $2..."

    gcloud organizations get-iam-policy $2 \
    --filter="bindings.members:$1" \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" > org-level-roles-output.txt

    lines=$(cat org-level-roles-output.txt | grep -e roles/resourcemanager.folderCreator -e roles/resourcemanager.organizationAdmin| wc -l)
    if [ $lines -ne 2 ]; then
        echo "The User must have the Organization Roles resourcemanager.folderCreator and resourcemanager.organizationAdmin"
        rm -Rf org-level-roles-output.txt
        exit 1
    fi
    rm -Rf org-level-roles-output.txt
}

# Verifies wheter a user is assigned to the expected Billing Level roles
function check_billing_account_roles(){
    echo "Checking billing account roles for $1 at billing account $2..."

    gcloud beta billing accounts get-iam-policy $2 \
        --filter="bindings.members:$1" \
        --flatten="bindings[].members" \
        --format="table(bindings.role)" > billing-account-roles.txt

    lines=$(cat billing-account-roles.txt | grep -e roles/billing.admin | wc -l)
    if [ $lines -ne 1 ]; then
        echo "The User must have the Billing Account Role billing.admin"
        rm -Rf billing-account-roles.txt
        exit 1
    fi
    rm -Rf billing-account-roles.txt
}


echo "Validating Terraform installation..."
validate_terraform

echo "Validating Google Cloud SDK installation..."
validate_gcloud

echo "Validating GIT installation..."
validate_git

echo "Validating local gcloud configuration..."
validate_gcloud_configuration

echo "Validating roles assignement for current end user credential..."
validate_credential_roles
