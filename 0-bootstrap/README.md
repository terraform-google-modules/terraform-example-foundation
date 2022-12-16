# 0-bootstrap

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td>0-bootstrap (this file)</td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a <a href="../docs/GLOSSARY.md#foundation-cicd-pipeline">CI/CD Pipeline</a> for foundations code in subsequent
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

The purpose of this step is to bootstrap a Google Cloud organization, creating all the required resources & permissions to start using the Cloud Foundation Toolkit (CFT). This step also configures a [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline) for foundations code in subsequent stages. The [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline) can use either Cloud Build and Cloud Source Repos or Jenkins and your own Git repos (which might live on-premises).

## Prerequisites

To run the commands described in this document, you need to have the following
installed:

- The [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0 or later
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.3.0

**Note:** Make sure that you use version 1.3.0 of Terraform throughout this series. Otherwise, you might experience Terraform state snapshot lock errors.

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
1. For the user who will run the procedures in this document, granted the following roles:
   - The `roles/resourcemanager.organizationAdmin` role on the Google Cloud organization.
   - The `roles/orgpolicy.policyAdmin` role on the Google Cloud organization.
   - The `roles/billing.admin` role on the billing account.
   - The `roles/resourcemanager.folderCreator` role.

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

### Optional - Cloud Build access to on-prem

Please refer to [onprem](./onprem.md) for instructions on how to configure Cloud Build access to on-prem.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Deploying with Jenkins

If you are using the `jenkins_bootstrap` sub-module, see
[README-Jenkins](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README-Jenkins.md)
for requirements and instructions on how to run the 0-bootstrap step. Using
Jenkins requires a few manual steps, including configuring connectivity with
your current Jenkins manager (controller) environment.

## Deploying with Cloud Build

1. Clone [terraform-example-foundation](https://github.com/terraform-google-modules/terraform-example-foundation) into your local environment and navigate to the `0-bootstrap` folder.

   ```bash
   git clone https://github.com/terraform-google-modules/terraform-example-foundation.git

   cd terraform-example-foundation/0-bootstrap
   ```

1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment:

   ```bash
   mv terraform.example.tfvars terraform.tfvars
   ```

1. Use the helper script [validate-requirements.sh](../scripts/validate-requirements.sh) to validate your environment:

   ```bash
   ../scripts/validate-requirements.sh -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID> -u <END_USER_EMAIL>
   ```

   **Note:** The script is not able to validate if the user is in a Cloud Identity or Google Workspace group with the required roles.

1. Run `terraform init` and `terraform plan` and review the output.

   ```bash
   terraform init
   terraform plan -input=false -out bootstrap.tfplan
   ```

1. To run `gcloud beta terraform vet` steps please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Run the following commands and check for violations:

   ```bash
   export VET_PROJECT_ID=A-VALID-PROJECT-ID
   terraform show -json bootstrap.tfplan > bootstrap.json
   gcloud beta terraform vet bootstrap.json --policy-library="../policy-library" --project ${VET_PROJECT_ID}
   ```

   - *`A-VALID-PROJECT-ID`* must be an existing project you have access to, this is necessary because Terraform-validator needs to link resources to a valid Google Cloud Platform project.
1. Run `terraform apply`.

   ```bash
   terraform apply bootstrap.tfplan
   ```

1. Run `terraform output` to get the email address of the terraform service accounts that will be used to run manual steps for `shared` environments in steps `3-networks-dual-svpc`, `3-networks-hub-and-spoke`, and `4-projects` and the state bucket that will be used by step 4-projects.

   ```bash
   export network_step_sa=$(terraform output -raw networks_step_terraform_service_account_email)
   export projects_step_sa=$(terraform output -raw projects_step_terraform_service_account_email)
   export projects_gcs_bucket_tfstate=$(terraform output -raw projects_gcs_bucket_tfstate)

   echo "network step service account = ${network_step_sa}"
   echo "projects step service account = ${projects_step_sa}"
   echo "projects gcs bucket tfstate = ${projects_gcs_bucket_tfstate}"
   ```

1. Run `terraform output` to get the ID of your Cloud Build project:

   ```bash
   export cloudbuild_project_id=$(terraform output -raw cloudbuild_project_id)
   echo "cloud build project ID = ${cloudbuild_project_id}"
   ```

1. Copy the backend and update `backend.tf` with the name of your Google Cloud bucket for Terraform's state. Also update the `backend.tf` of all steps.

   ```bash
   export backend_bucket=$(terraform output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"

   export backend_bucket_projects=$(terraform output -raw projects_gcs_bucket_tfstate)
   echo "backend_bucket_projects = ${backend_bucket_projects}"

   cp backend.tf.example backend.tf
   cd ..

   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_PROJECTS_BACKEND/${backend_bucket_projects}/" $i; done

   cd 0-bootstrap
   ```

1. Re-run `terraform init`. When you're prompted, agree to copy Terraform state to Cloud Storage.

   ```bash
   terraform init
   ```

1. (Optional) Run `terraform plan` to verify that state is configured correctly. You should see no changes from the previous state.
1. Clone the policy repo and copy contents of policy-library to new repo. Clone the repo at the same level of the `terraform-example-foundation` folder, the next instructions assume that layout.

   ```bash
   cd ../..

   gcloud source repos clone gcp-policies --project=${cloudbuild_project_id}

   cd gcp-policies
   git checkout -b main
   cp -RT ../terraform-example-foundation/policy-library/ .
   ```

1. Commit changes and push your main branch to the policy repo.

   ```bash
   git add .
   git commit -m 'Initialize policy library repo'
   git push --set-upstream origin main
   ```

1. Navigate out of the repo.

   ```bash
   cd ..
   ```

1. Save `0-bootstrap` Terraform configuration to `gcp-bootstrap` source repository:

   ```bash
   gcloud source repos clone gcp-bootstrap --project=${cloudbuild_project_id}

   cd gcp-bootstrap
   git checkout -b plan
   mkdir -p envs/shared

   cp -RT ../terraform-example-foundation/0-bootstrap/ ./envs/shared
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh

   git add .
   git commit -m 'Initialize bootstrap repo'
   git push --set-upstream origin plan
   ```

1. You can now move to the instructions in the [1-org](../1-org/README.md) step.

**Note 1:** The stages after `0-bootstrap` use `terraform_remote_state` data source to read common configuration like the organization ID from the output of the `0-bootstrap` stage. They will [fail](../docs/TROUBLESHOOTING.md#error-unsupported-attribute) if the state is not copied to the Cloud Storage bucket.

**Note 2:** After the deploy, even if you did not receive the project quota error described in the [Troubleshooting guide](../docs/TROUBLESHOOTING.md#project-quota-exceeded), we recommend that you request 50 additional projects for the **projects step service account** created in this step.

## Running Terraform locally

If you deploy using Cloud Build, the bucket information is replaced in the state
backends as a part of the build process when the build is executed by Cloud Build.
If you want to execute Terraform locally, you need to add your Cloud
Storage bucket to the `backend.tf` files.
Each step has instructions for this change.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| bucket\_force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects. | `bool` | `false` | no |
| bucket\_prefix | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
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
| bootstrap\_step\_terraform\_service\_account\_email | Bootstrap Step Terraform Account |
| cloud\_build\_peered\_network\_id | The ID of the Cloud Build peered network. |
| cloud\_build\_private\_worker\_pool\_id | ID of the Cloud Build private worker pool. |
| cloud\_build\_worker\_peered\_ip\_range | The IP range of the peered service network. |
| cloud\_build\_worker\_range\_id | The Cloud Build private worker IP range ID. |
| cloud\_builder\_artifact\_repo | GAR Repo created to store TF Cloud Builder images. |
| cloudbuild\_project\_id | Project where CloudBuild configuration and terraform container image will reside. |
| common\_config | Common configuration data to be used in other steps. |
| csr\_repos | List of Cloud Source Repos created by the module, linked to Cloud Build triggers. |
| environment\_step\_terraform\_service\_account\_email | Environment Step Terraform Account |
| gcs\_bucket\_cloudbuild\_artifacts | Bucket used to store Cloud/Build artifacts in CloudBuild project. |
| gcs\_bucket\_cloudbuild\_logs | Bucket used to store Cloud/Build logs in CloudBuild project. |
| gcs\_bucket\_tfstate | Bucket used for storing terraform state for Foundations Pipelines in Seed Project. |
| group\_billing\_admins | Google Group for GCP Billing Administrators. |
| group\_org\_admins | Google Group for GCP Organization Administrators. |
| networks\_step\_terraform\_service\_account\_email | Networks Step Terraform Account |
| optional\_groups | List of Google Groups created that are optional to the Example Foundation steps. |
| organization\_step\_terraform\_service\_account\_email | Organization Step Terraform Account |
| projects\_gcs\_bucket\_tfstate | Bucket used for storing terraform state for stage 4-projects foundations pipelines in seed project. |
| projects\_step\_terraform\_service\_account\_email | Projects Step Terraform Account |
| required\_groups | List of Google Groups created that are required by the Example Foundation steps. |
| seed\_project\_id | Project where service accounts and core APIs will be enabled. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
