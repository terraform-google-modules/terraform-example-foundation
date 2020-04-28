# 3-projects

The purpose of this step is to setup folder structure and projects for applications, which are connected as service projects to the shared VPC created in the previous stage. Optionally, you can also create dedicated DNS zones and subnets for these applications.

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
| domain | The top level domain name for the organization | string | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| example\_single\_project |  |
| example\_single\_project\_optional |  |
| example\_standard\_projects |  |
| example\_standard\_projects\_optional |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
