#!/bin/bash

# Define the root folder where you want to start the search and renaming
root_folder="../../terraform-example-foundation"

# Use 'find' to locate all files named 'backend.tf' and 'backend.tf.cloud.example'
# in the specified folder and its subfolders, excluding directories that start with ".terraform"
find "$root_folder" -type d -name '.terraform' -prune -o \( -type f \( -name 'backend.tf' -o -name 'backend.tf.cloud.example' \) \) -print0 | while IFS= read -r -d '' file; do
    # Extract the file name without the path
    file_name=$(basename "$file")

    # Check if 'backend.tf.old' already exists in the same directory
    if [ "$file_name" = "backend.tf" ]; then
        directory="${file%/*}"
        if [ -e "$directory/backend.tf.old" ]; then
            echo "File 'backend.tf.old' already exists in '$directory'. Exiting."
            exit 1
        fi
    fi

    # Rename 'backend.tf' to 'backend.tf.old'
    if [ "$file_name" = "backend.tf" ]; then
        new_name="${file%/*}/backend.tf.old"
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi

    # Rename 'backend.tf.cloud.example' to 'backend.tf'
    if [ "$file_name" = "backend.tf.cloud.example" ]; then
        new_name="${file%/*}/backend.tf"
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done

echo "Done!"
