# 0-bootstrap

The purpose of this step is to bootstrap a GCP organization, creating all the required resources & permissions to start using the Cloud Foundation Toolkit (CFT). This step also configures a CICD pipeline for foundations code in subsequent stages. The CICD pipeline can use either Cloud Build & Cloud Source Repos or Jenkins & your own Git repos (which might live on-prem).

## Prerequisites

1. A GCP [Organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization)
1. A GCP [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account)
1. Cloud Identity / G Suite groups for organization and billing admins
1. Membership in the `group_org_admins` group for user running terraform
1. Grant the roles mentioned in bootstrap [README.md](https://github.com/terraform-google-modules/terraform-google-bootstrap#permissions), as well as `roles/resourcemanager.folderCreator` for the user running the step.

Further details of permissions required and resources created, can be found in the bootstrap module [documentation.](https://github.com/terraform-google-modules/terraform-google-bootstrap)

**Note:** when running the examples in this repository, you may receive an error like `Error code 8, message: The project cannot be created because you have exceeded your allotted project quota.` when applying terraform. That means you have reached your [Project creation quota](https://support.google.com/cloud/answer/6330231). In this case you can use this [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase) form to request a quota increase. The `terraform_sa_email` created in `0-bootstrap` should also be listed in "Email addresses that will be used to create projects" in that support form. If you face others quota errors, check the [Quota documentation](https://cloud.google.com/docs/quota) for guidence.

## 0-bootstrap usage to deploy Jenkins

If you are using the `jenkins_bootstrap` sub-module, please see [README-Jenkins](./README-Jenkins.md) for requirements and instructions on how to run the 0-bootstrap step. Using Jenkins requires a few manual steps, including configuring connectivity with your current Jenkins Master environment.

## 0-bootstrap usage to deploy Cloud Build

1. Change into 0-bootstrap folder
1. Copy tfvars by running `cp terraform.example.tfvars terraform.tfvars` and update `terraform.tfvars` with values from your environment.
1. Run `terraform init`
1. Run `terraform plan` and review output
1. Run `terraform apply`
1. Run `terraform output gcs_bucket_tfstate` to get your GCS bucket from the apply step
1. Copy the backend by running `cp backend.tf.example backend.tf` and update `backend.tf` with your GCS bucket.
1. Re-run `terraform init` agree to copy state to GCS when prompted
    1. (Optional) Run `terraform apply` to verify state is configured correctly

### (Optional) State backends for running terraform locally

Currently, the bucket information is replaced in the state backends as a part of the build process when executed by Cloud Build. If you would like to execute terraform locally, you will need to add your GCS bucket to the `backend.tf` files. You can update all of these files with the following steps:

1. Change into the main directory for the terraform-example-foundation.
1. Run this command ```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/GCS_BUCKET_NAME/' $i; done``` where `GCS_BUCKET_NAME` is the name of your bucket from the steps executed above.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The ID of the billing account to associate projects with. | string | n/a | yes |
| default\_region | Default region to create resources where applicable. | string | `"us-central1"` | no |
| group\_billing\_admins | Google Group for GCP Billing Administrators | string | n/a | yes |
| group\_org\_admins | Google Group for GCP Organization Administrators | string | n/a | yes |
| org\_id | GCP Organization ID | string | n/a | yes |
| org\_project\_creators | Additional list of members to have project creator role across the organization. Prefix of group: user: or serviceAccount: is required. | list(string) | `<list>` | no |
| parent\_folder | Optional - if using a folder for testing. | string | `""` | no |
| skip\_gcloud\_download | Whether to skip downloading gcloud (assumes gcloud is already available outside the module) | bool | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudbuild\_project\_id | Project where CloudBuild configuration and terraform container image will reside. |
| csr\_repos | List of Cloud Source Repos created by the module, linked to Cloud Build triggers. |
| gcs\_bucket\_cloudbuild\_artifacts | Bucket used to store Cloud/Build artefacts in CloudBuild project. |
| gcs\_bucket\_tfstate | Bucket used for storing terraform state for foundations pipelines in seed project. |
| kms\_crypto\_key | KMS key created by the module. |
| kms\_keyring | KMS Keyring created by the module. |
| seed\_project\_id | Project where service accounts and core APIs will be enabled. |
| terraform\_sa\_email | Email for privileged service account for Terraform. |
| terraform\_sa\_name | Fully qualified name for privileged service account for Terraform. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

- [gcloud sdk](https://cloud.google.com/sdk/install) >= 206.0.0
- [Terraform](https://www.terraform.io/downloads.html) >= 0.12.6
    - You should use the same version in the manual steps during 0-bootstrap to avoid possible  [Terraform State Snapshot Lock](https://github.com/hashicorp/terraform/issues/23290) errors caused by differences in terraform versions. This can usually be resolved with a version upgrade.
