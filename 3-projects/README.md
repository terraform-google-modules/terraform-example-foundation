# 3-projects

The purpose of this step is to setup folder structure, project, DNS and subnets used for applications.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-networks executed successfully.

## Usage
### Setup to run via Cloud Build
1. Clone repo gcloud source repos clone gcp-projects --project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Change freshly cloned repo and change to non master branch git checkout -b plan
1. Copy contents of foundation to new repo cp ../terraform-example-foundation/3-projects/* .
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Commit changes with git add . and git commit -m 'Your message'
1. Push your non master branch to trigger a plan git push --set-upstream origin plan
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to master with git checkout -b master and git push origin master
    1.Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Run terraform locally
1. Change into 3-projects folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Run terraform init
1. Run terraform plan and review output
1. Run terraform apply

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| default\_region | Default region for subnet. | string | n/a | yes |
| domain | The top level domain name for the organization | string | `""` | no |
| organization\_id | The organization id for the associated services | string | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
