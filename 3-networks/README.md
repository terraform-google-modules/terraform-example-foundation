# 3-networks

The purpose of this step is to setup shared VPCs with default DNS, NAT, Private Service networking and baseline firewall rules.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.

## Usage

### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-networks --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/3-networks/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory)
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your non master branch to trigger a plan `git push --set-upstream origin plan`
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to master with `git checkout -b master` and `git push origin master`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Run terraform locally
1. Change into 3-networks folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Run `terraform init`
1. Run `terraform plan` and review output
1. Run `terraform apply`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| default\_region1 | Default region standard_shared_vpc currently only configures two regions | string | n/a | yes |
| default\_region2 | Default region standard_shared_vpc currently only configures two regions | string | n/a | yes |
| org\_id | Organization ID | string | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| nonprod\_default\_policy | DNS Policy created in the network |
| nonprod\_dns\_record\_set\_gcr\_api | DNS Record set for GCR APIs |
| nonprod\_dns\_record\_set\_private\_api | DNS Record set for Private APIs |
| nonprod\_host\_project\_id | The host project ID for nonprod |
| nonprod\_network\_name | The name of the VPC being created |
| nonprod\_network\_self\_link | The URI of the VPC being created |
| nonprod\_region1\_router1 | Router 1 for Region 1 |
| nonprod\_region1\_router2 | Router 1 for Region 2 |
| nonprod\_region2\_router1 | Router 2 for Region 1 |
| nonprod\_region2\_router2 | Router 2 for Region 2 |
| nonprod\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| nonprod\_subnets\_names | The names of the subnets being created |
| nonprod\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| nonprod\_subnets\_self\_links | The self-links of subnets being created |
| prod\_default\_policy | DNS Policy created in the network |
| prod\_dns\_record\_set\_gcr\_api | DNS Record set for GCR APIs |
| prod\_dns\_record\_set\_private\_api | DNS Record set for Private APIs |
| prod\_host\_project\_id | The host project ID for prod |
| prod\_network\_name | The name of the VPC being created |
| prod\_network\_self\_link | The URI of the VPC being created |
| prod\_region1\_router1 | Router 1 for Region 1 |
| prod\_region1\_router2 | Router 1 for Region 2 |
| prod\_region2\_router1 | Router 2 for Region 1 |
| prod\_region2\_router2 | Router 2 for Region 2 |
| prod\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| prod\_subnets\_names | The names of the subnets being created |
| prod\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| prod\_subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
