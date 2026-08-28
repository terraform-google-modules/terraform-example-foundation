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

set -e

action=$1
branch=$2
base_dir=$(pwd)
tmp_plan="${base_dir}/tmp_plan" #if you change this, update build triggers

#==============================================================================#
# Configuration for the search depth of folders in the source code that
# contains the terraform configurations.
#==============================================================================#
max_depth=1  # Must be configured based in your directory design
min_depth=1  # Must be configured based in your directory design


#==============================================================================#
# The regex to find folders that contains the Terraform configurations to apply.
#
# When using environments as leaf nodes (default) the regex contains the there
# branches/environments development, nonproduction, and "production" and the
# additional special value "shared"
#
# When using environments as root nodes the regex  contains the name of the
# folder that contain the Terraform configuration e.g: business_unit_1
# and business_unit_2
#==============================================================================#

# Environments as leaf nodes in source code case
leaf_regex_plan="^(development|nonproduction|production|shared)$"

# Environments as root nodes in source code case
# leaf_regex_plan="^(business_unit_1|business_unit_2)$"

#====================================================================#
# Function used for the criteria for running terraform int/plan/show
# for all the Terraform configurations.
#====================================================================#
do_plan() {
  local leaf
  leaf="$(basename "$1")"
  if [[ "$leaf" =~ $leaf_regex_plan ]] ; then
      echo "true"
  else
      echo "false"
  fi
}

#=========================================================#
# Environments as leaf nodes in source code case (Default)
# Example:
#         git-repo
#         └── business_unit_1
#             ├── development
#             ├── nonproduction
#             └── production
#         └── business_unit_2
#             ├── development
#             ├── nonproduction
#             └── production
#=========================================================#

##### Start of default source organization - comment to use Environments as root nodes #####
do_action() {
  local leaf
  leaf="$(basename "$1")"
  if [[ "$leaf" == "$branch" ]] || [[ "$leaf" == "shared" && "$branch" == "production" ]]; then
      echo "true"
  else
      echo "false"
  fi
}
##### End of default source organization #####

#=============================================================#
# Environments as root nodes in source code Case (alternative)
# Example:
#         git-repo
#         └── development
#             ├── business_unit_1
#             └── business_unit_2
#         └── nonproduction
#             ├── business_unit_1
#             └── business_unit_2
#         └── production
#             ├── business_unit_1
#             └── business_unit_2
#=============================================================#

##### Start of alternative source organization - uncomment to use Environments as root nodes  #####

# leaf_regex_action="^(business_unit_1|business_unit_2)$" # edit this list
# do_action() {
#   local env_path="$1"
#   local tf_env="${env_path#$base_dir/}"
#   local tf_leaf
#   local tf_root
#   tf_leaf="$(basename "$env_path")"
#   tf_root="$(echo "$tf_env" | cut -d/ -f1)"
#   if [[ "$tf_leaf" =~ $leaf_regex_action ]] && [[ "$tf_root" == "$branch" ]] ; then
#       echo "true"
#   else
#       if [[ "$tf_leaf" =~ $leaf_regex_action  && "$tf_root" == "shared" && "$branch" == "production" ]]; then
#         echo "true"
#       else
#         echo "false"
#       fi
#   fi
# }

##### End of alternative source organization #####

#====================================================================#
# Function to replace '/' with '-' to convert a path to a file name
#====================================================================#
convert_path() {
  echo "$1" | sed -r 's/\//-/g'
}

## Terraform apply for single environment.
tf_apply() {
  local path=$1
  local tf_env="${path#"$base_dir"/}"
  local tf_file
  tf_file="$(convert_path "$tf_env")"
  echo "*************** TERRAFORM APPLY *******************"
  echo "      At environment: ${tf_env} "
  echo "***************************************************"
  if [ -d "$path" ]; then
    cd "$path" || exit
    terraform apply -no-color -input=false -auto-approve "${tmp_plan}/${tf_file}.tfplan" || exit 1
    cd "$base_dir" || exit
  else
    echo "ERROR: ${path} does not exist"
  fi
}

