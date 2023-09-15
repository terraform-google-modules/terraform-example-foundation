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

PAYLOAD=$(cat <<EOF
{
"audience": "//iam.googleapis.com/${WIF_PROVIDER_NAME}",
"grantType": "urn:ietf:params:oauth:grant-type:token-exchange",
"requestedTokenType": "urn:ietf:params:oauth:token-type:access_token",
"scope": "https://www.googleapis.com/auth/cloud-platform",
"subjectTokenType": "urn:ietf:params:oauth:token-type:jwt",
"subjectToken": "${CI_JOB_JWT_V2}"
}
EOF
)
#echo "${PROJECT_NUMBER}"

FEDERATED_TOKEN=$(curl -X POST "https://sts.googleapis.com/v1/token" \
 --header "Accept: application/json" \
 --header "Content-Type: application/json" \
 --data "${PAYLOAD}" \
 | jq -r '.access_token'
 )

ACCESS_TOKEN=$(curl -X POST "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${SERVICE_ACCOUNT_EMAIL}:generateAccessToken" \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer ${FEDERATED_TOKEN}" \
--data '{"scope": ["https://www.googleapis.com/auth/cloud-platform"]}' \
| jq -r '.accessToken'
)
echo "${ACCESS_TOKEN}"

echo "${CI_JOB_JWT_V2}" > .ci_job_jwt_file
gcloud iam workload-identity-pools create-cred-config "${WIF_PROVIDER_NAME}" \
--service-account="${SERVICE_ACCOUNT_EMAIL}" \
--output-file=.gcp_temp_cred.json \
--credential-source-file=.ci_job_jwt_fgcloud conf listile
gcloud auth login --cred-file=.gcp_temp_cred.json
