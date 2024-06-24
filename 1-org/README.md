# 1-org

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture that is described in the
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
<td>Sets up top-level shared folders, networking projects, and
organization-level logging, and sets baseline security settings through
organizational policy.</td>
</tr>
<tr>
<td><a href="../2-environments"><span style="white-space: nowrap;">2-environments</span></a></td>
<td>Sets up development, nonproduction, and production environments within the
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
hub-and-spoke network model. It also sets up the global DNS hub.</td>
</tr>
</tr>
<tr>
<td><a href="../4-projects">4-projects</a></td>
<td>Sets up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td><a href="../5-app-infra">5-app-infra</a></td>
<td>Deploy a <a href="https://cloud.google.com/compute/">Compute Engine</a> instance in one of the business unit projects using the infra pipeline set up in 4-projects.</td>
</tr>
</tbody>
</table>

For an overview of the architecture and the parts, see the
[terraform-example-foundation README](https://github.com/terraform-google-modules/terraform-example-foundation).

## Purpose

The purpose of this step is to set up top-level shared folders, networking projects, organization-level logging, and baseline security settings through organizational policies.

## Prerequisites

1. Run 0-bootstrap.
1. To enable Security Command Center notifications, choose a Security Command Center tier and create and grant permissions for the Security Command Center service account as described in [Setting up Security Command Center](https://cloud.google.com/security-command-center/docs/quickstart-security-command-center).

### Troubleshooting

See [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Disclaimer:** This step enables [Data Access logs](https://cloud.google.com/logging/docs/audit#data-access) for all services in your organization.
Enabling Data Access logs might result in your project being charged for the additional logs usage.
For details on costs you might incur, go to [Pricing](https://cloud.google.com/stackdriver/pricing).
You can choose not to enable the Data Access logs by setting the variable `data_access_logs_enabled` to false.

Consider the following:

- This module creates a sink to export all logs to a Cloud Logging bucket. It also creates sinks to export a subset of security-related logs
to Bigquery and Pub/Sub. This will result in additional charges for those copies of logs. For the log bucket destination, logs retained for the default retention period (30 days) [don't incur a storage cost](https://cloud.google.com/stackdriver/pricing#:~:text=Logs%20retained%20for%20the%20default%20retention%20period%20don%27t%20incur%20a%20storage%20cost.).
  You can change the filters and sinks by modifying the configuration in `envs/shared/log_sinks.tf`.

- This module implements but does not enable [bucket policy retention](https://cloud.google.com/storage/docs/bucket-lock) for organization logs. If needed, enable a retention policy by configuring the `log_export_storage_retention_policy` variable.

- This module implements but does not enable [object versioning](https://cloud.google.com/storage/docs/object-versioning) for organization logs. If needed, enable object versioning by setting the `log_export_storage_versioning` variable to true.

- Bucket policy retention and object versioning are **mutually exclusive**.

- To use the **hub-and-spoke** architecture described in the **Networking** section of the [Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke), set the `enable_hub_and_spoke` variable to `true`.

- If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is required for Linux, but causes problems for MacOS.

- This module manages contacts for notifications using [Essential Contacts](https://cloud.google.com/resource-manager/docs/managing-notification-contacts). Essential Contacts are assigned at the parent (organization or folder) that you configure to be inherited by all child resources. You can also assign Essential Contacts directly to projects using the project-factory [essential_contacts submodule](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/13.1.0/submodules/essential_contacts#example-usage). Billing notifications are sent to the `group_billing_admins` mandatory group. Legal and suspension notifications are sent to the `group_org_admins` mandatory group. If you provide all other groups, notifications are configured as described in the following table.

| Group | Notification Category | Fallback Group |
|-------|-----------------------|----------------|
| gcp_network_viewer | Technical | Org Admins |
| gcp_platform_viewer | Product updates and technical | Org Admins |
| gcp_scc_admin | Product updates and security | Org Admins |
| gcp_security_reviewer | Security and technical | Org Admins |

This module creates and applies [tags](https://cloud.google.com/resource-manager/docs/tags/tags-overview) to common, network, and bootstrap folders. These tags are also applied to environment folders of step [2-environments](../2-environments/README.md). You can create your own tags by editing the `local.tags` map in `tags.tf` and following the commented template. The following table describes details about the tags that are applied to resources:

| Resource | Type | Step | Tag Key | Tag Value |
|----------|------|------|---------|-----------|
| bootstrap | folder | 1-org | environment | bootstrap |
| common | folder | 1-org | environment | production |
| network | folder | 1-org | environment | production |
| enviroment development | folder | [2-environments](../2-environments/README.md) | environment | development |
| enviroment nonproduction | folder | [2-environments](../2-environments/README.md) | environment | nonproduction |
| enviroment production | folder | [2-environments](../2-environments/README.md) | environment | production |

### Deploying with Cloud Build

1. Clone the `gcp-org` repo based on the Terraform output from the `0-bootstrap` step.
Clone the repo at the same level of the `terraform-example-foundation` folder.
If required, run `terraform output cloudbuild_project_id` in the `0-bootstrap` folder to get the Cloud Build Project ID.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   gcloud source repos clone gcp-org --project=${CLOUD_BUILD_PROJECT_ID}
   ```

   **Note:** The message `warning: You appear to have cloned an empty repository.` is
   normal and can be ignored.

1. Navigate into the repo, change to a nonproduction branch, and copy the contents of foundation to the new repo.
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

1. Check if a Security Command Center notification with the default name, **scc-notify**, already exists. If it exists, choose a different value for the `scc_notification_name` variable in the `./envs/shared/terraform.tfvars` file.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' --raw-output)
   gcloud scc notifications describe "scc-notify" --organization=${ORGANIZATION_ID}
   ```

1. Check if your organization already has an Access Context Manager policy.

   ```bash
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```

1. Update the `envs/shared/terraform.tfvars` file with values from your environment and 0-bootstrap step. If the previous step showed a numeric value, un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars

   if [ ! -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i'' -e "s=//create_access_context_manager_access_policy=create_access_context_manager_access_policy=" ./envs/shared/terraform.tfvars; fi
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

1. Merge changes to the production branch. Because the _production_ branch is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b production
   git push origin production
   ```

1. Proceed to the [2-environments](../2-environments/README.md) step.

**Troubleshooting:**
If you received a `PERMISSION_DENIED` error while running the `gcloud access-context-manager` or the `gcloud scc notifications` commands, you can append the following to run the command as the Terraform service account:

```bash
--impersonate-service-account=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw organization_step_terraform_service_account_email)
```

### Deploying with Jenkins

See `0-bootstrap` [README-Jenkins.md](../0-bootstrap/README-Jenkins.md#deploying-step-1-org).

### Deploying with GitHub Actions

See `0-bootstrap` [README-GitHub.md](../0-bootstrap/README-GitHub.md#deploying-step-1-org).

### Running Terraform locally

1. The next instructions assume that you are at the same level of the `terraform-example-foundation` folder.
Change into the `1-org` folder, copy the Terraform wrapper script, and ensure it can be executed.

   ```bash
   cd terraform-example-foundation/1-org
   cp ../build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars`.

   ```bash
   mv ./envs/shared/terraform.example.tfvars ./envs/shared/terraform.tfvars
   ```

1. Check if a Security Command Center notification with the default name, **scc-notify**, already exists. If it exists, choose a different value for the `scc_notification_name` variable in the `./envs/shared/terraform.tfvars` file.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../0-bootstrap/" output -json common_config | jq '.org_id' --raw-output)
   gcloud scc notifications describe "scc-notify" --organization=${ORGANIZATION_ID}
   ```

1. Check if your organization already has an Access Context Manager policy.

   ```bash
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```

1. Update the `envs/shared/terraform.tfvars` file with values from your environment and 0-bootstrap step. If the previous step showed a numeric value, un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars

   if [ ! -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i'' -e "s=//create_access_context_manager_access_policy=create_access_context_manager_access_policy=" ./envs/shared/terraform.tfvars; fi
   ```

You can now deploy your environment (production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool, each environment corresponding to a branch is the repository for 1-org step and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.

1. Use `terraform output` to get the Cloud Build project ID and the organization step Terraform service account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../0-bootstrap/" output -raw organization_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review the output.

   ```bash
   ./tf-wrapper.sh init production
   ./tf-wrapper.sh plan production
   ```

1. Run `validate` and resolve any violations.

   ```bash
   ./tf-wrapper.sh validate production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```

1. Run `apply production`.

   ```bash
   ./tf-wrapper.sh apply production
   ```

If you receive any errors or made any changes to the Terraform config or `terraform.tfvars`, re-run `./tf-wrapper.sh plan production` before you run `./tf-wrapper.sh apply production`.

Before executing the next stages, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

```bash
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```
