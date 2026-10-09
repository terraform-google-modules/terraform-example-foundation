#!/bin/bash

# Copyright 2024 Google LLC
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

# This logic is also mirrored in the deploy helper and testutils.
# The RenameBuildFiles function mirrors these build types; see
# test/integration/testutils/files.go.

set -eo pipefail

# Validate input presence and help flags
if [[ $# -eq 0 || -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 <cb|github|gitlab|terraform_cloud|local>"
  exit 1
fi

# Define root directory relative to script location
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd "$SCRIPTS_DIR/.." &> /dev/null && pwd )"
TARGET_BUILD="$1"

# Define allowed build types for validation
build_types=("cb" "github" "gitlab" "terraform_cloud" "local")

# Validate the build_type input
valid_build_type=false
for b_type in "${build_types[@]}"; do
  if [[ "$b_type" == "$TARGET_BUILD" ]]; then
    valid_build_type=true
    break
  fi
done

if [[ "$valid_build_type" != true ]]; then
  echo "Error: Invalid build type '$TARGET_BUILD'. Must be one of: ${build_types[*]}"
  exit 1
fi

# Discover target search directories across relevant stages
SEARCH_PATHS=()

# 0-bootstrap
if [[ -d "$ROOT_DIR/0-bootstrap" ]]; then
  SEARCH_PATHS+=("$ROOT_DIR/0-bootstrap")
fi

# 4-projects shared directories across business units
for shared_dir in "$ROOT_DIR"/4-projects/business_unit_*/shared; do
  if [[ -d "$shared_dir" ]]; then
    SEARCH_PATHS+=("$shared_dir")
  fi
done

# 5-app-infra
if [[ -d "$ROOT_DIR/5-app-infra" ]]; then
  SEARCH_PATHS+=("$ROOT_DIR/5-app-infra")
fi

# Fallback: if executed in an extracted standalone stage directory
if [[ ${#SEARCH_PATHS[@]} -eq 0 ]]; then
  SEARCH_PATHS+=("$ROOT_DIR")
fi

# Deactivate all other build types to ensure a clean state
for type in "${build_types[@]}"; do
  if [[ "$type" != "$TARGET_BUILD" ]]; then
    find "${SEARCH_PATHS[@]}" -type d \( -name .git -o -name .terraform \) -prune -o -name "*_$type.tf" -type f -print0 | while IFS= read -r -d $'\0' file; do
      if [ -f "$file" ]; then
        new_name="${file}.example"
        echo "Deactivating: renaming \"$file\" to \"$new_name\""
        mv "$file" "$new_name"
      fi
    done
  fi
done

# Activate the target build type
find "${SEARCH_PATHS[@]}" -type d \( -name .git -o -name .terraform \) -prune -o -name "*_$TARGET_BUILD.tf.example" -type f -print0 | while IFS= read -r -d $'\0' file; do
  base_name="${file%.tf.example}"
  new_name="$base_name.tf"

  echo "Activating: renaming \"$file\" to \"$new_name\""
  mv "$file" "$new_name"
done

echo "File renaming complete."
