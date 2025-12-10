#!/bin/bash

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

# This logic is also implemented in the deploy helper.
# The deploy helper version is working on a subset of the options: cb, github, and gitlab
# See helpers/foundation-deployer/utils/files.go RenameBuildFiles function

set -e

# Define the base path where the build type files are
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASE_PATH="$SCRIPTS_DIR/.."
TARGET_BUILD="$1"

# Define the allowed build types for validation
build_types=("cb" "github" "gitlab" "jenkins" "terraform_cloud")

# Validate the build_type input
if [[ ! " ${build_types[*]} " == *" ${TARGET_BUILD} "* ]]; then
  echo "Error: Invalid build type '$TARGET_BUILD'.  Must be one of: ${build_types[*]}"
  exit 1
fi

# Deactivate all other build types to ensure a clean state
for type in "${build_types[@]}"; do
  if [[ "$type" != "$TARGET_BUILD" ]]; then
    find "$BASE_PATH" -name "*_$type.tf" -print0 | while IFS= read -r -d $'\0' file; do
      if [ -f "$file" ]; then
        new_name="${file}.example"
        echo "Deactivating: renaming \"$file\" to \"$new_name\""
        mv "$file" "$new_name"
      fi
    done
  fi
done

# Activate the target build type
find "$BASE_PATH" -name "*_$TARGET_BUILD.tf.example" -print0 | while IFS= read -r -d $'\0' file; do
  base_name="${file%.tf.example}"
  new_name="$base_name.tf"

  echo "Activating: renaming \"$file\" to \"$new_name\""
  mv "$file" "$new_name"
done

echo "File renaming complete."
