#!/bin/bash

# Copyright 2026 Google LLC
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

# Enable strict mode
set -euo pipefail

RAW_TARGET="${1:-}"
RAW_TF_FOLDER="${2:-}"

if [ -z "$RAW_TARGET" ] || [ -z "$RAW_TF_FOLDER" ]; then
  echo "Error: Missing arguments." >&2
  echo "Usage: $0 <target_directory> <tf_state_folder>" >&2
  exit 1
fi

# Check if terraform is installed
if ! command -v terraform >/dev/null 2>&1; then
  echo "Error: 'terraform' is not installed or not available in the PATH." >&2
  exit 1
fi

# Validate directories exist before proceeding
if [ ! -d "$RAW_TARGET" ]; then
  echo "Error: Target directory '$RAW_TARGET' does not exist." >&2
  exit 1
fi

if [ ! -d "$RAW_TF_FOLDER" ]; then
  echo "Error: Terraform state folder '$RAW_TF_FOLDER' does not exist." >&2
  exit 1
fi

TARGET_DIR=$(realpath "$RAW_TARGET")
TF_STATE_FOLDER=$(realpath "$RAW_TF_FOLDER")
SKIP_FILE="${TF_STATE_FOLDER}/backend.tf"


# get output values from terraform from path to bootstrap state
backend_bucket=$(terraform -chdir="$TF_STATE_FOLDER" output -raw backend_bucket)
backend_bucket_projects=$(terraform -chdir="$TF_STATE_FOLDER" output -raw backend_bucket_projects)
universe_domain=$(terraform -chdir="$TF_STATE_FOLDER" output -raw universe_domain)

if [ -z "$backend_bucket" ] || [ -z "$backend_bucket_projects" ] || [ -z "$universe_domain" ]; then
  echo "Error: Could not find one or more required variables in the Terraform outputs."
  echo "Ensure backend_bucket, backend_bucket_projects, and universe_domain are defined as outputs."
  exit 1
fi

find "$TARGET_DIR" -name 'backend.tf' -print0 | while IFS= read -r -d '' i; do

  if [ "$i" = "$SKIP_FILE" ]; then
    echo "Skipping $i"
    continue # This skips the rest of the loop and moves to the next file
  fi

  # Your combined sed
  sed -i'' -e "s/UPDATE_ME/${backend_bucket}/" -e "s/UPDATE_PROJECTS_BACKEND/${backend_bucket_projects}/" "$i"

  CURRENT_FOLDER=$(dirname "$i")

  TFVARS_FILE="${CURRENT_FOLDER}/universe.auto.tfvars"

  # Add your other commands...
    cat <<EOF > "$TFVARS_FILE"
universe_domain = "${universe_domain}"
EOF

done
