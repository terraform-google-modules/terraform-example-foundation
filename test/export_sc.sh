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

# this sets the outputs of networks as TF_VAR env vars
# used for plumbing service perimeter names into projects while testing
pushd /workspace/test/fixtures/networks
terraform workspace select kitchen-terraform-networks-default
# shellcheck disable=SC1090
source <(python /usr/local/bin/export_tf_outputs.py --path=/workspace/test/fixtures/networks)
popd
