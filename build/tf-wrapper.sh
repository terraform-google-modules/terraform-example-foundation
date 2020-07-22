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

branch=$2
policyrepo=$3

prod_path="prod"
shared_path="shared"

tf_validator_path="./terraform-validator"

##functions
tf_apply() {
  echo "*************** TERRAFORM APPLY *******************"
  echo "      At environment: ${branchname} "
  echo "***************************************************"
  if [ -d "./envs/${branchname}" ]; then
    cd "./envs/${branchname}" || exit
    terraform apply -input=false -auto-approve "${branchname}.tfplan" || exit 1
    cd ../.. || exit
  else
    echo "ERROR:  ${branchname} does not exist"
  fi
}

tf_init() {
  echo "*************** TERRAFORM INIT *******************"
  echo "      At environment: ${branchname} "
  echo "**************************************************"
  if [ -d "./envs/${branchname}" ]; then
    cd "./envs/${branchname}" || exit
    terraform init || exit 11
    cd ../.. || exit
  else
    echo "ERROR:  ${branchname} does not exist"
  fi
}

tf_plan() {
  echo "*************** TERRAFORM PLAN *******************"
  echo "      At environment: ${branchname} "
  echo "**************************************************"
  if [ -d "./envs/${branchname}" ]; then
    cd "./envs/${branchname}" || exit
    terraform plan -input=false -out "${branchname}.tfplan" || exit 21
    cd ../.. || exit
  else
    echo "ERROR:  ${branchname} does not exist"
  fi
}

tf_validate() {
  echo "*************** TERRAFORM VALIDATE ******************"
  echo "      At environment: ${branchname} "
  echo "      Using policy from: ${policyrepo} "
  echo "*****************************************************"
  if ! ${tf_validator_path} version &> /dev/null; then
    echo "terraform-validator not found!  Check path or visit"
    echo "https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator"
  else
    if [ -d "./envs/${branchname}" ]; then
      cd "./envs/${branchname}" || exit
      terraform show -json "${branchname}.tfplan" > "${branchname}.json" || exit 32
      terraform-validator validate "${branchname}.json" --policy-path="${policyrepo}" || exit 33
      cd ../.. || exit
    else
      echo "ERROR:  ${branchname} does not exist"
    fi
  fi
}

##main
if [ "${branch}" == "${prod_path}" ]; then
  branches=("${shared_path}" "${branch}")
else
  branches=("${branch}")
fi

case "$1" in
  apply )
    for branchname in "${branches[@]}"; do
      tf_apply
    done
    ;;

  init )
    for branchname in "${branches[@]}"; do
      tf_init
    done
    ;;

  plan )
    for branchname in "${branches[@]}"; do
      tf_plan
    done
    ;;

  validate )
    for branchname in "${branches[@]}"; do
      tf_validate
    done
    ;;
  * )
    echo "unknown option: ${1}"
    exit 99
    ;;
esac
