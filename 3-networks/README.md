# 3-networks

The purpose of this step is to :

- Setup the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones).
- Setup private and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, onprem dedicated interconnect and baseline firewall rules for each environment.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`.

## Usage

### Setup to run via Cloud Build

1. Clone repo `gcloud source repos clone gcp-networks --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/3-networks/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory)
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` (modify accordingly based on your current directory)
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Within each envs/ folder rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your plan branch to trigger a plan `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `dev`, `nonprod` or `prod` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Plan will fail for dev/nonprod/prod until prod has been applied at least once since all envs depend on shared (DNS Hub) that is deployed in the prod branch.
1. Merge changes to prod with `git checkout -b prod` and `git push origin prod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After prod has been applied apply dev and nonprod
1. Merge changes to dev with `git checkout -b dev` and `git push origin dev`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to nonprod with `git checkout -b nonprod` and `git push origin nonprod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Run terraform locally

1. Change into 3-networks folder
1. Within each envs/ folder rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Within each envs/ folder, update backend.tf with your bucket name from the bootstrap step.
1. In this sequence (shared, prod, dev, nonprod), change into each folder within the envs/ folder and run the following commands:
    1. Run `terraform init`
    1. Run `terraform plan` and review output
    1. Run `terraform apply`
