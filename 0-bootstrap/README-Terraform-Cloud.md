# Deploying a Terraform Cloud (TFC) compatible environment

The objective of the instructions below is to configure the infrastructure that allows you to run CI/CD deployments using
Terraform Cloud for the Terraform Example Foundation stages (`0-bootstrap`, `1-org`, `2-environments`, `3-networks`, `4-projects`).
The infrastructure consists in two Google Cloud Platform projects (`prj-b-seed` and `prj-b-cicd-wif-tfc`).

It is a best practice to have two separate projects here (`prj-b-seed` and `prj-b-cicd-wif-tfc`) for separation of concerns.
On one hand, `prj-b-seed` has the Service Accounts able to create / modify infrastructure.
On the other hand, the authentication infrastructure using [Workload identity federation](https://cloud.google.com/iam/docs/workload-identity-federation) is implemented in `prj-b-cicd-wif-tfc`. Unlike other deployment methods, Terraform state will be stored in Terraform Cloud instead of in a bucket in GCP.

Note: If you choose to use [Terraform Cloud with Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents) a private autopilot GKE cluster will be deployed in your `prj-b-cicd-wif-tfc` GCP project to be used as the Agent.

## Requirements

To run the instructions described in this document, install the following:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0 or later
    - [terraform-tools](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) component
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.5.7 or later
- [jq](https://jqlang.github.io/jq/download/) version 1.6.0 or later

For the manual steps described in this document, you need to use the same [Terraform](https://www.terraform.io/downloads.html) version used on the build pipeline.
Otherwise, you might experience Terraform state snapshot lock errors.

Also make sure that you have the following:

- A [Terraform Cloud account](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up#create-an-account) for your User or [Organization](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up#create-an-organization).
- A Terraform Cloud [organization](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/organizations#creating-organizations).
- A Terraform Cloud [User token](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens#user-api-tokens) or [Organization token](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens#organization-api-tokens).
   - Organization token is prefered since the permissions are limited to a single TFC organization.
- A [supported](https://developer.hashicorp.com/terraform/cloud-docs/vcs#supported-vcs-providers) version control system (VCS) provider [connected](https://developer.hashicorp.com/terraform/cloud-docs/vcs) with your Terraform Cloud account.
   - The following list has the supported methods for connecting TFC to your VCS provider fully supported by this README. While it's possible to connect with providers not listed here, doing so may require some adjustments.
      - [GitHub (OAuth)](https://developer.hashicorp.com/terraform/cloud-docs/vcs/github)
      - [GitHub Enterprise](https://developer.hashicorp.com/terraform/cloud-docs/vcs/github-enterprise)
      - [GitLab.com](https://developer.hashicorp.com/terraform/cloud-docs/vcs/gitlab-com)
      - [GitLab EE/CE](https://developer.hashicorp.com/terraform/cloud-docs/vcs/gitlab-eece)
   - Once you have any VCS provider configured you should be able to copy `OAuth Token ID` available in TFC console (https://app.terraform.io/app/YOUR-TFC-ORGANIZATION/settings/version-control).
- A **private** repository (or project) in your VCS provider for each one of the stages of Foundation:
   - Bootstrap
   - Organization
   - Environments
   - Networks
   - Projects
   - See [GitHub repository creation](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository) or [GitLab project creation](https://docs.gitlab.com/ee/user/project/index.html#create-a-blank-project) for more details.
- A Google Cloud [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
- A Google Cloud [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
- Cloud Identity or Google Workspace groups for organization and billing admins.
- For the user who will run the procedures in this document, grant the following roles:
   - The `roles/resourcemanager.organizationAdmin` role on the Google Cloud organization.
   - The `roles/orgpolicy.policyAdmin` role on the Google Cloud organization.
   - The `roles/resourcemanager.projectCreator` role on the Google Cloud organization.
   - The `roles/billing.admin` role on the billing account.
   - The `roles/resourcemanager.folderCreator` role.

### Instructions

1. Clone [terraform-example-foundation](https://github.com/terraform-google-modules/terraform-example-foundation) into your local environment.

   ```bash
   git clone https://github.com/terraform-google-modules/terraform-example-foundation.git
   ```

1. Clone all the private repositories (or projects) you created at the same level of the `terraform-example-foundation` folder.
You must be authenticated to the VCS provider. See [GitHub authentication](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github) or [GitLab authentication](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github) for more details.

   ```bash
   git clone git@<VCS-SERVICE-PROVIDER>.com:<VCS-OWNER>/<VCS-BOOTSTRAP-REPO>.git gcp-bootstrap
   ```
   ```bash
   git clone git@<VCS-SERVICE-PROVIDER>.com:<VCS-OWNER>/<VCS-ORGANIZATION-REPO>.git gcp-org
   ```
   ```bash
   git clone git@<VCS-SERVICE-PROVIDER>.com:<VCS-OWNER>/<VCS-ENVIRONMENTS-REPO>.git gcp-environments
   ```
   ```bash
   git clone git@<VCS-SERVICE-PROVIDER>.com:<VCS-OWNER>/<VCS-NETWORKS-REPO>.git gcp-networks
   ```
   ```bash
   git clone git@<VCS-SERVICE-PROVIDER>.com:<VCS-OWNER>/<VCS-PROJECTS-REPO>.git gcp-projects
   ```

1. The layout should be:

   ```bash
   gcp-bootstrap/
   gcp-org/
   gcp-environments/
   gcp-networks/
   gcp-projects/
   terraform-example-foundation/
   ```

1. In your VCS repositories (or projects) it is expected to have the following branches created. Also, these branches shouldn't be empty, you need at least a single file. Run `scripts/git_create_branches_helper.sh` script to create these branches with a seed file for each repository automatically.
   - Bootstrap: `production`
   - Organization: `production`
   - Environments: `development`, `nonproduction` and `production`
   - Networks: `development`, `nonproduction` and `production`
   - Projects: `development`, `nonproduction` and `production`
   - Note: `scripts/git_create_branches_helper.sh` script and the following commands assume you are running it from the directory that has all the repos cloned (layout described in the previous step). If you run from another directory, adjust the `BASE_PATH` variable at the `scripts/git_create_branches_helper.sh` and adjust in the following commands.

   ```bash
   chmod 755 ./terraform-example-foundation/0-bootstrap/scripts/git_create_branches_helper.sh
   ./terraform-example-foundation/0-bootstrap/scripts/git_create_branches_helper.sh
   ```

   You will see some GIT logs related to the branches creation in the console and the message  `"Branch creation and push completed for all repositories"` at the end of the script execution.

1. [Authenticate your Terraform CLI](https://developer.hashicorp.com/terraform/cli/commands/login) by running the `login` command and following the instructions provided in the browser tab that should open automatically.
   ```bash
   terraform login
   ```
**Note**: It is required to do this step even if you already have an [Organization token](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens#organization-api-tokens) in order to generate your User token.

### Deploying step 0-bootstrap

1. Navigate into the repo. All subsequent
   steps assume you are running them from the `gcp-bootstrap` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-bootstrap
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo (modify accordingly based on your current directory).

   ```bash
   mkdir -p envs/shared
   cp -RT ../terraform-example-foundation/0-bootstrap/ ./envs/shared
   cd ./envs/shared
   ```

1. In the versions file `./versions.tf` un-comment the `tfe` required provider
1. In the variables file `./variables.tf` un-comment variables in the section `Specific to tfc_bootstrap`
1. In the outputs file `./outputs.tf` Comment-out outputs in the section `Specific to cloudbuild_module`
1. In the outputs file `./outputs.tf` un-comment outputs in the section `Specific to tfc_bootstrap`
    1. If you want to use [Terraform Cloud with Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents), in addition to `Specific to tfc_bootstrap`, un-comment outputs in the section `Specific to tfc_bootstrap with Terraform Cloud Agents` and update `enable_tfc_cloud_agents` to `true` variable at `terraform.tfvars`
1. Rename file `./cb.tf` to `./cb.tf.example`

   ```bash
   mv ./cb.tf ./cb.tf.example
   ```

1. Rename file `.terraform_cloud.tf.example` to `./terraform_cloud.tf`

   ```bash
   mv ./terraform_cloud.tf.example ./terraform_cloud.tf
   ```

1. Rename file `terraform.example.tfvars` to `terraform.tfvars`

   ```bash
   mv ./terraform.example.tfvars ./terraform.tfvars
   ```

1. Update the file `terraform.tfvars` with values from your Google Cloud environment
1. Update the file `terraform.tfvars` with values from your VCS repositories at `tfc_bootstrap` section
1. Update the file `terraform.tfvars` with values from your Terraform Cloud organization at `tfc_bootstrap` section
    1. If you want to use [Terraform Cloud with Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents) update `enable_tfc_cloud_agents` variable at `tfc_bootstrap` section
1. To prevent saving the `tfc_token` in plain text in the `terraform.tfvars` file,
export the Terraform Cloud token as an environment variable:

   ```bash
   export TF_VAR_tfc_token=YOUR-TFC-TOKEN
   ```
1. To prevent saving the `vcs_oauth_token_id` in plain text in the `terraform.tfvars` file,
export the OAuth Token ID as an environment variable:

   ```bash
   export TF_VAR_vcs_oauth_token_id=YOUR-VCS-OAUTH-TOKEN-ID
   ```

1. Run `terraform version` to get the version of your TF and export it as environment variables. `terraform_version` variable will be used by the `tfe_workspace` resource in order to set the version of the TF in TFC workspaces. This is important so the state migration (from your local to TFC) works.

   ```bash
   TF_VAR_tfc_terraform_version=$(terraform --version -json | jq '.terraform_version' | sed 's/"//g')
   export TF_VAR_tfc_terraform_version
   echo "TF Version = ${TF_VAR_tfc_terraform_version}"
   ```

   Note: You may need to install `jq`, if your OS doesn't have built-in. An alternative would be run `terraform --version` and manually copy the number version output to be set at the environment variable.

1. Use the helper script [validate-requirements.sh](../scripts/validate-requirements.sh) to validate your environment:

   ```bash
   ../../../terraform-example-foundation/scripts/validate-requirements.sh  -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID> -u <END_USER_EMAIL> -e
   ```

   **Note:** The script is not able to validate if the user is in a Cloud Identity or Google Workspace group with the required roles.

1. Run `terraform init` and `terraform plan` and review the output.

   ```bash
   terraform init
   terraform plan -input=false -out bootstrap.tfplan
   ```

1. Run `terraform apply`.

   ```bash
   terraform apply bootstrap.tfplan
   ```

1. If you set `enable_tfc_cloud_agents` variable to `true` on `terraform.tfvars` in order to use [Terraform Cloud with Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents) you need to run these additional steps. If not, you should skip it.
    1. In `provider.tf` file, un-comment kubernetes provider section;
    1. In `terraform_cloud.tf` file, un-comment `providers` block at `tfc_agent_gke` module;
    1. Run `terraform plan -input=false -out bootstrap_2.tfplan`
    1. Run `terraform apply bootstrap_2.tfplan`

1. Run `terraform output` to get the email address of the terraform service accounts that will be used to run manual steps for `shared` environments in steps `3-networks-dual-svpc`, `3-networks-hub-and-spoke`, and `4-projects`.

   ```bash
   export network_step_sa=$(terraform output -raw networks_step_terraform_service_account_email)
   export projects_step_sa=$(terraform output -raw projects_step_terraform_service_account_email)

   echo "network step service account = ${network_step_sa}"
   echo "projects step service account = ${projects_step_sa}"
   ```

1. Run `terraform output` to get the ID of your CI/CD project:

   ```bash
   export cicd_project_id=$(terraform output -raw cicd_project_id)
   echo "CI/CD Project ID = ${cicd_project_id}"
   ```

1. Run `terraform output` to get the name of the TFC organization and export it as environment variables. `TF_CLOUD_ORGANIZATION` variable will be used by the `cloud` block in order to move the local Terraform's state to TFC and `TF_VAR_tfc_org_name` will be used to run manual steps for `shared` environments in steps `3-networks-dual-svpc`, `3-networks-hub-and-spoke`, and `4-projects`

   ```bash
   export TF_CLOUD_ORGANIZATION=$(terraform output -raw tfc_org_name)
   export TF_VAR_tfc_org_name=$TF_CLOUD_ORGANIZATION
   echo "TFC Organization = ${TF_CLOUD_ORGANIZATION}"
   ```

1. You need to rename the following files in order to configure the foundation steps for TFC:
   - `backend.tf` to `backend.tf.gcs.example` and `backend.tf.cloud.example` to `backend.tf` in order to define TFC workspace configuration and store Terraform's state in TFC.
   - `remote.tf` to `remote.tf.gcs.example` and `remote.tf.cloud.example` to `remote.tf` in order to retrieve the state outputs from workspace in TFC .
   - **Note:** You need to do this renaming in all the steps. You can run `scripts/set-tfc-backend-and-remote.sh` script to do the renaming for all the steps automatically.

   ```bash
   mv backend.tf.cloud.example backend.tf
   cd ../../../
   chmod 775 ./terraform-example-foundation/scripts/set-tfc-backend-and-remote.sh
   ./terraform-example-foundation/scripts/set-tfc-backend-and-remote.sh
   cd ./gcp-bootstrap/envs/shared
   ```

1. Re-run `terraform init`. When you're prompted, agree to copy Terraform state to Terraform Cloud.

   ```bash
   terraform init
   ```

1. (Optional) Run `terraform plan` to verify that state is configured correctly. You should see no changes from the previous state.
1. Save the Terraform configuration to `gcp-bootstrap` VCS repository:

   ```bash
   cd ../..
   git add .
   git commit -m 'Initialize bootstrap repo'
   git push --set-upstream origin plan
   ```

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `plan` branch to the `production` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `production` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/0-shared/runs under `Run List` item. The output should be `Your infrastructure matches the configuration` since we applied the 0-bootstrap locally.
1. If the speculative plan is successful, merge the pull request in to the `production` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan again for the terraform configuration for the `production` environment.

1. Before moving to the next step, go back to the parent directory.

   ```bash
   cd ..
   ```

**Note:** After the deploy, to prevent the project quota error described in the [Troubleshooting guide](../docs/TROUBLESHOOTING.md#project-quota-exceeded),
we recommend that you request 50 additional projects for the **projects step service account** created in this step.

## Deploying step 1-org

1. Navigate into the repo. All subsequent steps assume you are running them from the `gcp-org` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-org
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/1-org/ .
   ```

1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars`

   ```bash
   mv ./envs/shared/terraform.example.tfvars ./envs/shared/terraform.tfvars
   ```

1. Update the file `envs/shared/terraform.tfvars` with values from your GCP environment.
See the shared folder [README.md](../1-org/envs/shared/README.md#inputs) for additional information on the values in the `terraform.tfvars` file.

1. Un-comment the variable `create_access_context_manager_access_policy = false` if your organization already has an Access Context Manager Policy.

    ```bash
    export ORGANIZATION_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -json common_config | jq '.org_id' --raw-output)

    export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")

    echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"

    if [ ! -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i "s=//create_access_context_manager_access_policy=create_access_context_manager_access_policy=" ./envs/shared/terraform.tfvars; fi
    ```

1. Check if a Security Command Center Notification with the default name, **scc-notify**, already exists in your organization.

   ```bash
   export ORG_STEP_SA=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw organization_step_terraform_service_account_email)

   gcloud scc notifications describe "scc-notify" --format="value(name)" --organization=${ORGANIZATION_ID} --impersonate-service-account=${ORG_STEP_SA}
   ```

1. If the notification exists the output will be:

    ```text
    organizations/ORGANIZATION_ID/notificationConfigs/scc-notify
    ```

1. If the notification does not exist the output will be:

    ```text
    ERROR: (gcloud.scc.notifications.describe) NOT_FOUND: Requested entity was not found.
    ```

1. If the notification exists, choose a different value for the `scc_notification_name` variable in the `./envs/shared/terraform.tfvars` file.

1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize org repo'
   ```

1. Push your plan branch.

   ```bash
   git push --set-upstream origin plan
   ```

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `plan` branch to the `production` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `production` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/1-shared/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `production` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `production` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/1-shared/runs under `Run List` item.

1. Before moving to the next step, go back to the parent directory.

   ```bash
   cd ..
   ```


## Deploying step 2-environments

1. Navigate into the repo. All subsequent
   steps assume you are running them from the `gcp-environments` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-environments
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/2-environments/ .
   ```

1. Rename `terraform.example.tfvars` to `terraform.tfvars`.

   ```bash
   mv terraform.example.tfvars terraform.tfvars
   ```

1. Update the file with values from your GCP environment.
See any of the envs folder [README.md](../2-environments/envs/production/README.md#inputs) files for additional information on the values in the `terraform.tfvars` file.

1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize environments repo'
   ```

1. Push your plan branch.

   ```bash
   git push --set-upstream origin plan
   ```

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `plan` branch to the `development` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `development` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/2-development/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `development` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `development` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/2-development/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `development` branch to the `nonproduction` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `nonproduction` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/2-nonproduction/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `nonproduction` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `nonproduction` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/2-nonproduction/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `nonproduction` branch to the `production` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `production` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/2-production/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `production` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `production` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/2-production/runs under `Run List` item.

1. You can now move to the instructions in the network stage.
To use the [Dual Shared VPC](https://cloud.google.com/architecture/security-foundations/networking#vpcsharedvpc-id7-1-shared-vpc-) network mode go to [Deploying step 3-networks-dual-svpc](#deploying-step-3-networks-dual-svpc),
or go to [Deploying step 3-networks-hub-and-spoke](#deploying-step-3-networks-hub-and-spoke) to use the [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) network mode.

1. Before moving to the next step, go back to the parent directory.

   ```bash
   cd ..
   ```

## Deploying step 3-networks-dual-svpc

**Note:** For all purposes we treat `shared` environment as `production` environment due to the possible impacts into `production`. So `3-production` TFC workspace have a [Run Trigger](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers) sourcing `3-shared` TFC workspace, which means that every time you successfully run an apply job in `3-shared` TFC workspace, a `Plan and apply` job will be triggered automatically for `3-production` TFC workspace. (All the applies will continue requiring manual approvals in TFC console).

1. Navigate into the repo. All subsequent steps assume you are running them from the `gcp-networks` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-networks
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/3-networks-dual-svpc/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```

1. Update the file `shared.auto.tfvars` with the values for the `target_name_server_addresses`.
1. Update the file `access_context.auto.tfvars` with the organization's `access_context_manager_policy_id`.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -json common_config | jq '.org_id' --raw-output)

   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")

   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"

   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars
   ```

1. Update `common.auto.tfvars` file with values from your GCP environment.
See any of the envs folder [README.md](../3-networks-dual-svpc/envs/production/README.md#inputs) files for additional information on the values in the `common.auto.tfvars` file.
1. You must add your user email in the variable `perimeter_additional_members` to be able to see the resources created in the restricted project.

1. You must manually plan and apply the `shared` environment from your (only once) since the `development`, `nonproduction` and `production` environments depend on it.

1. In order to manually run the apply for shared workspace from your local we need to temporary unset the TFC backend by renaming `envs/shared/backend.tf` to `envs/shared/backend.tf.temporary_disabled`.

   ```bash
   mv envs/shared/backend.tf envs/shared/backend.tf.temporary_disabled
   ```

1. Use `terraform output` to get the CI/CD project ID and the networks step Terraform Service Account from gcp-bootstrap output.
1. The CI/CD project ID will be used in the [validation](https://cloud.google.com/docs/terraform/policy-validation/quickstart) of the Terraform configuration

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}
   ```
1. Use `terraform output` to get the name of the TFC organization from gcp-bootstrap output and export it as environment variables. The TFC organization  will be used during the manual apply process by `tfe_outputs` resource in order to grab the outputs from previous steps.

   ```bash
   export TF_VAR_tfc_org_name=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw tfc_org_name)
   echo "TFC Organization = ${TF_VAR_tfc_org_name}"
   ```

1. The networks step Terraform Service Account will be used for [Service Account impersonation](https://cloud.google.com/docs/authentication/use-service-account-impersonation) in the following steps.
An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set with the Terraform Service Account to enable impersonation.

   ```bash
   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw networks_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/policy-library ${CICD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```

   **Note:** Because we are running an apply locally instead of in the TFC workspace, this apply to shared won't be triggerring the [TFC Run Trigger](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers) for `3-production` TFC workspace.

1. In order to set the TFC backend for shared workspace we now can rename `envs/shared/backend.tf.temporary_disabled` to `envs/shared/backend.tf` and run `terraform init`. When you're prompted, agree to copy Terraform state to Terraform Cloud.

   ```bash
   cd envs/shared/
   mv backend.tf.temporary_disabled backend.tf
   terraform init
   cd ../..
   ```

1. Commit changes

   ```bash
   git add .
   git commit -m 'Initialize networks repo'
   ```

1. Push your plan branch.

   ```bash
   git push --set-upstream origin plan
   ```

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `plan` branch to the `development` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `development` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-development/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `development` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `development` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-development/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `development` branch to the `nonproduction` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `nonproduction` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-nonproduction/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `nonproduction` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `nonproduction` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-nonproduction/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `nonproduction` branch to the `production` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `production` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-production/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `production` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `production` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-production/runs under `Run List` item.

1. Before executing the next steps, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```

1. Before moving to the next step, go back to the parent directory.

   ```bash
   cd ..
   ```

1. You can now move to the instructions in the [4-projects](#deploying-step-4-projects) stage.

## Deploying step 3-networks-hub-and-spoke

**Note:** For all purposes we treat `shared` environment as `production` environment due to the possible impacts into `production`. So `3-production` TFC workspace have a [Run Trigger](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers) sourcing `3-shared` TFC workspace, which means that every time you successfully run an apply job in `3-shared` TFC workspace, a `Plan and apply` job will be triggered automatically for `3-production` TFC workspace. (All the applies will continue requiring manual approvals in TFC console).

1. Navigate into the repo. All subsequent steps assume you are running them from the `gcp-networks` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-networks
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/3-networks-hub-and-spoke/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```

1. Update `common.auto.tfvars` file with values from your GCP environment.
See any of the envs folder [README.md](../3-networks-hub-and-spoke/envs/production/README.md#inputs) files for additional information on the values in the `common.auto.tfvars` file.
1. You must add your user email in the variable `perimeter_additional_members` to be able to see the resources created in the restricted project.

1. You must manually plan and apply the `shared` environment (only once) since the `development`, `nonproduction` and `production` environments depend on it.

1. In order to manually run the apply for shared workspace from your local we need to temporary unset the TFC backend by renaming `envs/shared/backend.tf` to `envs/shared/backend.tf.temporary_disabled`.

   ```bash
   mv envs/shared/backend.tf envs/shared/backend.tf.temporary_disabled
   ```

1. Use `terraform output` to get the CI/CD project ID and the networks step Terraform Service Account from gcp-bootstrap output.
1. The CI/CD project ID will be used in the [validation](https://cloud.google.com/docs/terraform/policy-validation/quickstart) of the Terraform configuration

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}
   ```

1. Use `terraform output` to get the name of the TFC organization from gcp-bootstrap output and export it as environment variables. The TFC organization  will be used during the manual apply process by `tfe_outputs` resource in order to grab the outputs from previous steps.

   ```bash
   export TF_VAR_tfc_org_name=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw tfc_org_name)
   echo "TFC Organization = ${TF_VAR_tfc_org_name}"
   ```

1. The networks step Terraform Service Account will be used for [Service Account impersonation](https://cloud.google.com/docs/authentication/use-service-account-impersonation) in the following steps.
An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set with the Terraform Service Account to enable impersonation.

   ```bash
   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw networks_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/policy-library ${CICD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```
   **Note:** Because we are running an apply locally instead of in the TFC workspace, this apply to shared won't be triggerring the [TFC Run Trigger](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers) for `3-production` TFC workspace.

1. In order to set the TFC backend for shared workspace we now can rename `envs/shared/backend.tf.temporary_disabled` to `envs/shared/backend.tf` and run `terraform init`. When you're prompted, agree to copy Terraform state to Terraform Cloud.

   ```bash
   cd envs/shared/
   mv backend.tf.temporary_disabled backend.tf
   terraform init
   cd ../..
   ```

1. Commit changes

   ```bash
   git add .
   git commit -m 'Initialize networks repo'
   ```

1. Push your plan branch.

   ```bash
   git push --set-upstream origin plan
   ```

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `plan` branch to the `development` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `development` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-development/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `development` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `development` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-development/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `development` branch to the `nonproduction` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `nonproduction` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-nonproduction/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `nonproduction` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `nonproduction` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-nonproduction/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `nonproduction` branch to the `production` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `production` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-production/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `production` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `production` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/3-production/runs under `Run List` item.


1. Before executing the next steps, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```

1. Before moving to the next step, go back to the parent directory.

   ```bash
   cd ..
   ```

1. You can now move to the instructions in the [4-projects](#deploying-step-4-projects) stage.

## Deploying step 4-projects

**Note:** For all purposes we treat `shared` environment as `production` environment due to the possible impacts into `production`. So `4-<business_unit>-production` TFC workspace have a [Run Trigger](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers) sourcing `4-<business_unit>-shared` TFC workspace, which means that every time you successfully run an apply job in `4-<business_unit>-shared` TFC workspace, a `Plan and apply` job will be triggered automatically for `4-<business_unit>-production` TFC workspace. (All the applies will continue requiring manual approvals in TFC console).

1. Navigate into the repo. All subsequent
   steps assume you are running them from the `gcp-projects` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-projects
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/4-projects/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `auto.example.tfvars` files to `auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv development.auto.example.tfvars development.auto.tfvars
   mv nonproduction.auto.example.tfvars nonproduction.auto.tfvars
   mv production.auto.example.tfvars production.auto.tfvars
   ```

1. See any of the envs folder [README.md](../4-projects/business_unit_1/production/README.md#inputs) files for additional information on the values in the `common.auto.tfvars`, `development.auto.tfvars`, `nonproduction.auto.tfvars`, and `production.auto.tfvars` files.
1. See any of the shared folder [README.md](../4-projects/business_unit_1/shared/README.md#inputs) files for additional information on the values in the `shared.auto.tfvars` file.

1. You need to manually plan and apply only once the `business_unit_1/shared` and `business_unit_2/shared` environments since `development`, `nonproduction`, and `production` depend on them.

1. In order to manually run the apply for shared workspace from your local we need to temporary unset the TFC backend by renaming `envs/shared/backend.tf` to `envs/shared/backend.tf.temporary_disabled`.

   ```bash
   mv business_unit_1/shared/backend.tf business_unit_1/shared/backend.tf.temporary_disabled
   mv business_unit_2/shared/backend.tf business_unit_2/shared/backend.tf.temporary_disabled
   ```

1. Use `terraform output` to get the CI/CD project ID and the projects step Terraform Service Account from gcp-bootstrap output.
1. The CI/CD project ID will be used in the [validation](https://cloud.google.com/docs/terraform/policy-validation/quickstart) of the Terraform configuration

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}
   ```

1. Use `terraform output` to get the name of the TFC organization from gcp-bootstrap output and export it as environment variables. The TFC organization  will be used during the manual apply process by `tfe_outputs` resource in order to grab the outputs from previous steps.

   ```bash
   export TF_VAR_tfc_org_name=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw tfc_org_name)
   echo "TFC Organization = ${TF_VAR_tfc_org_name}"
   ```

1. The projects step Terraform Service Account will be used for [Service Account impersonation](https://cloud.google.com/docs/authentication/use-service-account-impersonation) in the following steps.
An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set with the Terraform Service Account to enable impersonation.

   ```bash
   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw projects_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/policy-library ${CICD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```
   **Note:** Because we are running an apply locally instead of in the TFC workspace, this apply to shared won't be triggerring the [TFC Run Trigger](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers) for `4-<business_unit>-production` TFC workspace.


1. In order to set the TFC backend for shared workspace we now can rename `envs/shared/backend.tf.temporary_disabled` to `envs/shared/backend.tf` and run `terraform init`. When you're prompted, agree to copy Terraform state to Terraform Cloud.

   ```bash
   mv business_unit_1/shared/backend.tf.temporary_disabled business_unit_1/shared/backend.tf
   mv business_unit_2/shared/backend.tf.temporary_disabled business_unit_2/shared/backend.tf
   terraform -chdir="business_unit_1/shared/" init
   terraform -chdir="business_unit_2/shared/" init
   ```

1. (Optional) If you want additional subfolders for separate business units or entities, make additional copies of the folder `business_unit_1` and modify any values that vary across business unit like `business_code`, `business_unit`, or `subnet_ip_range`.

For example, to create a new business unit similar to business_unit_1, run the following:

   ```bash
   #copy the business_unit_1 folder and it's contents to a new folder business_unit_2
   cp -r  business_unit_1 business_unit_2

   # search all files under the folder `business_unit_2` and replace strings for business_unit_1 with strings for business_unit_2
   grep -rl bu1 business_unit_2/ | xargs sed -i 's/bu1/bu2/g'
   grep -rl business_unit_1 business_unit_2/ | xargs sed -i 's/business_unit_1/business_unit_2/g'
   ```


1. Commit changes

   ```bash
   git add .
   git commit -m 'Initialize networks repo'
   ```

1. Push your plan branch.

   ```bash
   git push --set-upstream origin plan
   ```

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `plan` branch to the `development` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `development` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/4-development/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `development` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `development` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/4-development/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `development` branch to the `nonproduction` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `nonproduction` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/4-nonproduction/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `nonproduction` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `nonproduction` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/4-nonproduction/runs under `Run List` item.
1. If the TFC Apply is successful, you can open the pull request (or merge request) for the next environment.

1. Open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) (for GitHub) or a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html) (for GitLab) from the `nonproduction` branch to the `production` branch and review the output.
1. The pull request (or merge request) will trigger a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans) in the `production` environment.
1. Review the speculative plan output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/4-production/runs under `Run List` item.
1. If the speculative plan is successful, merge the pull request in to the `production` branch.
1. The merge will trigger a Terraform Cloud `Plan and Apply` run, that will run the plan and apply the terraform configuration for the `production` environment. You need to approve the apply in the `Runs` menu.
1. Review apply output in Terraform Cloud https://app.terraform.io/app/TFC-ORGANIZATION-NAME/workspaces/4-production/runs under `Run List` item.

1. Unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```
