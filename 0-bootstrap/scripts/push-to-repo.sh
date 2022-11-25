#!/usr/bin/env bash
# Copyright 2022 Google LLC
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


set -ex

if [ "$#" -lt 3 ]; then
    >&2 echo "Not all expected arguments set."
    exit 1
fi

CSR_PROJECT_ID=$1
CSR_NAME=$2
DOCKERFILE_PATH=$3

# create temp dir, cleanup at exit
tmp_dir=$(mktemp -d)
# # shellcheck disable=SC2064
# trap "rm -rf $tmp_dir" EXIT
gcloud source repos clone "${CSR_NAME}" "${tmp_dir}" --project "${CSR_PROJECT_ID}"
cp "${DOCKERFILE_PATH}" "${tmp_dir}"
pushd "${tmp_dir}"
git config credential.helper gcloud.sh
git config init.defaultBranch main
git config user.email "terraform-robot@example.com"
git config user.name "TF Robot"
git checkout main || git checkout -b main
git add Dockerfile
git commit -m "Initialize tf dockerfile repo"
git push origin main -f
