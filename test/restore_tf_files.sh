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

function org(){
    # restore backend configs in main module
    mv 1-org/envs/shared/backend.tf.disabled  1-org/envs/shared/backend.tf 
}

function envs(){
    # restore backend configs in main module
    mv 2-environments/envs/development/backend.tf.disabled  2-environments/envs/development/backend.tf
    mv 2-environments/envs/non-production/backend.tf.disabled  2-environments/envs/non-production/backend.tf
    mv 2-environments/envs/production/backend.tf.disabled  2-environments/envs/production/backend.tf
}

function networks(){
    # restore backend configs in main module
    mv 3-networks/envs/development/backend.tf.disabled  3-networks/envs/development/backend.tf
    mv 3-networks/envs/non-production/backend.tf.disabled  3-networks/envs/non-production/backend.tf
    mv 3-networks/envs/production/backend.tf.disabled  3-networks/envs/production/backend.tf

    # restore access_context.auto.tfvars in main module
    mv 3-networks/envs/development/access_context.auto.tfvars.disabled  3-networks/envs/development/access_context.auto.tfvars
    mv 3-networks/envs/non-production/access_context.auto.tfvars.disabled  3-networks/envs/non-production/access_context.auto.tfvars
    mv 3-networks/envs/production/access_context.auto.tfvars.disabled  3-networks/envs/production/access_context.auto.tfvars 

    # restore common.auto.tfvars in main module
    mv 3-networks/envs/development/common.auto.tfvars.disabled  3-networks/envs/development/common.auto.tfvars 
    mv 3-networks/envs/non-production/common.auto.tfvars.disabled  3-networks/envs/non-production/common.auto.tfvars  
    mv 3-networks/envs/production/common.auto.tfvars.disabled  3-networks/envs/production/common.auto.tfvars  
}

function networks-hub-and-spoke(){
    # restore backend configs in main module
    mv 3-networks-hub-and-spoke/envs/development/backend.tf.disabled  3-networks-hub-and-spoke/envs/development/backend.tf
    mv 3-networks-hub-and-spoke/envs/non-production/backend.tf.disabled  3-networks-hub-and-spoke/envs/non-production/backend.tf
    mv 3-networks-hub-and-spoke/envs/production/backend.tf.disabled  3-networks-hub-and-spoke/envs/production/backend.tf

    # restore access_context.auto.tfvars in main module
    mv 3-networks-hub-and-spoke/envs/development/access_context.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/development/access_context.auto.tfvars
    mv 3-networks-hub-and-spoke/envs/non-production/access_context.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/non-production/access_context.auto.tfvars
    mv 3-networks-hub-and-spoke/envs/production/access_context.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/production/access_context.auto.tfvars 

    # restore common.auto.tfvars in main module
    mv 3-networks-hub-and-spoke/envs/development/common.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/development/common.auto.tfvars 
    mv 3-networks-hub-and-spoke/envs/non-production/common.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/non-production/common.auto.tfvars  
    mv 3-networks-hub-and-spoke/envs/production/common.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/production/common.auto.tfvars  
}

function shared(){
    # restore backend configs in main module
    mv 3-networks/envs/shared/backend.tf.disabled  3-networks/envs/shared/backend.tf 

    # restore access_context.auto.tfvars in main module
    mv 3-networks/envs/shared/access_context.auto.tfvars.disabled  3-networks/envs/shared/access_context.auto.tfvars 

    # restore common.auto.tfvars in main module
    mv  3-networks/envs/shared/common.auto.tfvars.disabled  3-networks/envs/shared/common.auto.tfvars 

    # restore shared.auto.tfvars in main module
    mv 3-networks/envs/shared/shared.auto.tfvars.disabled  3-networks/envs/shared/shared.auto.tfvars 
}

