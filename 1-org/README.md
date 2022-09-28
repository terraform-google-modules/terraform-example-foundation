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
1. Security Command Center notifications require that you choose a Security Command Center tier and create and grant permissions for the Security Command Center service account as outlined in [Setting up Security Command Center](https://cloud.google.com/security-command-center/docs/quickstart-security-command-center)
1. Ensure that you have requested a sufficient project quota, as the Terraform scripts will create multiple projects from this point onwards. For more information, please [see the FAQ](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/FAQ.md#why-am-i-encountering-a-low-quota-with-projects-created-via-terraform-example-foundation).

**Note:** Make sure that you use version 1.0.0 of Terraform throughout this series, otherwise you might experience Terraform state snapshot lock errors.

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

**Note:** Currently, this module does not enable [bucket policy retention](https://cloud.google.com/storage/docs/bucket-lock) for organization logs, please, enable it if needed.

**Note:** You need to set variable `enable_hub_and_spoke` to `true` to be able to use the **Hub-and-Spoke** architecture detailed in the **Networking** section of the [Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke).

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

**Note:** This module creates a Security Command Center Notification.
The notification name must be unique in the organization.
The suggested name in the `terraform.tfvars` file is **scc-notify**.
To check if it already exists run:

```bash
org_id=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' | tr -d '"')
gcloud scc notifications describe "scc-notify" --organization=${org_id}
```

**Note:** This module manages contacts for notifications using [Essential Contacts](https://cloud.google.com/resource-manager/docs/managing-notification-contacts) API. This is assigned at the Parent Level (Organization or Folder) you configured to be inherited by all child resources. There is also possible to assign Essential Contacts directly to projects using project-factory [essential_contacts submodule](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/13.1.0/submodules/essential_contacts#example-usage). Billing notifications are assigned to be sent to `group_billing_admins` mandatory group. Legal and Suspension notifications are assigned to `group_org_admins` mandatory group. If you provide all other groups notifications will be configured like the table below:

| Group | Notification Category | Fallback Group |
|-------|-----------------------|----------------|
| gcp_network_viewer | Technical | Org Admins |
| gcp_platform_viewer | Product Updates and Technical | Org Admins |
| gcp_scc_admin | Product Updates and Security | Org Admins |
| gcp_security_reviewer | Security and Technical | Org Admins |

### Deploying with Cloud Build

1. Clone the policy repo based on the Terraform output from the previous section.
Clone the repo at the same level of the `terraform-example-foundation` folder, the next instructions assume that layout.
Run `terraform output cloudbuild_project_id` in the `0-bootstrap` folder to see the project again.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}
   gcloud source repos clone gcp-policies --project=${CLOUD_BUILD_PROJECT_ID}
   ```

1. Navigate into the repo and copy contents of policy-library to new repo.
   All subsequent steps assume you are running them
   from the gcp-policies directory. If you run them from another directory,
   adjust your copy paths accordingly.

   ```bash
   cd gcp-policies
   git checkout -b main
   cp -RT ../terraform-example-foundation/policy-library/ .
   ```

1. Commit changes and push your main branch to the new repo.

   ```bash
   git add .
   git commit -m 'Your message'
   git push --set-upstream origin main
   ```

1. Navigate out of the repo.

   ```bash
   cd ..
   ```

1. Clone the repo.

   ```bash
   gcloud source repos clone gcp-org --project=${CLOUD_BUILD_PROJECT_ID}
   ```

   - The message `warning: You appear to have cloned an empty repository.` is
   normal and can be ignored.
1. Navigate into the repo, change to a non-production branch and copy contents of foundation to new repo.
   All subsequent steps assume you are running them from the gcp-org directory.
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

1. Check if your organization already has an Access Context Manager Policy.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' | tr -d '"')
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```

1. Update the file with values from your environment and 0-bootstrap step. If the previous step showed a numeric value, make sure to un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"

   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars

   if [ -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i "s/#create_access_context_manager_access_policy/create_access_context_manager_access_policy/" ./envs/shared/terraform.tfvars; fi
   ```

1. Commit changes.

   ```bash
   git add .
   git commit -m 'Your message'
   ```

1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_.

   ```bash
   git push --set-upstream origin plan
   ```

1. Review the plan output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch. Because the _production_ branch is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.

   ```bash
   git checkout -b production
   git push origin production
   ```

1. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. You can now move to the instructions in the [2-environments](../2-environments/README.md) step.

**Troubleshooting:**
If you received a `PERMISSION_DENIED` error running the `gcloud access-context-manager` or the `gcloud scc notifications` commands you can append

```bash
--impersonate-service-account=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw organization_step_terraform_service_account_email)
```

to run the command as the Terraform Service Account.

### Deploying with Jenkins

1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-1-org>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the <YOUR_NEW_REPO-1-org> directory. If
   you run them from another directory, adjust your copy paths accordingly.
   ```
   cd YOUR_NEW_REPO_CLONE-1-org
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/1-org/ .
   ```
1. Copy contents of policy-library to new repo.
   ```
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   ```
1. Copy the Jenkinsfile script to the root of your new repository.\

   ```
   cp ../terraform-example-foundation/build/Jenkinsfile .
   ```
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the CI/CD project ID)
    ```
1. Copy Terraform wrapper script to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Check if your organization already has an Access Context Manager Policy.
   ```
   gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"
   ```
1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars` and update the file with values from your environment and bootstrap. You can re-run `terraform output` in the 0-bootstrap directory to find these values. Make sure that `default_region` is set to a valid [BigQuery dataset region](https://cloud.google.com/bigquery/docs/locations). Also, if the previous step showed a numeric value, make sure to un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch.
    - Assuming you configured an automatic trigger in your Jenkins Controller (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](https://www.jenkins.io) for more details.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your Controller's web UI.
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Controller's web UI. (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).

### Running Terraform locally

1. Change into `1-org` folder, copy the Terraform wrapper script and ensure it can be executed.

   ```bash
   cd 1-org
   cp ../build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Change into `envs/shared` folder and rename `terraform.example.tfvars` to `terraform.tfvars`.

   ```bash
   cd envs/shared
   mv terraform.example.tfvars terraform.tfvars
   ```

1. Update the file with values from your environment and 0-bootstrap output.
1. Use `terraform output` to get the backend bucket value from 0-bootstrap output.

   ```bash
   export backend_bucket=$(terraform -chdir="../../../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"

   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./terraform.tfvars
   ```

1. Also update `backend.tf` with your backend bucket from 0-bootstrap output.

   ```bash
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   ```

1. Return to `1-org` folder

   ```bash
   cd ../../../1-org
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
