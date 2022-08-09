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
<td><a href="../1-org">1-org</a></td>
<td>Sets up top level shared folders, monitoring and networking projects, and
organization-level logging, and sets baseline security settings through
organizational policy.</td>
</tr>
<tr>
<td><a href="../2-environments"><span style="white-space: nowrap;">2-environments</span></a></td>
<td>Sets up development, non-production, and production environments within the
Google Cloud organization that you've created.</td>
</tr>
<tr>
<td><a href="../3-networks-dual-svpc">3-networks-dual-svpc</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect, and baseline firewall rules for each environment. It also sets
up the global DNS hub.</td>
</tr>
<tr>
<td><a href="../3-networks-hub-and-spoke">3-networks-hub-and-spoke</a></td>
<td>Sets up base and restricted shared VPCs with all the default configuration
found on step 3-networks-dual-svpc, but here the architecture will be based on the
Hub and Spoke network model. It also sets up the global DNS hub</td>
</tr>
</tr>
<tr>
<td><a href="../4-projects">4-projects</a></td>
<td>Set up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td><a href="../5-app-infra">5-app-infra</a></td>
<td>Deploy a simple <a href="https://cloud.google.com/compute/">Compute Engine</a> instance in one of the business unit projects using the infra pipeline set up in 4-projects.</td>
</tr>
</tbody>
</table>

