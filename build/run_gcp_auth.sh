#!/bin/sh -x

# Copyright 2023 Google LLC
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

# An id_tokens configured for the audience of the Workload Identity Federation provider
# See https://docs.gitlab.com/ee/ci/secrets/id_token_authentication.html
OIDC_TOKEN="$1"

# A Workload Identity Federation provider
# See https://cloud.google.com/iam/docs/workload-identity-federation
WIF_PROVIDER="$2"

# A Google Cloud Platform Service Account
# See https://cloud.google.com/iam/docs/service-account-overview
SA="$3"

# System folder to save the temporary files
SAVE_PATH="$4"

# TODO
echo "${OIDC_TOKEN}" > "${SAVE_PATH}"/.ci_job_token_file

# TODO
gcloud iam workload-identity-pools \
create-cred-config "${WIF_PROVIDER}" \
--service-account="${SA}" \
--output-file="${SAVE_PATH}"/.gcp_generated_credentials.json \
--credential-source-file="${SAVE_PATH}"/.ci_job_token_file \

# TODO
gcloud auth login --cred-file="${SAVE_PATH}"/.gcp_generated_credentials.json --update-adc
