#!/bin/bash

# Copyright 2022 Google LLC
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

# Usage:
# bash scripts/validate-requirements.sh "END_USER_EMAIL" "ORGANIZATION_ID" "BILLING_ACCOUNT_ID"

# -------------------------- Variables --------------------------
# Expected versions of the installers
TF_VERSION="1.5.7"
# Version 393.0.0 due to terraform-tools 0.5.0 version that fixes the issue
# mentioned in this PR https://github.com/terraform-google-modules/terraform-example-foundation/pull/729#discussion_r919427668
GCLOUD_SDK_VERSION="393.0.0"
GIT_VERSION="2.28.0"

# Expected roles
ORGANIZATION_LEVEL_ROLES=("roles/resourcemanager.folderCreator" "roles/resourcemanager.organizationAdmin" "roles/orgpolicy.policyAdmin")
BILLING_LEVEL_ROLES=("roles/billing.admin")

# Input variables
END_USER_CREDENTIAL=""
ORGANIZATION_ID=""
BILLING_ACCOUNT=""
EXTERNAL_REPO="false"

# Collect the errors
ERRORS=""

# -------------------------- Functions ---------------------------

# Compare two semantic versions
# returns:
# 0 = $1 is equal $2
# 1 = $1 is higher than $2
# 2 = $1 is lower than $2
function compare_version(){

    # when both inputs are the equal, just return 0
    if [[ "$1" == "$2" ]]; then
        echo 0
        return 0
    fi

    local IFS=.
    local i
    local version1=("$1")
    local version2=("$2")
    # completing with zeroes on $1 so it can have the same size than $2
    for ((i=${#version1[@]}; i<${#version2[@]}; i++))
    do
        version1[i]=0
    done
    for ((i=0; i<${#version1[@]}; i++))
    do
        # completing with zeroes on $2 so it can have the same size than $1
        if [[ -z ${version2[i]} ]]; then
            version2[i]=0
        fi
        # if the number at index i for $1 is higher than $2, return 1
        if [[ ${version1[i]} > ${version2[i]} ]]; then
            echo 1
            return 1
        fi
        # if the number at index i for $1 is lower than $2, return 2
        if [[ ${version1[i]} < ${version2[i]} ]]; then
            echo 2
            return 2
        fi
    done
    return 0
}

# Validate the Terraform installation and version
function validate_terraform(){

    if [ ! "$(command -v terraform )" ]; then
        echo_missing_installation "Terraform" "https://learn.hashicorp.com/tutorials/terraform/install-cli"
        ERRORS+=$'  Terraform not found\n'
    else
        TERRAFORM_CURRENT_VERSION=$(terraform version -json | jq -r .terraform_version)
        if [ "$(compare_version "$TERRAFORM_CURRENT_VERSION" "$TF_VERSION")" -gt 1 ]; then
            echo_wrong_version "Terraform" "greater than or equal to" "$TF_VERSION" "https://learn.hashicorp.com/tutorials/terraform/install-cli" "$TERRAFORM_CURRENT_VERSION"
            ERRORS+=$'  Terraform version is incompatible.\n'
        fi
    fi
}

# Validate the Google Cloud SDK installation and version
function validate_gcloud(){
    if [ ! "$(command -v gcloud)" ]; then
        echo_missing_installation "gcloud CLI" "https://cloud.google.com/sdk/docs/install"
        ERRORS+=$'  gcloud not found.\n'
    else
        GCLOUD_CURRENT_VERSION=$(gcloud version --format=json | jq -r '."Google Cloud SDK"')
        if [ "$(compare_version "$GCLOUD_CURRENT_VERSION" "$GCLOUD_SDK_VERSION")" -eq 2 ]; then
            echo_wrong_version "gcloud CLI" "at least" "$GCLOUD_SDK_VERSION" "https://cloud.google.com/sdk/docs/install" "$GCLOUD_CURRENT_VERSION"
            ERRORS+=$'  gcloud version is incompatible.\n'
        fi
    fi
}

# Validate the Git installation and version
function validate_git(){
    if [ ! "$(command -v git)" ]; then
        echo_missing_installation "git" "https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
        ERRORS+=$'  git not found.\n'
    else
        GIT_CURRENT_VERSION=$(git version | awk '{print $3}')
        if [ "$(compare_version "$GIT_CURRENT_VERSION" "$GIT_VERSION")" -eq 2 ]; then
            echo_wrong_version "git" "at least" "$GIT_VERSION" "https://git-scm.com/book/en/v2/Getting-Started-Installing-Git" "$GIT_CURRENT_VERSION"
            ERRORS+=$'  git version is incompatible.\n'
        fi
    fi

    if ! git config init.defaultBranch | grep "main" >/dev/null ; then
        echo "  git default branch must be configured as main."
        echo "  See the instructions at https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/TROUBLESHOOTING.md#default-branch-setting ."
        ERRORS+=$'  git default branch must be configured as main.\n'
    fi
}

# Validate some utility tools that the environment must have before running the other checkers
function validate_utils(){
    if [ ! "$(command -v jq)" ]; then
        echo_missing_installation "jq" "https://stedolan.github.io/jq/download/"
        ERRORS+=$'  jq not found.\n'
    fi
}

# Validate the configuration of the Gcloud CLI
function validate_gcloud_configuration(){

    END_USER_CREDENTIAL_OUTPUT="$(gcloud config get-value account 2>&1 >/dev/null)"
    if [ "$(echo "$END_USER_CREDENTIAL_OUTPUT" | grep -c unset)" -eq 1 ]; then
        echo "  You must configure an End User Credential."
        echo "  Visit https://cloud.google.com/sdk/gcloud/reference/auth/login and follow the instructions to authorize gcloud to access the Cloud Platform with Google user credentials."
        ERRORS+=$'  gcloud not configured with end user credential.\n'
    fi

    APPLICATION_DEFAULT_CREDENTIAL_OUTPUT="$(gcloud auth application-default print-access-token 2>&1 >/dev/null)"
    if [ "$(echo "$APPLICATION_DEFAULT_CREDENTIAL_OUTPUT" | grep -c 'Could not automatically determine credentials')" -eq 1 ]; then
        echo "  You must configure an Application Default Credential."
        echo "  Visit https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login and follow the instructions to authorize gcloud to access the Cloud Platform with Google user credentials."
        ERRORS+=$'  gcloud not configured with application default credential.\n'
    fi
}

#  Function to validate the roles attached to credentialed account
function validate_credential_roles(){
    check_org_level_roles "$END_USER_CREDENTIAL" "$ORGANIZATION_ID"
    check_billing_account_roles "$END_USER_CREDENTIAL" "$BILLING_ACCOUNT"
}

# Verifies whether a user has the expected Organization level roles
function check_org_level_roles(){
    local end_user=$1
    local organization_id=$2

    ORG_LEVEL_ROLES_OUTPUT=$(
        gcloud organizations get-iam-policy "$organization_id" \
        --filter="bindings.members:$end_user" \
        --flatten="bindings[].members" \
        --format="value(bindings.role)" 2>/dev/null)

    lines=0
    for i in "${ORGANIZATION_LEVEL_ROLES[@]}"
    do
        if [[ "$ORG_LEVEL_ROLES_OUTPUT" == *"$i"* ]]; then
            lines=$((lines + 1))
        fi
    done

    if [ "$lines" -ne ${#ORGANIZATION_LEVEL_ROLES[@]} ]; then
        echo "  The User must have the Organization Roles resourcemanager.folderCreator, resourcemanager.organizationAdmin and roles/orgpolicy.policyAdmin."
        ERRORS+=$'  There are missing organization level roles on the Credential.\n'
    fi
}

# Verifies whether a user has the expected Billing Level roles
function check_billing_account_roles(){
    local end_user=$1
    local billing_account_id=$2

    BILLING_LEVEL_ROLES_OUTPUT=$(
        gcloud beta billing accounts get-iam-policy "$billing_account_id" \
        --filter="bindings.members:$end_user" \
        --flatten="bindings[].members" \
        --format="value(bindings.role)" 2>/dev/null)

    lines=0
    for i in "${BILLING_LEVEL_ROLES[@]}"
    do
        if [[ "$BILLING_LEVEL_ROLES_OUTPUT" == *"$i"* ]]; then
            lines=$((lines + 1))
        fi
    done

    if [ "$lines" -ne ${#BILLING_LEVEL_ROLES[@]} ]; then
        echo "  The User must have the Billing Account Role billing.admin."
        ERRORS+=$'  There are missing billing account level roles on the Credential.\n'
    fi

}

# Checks if initial config was done for 0-bootstrap step
function validate_bootstrap_step(){
    SCRIPTS_DIR="$( dirname -- "$0"; )"
    FILE="$SCRIPTS_DIR/../0-bootstrap/terraform.tfvars"
    if [ ! -f "$FILE" ]; then
        echo "  Rename the file 0-bootstrap/terraform.example.tfvars to 0-bootstrap/terraform.tfvars"
        ERRORS+=$'  terraform.tfvars file must exist for 0-bootstrap step.\n'
    else
	if [ "$(grep -v '^#' "$FILE" |grep -c 'REPLACE_ME')" != 0 ]; then
            echo "  0-bootstrap/terraform.tfvars must have required values fulfilled."
            ERRORS+=$'  terraform.tfvars file must be correctly fulfilled for 0-bootstrap step.\n'
        fi
    fi
}

# Checks if initial config was done for 0-bootstrap step using external repository
function validate_bootstrap_step_external_repo(){
    SCRIPTS_DIR="$( dirname -- "$0"; )"
    FILE="$SCRIPTS_DIR/../../gcp-bootstrap/envs/shared/terraform.tfvars"
    if [ ! -f "$FILE" ]; then
        echo "  Rename the file gcp-bootstrap/envs/shared/terraform.example.tfvars to gcp-bootstrap/envs/shared/terraform.tfvars"
        ERRORS+=$'  terraform.tfvars file must exist for gcp-bootstrap step.\n'
    else
	if [ "$(grep -v '^#' "$FILE" |grep -c 'REPLACE_ME')" != 0 ]; then
            echo "  gcp-bootstrap/envs/shared/terraform.tfvars must have required values fulfilled."
            ERRORS+=$'  terraform.tfvars file must be correctly fulfilled for gcp-bootstrap step.\n'
        fi
    fi
}

# Echoes messages for cases where an installation is missing
# $1 = name of the missing binary
# $2 = web site to find the installation details of the missing binary
function echo_missing_installation () {
    local binary_name=$1
    local installer_url=$2

    echo "  $binary_name not found."
    echo "  Visit $installer_url and follow the instructions to install $binary_name."
}

# Echoes messages for cases where an installation version is incompatible
# $1 = name of the missing binary
# $2 = "at least" / "equal"
# $3 = version to be displayed
# $4 = web site to find the installation details of the missing binary
# $5 = current version
function echo_wrong_version () {
    local binary_name=$1
    local constraint=$2
    local target_version=$3
    local installer_url=$4
    local current_version=$5

    echo "  An incompatible $binary_name version, $current_version, was found."
    echo "  Version required should be $constraint $target_version"
    echo "  Visit $installer_url and follow the instructions to install $binary_name."
}

function main(){

    echo "Validating required utility tools..."
    validate_utils

    if [ -n "$ERRORS" ]; then
        echo "Some requirements are missing:"
        echo "$ERRORS"
        exit 1
    fi

    echo "Validating Terraform installation..."
    validate_terraform

    echo "Validating Google Cloud SDK installation..."
    validate_gcloud

    echo "Validating Git installation..."
    validate_git

    if [[ ! "$ERRORS" == *"gcloud"* ]]; then
        echo "Validating local gcloud configuration..."
        validate_gcloud_configuration

        if [[ ! "$ERRORS" == *"gcloud not configured"* ]]; then
        echo "Validating roles assignment for current end user credential..."
        validate_credential_roles
        fi
    fi

    echo "Validating 0-bootstrap configuration..."
    if [[ "$EXTERNAL_REPO" == "true" ]]; then
        validate_bootstrap_step_external_repo
    else
        validate_bootstrap_step
    fi

    echo "......................................."
    if [ -z "$ERRORS" ]; then
        echo "Validation successful!"
        echo "No errors found."
    else
        echo "Validation failed!"
        echo "Errors found:"
        echo "$ERRORS"
    fi
}

usage() {
    echo
    echo " Usage:"
    echo "     $0 -o <organization id> -b <billing account id> -u <end user email> [-e]"
    echo "         organization id                   (required)"
    echo "         billing account id                (required)"
    echo "         end user email                    (required)"
    echo "         set -e if using an external repo  (optional)"
    echo
    exit 1
}

# Check for input variables
while getopts ":o:b:u:e" OPT; do
  case ${OPT} in
    o )
      ORGANIZATION_ID=$OPTARG
      ;;
    b )
      BILLING_ACCOUNT=$OPTARG
      ;;
    u )
      END_USER_CREDENTIAL=$OPTARG
      ;;
    e )
      EXTERNAL_REPO="true"
      ;;
    : )
      echo
      echo " Error: option -${OPTARG} requires an argument"
      usage
      ;;
   \? )
      echo
      echo " Error: invalid option -${OPTARG}"
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Check for required input variables
if [ -z "${ORGANIZATION_ID}" ] || [ -z "${BILLING_ACCOUNT}" ]|| [ -z "${END_USER_CREDENTIAL}" ]; then
  echo
  echo " Error: -o <organization id>, -b <billing account id> and -u <end user email> are required."
  usage
fi

main
