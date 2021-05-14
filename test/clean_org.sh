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

# clean up access-context-manager policies and scc notifications if any

source /usr/local/bin/task_helper_functions.sh && source_test_env && init_credentials
gcloud config set project "${TF_VAR_project_id:?}"
# sleep 60s to give time for permissions in prepare step to take effect
sleep 60
gcloud scc notifications delete test-scc-notification --organization "${TF_VAR_org_id:?}" -q || true
POLICY_ID=$(gcloud access-context-manager policies list --organization="${TF_VAR_org_id:?}" --format="value(name)")
gcloud access-context-manager policies delete "${POLICY_ID}" -q || true
