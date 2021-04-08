# 0-bootstrap

The purpose of this step is to bootstrap a GCP organization, creating all the required resources & permissions to start using the Cloud Foundation Toolkit (CFT). This step also configures a CICD pipeline for foundations code in subsequent stages. The CICD pipeline can use either Cloud Build & Cloud Source Repos or Jenkins & your own Git repos (which might live on-prem).

## Prerequisites

1. A GCP [Organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization)
1. A GCP [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account)
1. Cloud Identity / Google Workspace (former G Suite) groups for organization and billing admins
1. User account should be used for running this step, service accounts are not supported.
1. Membership in the `group_org_admins` group for the user running terraform.
1. Grant the roles mentioned in bootstrap module [README.md](https://github.com/terraform-google-modules/terraform-google-bootstrap#permissions), as well as `roles/resourcemanager.folderCreator` for the user running the step.

Further details of groups, permissions required and resources created, can be found in the bootstrap module [documentation.](https://github.com/terraform-google-modules/terraform-google-bootstrap)

**Note:** when running the examples in this repository, you may receive various errors when applying terraform:

- `Error code 8, message: The project cannot be created because you have exceeded your allotted project quota.`. That means you have reached your [Project creation quota](https://support.google.com/cloud/answer/6330231). In this case you can use this [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase) form to request a quota increase. The `terraform_service_account` created in `0-bootstrap` should also be listed in "Email addresses that will be used to create projects" in that support form. If you face others quota errors, check the [Quota documentation](https://cloud.google.com/docs/quota) for guidance.
- `Error: Error when reading or editing Organization Not Found : <organization-id>: googleapi: Error 403: The caller does not have permission, forbidden`.
  - Check that your user have [Organization Admin](https://cloud.google.com/iam/docs/understanding-roles#resource-manager-roles) predefined role at the Organization level.
  -  If this is the case, try the following:
      ```
      gcloud auth application-default login
      gcloud auth list # <- confirm that correct account has a star next to it
      ```
  - Re-run `terraform` after.
- `Error: Error setting billing account "XXXXXX-XXXXXX-XXXXXX" for project "projects/some-project": googleapi: Error 400: Precondition check failed., failedPrecondition`. Most likely this is related to billing quota issue.
  - To confirm this, try `gcloud alpha billing projects link projects/some-project --billing-account XXXXXX-XXXXXX-XXXXXX`.
  - If output states `Cloud billing quota exceeded`, please request increase via [https://support.google.com/code/contact/billing_quota_increase](https://support.google.com/code/contact/billing_quota_increase).

## 0-bootstrap usage to deploy Jenkins

If you are using the `jenkins_bootstrap` sub-module, please see [README-Jenkins](./README-Jenkins.md) for requirements and instructions on how to run the 0-bootstrap step. Using Jenkins requires a few manual steps, including configuring connectivity with your current Jenkins Master environment.

## 0-bootstrap usage to deploy Cloud Build

1. Change into 0-bootstrap folder
1. Copy tfvars by running `cp terraform.example.tfvars terraform.tfvars` and update `terraform.tfvars` with values from your environment.
1. Run `terraform init`
1. Run `terraform plan` and review output
1. To run terraform-validator steps please follow the [instructions](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#install-terraform-validator) in the **Install Terraform Validator** section and install version `2021-03-22`. You will also need to rename the binary from `terraform-validator-<your-platform>` to `terraform-validator`.
    1. Run `terraform plan -input=false -out bootstrap.tfplan`
    1. Run `terraform show -json bootstrap.tfplan > bootstrap.json`
    1. Run `terraform-validator validate bootstrap.json --policy-path="../policy-library" --project <A-VALID-PROJECT-ID>` and check for violations (`<A-VALID-PROJECT-ID>` must be an existing project you have access to, this is necessary because Terraform-validator needs to link resources to a valid Google Cloud Platform project).
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
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| bucket\_prefix | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
| cloud\_source\_repos | List of Cloud Source Repositories created during bootstrap project build stage for use with Cloud Build. | `list(string)` | <pre>[<br>  "gcp-org",<br>  "gcp-environments",<br>  "gcp-networks",<br>  "gcp-projects"<br>]</pre> | no |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| folder\_prefix | Name prefix to use for folders created. | `string` | `"fldr"` | no |
| group\_billing\_admins | Google Group for GCP Billing Administrators | `string` | n/a | yes |
| group\_org\_admins | Google Group for GCP Organization Administrators | `string` | n/a | yes |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| org\_policy\_admin\_role | Additional Org Policy Admin role for admin group. You can use this for testing purposes. | `bool` | `false` | no |
| org\_project\_creators | Additional list of members to have project creator role across the organization. Prefix of group: user: or serviceAccount: is required. | `list(string)` | `[]` | no |
| parent\_folder | Optional - if using a folder for testing. | `string` | `""` | no |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudbuild\_project\_id | Project where CloudBuild configuration and terraform container image will reside. |
| csr\_repos | List of Cloud Source Repos created by the module, linked to Cloud Build triggers. |
| gcs\_bucket\_cloudbuild\_artifacts | Bucket used to store Cloud/Build artifacts in CloudBuild project. |
| gcs\_bucket\_tfstate | Bucket used for storing terraform state for foundations pipelines in seed project. |
| kms\_crypto\_key | KMS key created by the module. |
| kms\_keyring | KMS Keyring created by the module. |
| seed\_project\_id | Project where service accounts and core APIs will be enabled. |
| terraform\_sa\_name | Fully qualified name for privileged service account for Terraform. |
| terraform\_service\_account | Email for privileged service account for Terraform. |
| terraform\_validator\_policies\_repo | Cloud Source Repository created for terraform-validator policies. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

- [gcloud sdk](https://cloud.google.com/sdk/install) >= 206.0.0
- [Terraform](https://www.terraform.io/downloads.html) >= 0.13.6
  - You should use the same version in the manual steps during 0-bootstrap to avoid possible [Terraform State Snapshot Lock](https://github.com/hashicorp/terraform/issues/23290) errors caused by differences in terraform versions. This can usually be resolved with a version upgrade.
