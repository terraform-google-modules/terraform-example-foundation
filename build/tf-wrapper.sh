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

branchname=$2
policyrepo=$3

tf_validator_path="./terraform-validator-linux-amd64"

##functions
tf_apply() {
  terraform apply -input=false -auto-approve "${branchname}.tfplan" || exit 1
}

tf_init() {
  terraform init || exit 11
}

tf_plan() {
  terraform plan -input=false -out "${branchname}.tfplan" || exit 21
}

tf_validate() {
  if ! ${tf_validator_path} version &> /dev/null; then
    echo "terraform-validator not found!  Check path or visit"
    echo "https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator"
  else
    terraform show -json "${branchname}.tfplan" > "${branchname}.json" || exit 32
    terraform-validator-linux-amd64 validate "${branchname}.json" --policy-path="${policyrepo}" || exit 33
  fi
}

##main
case "$1" in
  apply )
    echo "*************** TERRAFORM APPLY *******************"
    echo "      At environment: ${branchname} "
    echo "***************************************************"

    cd "./envs/${branchname}" || exit 44

    if [ ! -d ".terraform" ]; then
      tf_init
    fi

    if [ ! -f "${branchname}.tfplan" ]; then
      tf_plan
    fi

    tf_validate

    tf_apply
    ;;

  init )
    echo "*************** TERRAFORM INIT *******************"
    echo "      At environment: ${branchname} "
    echo "**************************************************"

    cd "./envs/${branchname}" || exit 44

    tf_init
    ;;

  plan )
    echo "*************** TERRAFORM PLAN *******************"
    echo "      At environment: ${branchname} "
    echo "**************************************************"

    cd "./envs/${branchname}" || exit 44

    if [ ! -d ".terraform" ]; then
      tf_init
    fi

    tf_plan
    ;;

  validate )
    echo "*************** TERRAFORM VALIDATE ******************"
    echo "      At environment: ${branchname} "
    echo "      Using policy from: ${policyrepo} "
    echo "****************************************************"

    cd "./envs/${branchname}" || exit 44

    if [ ! -d ".terraform" ]; then
      tf_init
    fi

    if [ ! -f "${branchname}.tfplan" ]; then
      tf_plan
    fi

    tf_validate
    ;;
  * )
    echo "unknown option: ${1}"
    exit 99
    ;;
esac
