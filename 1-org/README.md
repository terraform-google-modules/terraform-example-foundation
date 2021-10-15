# 1-org

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf)
(PDF). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="../0-bootstrap">0-bootstrap</a></td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a CI/CD pipeline for foundations code in subsequent
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
<td><a href="../3-networks">3-networks</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect, and baseline firewall rules for each environment. It also sets
up the global DNS hub.</td>
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
2. Cloud Identity / Google Workspace group for security admins.
3. Membership in the security admins group for the user running Terraform.
4. Security Command Center notifications require that you choose a Security Command Center tier and create and grant permissions for the Security Command Center service account as outlined in [Setting up Security Command Center](https://cloud.google.com/security-command-center/docs/quickstart-security-command-center)
5. Ensure that you have requested for sufficient projects quota, as the Terraform scripts will create multiple projects from this point onwards. For more information, please [see the FAQ](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/FAQ.md).

**Note:** Make sure that you use the same version of Terraform throughout this series, otherwise you might experience Terraform state snapshot lock errors.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Disclaimer:** This step enables [Data Access logs](https://cloud.google.com/logging/docs/audit#data-access) for all services in your organization.
Enabling Data Access logs might result in your project being charged for the additional logs usage.
For details on costs you might incur, go to [Pricing](https://cloud.google.com/stackdriver/pricing).
You can choose not to enable the Data Access logs by setting variable `data_access_logs_enabled` to false.

**Note:** This module creates a sink to export all logs to Google Storage. It also creates sinks to export a subset of security related logs
to Bigquery and Pub/Sub. This will result in additional charges for those copies of logs.
You can change the filters & sinks by modifying the configuration in `envs/shared/log_sinks.tf`.

**Note:** Currently, this module does not enable [bucket policy retention](https://cloud.google.com/storage/docs/bucket-lock) for organization logs, please, enable it if needed.

**Note:** It is possible to enable an organization policy for [OS Login](https://cloud.google.com/compute/docs/oslogin/manage-oslogin-in-an-org) with this module.
OS Login has some [limitations](https://cloud.google.com/compute/docs/instances/managing-instance-access#limitations).
If those limitations do not apply to your workload/environment, you can choose to enable the OS Login policy by setting variable `enable_os_login_policy` to `true`.

**Note:** You need to set variable `enable_hub_and_spoke` to `true` to be able to used the **Hub-and-Spoke** architecture detailed in the **Networking** section of the [google cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf).

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

**Note:** This module creates a Security Command Center Notification.
The notification name must be unique in the organization.
The suggested name in the `terraform.tfvars` file is **scc-notify**.
To check if it already exists run:

```
gcloud scc notifications describe <scc_notification_name> --organization=<org_id>
```

### Deploying with Cloud Build

1. Clone the policy repo based on the Terraform output from the previous section.
Clone the repo at the same level of the `terraform-example-foundation` folder, the next instructions assume that layout.
Run `terraform output cloudbuild_project_id` in the `0-bootstrap` folder to see the project again.
   ```
   gcloud source repos clone gcp-policies --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```
1. Navigate into the repo. All subsequent steps assume you are running them
   from the gcp-policies directory. If you run them from another directory,
   adjust your copy paths accordingly.
   ```
   cd gcp-policies
   ```
1. Copy contents of policy-library to new repo.
   ```
   cp -RT ../terraform-example-foundation/policy-library/ .
   ```

1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your master branch to the new repo.
   ```
   git push --set-upstream origin master
   ```
1. Navigate out of the repo.
   ```
   cd ..
   ```
1. Clone the repo.
   ```
   gcloud source repos clone gcp-org --project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```
   The message `warning: You appear to have cloned an empty repository.` is
   normal and can be ignored.
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the gcp-environments directory. If
   you run them from another directory, adjust your copy paths accordingly.
   ```
   cd gcp-org
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo (terraform variables will updated in a future step).
   ```
   cp -RT ../terraform-example-foundation/1-org/ .
   ```
1. Copy Cloud Build configuration files for Terraform. You may need to modify the command to reflect
   your current directory.
   ```
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   ```
1. Copy the Terraform wrapper script to the root of your new repository (modify accordingly based on your current directory).
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
1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars` and update the file with values from your environment and bootstrap step (you can re-run `terraform output` in the 0-bootstrap directory to find these values). Make sure that `default_region` is set to a valid [BigQuery dataset region](https://cloud.google.com/bigquery/docs/locations). Also, if the previous step showed a numeric value, make sure to un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](./docs/FAQ.md), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch.  Because the _production_ branch is a [named environment branch](./docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. You can now move to the instructions in the [2-environments](../2-environments/README.md) step.

**Troubleshooting:**
If you received a `PERMISSION_DENIED` error running the `gcloud access-context-manager` or the `gcloud scc notifications` commands you can append
```
--impersonate-service-account=org-terraform@<SEED_PROJECT_ID>.iam.gserviceaccount.com
```
to run the command as the Terraform service account.

### Deploying with Jenkins

1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-1-org>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the gcp-environments directory. If
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
    _PROJECT_ID (the cicd project id)
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
    - Assuming you configured an automatic trigger in your Jenkins Master (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](http://www.jenkins.io) for more details.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your Master's web UI.
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Master's web UI. (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

### Running Terraform locally

1. Change into 1-org folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`
1. Change into 1-org/envs/shared/ folder.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment and bootstrap.
1. Obtain your bucket name by running the following command in the 0-bootstrap folder.
   ```
   terraform output gcs_bucket_tfstate
   ```
1. Update `backend.tf` with your bucket from bootstrap.
   ```
   for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done
   ```

We will now deploy our environment (production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 1-org step and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://github.com/GoogleCloudPlatform/terraform-validator/blob/main/docs/install.md) in the **Install Terraform Validator** section and install version `v0.4.0` in your system. You will also need to rename the binary from `terraform-validator-<your-platform>` to `terraform-validator` and the `terraform-validator` binary must be in your `PATH`.

1. Run `./tf-wrapper.sh init production`.
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh validate production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply production`.

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan production` before run `./tf-wrapper.sh apply production`.
