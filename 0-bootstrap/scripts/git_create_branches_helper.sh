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

# Define the base path where your repositories are located
SCRIPTS_DIR="$( dirname -- "$0"; )"
BASE_PATH="$SCRIPTS_DIR/../../.."
TARGET="$1"

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
    if [[ ! $repo_name =~ (gcp-bootstrap|gcp-org|gcp-environments|gcp-networks|gcp-projects|gcp-cicd-runner) ]]; then
      return
    fi

    echo "Processing repository: $repo_name"

    # process gcp-cicd-runner repo
    if [[ $repo_name == *"gcp-cicd-runner"* && $TARGET == "GITLAB" ]]; then
      git checkout -b image
      touch .gitignore
      git add .gitignore
      git commit -m "seed commit"
      git push --set-upstream origin image
      echo "Branch (image) created and pushed for $repo_name"
      return
    fi

    # Create plan branch
    if [[ $TARGET == "GITLAB" ]]; then
      git checkout -b plan
      touch .gitignore
      git add .gitignore
      git commit -m "seed commit"
      git push --set-upstream origin plan
      echo "Branch (plan) created and pushed for $repo_name"
    fi

    # Create production branch
    git checkout -b production
    touch .gitignore
    git add .gitignore
    git commit -m "seed commit"
    git push --set-upstream origin production
    echo "Branch (production) created and pushed for $repo_name"

    # Check if the repo name contains "bootstrap" or "org"
    if [[ $repo_name == *"gcp-bootstrap"* || $repo_name == *"gcp-org"* ]]; then
      echo "All branches created and pushed for $repo_name"
    else
      # Create development and nonproduction branches
      git checkout -b development
      touch .gitignore
      git add .gitignore
      git commit -m "seed commit"
      git push --set-upstream origin development
      echo "Branch (development) created and pushed for $repo_name"

      git checkout -b nonproduction
      touch .gitignore
      git add .gitignore
      git commit -m "seed commit"
      git push --set-upstream origin nonproduction
      echo "Branch (nonproduction) created and pushed for $repo_name"

      echo "All branches created and pushed for $repo_name"
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
