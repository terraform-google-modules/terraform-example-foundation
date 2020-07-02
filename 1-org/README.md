# 1-org

The purpose of this step is to setup top level shared folders, monitoring & networking projects, org level logging and set baseline security settings through organizational policy.

## Prerequisites

1. 0-bootstrap executed successfully.

## Usage

### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-org --project=YOUR_CLOUD_BUILD_PROJECT_ID (this is from `terraform output` from the previous section, 0-bootstrap)`
1. Navigate into the repo `cd gcp-org` and change to a non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/1-org/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory)
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values).
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your non master branch to trigger a plan `git push --set-upstream origin plan`
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to master with `git checkout -b master` and `git push origin master`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Run terraform locally
1. Change into 1-org folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Run `terraform init`
1. Run `terraform plan` and review output
1. Run `terraform apply`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_table\_expiration\_ms | Period before tables expire for access logs in milliseconds. Default is 400 days. | number | `"34560000000"` | no |
| audit\_data\_users | Gsuite or Cloud Identity group that have access to audit logs. | string | n/a | yes |
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| billing\_data\_users | Gsuite or Cloud Identity group that have access to billing data set. | string | n/a | yes |
| data\_access\_table\_expiration\_ms | Period before tables expire for data access logs in milliseconds. Default is 30 days. | number | `"2592000000"` | no |
| default\_region | Default region for BigQuery resources. | string | n/a | yes |
| domains\_to\_allow | The list of domains to allow users from in IAM. | list(string) | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | string | `""` | no |
| scc\_notification\_filter | Filter used to SCC Notification | string | `"state=\\\"ACTIVE\\\""` | no |
| scc\_notification\_name | Name of SCC Notification | string | n/a | yes |
| system\_event\_table\_expiration\_ms | Period before tables expire for system event logs in milliseconds. Default is 400 days. | number | `"34560000000"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