## terraform init for single environment.
tf_init() {
  local path=$1
  local tf_env="${path#"$base_dir"/}"
  echo "*************** TERRAFORM INIT *******************"
  echo "      At environment: ${tf_env} "
  echo "**************************************************"
  if [ -d "$path" ]; then
    cd "$path" || exit
    terraform init -no-color || exit 11
    cd "$base_dir" || exit
  else
    echo "ERROR: ${path} does not exist"
  fi
}

## terraform plan for single environment.
tf_plan() {
  local path=$1
  local tf_env="${path#"$base_dir"/}"
  local tf_file
  tf_file="$(convert_path "$tf_env")"
  echo "*************** TERRAFORM PLAN *******************"
  echo "      At environment: ${tf_env} "
  echo "**************************************************"
  if [ ! -d "${tmp_plan}" ]; then
    mkdir "${tmp_plan}" || exit
  fi
  if [ -d "$path" ]; then
    cd "$path" || exit
    terraform plan -no-color -input=false -out "${tmp_plan}/${tf_file}.tfplan" || exit 21
    cd "$base_dir" || exit
  else
    echo "ERROR: ${path} does not exist"
  fi
}

#============================================================================#
# terraform init/plan/validate for all valid environments matching condition.
#============================================================================#
tf_plan_validate_all() {
  local leaf
  find "$base_dir" -mindepth 1 -maxdepth 1 -type d \
  -not -path "$base_dir/modules" \
  -not -path "$base_dir/.git" \
  -not -path "$base_dir/.terraform" | while read -r component_path ; do
    find "$component_path" -mindepth "$min_depth" -maxdepth "$max_depth" -type d | while read -r env_path ; do
      if [[ "$(do_plan "$env_path")" == "true" ]] ; then
        tf_init "$env_path"
        tf_plan "$env_path"
      else
        echo "${env_path#"$base_dir"/} doesn't match $leaf_regex_plan; skipping"
      fi
    done
  done
}

## terraform show for single environment.
tf_show() {
  local path=$1
  local tf_env="${path#"$base_dir"/}"
  local tf_file
  tf_file="$(convert_path "$tf_env")"
  echo "*************** TERRAFORM SHOW *******************"
  echo "      At environment: ${tf_env} "
  echo "**************************************************"
  if [ -d "$path" ]; then
    cd "$path" || exit
    terraform show -no-color "${tmp_plan}/${tf_file}.tfplan" || exit 41
    cd "$base_dir" || exit
  else
    echo "ERROR: ${path} does not exist"
  fi
}

#=================================================================#
# Runs single action for each instance of env in folder hierarchy.
#=================================================================#
single_action_runner() {
  local leaf
  # filter folders that does not contain Terraform configurations
  find "$base_dir" -mindepth 1 -maxdepth 1 -type d \
  -not -path "$base_dir/modules" \
  -not -path "$base_dir/.git" \
  -not -path "$base_dir/.terraform" | while read -r component_path ; do
     # sort -r is added to ensure shared is first if it exists.
    find "$component_path" -mindepth "$min_depth" -maxdepth "$max_depth" -type d | sort -r | while read -r env_path ; do
      if [[ "$(do_action "$env_path")" == "true" ]]; then
        case "$action" in
          apply )
            tf_apply "$env_path"
            ;;

          init )
            tf_init "$env_path"
            ;;

          plan )
            tf_plan "$env_path"
            ;;

          show )
            tf_show "$env_path"
            ;;

          * )
            echo "unknown option: ${action}"
            ;;
        esac
      else
        echo "${env_path#"$base_dir"/}  doesn't match ${branch}; skipping"
      fi
    done
  done
}

case "$action" in
  init|plan|apply|show )
    single_action_runner
    ;;

  plan_validate_all )
    tf_plan_validate_all
    ;;

  * )
    echo "unknown option: ${1}"
    exit 99
    ;;
esac
