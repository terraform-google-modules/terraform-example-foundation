# 4-projects

The purpose of this step is to setup folder structure and projects for applications, which are connected as service projects to the shared VPC created in the previous stage. Optionally, you can also create dedicated DNS zones and subnets for these applications.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. 3-networks executed successfully.

## Usage
### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-projects --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/4-projects/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` (modify accordingly based on your current directory)
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Copy terraform.tfvars to each business_unit/envs/ folder.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your plan branch to trigger a plan `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `dev`, `nonprod` or `prod` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to dev with `git checkout -b dev` and `git push origin dev`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to nonprod with `git checkout -b nonprod` and `git push origin nonprod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to prod with `git checkout -b prod` and `git push origin prod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Run terraform locally
1. Change into 4-projects folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Update backend.tf with your bucket from bootstrap.
1. Run `terraform init`
1. Run `terraform plan` and review output
1. Run `terraform apply`

### Subnetting Module (Optional)
Creates a dedicated subnet per environment, per project and applies org policy to restrict access to only this subnet. Refer to the README [here](./modules/project_subnet/README.md) for details about this module.

### Private DNS Module (Optional)
Creates a dedicated private DNS zone per environment, per project and makes it available in the Shared VPC through DNS peering. Refer to the README [here](./modules/private_dns/README.md) for details about this module.

### Example Code for Subnetting and Private DNS (Optional)
If you have uncommented the Subnetting and Private DNS Management module from previous steps. Please also uncomment *single-project-example-optional.tf* and *standard-project-example-optional.tf* for the example code.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| default\_region | Default region for subnet. | string | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | string | `""` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
