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

function export_access_context_manager_policy(){
    # export Access Context Manager Policy ID
    local policy_id
    policy_id=$(gcloud access-context-manager policies list --organization="${TF_VAR_org_id:?}" --format="value(name)")
    export TF_VAR_access_context_manager_policy_id=$policy_id
}

function org(){
    # TBD
    echo "Not Implemented"
}

function envs(){
    # TBD
    echo "Not Implemented"
}

function networks(){
    # export Access Context Manager Policy ID
    export_access_context_manager_policy
}

function shared(){
    # export Access Context Manager Policy ID
    export_access_context_manager_policy
}

function projects(){
    # export Access Context Manager Policy ID
    export_access_context_manager_policy
}

function appinfra(){
    # TBD
    echo "Not Implemented"
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
    -o|--org)
      org
      shift
      ;;
    -e|--envs)
      envs
      shift
      ;;
    -a|--appinfra)
      appinfra
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
