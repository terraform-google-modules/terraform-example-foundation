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

# Define the base path where the build type files are
SCRIPTS_DIR="$( dirname -- "$0"; )"
BASE_PATH="$SCRIPTS_DIR/.."
TARGET_BUILD="$1"

# Define the allowed build types for validation
build_types=("cb" "github" "gitlab" "jenkins" "terraform_cloud")

# Validate the build_type input
valid_build_type=false
for valid_type in "${build_types[@]}"; do
  if [ "$TARGET_BUILD" = "$valid_type" ]; then
    valid_build_type=true
    break
  fi
done

if [ "$valid_build_type" = false ]; then
  echo "Error: Invalid build type '$TARGET_BUILD'.  Must be one of: ${build_types[*]}"
  exit 1
fi

# Rename *_cb.tf files to *_cb.tf.example if BUILD_TYPE is not "cb"
if [ "$TARGET_BUILD" != "cb" ]; then
  find "$BASE_PATH" -name "*_cb.tf" -print0 | while IFS= read -r -d $'\0' file; do
    new_name="${file}.example"
    echo "Renaming \"$file\" to \"$new_name\""
    mv "$file" "$new_name"
  done
fi

# Rename *_BUILD_TYPE.tf.example to *_BUILD_TYPE.tf if they exist
find "$BASE_PATH" -name "*_$TARGET_BUILD.tf.example" -print0 | while IFS= read -r -d $'\0' file; do
  # Extract the base name without the .example extension
  base_name="${file%.tf.example}"
  new_name="$base_name.tf"

  echo "Renaming \"$file\" to \"$new_name\""
  mv "$file" "$new_name"
done

echo "File renaming complete."
