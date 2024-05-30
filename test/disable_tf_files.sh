#!/usr/bin/env bash

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

function networks(){

    # shellcheck disable=SC2154
    if [ "$TF_VAR_example_foundations_mode" == "HubAndSpoke" ]; then
        network_dir="3-networks-hub-and-spoke"
    else
        network_dir="3-networks-dual-svpc"
    fi

    # disable access_context.auto.tfvars in main module
    mv $network_dir/envs/development/access_context.auto.tfvars  $network_dir/envs/development/access_context.auto.tfvars.disabled
    mv $network_dir/envs/nonproduction/access_context.auto.tfvars  $network_dir/envs/nonproduction/access_context.auto.tfvars.disabled
    mv $network_dir/envs/production/access_context.auto.tfvars  $network_dir/envs/production/access_context.auto.tfvars.disabled

    # disable common.auto.tfvars in main module
    mv $network_dir/envs/development/common.auto.tfvars $network_dir/envs/development/common.auto.tfvars.disabled
    mv $network_dir/envs/nonproduction/common.auto.tfvars  $network_dir/envs/nonproduction/common.auto.tfvars.disabled
    mv $network_dir/envs/production/common.auto.tfvars  $network_dir/envs/production/common.auto.tfvars.disabled
}

function shared(){

    if [ "$TF_VAR_example_foundations_mode" == "HubAndSpoke" ]; then
        network_dir="3-networks-hub-and-spoke"
    else
        network_dir="3-networks-dual-svpc"
    fi

    # disable access_context.auto.tfvars in main module
    mv $network_dir/envs/shared/access_context.auto.tfvars $network_dir/envs/shared/access_context.auto.tfvars.disabled

    # disable common.auto.tfvars in main module
    mv $network_dir/envs/shared/common.auto.tfvars  $network_dir/envs/shared/common.auto.tfvars.disabled

    # disable shared.auto.tfvars in main module
    mv $network_dir/envs/shared/shared.auto.tfvars  $network_dir/envs/shared/shared.auto.tfvars.disabled
}

function projectsshared(){
    # disable shared.auto.tfvars
    mv 4-projects/business_unit_1/shared/shared.auto.tfvars  4-projects/business_unit_1/shared/shared.auto.tfvars.disabled

    # disable common.auto.tfvars
    mv 4-projects/business_unit_1/shared/common.auto.tfvars 4-projects/business_unit_1/shared/common.auto.tfvars.disabled
}

function projects(){
    # disable ENVS.auto.tfvars in main module
    mv 4-projects/business_unit_1/development/development.auto.tfvars 4-projects/business_unit_1/development/development.auto.tfvars.disabled
    mv 4-projects/business_unit_1/nonproduction/nonproduction.auto.tfvars  4-projects/business_unit_1/nonproduction/nonproduction.auto.tfvars.disabled
    mv 4-projects/business_unit_1/production/production.auto.tfvars 4-projects/business_unit_1/production/production.auto.tfvars.disabled

    # disable common.auto.tfvars in main module
    mv 4-projects/business_unit_1/development/common.auto.tfvars 4-projects/business_unit_1/development/common.auto.tfvars.disabled
    mv 4-projects/business_unit_1/nonproduction/common.auto.tfvars  4-projects/business_unit_1/nonproduction/common.auto.tfvars.disabled
    mv 4-projects/business_unit_1/production/common.auto.tfvars 4-projects/business_unit_1/production/common.auto.tfvars.disabled
}

function appinfra(){
    # disable common.auto.tfvars in main module
    mv 5-app-infra/business_unit_1/development/common.auto.tfvars 5-app-infra/business_unit_1/development/common.auto.tfvars.disabled
    mv 5-app-infra/business_unit_1/nonproduction/common.auto.tfvars  5-app-infra/business_unit_1/nonproduction/common.auto.tfvars.disabled
    mv 5-app-infra/business_unit_1/production/common.auto.tfvars  5-app-infra/business_unit_1/production/common.auto.tfvars.disabled
}


# parse args
for arg in "$@"
do
  case $arg in
    -n|--networks)
      networks
      shift
      ;;
    -s|--shared)
      shared
      shift
      ;;
    -a|--appinfra)
      appinfra
      shift
      ;;
    -d|--projectsshared)
      projectsshared
      shift
      ;;
    -p|--projects)
      projects
      shift
      ;;
      *) # end argument parsing
      shift
      ;;
  esac
done
