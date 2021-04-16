# 0-bootstrap

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf)
(PDF). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td>0-bootstrap (this file)</td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a CI/CD pipeline for foundations code in subsequent
stages.</td>
</tr>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/1-org">1-org</a></td>
<td>Sets up top level shared folders, monitoring and networking projects, and
organization-level logging, and sets baseline security settings through
organizational policy.</td>
</tr>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/2-environments">2-environments</a></td>
<td>Sets up development, non-production, and production environments within the
Google Cloud organization that you've created.</td>
</tr>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/3-networks">3-networks</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect, and baseline firewall rules for each environment. Also sets
up the global DNS hub.</td>
</tr>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/4-projects">4-projects</a></td>
<td>Set up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
</tbody>
</table>

For an overview of the architecture and the parts, see the
[terraform-example-foundation README](https://github.com/terraform-google-modules/terraform-example-foundation)
file.

## Purpose

The purpose of this step is to bootstrap a GCP organization, creating all the required resources & permissions to start using the Cloud Foundation Toolkit (CFT). This step also configures a CI/CD pipeline for foundations code in subsequent stages. The CI/CD pipeline can use either Cloud Build & Cloud Source Repos or Jenkins & your own Git repos (which might live on-prem).

## Prerequisites

To run the commands described in this document, you need to have the following
installed:

-  The [Google Cloud SDK](https://cloud.google.com/sdk/install) version
   206.0.0 or later
-  [Terraform](https://www.terraform.io/downloads.html) version 0.13.6 or later.

Note: Make sure that you use the same version of Terraform throughout this
series. Otherwise, you might experience Terraform state snapshot lock errors.

Also make sure that you've done the following:

1. Set up a Google Cloud
   [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
1. Set up a Google Cloud
   [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
1. Created Cloud Identity or Google Workspace (formerly G Suite) groups for
   organization and billing admins.
1. Added the user who will use Terraform to the `group_org_admins` group.
   They must be in this group or they won't have
   `roles/resourcemanager.projectCreator` access.
1. For the user who will run the procedures in this document, granted the
   following roles:
   -  The `roles/resourcemanager.organizationAdmin` role on the Google
      Cloud organization.
   -  The `roles/billing.admin` role on the billing account.
   -  The `roles/resourcemanager.folderCreator` role.

If other users need to be able to run these procedures, add them to the group
represented by the `org_project_creators` variable.
For more information about the permissions that are required and the resources
that are created, see the organization bootstrap module
[documentation.](https://github.com/terraform-google-modules/terraform-google-bootstrap)

## Deploying with Jenkins

If you are using the `jenkins_bootstrap` sub-module, see
[README-Jenkins](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README-Jenkins.md)
for requirements and instructions on how to run the 0-bootstrap step. Using
Jenkins requires a few manual steps, including configuring connectivity with
your current Jenkins manager (master) environment.

## Deploying with Cloud Build

1. Go to the `0-bootstrap` folder.
1. Copy the `tfvars` file:

   ```
   cp terraform.example.tfvars terraform.tfvars
   ```

1. Update the `terraform.tfvars` file with values from your environment.
1. Run `terraform init`.
1. Run `terraform plan` and review the output.
1. To run terraform-validator steps please follow the [instructions](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#install-terraform-validator) in the **Install Terraform Validator** section and install version `2021-03-22`. You will also need to rename the binary from `terraform-validator-<your-platform>` to `terraform-validator`.
    1. Run `terraform plan -input=false -out bootstrap.tfplan`
    1. Run `terraform show -json bootstrap.tfplan > bootstrap.json`
    1. Run `terraform-validator validate bootstrap.json --policy-path="../policy-library" --project <A-VALID-PROJECT-ID>` and check for violations (`<A-VALID-PROJECT-ID>` must be an existing project you have access to, this is necessary because Terraform-validator needs to link resources to a valid Google Cloud Platform project).
1. Run `terraform apply`.
1. Run `terraform output gcs_bucket_tfstate` to get your Google Cloud bucket
   from the previous step.
1. Copy the backend:

   ```
   cp backend.tf.example backend.tf
   ```

1. Update `backend.tf` with the name of your Cloud Storage bucket.
1. Run `terraform output terraform_sa_email` to get the email address of the
   admin. You need this address in a later procedure.
1. Re-run `terraform init`. When you're prompted, agree to copy state to
   Cloud Storage.
1. (Optional) Run `terraform apply` to verify that state is configured
   correctly. You should see no changes from the previous state.

## Running Terraform locally

If you deploy using Cloud Build, the bucket information is replaced in the state
backends as a part of the build process when the build is executed by Cloud
Build. If you want to execute Terraform locally, you need to add your Cloud
Storage bucket to the `backend.tf` files. You can update all of these files with
the following steps:

1. Go to the `terraform-example-foundation` directory.
1. Run the following command:

   ```
   for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/GCS_BUCKET_NAME/' $i; done
   ```

   where `GCS_BUCKET_NAME` is the name of your bucket from the steps you ran
   earlier.

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

## Troubleshooting

When you run the examples in this repository, you might see the following errors
during a Terraform `apply` command:

- `Error code 8, message: The project cannot be created because you have exceeded
   your allotted project quota`.

  - This message means you have reached your [project creation
     quota](https://support.google.com/cloud/answer/6330231). In this case, you can
    use the
    [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase)
    form to request a quota increase. In the support form, for **Email addresses
    that will be used to create projects**, use the `terraform_sa_email` address
    that's created in the organization bootstrap module. If you see other quota
    errors, see the [Quota documentation](https://cloud.google.com/docs/quota).

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