function shared-hub-and-spoke(){
    # restore backend configs in main module
    mv 3-networks-hub-and-spoke/envs/shared/backend.tf.disabled  3-networks-hub-and-spoke/envs/shared/backend.tf 

    # restore access_context.auto.tfvars in main module
    mv 3-networks-hub-and-spoke/envs/shared/access_context.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/shared/access_context.auto.tfvars 

    # restore common.auto.tfvars in main module
    mv  3-networks-hub-and-spoke/envs/shared/common.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/shared/common.auto.tfvars 

    # restore shared.auto.tfvars in main module
    mv 3-networks-hub-and-spoke/envs/shared/shared.auto.tfvars.disabled  3-networks-hub-and-spoke/envs/shared/shared.auto.tfvars 
}

function projects(){
    # restore backend configs in main module
    mv 4-projects/business_unit_1/development/backend.tf.disabled 4-projects/business_unit_1/development/backend.tf 
    mv 4-projects/business_unit_1/non-production/backend.tf.disabled 4-projects/business_unit_1/non-production/backend.tf 
    mv 4-projects/business_unit_1/production/backend.tf.disabled 4-projects/business_unit_1/production/backend.tf
    mv 4-projects/business_unit_1/shared/backend.tf.disabled 4-projects/business_unit_1/shared/backend.tf 
    mv 4-projects/business_unit_2/development/backend.tf.disabled 4-projects/business_unit_2/development/backend.tf
    mv 4-projects/business_unit_2/non-production/backend.tf.disabled 4-projects/business_unit_2/non-production/backend.tf 
    mv 4-projects/business_unit_2/production/backend.tf.disabled 4-projects/business_unit_2/production/backend.tf
    mv 4-projects/business_unit_2/shared/backend.tf.disabled 4-projects/business_unit_2/shared/backend.tf 

    # restore access_context.auto.tfvars in main module
    mv 4-projects/business_unit_1/development/access_context.auto.tfvars.disabled 4-projects/business_unit_1/development/access_context.auto.tfvars
    mv 4-projects/business_unit_1/non-production/access_context.auto.tfvars.disabled 4-projects/business_unit_1/non-production/access_context.auto.tfvars 
    mv 4-projects/business_unit_1/production/access_context.auto.tfvars.disabled 4-projects/business_unit_1/production/access_context.auto.tfvars
    mv 4-projects/business_unit_2/development/access_context.auto.tfvars.disabled 4-projects/business_unit_2/development/access_context.auto.tfvars
    mv 4-projects/business_unit_2/non-production/access_context.auto.tfvars.disabled 4-projects/business_unit_2/non-production/access_context.auto.tfvars 
    mv 4-projects/business_unit_2/production/access_context.auto.tfvars.disabled 4-projects/business_unit_2/production/access_context.auto.tfvars

    # restore business_unit_1.auto.tfvars in main module
    mv 4-projects/business_unit_1/development/business_unit_1.auto.tfvars.disabled 4-projects/business_unit_1/development/business_unit_1.auto.tfvars
    mv 4-projects/business_unit_1/non-production/business_unit_1.auto.tfvars.disabled 4-projects/business_unit_1/non-production/business_unit_1.auto.tfvars 
    mv 4-projects/business_unit_1/production/business_unit_1.auto.tfvars.disabled 4-projects/business_unit_1/production/business_unit_1.auto.tfvars 

    # restore business_unit_2.auto.tfvars in main module
    mv 4-projects/business_unit_2/development/business_unit_2.auto.tfvars.disabled 4-projects/business_unit_2/development/business_unit_2.auto.tfvars
    mv 4-projects/business_unit_2/non-production/business_unit_2.auto.tfvars.disabled 4-projects/business_unit_2/non-production/business_unit_2.auto.tfvars 
    mv 4-projects/business_unit_2/production/business_unit_2.auto.tfvars.disabled 4-projects/business_unit_2/production/business_unit_2.auto.tfvars 

    # restore ENVS.auto.tfvars in main module
    mv 4-projects/business_unit_1/development/development.auto.tfvars.disabled 4-projects/business_unit_1/development/development.auto.tfvars
    mv 4-projects/business_unit_2/development/development.auto.tfvars.disabled 4-projects/business_unit_2/development/development.auto.tfvars
    mv 4-projects/business_unit_1/non-production/non-production.auto.tfvars.disabled 4-projects/business_unit_1/non-production/non-production.auto.tfvars 
    mv 4-projects/business_unit_2/non-production/non-production.auto.tfvars.disabled 4-projects/business_unit_2/non-production/non-production.auto.tfvars 
    mv 4-projects/business_unit_1/production/production.auto.tfvars.disabled 4-projects/business_unit_1/production/production.auto.tfvars
    mv 4-projects/business_unit_2/production/production.auto.tfvars.disabled 4-projects/business_unit_2/production/production.auto.tfvars
    mv 4-projects/business_unit_1/shared/shared.auto.tfvars.disabled 4-projects/business_unit_1/shared/shared.auto.tfvars 
    mv 4-projects/business_unit_2/shared/shared.auto.tfvars.disabled 4-projects/business_unit_2/shared/shared.auto.tfvars 

    # restore common.auto.tfvars in main module
    mv 4-projects/business_unit_1/development/common.auto.tfvars.disabled 4-projects/business_unit_1/development/common.auto.tfvars
    mv 4-projects/business_unit_1/non-production/common.auto.tfvars.disabled 4-projects/business_unit_1/non-production/common.auto.tfvars 
    mv 4-projects/business_unit_1/production/common.auto.tfvars.disabled 4-projects/business_unit_1/production/common.auto.tfvars
    mv 4-projects/business_unit_1/shared/common.auto.tfvars.disabled 4-projects/business_unit_1/shared/common.auto.tfvars
    mv 4-projects/business_unit_2/development/common.auto.tfvars.disabled 4-projects/business_unit_2/development/common.auto.tfvars
    mv 4-projects/business_unit_2/non-production/common.auto.tfvars.disabled 4-projects/business_unit_2/non-production/common.auto.tfvars 
    mv 4-projects/business_unit_2/production/common.auto.tfvars.disabled 4-projects/business_unit_2/production/common.auto.tfvars
    mv 4-projects/business_unit_2/shared/common.auto.tfvars.disabled 4-projects/business_unit_2/shared/common.auto.tfvars

}

