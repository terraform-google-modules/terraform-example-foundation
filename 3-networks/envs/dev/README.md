# 3-networks/dev

The purpose of this step is to setup private and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, onprem dedicated interconnect, onprem VPN and baseline firewall rules for environment dev.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments/envs/dev executed successfully.
1. 3-networks/envs/shared executed successfully.

## Usage

### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-networks --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan-dev`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/3-networks/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Change cloud build configuration files in order to `terraform init ./envs/dev`, `terraform plan ./envs/dev`, and `terraform apply ./envs/dev`.
1. Rename ./envs/dev/terraform.example.tfvars to ./envs/dev/terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename ./envs/dev/backend.tf.example to ./envs/dev/backend.tf and update with your bucket from bootstrap.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your non master branch to trigger a plan `git push --set-upstream origin plan-dev`
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to master with `git checkout -b master` and `git push origin master`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Run terraform locally
1. Change into 3-networks/envs/dev folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example to backend.tf and update with your bucket from bootstrap.
1. Run `terraform init`
1. Run `terraform plan` and review output
1. Run `terraform apply`


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID`. | number | n/a | yes |
| default\_region1 | First subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| default\_region2 | Second subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| domain | The DNS name of peering managed zone, for instance 'example.com.' | string | n/a | yes |
| org\_id | Organization ID | string | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_host\_project\_id | The private host project ID |
| private\_network\_name | The name of the VPC being created |
| private\_network\_self\_link | The URI of the VPC being created |
| private\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| private\_subnets\_names | The names of the subnets being created |
| private\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| private\_subnets\_self\_links | The self-links of subnets being created |
| restricted\_host\_project\_id | The restricted host project ID |
| restricted\_network\_name | The name of the VPC being created |
| restricted\_network\_self\_link | The URI of the VPC being created |
| restricted\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| restricted\_subnets\_names | The names of the subnets being created |
| restricted\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| restricted\_subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
