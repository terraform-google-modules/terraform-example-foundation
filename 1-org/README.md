# 1-org

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="../0-bootstrap">0-bootstrap</a></td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a <a href="../docs/GLOSSARY.md#foundation-cicd-pipeline">CI/CD Pipeline</a> for foundations code in subsequent
stages.</td>
</tr>
<tr>
<td>1-org (this file)</td>
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
<td>Sets up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td><a href="../5-app-infra">5-app-infra</a></td>
<td>Deploy a simple <a href="https://cloud.google.com/compute/">Compute Engine</a> instance in one of the business unit projects using the infra pipeline set up in 4-projects.</td>
</tr>
</tbody>
</table>

For an overview of the architecture and the parts, see the
[terraform-example-foundation README](https://github.com/terraform-google-modules/terraform-example-foundation).

## Purpose

The purpose of this step is to set up top-level shared folders, monitoring and networking projects, organization-level logging, and baseline security settings through organizational policies.

## Prerequisites

1. 0-bootstrap executed successfully.
1. Security Command Center notifications require that you choose a Security Command Center tier and create and grant permissions for the Security Command Center service account as outlined in [Setting up Security Command Center](https://cloud.google.com/security-command-center/docs/quickstart-security-command-center).

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Disclaimer:** This step enables [Data Access logs](https://cloud.google.com/logging/docs/audit#data-access) for all services in your organization.
Enabling Data Access logs might result in your project being charged for the additional logs usage.
For details on costs you might incur, go to [Pricing](https://cloud.google.com/stackdriver/pricing).
You can choose not to enable the Data Access logs by setting variable `data_access_logs_enabled` to false.

**Note:** This module creates a sink to export all logs to Google Storage and Log Bucket. It also creates sinks to export a subset of security related logs
to Bigquery and Pub/Sub. This will result in additional charges for those copies of logs. For Log Bucket destination, logs retained for the default retention period (30 days) [don't incur a storage cost](https://cloud.google.com/stackdriver/pricing#:~:text=Logs%20retained%20for%20the%20default%20retention%20period%20don%27t%20incur%20a%20storage%20cost.).
You can change the filters & sinks by modifying the configuration in `envs/shared/log_sinks.tf`.

**Note:** This module implements but does not enable by default [bucket policy retention](https://cloud.google.com/storage/docs/bucket-lock) for organization logs. Please, enable it if needed by configuring variable `log_export_storage_retention_policy`.

**Note:** This module implements but does not enable by default [object versioning](https://cloud.google.com/storage/docs/object-versioning) for organization logs. Please, enable it if needed by setting variable `audit_logs_table_delete_contents_on_destroy` to true.

**Note:** Bucket policy retention and object versioning are **mutually exclusive**.

**Note:** You need to set variable `enable_hub_and_spoke` to `true` to be able to use the **Hub-and-Spoke** architecture detailed in the **Networking** section of the [Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke).

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

**Note:** This module manages contacts for notifications using [Essential Contacts](https://cloud.google.com/resource-manager/docs/managing-notification-contacts) API. This is assigned at the Parent Level (Organization or Folder) you configured to be inherited by all child resources. There is also possible to assign Essential Contacts directly to projects using project-factory [essential_contacts submodule](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/13.1.0/submodules/essential_contacts#example-usage). Billing notifications are assigned to be sent to `group_billing_admins` mandatory group. Legal and Suspension notifications are assigned to `group_org_admins` mandatory group. If you provide all other groups notifications will be configured like the table below:

| Group | Notification Category | Fallback Group |
|-------|-----------------------|----------------|
| gcp_network_viewer | Technical | Org Admins |
| gcp_platform_viewer | Product Updates and Technical | Org Admins |
| gcp_scc_admin | Product Updates and Security | Org Admins |
| gcp_security_reviewer | Security and Technical | Org Admins |

**Note:** This module creates and applies [Tags](https://cloud.google.com/resource-manager/docs/tags/tags-overview) to common and bootstrap folders. These tags are also applied to environment folders of step [2-environments](../2-environments/README.md). You can create your own tags by editing `local.tags` map in `tags.tf` and following the commented template. The following table lists details about tags applied to resources:

| Resource | Type | Step | Tag Key | Tag Value |
|----------|------|------|---------|-----------|
| bootstrap | folder | 1-org | environment | bootstrap |
| common | folder | 1-org | environment | production |
| enviroment development | folder | [2-environments](../2-environments/README.md) | environment | development |
| enviroment non-production | folder | [2-environments](../2-environments/README.md) | environment | non-production |
| enviroment production | folder | [2-environments](../2-environments/README.md) | environment | production |

### Deploying with Cloud Build

1. Clone the `gcp-org` repo based on the Terraform output from the `0-bootstrap` step.
Clone the repo at the same level of the `terraform-example-foundation` folder, the following instructions assume this layout.
Run `terraform output cloudbuild_project_id` in the `0-bootstrap` folder to get the Cloud Build Project ID.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   gcloud source repos clone gcp-org --project=${CLOUD_BUILD_PROJECT_ID}
   ```

   **Note:** The message `warning: You appear to have cloned an empty repository.` is
   normal and can be ignored.

1. Navigate into the repo, change to a non-production branch and copy contents of foundation to new repo.
   All subsequent steps assume you are running them from the `gcp-org` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-org
   git checkout -b plan

   cp -RT ../terraform-example-foundation/1-org/ .
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars`

   ```bash
   mv ./envs/shared/terraform.example.tfvars ./envs/shared/terraform.tfvars
   ```

1. Check if a Security Command Center Notification with the default name, **scc-notify**, already exists. If it exists, choose a different value for the `scc_notification_name` variable in the `./envs/shared/terraform.tfvars` file.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' --raw-output)
   gcloud scc notifications describe "scc-notify" --organization=${ORGANIZATION_ID}
   ```

1. Check if your organization already has an Access Context Manager Policy.

   ```bash
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```

1. Update the `envs/shared/terraform.tfvars` file with values from your environment and 0-bootstrap step. If the previous step showed a numeric value, make sure to un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars

   if [ ! -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i "s=//create_access_context_manager_access_policy=create_access_context_manager_access_policy=" ./envs/shared/terraform.tfvars; fi
   ```

1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize org repo'
   ```

1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_. Review the plan output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git push --set-upstream origin plan
   ```

1. Merge changes to production branch. Because the _production_ branch is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b production
   git push origin production
   ```

1. You can now move to the instructions in the [2-environments](../2-environments/README.md) step.

**Troubleshooting:**
If you received a `PERMISSION_DENIED` error running the `gcloud access-context-manager` or the `gcloud scc notifications` commands you can append

```bash
--impersonate-service-account=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw organization_step_terraform_service_account_email)
```

to run the command as the Terraform Service Account.

### Deploying with Jenkins

See `0-bootstrap` [README-Jenkins.md](../0-bootstrap/README-Jenkins.md#deploying-step-1-org)

### Running Terraform locally

1. The next instructions assume that you are at the same level of the `terraform-example-foundation` folder.
Change into `1-org` folder, copy the Terraform wrapper script and ensure it can be executed.

   ```bash
   cd terraform-example-foundation/1-org
   cp ../build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars`

   ```bash
   mv ./envs/shared/terraform.example.tfvars ./envs/shared/terraform.tfvars
   ```

1. Check if a Security Command Center Notification with the default name, **scc-notify**, already exists. If it exists, choose a different value for the `scc_notification_name` variable in the `./envs/shared/terraform.tfvars` file.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../0-bootstrap/" output -json common_config | jq '.org_id' --raw-output)
   gcloud scc notifications describe "scc-notify" --organization=${ORGANIZATION_ID}
   ```

1. Check if your organization already has an Access Context Manager Policy.

   ```bash
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```

1. Update the `envs/shared/terraform.tfvars` file with values from your environment and 0-bootstrap step. If the previous step showed a numeric value, make sure to un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars

   if [ ! -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i "s=//create_access_context_manager_access_policy=create_access_context_manager_access_policy=" ./envs/shared/terraform.tfvars; fi
   ```

We will now deploy our environment (production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponding to a branch is the repository for 1-org step and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.

1. Use `terraform output` to get the Cloud Build project ID and the organization step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../0-bootstrap/" output -raw organization_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output.

   ```bash
   ./tf-wrapper.sh init production
   ./tf-wrapper.sh plan production
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```

1. Run `apply` production.

   ```bash
   ./tf-wrapper.sh apply production
   ```

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan production` before run `./tf-wrapper.sh apply production`.

Before executing the next stages, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

```bash
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```
