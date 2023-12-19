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

# Define the root folder where you want to start the search and renaming
root_folder="./terraform-example-foundation"

# Use 'find' to locate all files named 'backend.tf'
# in the specified folder and its subfolders, excluding directories that start with ".terraform"
find "$root_folder" -type d -name '.terraform' -prune -o \( -type f \( -name 'backend.tf' \) \) -print0 | while IFS= read -r -d '' file; do
    # Extract the file name without the path
    file_name=$(basename "$file")

    # Check if 'backend.tf.gcs.example' already exists in the same directory
    if [ "$file_name" = "backend.tf" ]; then
        directory="${file%/*}"
        if [ -e "$directory/backend.tf.gcs.example" ]; then
            echo "File 'backend.tf.gcs.example' already exists in '$directory'. Exiting."
            exit 1
        fi
    fi

    # Rename 'backend.tf' to 'backend.tf.gcs.example'
    if [ "$file_name" = "backend.tf" ]; then
        new_name="${file%/*}/backend.tf.gcs.example"
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi

done

# Use 'find' to locate all files named 'backend.tf.cloud.example'
# in the specified folder and its subfolders, excluding directories that start with ".terraform"
find "$root_folder" -type d -name '.terraform' -prune -o \( -type f \( -name 'backend.tf.cloud.example' \) \) -print0 | while IFS= read -r -d '' file; do
    # Extract the file name without the path
    file_name=$(basename "$file")

    # Rename 'backend.tf.cloud.example' to 'backend.tf'
    if [ "$file_name" = "backend.tf.cloud.example" ]; then
        new_name="${file%/*}/backend.tf"
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done

# Use 'find' to locate all files named 'remote.tf'
# in the specified folder and its subfolders, excluding directories that start with ".terraform"
find "$root_folder" -type d -name '.terraform' -prune -o \( -type f \( -name 'remote.tf' \) \) -print0 | while IFS= read -r -d '' file; do
    # Extract the file name without the path
    file_name=$(basename "$file")

    # Check if 'remote.tf.gcs.example' already exists in the same directory
    if [ "$file_name" = "remote.tf" ]; then
        directory="${file%/*}"
        if [ -e "$directory/remote.tf.gcs.example" ]; then
            echo "File 'remote.tf.gcs.example' already exists in '$directory'. Exiting."
            exit 1
        fi
    fi

    # Rename 'remote.tf' to 'remote.tf.gcs.example'
    if [ "$file_name" = "remote.tf" ]; then
        new_name="${file%/*}/remote.tf.gcs.example"
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done

# Use 'find' to locate all files named 'remote.tf.cloud.example'
# in the specified folder and its subfolders, excluding directories that start with ".terraform"
find "$root_folder" -type d -name '.terraform' -prune -o \( -type f \( -name 'remote.tf.cloud.example' \) \) -print0 | while IFS= read -r -d '' file; do
    # Extract the file name without the path
    file_name=$(basename "$file")

    # Rename 'remote.tf.cloud.example' to 'remote.tf'
    if [ "$file_name" = "remote.tf.cloud.example" ]; then
        new_name="${file%/*}/remote.tf"
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done

echo "Done!"
