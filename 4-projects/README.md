# 4-projects

The purpose of this step is to setup folder structure and projects for applications, which are connected as service projects to the shared VPC created in the previous stage. Optionally, you can also create dedicated DNS zones and subnets for these applications.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. 4-projects executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`.
1. Obtain the values for the perimeter_name variable. Can be obteined by running
`gcloud access-context-manager perimeters list`

## Usage
### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-projects --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/4-projects/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` (modify accordingly based on your current directory)
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename common.auto.example.tfvars to common.auto.tfvars and update the file with values from your environment and bootstrap.
1. Run ` gcloud access-context-manager perimeters list --policy ACCESS_CONTEXT_MANAGER_POLICY_ID --format="value(name)"` to get the perimeter names for the access context manager policy id.
1. Rename dev.auto.example.tfvars to dev.auto.tfvars and update the file with the perimeter_name that starts with `sp_d_shared_restricted`.
1. Rename nonprod.auto.example.tfvars to nonprod.auto.tfvars and update the file with the perimeter_name that starts with `sp_n_shared_restricted`.
1. Rename prod.auto.example.tfvars to prod.auto.tfvars and update the file with the perimeter_name that starts with `sp_p_shared_restricted`.
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
1. Change into 4-projects folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Update backend.tf with your bucket from bootstrap. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.
You can run `terraform output gcs_bucket_tfstate` in the 0-bootstap folder to obtain the bucket name.

We will now deploy each of our environments(dev/prod/nonprod) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 4-projects step and only the corresponding environment is applied.

1. Run `./tf-wrapper.sh init prod`
1. Run `./tf-wrapper.sh plan prod` and review output.
1. Run `./tf-wrapper.sh apply prod`
1. Run `./tf-wrapper.sh init nonprod`
1. Run `./tf-wrapper.sh plan nonprod` and review output.
1. Run `./tf-wrapper.sh apply nonprod`
1. Run `./tf-wrapper.sh init dev`
1. Run `./tf-wrapper.sh plan dev` and review output.
1. Run `./tf-wrapper.sh apply dev`

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`

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
| access\_context\_manager\_policy\_id | The ID of the access context manager policy the perimeter lies in. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | string | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| default\_region | Default region for subnet. | string | `"us-west1"` | no |
| org\_id | The organization id for the associated services | string | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | string | `""` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