For an overview of the architecture and the parts, see the
[terraform-example-foundation README](https://github.com/terraform-google-modules/terraform-example-foundation)
file.

## Purpose

The purpose of this step is to bootstrap a Google Cloud organization, creating all the required resources & permissions to start using the Cloud Foundation Toolkit (CFT). This step also configures a CI/CD pipeline for foundations code in subsequent stages. The CI/CD pipeline can use either Cloud Build and Cloud Source Repos or Jenkins and your own Git repos (which might live on-premises).

## Prerequisites

To run the commands described in this document, you need to have the following
installed:

- The [Google Cloud SDK](https://cloud.google.com/sdk/install) version 391.0.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7.
- An existing project which the user has access to be used by terraform-validator.

**Note:** Make sure that you use the same version of Terraform throughout this series. Otherwise, you might experience Terraform state snapshot lock errors.

Also make sure that you've done the following:

1. Set up a Google Cloud
   [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
1. Set up a Google Cloud
   [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
1. Created Cloud Identity or Google Workspace (formerly G Suite) groups for
   organization and billing admins.
1. Added the user who will use Terraform to the `group_org_admins` group.
   They must be in this group, or they won't have
   `roles/resourcemanager.projectCreator` access.
1. For the user who will run the procedures in this document, granted the
   following roles:
   -  The `roles/resourcemanager.organizationAdmin` role on the Google
      Cloud organization.
   -  The `roles/orgpolicy.policyAdmin` role on the Google Cloud organization.
   -  The `roles/billing.admin` role on the billing account.
   -  The `roles/resourcemanager.folderCreator` role.

If other users need to be able to run these procedures, add them to the group
represented by the `org_project_creators` variable.
For more information about the permissions that are required, and the resources
that are created, see the organization bootstrap module
[documentation.](https://github.com/terraform-google-modules/terraform-google-bootstrap)

### Optional - Automatic creation of Google Cloud Identity groups

Google Cloud Identity groups are used for [authentication and access management](https://cloud.google.com/architecture/security-foundations/authentication-authorization) in the foundation.

To enable automatic creation of the [required groups](https://cloud.google.com/architecture/security-foundations/authentication-authorization#users_and_groups) you need to:

- Have an existing project for Cloud Identity API billing.
- Enable the Cloud Identity API(`cloudidentity.googleapis.com`) on the billing project.
- Grant role `roles/serviceusage.serviceUsageConsumer` to the user running Terraform on the billing project.
- Provide values for the groups and billing project in the variable `groups`.

All groups in the `groups.required_groups` are required.

All groups in the `groups.optional_groups` are optional.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Deploying with Jenkins

If you are using the `jenkins_bootstrap` sub-module, see
[README-Jenkins](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README-Jenkins.md)
for requirements and instructions on how to run the 0-bootstrap step. Using
Jenkins requires a few manual steps, including configuring connectivity with
your current Jenkins manager (controller) environment.

## Deploying with Cloud Build

1. Go to the `0-bootstrap` folder.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment:
    ```
    mv terraform.example.tfvars terraform.tfvars
    ```
1. Run `terraform init`.
1. Run `terraform plan` and review the output.
1. To run terraform-validator steps please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
    1. Run `terraform plan -input=false -out bootstrap.tfplan`
    1. Run `terraform show -json bootstrap.tfplan > bootstrap.json`
    1. Run `gcloud beta terraform vet bootstrap.json --policy-library="../policy-library" --project <A-VALID-PROJECT-ID>` and check for violations (`<A-VALID-PROJECT-ID>` must be an existing project you have access to, this is necessary because Terraform-validator needs to link resources to a valid Google Cloud Platform project).
1. Run `terraform apply`.
1. Run `terraform output terraform_service_account` to get the email address of the admin. You need this address in a later procedure.
1. Run `terraform output gcs_bucket_tfstate` to get your Google Cloud bucket name from Terraform's state.
1. Copy the backend:
   ```
   cp backend.tf.example backend.tf
   ```
1. Update `backend.tf` with the name of your Cloud Storage bucket.
1. Re-run `terraform init`. When you're prompted, agree to copy state to
   Cloud Storage.
1. (Optional) Run `terraform apply` to verify that state is configured
   correctly. You should see no changes from the previous state.

**Note 1:** The output of terraform-validator will contain lines like

```
ERROR: logging before flag.Parse: I0413 13:49:49.852283 6380 convert.go:189] unsupported resource: google_billing_account_iam_member
```

or

```
ERROR: logging before flag.Parse: I0413 13:49:49.852290 6380 convert.go:183] unknown resource: random_id
```

These are warnings for resources that are not yet supported or not known by terraform-validator, these are not actual errors.

**Note 2:** After the deploy, even if you did not receive the project quota error described in the [Troubleshooting guide](../docs/TROUBLESHOOTING.md#project-quota-exceeded), we recommend that you request 50 additional projects for the service account, `terraform_service_account`, created in this step.

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
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| group\_billing\_admins | Google Group for GCP Billing Administrators | `string` | n/a | yes |
| group\_org\_admins | Google Group for GCP Organization Administrators | `string` | n/a | yes |
| groups | Contain the details of the Groups to be created. | <pre>object({<br>    create_groups   = bool<br>    billing_project = string<br>    required_groups = object({<br>      group_org_admins           = string<br>      group_billing_admins       = string<br>      billing_data_users         = string<br>      audit_data_users           = string<br>      monitoring_workspace_users = string<br>    })<br>    optional_groups = object({<br>      gcp_platform_viewer      = string<br>      gcp_security_reviewer    = string<br>      gcp_network_viewer       = string<br>      gcp_scc_admin            = string<br>      gcp_global_secrets_admin = string<br>      gcp_audit_viewer         = string<br>    })<br>  })</pre> | <pre>{<br>  "billing_project": "",<br>  "create_groups": false,<br>  "optional_groups": {<br>    "gcp_audit_viewer": "",<br>    "gcp_global_secrets_admin": "",<br>    "gcp_network_viewer": "",<br>    "gcp_platform_viewer": "",<br>    "gcp_scc_admin": "",<br>    "gcp_security_reviewer": ""<br>  },<br>  "required_groups": {<br>    "audit_data_users": "",<br>    "billing_data_users": "",<br>    "group_billing_admins": "",<br>    "group_org_admins": "",<br>    "monitoring_workspace_users": ""<br>  }<br>}</pre> | no |
| initial\_group\_config | Define the group configuration when it are initialized. Valid values are: WITH\_INITIAL\_OWNER, EMPTY and INITIAL\_GROUP\_CONFIG\_UNSPECIFIED. | `string` | `"WITH_INITIAL_OWNER"` | no |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| org\_policy\_admin\_role | Additional Org Policy Admin role for admin group. You can use this for testing purposes. | `bool` | `false` | no |
| org\_project\_creators | Additional list of members to have project creator role across the organization. Prefix of group: user: or serviceAccount: is required. | `list(string)` | `[]` | no |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. | `string` | `""` | no |
| project\_prefix | Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters. | `string` | `"prj"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudbuild\_project\_id | Project where CloudBuild configuration and terraform container image will reside. |
| csr\_repos | List of Cloud Source Repos created by the module, linked to Cloud Build triggers. |
| environment\_step\_terraform\_service\_account\_email | Environment Step Terraform Account |
| gcs\_bucket\_cloudbuild\_artifacts | Bucket used to store Cloud/Build artifacts in CloudBuild project. |
| gcs\_bucket\_tfstate | Bucket used for storing terraform state for foundations pipelines in seed project. |
| networks\_step\_terraform\_service\_account\_email | Networks Step Terraform Account |
| optional\_groups | List of Google Groups created that are optional to the Example Foundation steps. |
| organization\_step\_terraform\_service\_account\_email | Organization Step Terraform Account |
| projects\_step\_terraform\_service\_account\_email | Projects Step Terraform Account |
| required\_groups | List of Google Groups created that are required by the Example Foundation steps. |
| seed\_project\_id | Project where service accounts and core APIs will be enabled. |
| terraform\_sa\_name | Fully qualified name for privileged service account for Terraform. |
| terraform\_service\_account | Email for privileged service account for Terraform. |
| terraform\_validator\_policies\_repo | Cloud Source Repository created for terraform-validator policies. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
