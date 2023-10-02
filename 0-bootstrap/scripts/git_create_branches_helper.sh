#!/bin/bash

# Define the base path where your repositories are located
BASE_PATH="../../"

# Function to create branches and push to remote
create_branches_and_push() {
  local repo_path="$1"
  cd "$repo_path" || exit 1

  # Check if the directory is a Git repository
  if [ -d .git ]; then
    echo "Processing repository: $repo_path"
    
    # Create the branches
    git checkout -b development
    git push origin development
    
    git checkout -b non-production
    git push origin non-production
    
    git checkout -b production
    git push origin production
    
    echo "Branches (development, non-production, production) created and pushed for $repo_path"
  else
    echo "Skipping non-Git directory: $repo_path"
  fi
}

# Iterate through all folders in the base path
for repo_dir in "$BASE_PATH"/*; do
  [ -d "$repo_dir" ] || continue  # Skip non-directories
  create_branches_and_push "$repo_dir"
done

echo "Branch creation and push completed for all repositories."
