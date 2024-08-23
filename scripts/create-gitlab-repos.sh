#!/bin/bash

gitlab_token=$1
group=$2 # example groupid: 2133412

if [[ -z $1 ]]; then
  echo "Please provide a gitlab token as argument"
  exit 1
fi

# Define the array with repository names
repos=(
    "gcp-bootstrap"
    "gcp-org"
    "gcp-environments"
    "gcp-projects"
    "gcp-networks"
    "tf-cloud-builder"    
)

# Loop through each repository name in the array
for repo in "${repos[@]}"; do
    # Create the repository
    curl -v --header "PRIVATE-TOKEN: $1" \
     --header "Content-Type: application/json" --data "{\"name\": \"$repo\", \"description\": \"terraform-iac\",\"initialize_with_readme\": \"true\", \"namespace_id\": \"$2\",  \"visibility\": \"private\"}" \
     --url "https://gitlab.com/api/v4/projects/"
done
