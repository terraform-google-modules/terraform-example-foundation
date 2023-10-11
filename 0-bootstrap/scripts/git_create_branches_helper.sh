#!/bin/bash

# Define the base path where your repositories are located
BASE_PATH="."

# Function to create branches and push to remote
create_branches_and_push() {
  local repo_path="$1"
  cd "$repo_path" || exit 1


  # Check if the directory is a Git repository
  if [ -d .git ]; then
    # Get the repository name from the directory path
    repo_name=$(basename "$repo_path")

    # Check if the repo name contains the expected repo names in order to avoid
    # creating branches for non-related foundation repos
    if [[ ! $repo_name =~ (gcp-bootstrap|gcp-org|gcp-environments|gcp-networks|gcp-projects) ]]; then
      return
    fi

    echo "Processing repository: $repo_name"

    # Create production branches
    git checkout -b production
    git push origin production

    # Check if the repo name contains "bootstrap" or "org"
    if [[ $repo_name == *"gcp-bootstrap"* || $repo_name == *"gcp-org"* ]]; then
      echo "Branches (production) created and pushed for $repo_name"
    else
      # Create development and non-production branches
      git checkout -b development
      git push origin development
      
      git checkout -b non-production
      git push origin non-production
      
      echo "Branches (development, non-production, production) created and pushed for $repo_name"
    fi
  else
    echo "Skipping non-Git directory: $repo_path"
  fi
}

# Iterate through all folders in the base path
for repo_dir in "$BASE_PATH"/*; do
  [ -d "$repo_dir" ] || continue  # Skip non-directories
  create_branches_and_push "$repo_dir"
  cd ..
done

echo "Branch creation and push completed for all repositories."
