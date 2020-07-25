# 2-environments

The purpose of this step is to set up dev, nonprod, and prod environments within the GCP organization.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. Cloud Identity / Gsuite group for monitoring admins.
1. Membership in the monitoring admins group for user running terraform

## Usage
### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-environments --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/2-environments/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory)
1. Change cloud build configuration files in order to `terraform init`, `terraform plan`, and `terraform apply` each environment in the envs folder.
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap. Copy terraform.tfvars into each of the folders within the envs/ folder.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your non master branch to trigger a plan `git push --set-upstream origin plan`
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to master with `git checkout -b master` and `git push origin master`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Run terraform locally
1. Change into 2-environments folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap. Copy terraform.tfvars into each of the folders within the envs/ folder.
1. Within each envs/ folder, update backend.tf with your bucket name from the bootstrap step.
1. In sequence, change into each folder within the envs/ folder and run the following commands:
    1. Run `terraform init`
    1. Run `terraform plan` and review output
    1. Run `terraform apply`
