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

action=$1
branch=$2
policyrepo=$3
base_dir=$(pwd)
tmp_plan="${base_dir}/tmp_plan" #if you change this, update build triggers
environments_regex="^(dev|nonprod|prod|shared)$"

## Terraform apply for single environment.
tf_apply() {
  local path=$1
  local tf_env=$2
  echo "*************** TERRAFORM APPLY *******************"
  echo "      At environment: ${tf_env} "
  echo "***************************************************"
  if [ -d "$path" ]; then
    cd "$path" || exit
    terraform apply -input=false -auto-approve "${tmp_plan}/${tf_env}.tfplan" || exit 1
    cd "$base_dir" || exit
  else
    echo "ERROR:  ${path} does not exist"
  fi
}

## terraform init for single environment.
tf_init() {
  local path=$1
  local tf_env=$2
  echo "*************** TERRAFORM INIT *******************"
  echo "      At environment: ${tf_env} "
  echo "**************************************************"
  if [ -d "$path" ]; then
    cd "$path" || exit
    terraform init || exit 11
    cd "$base_dir" || exit
  else
    echo "ERROR:  ${path} does not exist"
  fi
}

## terraform plan for single environment.
tf_plan() {
  local path=$1
  local tf_env=$2
  echo "*************** TERRAFORM PLAN *******************"
  echo "      At environment: ${tf_env} "
  echo "**************************************************"
  if [ ! -d "${tmp_plan}" ]; then
    mkdir "${tmp_plan}" || exit
  fi
  if [ -d "$path" ]; then
    cd "$path" || exit
    terraform plan -input=false -out "${tmp_plan}/${tf_env}.tfplan" || exit 21
    cd "$base_dir" || exit
  else
    echo "ERROR:  ${tf_env} does not exist"
  fi
}

## terraform init/plan for all valid environments matching regex.
tf_init_plan_all() {
  # shellcheck disable=SC2012
  ls "$base_dir" | while read -r component ; do
    # shellcheck disable=SC2012
    ls "$base_dir/$component" | while read -r env ; do
      if [[ "$env" =~ $environments_regex ]] ; then
       tf_dir="$base_dir/$component/$env"
       tf_init "$tf_dir" "$env"
       tf_plan "$tf_dir" "$env"
      else
        echo "$component/$env doesn't match $environments_regex; skipping"
      fi
    done
  done
}

## terraform validate for single environment.
tf_validate() {
  local path=$1
  local tf_env=$2
  local policy_file_path=$3
  echo "*************** TERRAFORM VALIDATE ******************"
  echo "      At environment: ${tf_env} "
  echo "      Using policy from: ${policy_file_path} "
  echo "*****************************************************"
  if ! command -v terraform-validator &> /dev/null; then
    echo "terraform-validator not found!  Check path or visit"
    echo "https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator"
  else
    if [ -d "$path" ]; then
      cd "$path" || exit
      terraform show -json "${tmp_plan}/${tf_env}.tfplan" > "${tf_env}.json" || exit 32
      terraform-validator validate "${tf_env}.json" --policy-path="${policy_file_path}" || exit 33
      cd "$base_dir" || exit
    else
      echo "ERROR:  ${path} does not exist"
    fi
  fi
}

# Runs single action for each instance of env in folder hierarchy.
single_action_runner() {
  # shellcheck disable=SC2012
  ls "$base_dir" | while read -r component ; do
    # sort -r is added to ensure shared is first if it exists.
    # shellcheck disable=SC2012
    ls "$base_dir/$component" | sort -r | while read -r env ; do
      # perform action only if folder matches branch OR folder is shared & branch is prod.
      if [[ "$env" == "$branch" ]] || [[ "$env" == "shared" && "$branch" == "prod" ]]; then
        tf_dir="$base_dir/$component/$env"
        case "$action" in
          apply )
            tf_apply "$tf_dir" "$env"
            ;;

          init )
            tf_init "$tf_dir" "$env"
            ;;

          plan )
            tf_plan "$tf_dir" "$env"
            ;;

          validate )
            tf_validate "$tf_dir" "$env" "$policyrepo"
            ;;
          * )
            echo "unknown option: ${action}"
            ;;
        esac
      else
        echo "${env} doesn't match ${branch}; skipping"
      fi
    done
  done
}

case "$action" in
  init|plan|apply|validate )
    single_action_runner
    ;;

  planall )
    tf_init_plan_all
    ;;

  * )
    echo "unknown option: ${1}"
    exit 99
    ;;
esac
