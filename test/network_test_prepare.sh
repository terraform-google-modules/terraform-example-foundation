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

function compare(){
config1=$1
config2=$2
if cmp -s "$config1" "$config2"; then
    echo "${config1} and ${config2} are the same"
else
    echo "${config1} and ${config2} differ"
    exit 1
fi
}

function prepare(){
    # assert provider.tf in network envs are same
    compare 3-networks/envs/development/providers.tf  3-networks/envs/non-production/providers.tf
    compare 3-networks/envs/non-production/providers.tf  3-networks/envs/production/providers.tf

    # copy one config to network fixture
    cp 3-networks/envs/development/providers.tf test/fixtures/networks/providers.tf

    # disable provider configs in main module
    mv 3-networks/envs/development/providers.tf 3-networks/envs/development/providers.tf.disabled
    mv 3-networks/envs/non-production/providers.tf  3-networks/envs/non-production/providers.tf.disabled
    mv 3-networks/envs/production/providers.tf  3-networks/envs/production/providers.tf.disabled

}

function restore(){
    # remove test provider config
    rm -rf test/fixtures/networks/providers.tf
    # replace original provider config
    # disable provider configs in main module
    mv 3-networks/envs/development/providers.tf.disabled 3-networks/envs/development/providers.tf
    mv 3-networks/envs/non-production/providers.tf.disabled  3-networks/envs/non-production/providers.tf
    mv 3-networks/envs/production/providers.tf.disabled  3-networks/envs/production/providers.tf
}


# parse args
for arg in "$@"
do
  case $arg in
    -p|--prepare)
      prepare
      shift
      ;;
    -r|--restore)
      restore
      shift
      ;;
      *) # end argument parsing
      shift
      ;;
  esac
done
