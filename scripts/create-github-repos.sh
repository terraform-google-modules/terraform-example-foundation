#!/bin/bash

# Define the array with repository names
repos=(
    "gcp-bootstrap"
    "gcp-org"
    "gcp-environments"
    "gcp-projects"
    "gcp-networks"
    "tf-cloud-builder"    
)

# Authenticate with GitHub CLI (only needed once, uncomment if not already authenticated)
# gh auth login

# Loop through each repository name in the array
for repo in "${repos[@]}"; do
    # Create the repository
    gh repo create "$repo" --private
done


# Loop through each repository name in the array
for repo in "${repos[@]}"; do
    repo_url=$(gh repo view "$repo" --json url -q .url)
    echo "$repo_url.git"
done
    