function appinfra(){
    # restore backend configs in main module
    mv 5-app-infra/business_unit_1/development/backend.tf.disabled 5-app-infra/business_unit_1/development/backend.tf
    mv 5-app-infra/business_unit_1/non-production/backend.tf.disabled 5-app-infra/business_unit_1/non-production/backend.tf 
    mv 5-app-infra/business_unit_1/production/backend.tf.disabled 5-app-infra/business_unit_1/production/backend.tf 

    # restore ENVS.auto.tfvars in main module
    mv 5-app-infra/business_unit_1/development/bu1-development.auto.tfvars.disabled 5-app-infra/business_unit_1/development/bu1-development.auto.tfvars
    mv 5-app-infra/business_unit_1/non-production/bu1-non-production.auto.tfvars.disabled 5-app-infra/business_unit_1/non-production/bu1-non-production.auto.tfvars 
    mv 5-app-infra/business_unit_1/production/bu1-production.auto.tfvars.disabled 5-app-infra/business_unit_1/production/bu1-production.auto.tfvars 

    # restore common.auto.tfvars in main module
    mv 5-app-infra/business_unit_1/development/common.auto.tfvars.disabled 5-app-infra/business_unit_1/development/common.auto.tfvars
    mv 5-app-infra/business_unit_1/non-production/common.auto.tfvars.disabled 5-app-infra/business_unit_1/non-production/common.auto.tfvars 
    mv 5-app-infra/business_unit_1/production/common.auto.tfvars.disabled 5-app-infra/business_unit_1/production/common.auto.tfvars 
}


# parse args
for arg in "$@"
do
  case $arg in
    -n|--networks)
      networks
      shift
      ;;
    -nh|--networks-hub-and-spoke)
      networks-hub-and-spoke
      shift
      ;;
    -s|--shared)
      shared
      shift
      ;;
    -sh|--shared-hub-and-spoke)
      shared-hub-and-spoke
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