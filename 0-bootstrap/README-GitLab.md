# Deploying a GitLab CI/CD compatible environment

The objective of the following instructions is to configure the infrastructure that allows CI/CD deployments using
GitLab CI/CD for the deploy of the Terraform Example Foundation stages (`0-bootstrap`, `1-org`, `2-environments`, `3-networks`, `4-projects`).
This infrastructure consists in two Google Cloud Platform projects (`prj-b-seed` and `prj-b-cicd-wif-gl`).

It is a best practice to have two separate projects here (`prj-b-seed` and `prj-b-cicd-wif-gl`) for separation of concerns.
On one hand, `prj-b-seed` stores terraform state and has the Service Accounts able to create / modify infrastructure.
On the other hand, the authentication infrastructure using [Workload identity federation](https://cloud.google.com/iam/docs/workload-identity-federation) is implemented in `prj-b-cicd-wif-gl`.

To run the instructions described in this document, install the following:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0 or later
    - [terraform-tools](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) component
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.5.7 or later
- [jq](https://jqlang.github.io/jq/) version 1.6 or later.

For the manual steps described in this document, you need to use the same [Terraform](https://www.terraform.io/downloads.html) version used on the build pipeline.
Otherwise, you might experience Terraform state snapshot lock errors.

Version 1.5.7 is the last version before the license model change. To use a later version of Terraform, ensure that the Terraform version used in the Operational System to manually execute part of the steps in `3-networks` and `4-projects` is the same version configured in the following code

- 0-bootstrap/modules/jenkins-agent/variables.tf
   ```
   default     = "1.5.7"
   ```

- 0-bootstrap/cb.tf
   ```
   terraform_version = "1.5.7"
   ```

- scripts/validate-requirements.sh
   ```
   TF_VERSION="1.5.7"
   ```

- build/github-tf-apply.yaml
   ```
   terraform_version: '1.5.7'
   ```

- github-tf-pull-request.yaml

   ```
   terraform_version: "1.5.7"
   ```

- 0-bootstrap/Dockerfile
   ```
   ARG TERRAFORM_VERSION=1.5.7
   ```

Also make sure that you have the following:

- A [GitLab](https://docs.gitlab.com/ee/user/profile/account/create_accounts.html) account for your User or Group.
- A private GitLab project (repository) for each one of the stages of Foundation and one for the GitLab runner Image:
    - Bootstrap
    - Organization
    - Environments
    - Networks
    - Projects
    - CI/CD Runner
- A [Personal](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) access token or a [Group](https://docs.gitlab.com/ee/user/group/settings/group_access_tokens.html) access token configured with the following [scopes](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#personal-access-token-scopes):
    - api
    - read_api
    - create_runner
    - read_repository
    - write_repository
    - read_registry
    - write_registry
- A Google Cloud [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
- A Google Cloud [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
- Cloud Identity or Google Workspace groups for organization and billing admins.
- For the user who will run the procedures in this document, grant the following roles:
   - The `roles/resourcemanager.organizationAdmin` role on the Google Cloud organization.
   - The `roles/orgpolicy.policyAdmin` role on the Google Cloud organization.
   - The `roles/resourcemanager.projectCreator` role on the Google Cloud organization.
   - The `roles/billing.admin` role on the billing account.
   - The `roles/resourcemanager.folderCreator` role.

## Instructions

### Clone Terraform Example Foundation repo

1. Clone [terraform-example-foundation](https://github.com/terraform-google-modules/terraform-example-foundation) into your local environment.

   ```bash
   git clone https://github.com/terraform-google-modules/terraform-example-foundation.git
   ```

### Create git branches

1. The instructions described in this document require that the branches used in the Terraform Example Foundation deploy to exist and to be [protected](https://docs.gitlab.com/ee/user/project/protected_branches.html). Follow the instructions on this section to create all the branches.
1. Clone all the private projects you created at the same level of the `terraform-example-foundation` folder.
You must have [SSH keys](https://docs.gitlab.com/ee/user/ssh.html) configured with GitLab for [authentication](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github).

   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-BOOTSTRAP-REPO>.git gcp-bootstrap
   ```
   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-ORGANIZATION-REPO>.git gcp-org
   ```
   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-ENVIRONMENTS-REPO>.git gcp-environments
   ```
   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-NETWORKS-REPO>.git gcp-networks
   ```
   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-PROJECTS-REPO>.git gcp-projects
   ```
   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-RUNNER-REPO>.git gcp-cicd-runner
   ```

1. The layout should be:

   ```bash
   gcp-bootstrap/
   gcp-cicd-runner/
   gcp-environments/
   gcp-networks/
   gcp-org/
   gcp-projects/
   terraform-example-foundation/
   ```

1. The following branches must be created in your git projects .

   - CI/CD Runner: `image`
   - Bootstrap: `plan` and `production`
   - Organization: `plan` and `production`
   - Environments: `plan`, `development`, `nonproduction`, and `production`
   - Networks: `plan`, `development`, `nonproduction`, and `production`
   - Projects: `plan`, `development`, `nonproduction`, and `production`

1. These branches must not be empty, so that they can be the target branch of a merge request.
Run the `0-bootstrap/scripts/git_create_branches_helper.sh` script to create these branches with a seed file for each repository automatically.

   ```bash
   ./terraform-example-foundation/0-bootstrap/scripts/git_create_branches_helper.sh GITLAB
   ```

1. The script will output logs related to the branches creation in the console and it will output the message
`"Branch creation and push completed for all repositories"` at the end of the script execution.
1. Terraform configuration on stage `0-bootstrap` will make these branches **protected**

### Build CI/CD runner image

1. Navigate into CI/CD runner the repo. All subsequent steps assume you are running them from the `gcp-cicd-runner` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-cicd-runner
   ```

1. Checkout branch `image`. It will contain the Docker image used in the GitLab Pipelines.

   ```bash
   git checkout image
   ```

1. Copy contents of foundation to cloned project (modify accordingly based on your current directory).

   ```bash
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/0-bootstrap/Dockerfile ./Dockerfile
   ```

1. Save the CI/CD runner configuration to `gcp-cicd-runner` GitLab project:

   ```bash
   git add .
   git commit -m 'Initialize CI/CD runner project'
   git push
   ```

1. Review the CI/CD Job output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-RUNNER-REPO/-/jobs under name `build-image`.
1. If the CI/CD Job is successful proceed with the next steps.

### Provide access to the CI/CD runner image

1. Go to https://gitlab.com/GITLAB-OWNER/GITLAB-RUNNER-REPO/-/settings/ci_cd#js-token-access
1. Add all the repositories: Bootstrap, Organization, Environments, Networks, and Projects to the allow list tha allow access to the CI/CD runner image.
1. In "Allow CI job tokens from the following projects to access this project" add the other projects/repositories. Format is <GITLAB-OWNER>/<GITLAB-REPO>

### Deploying step 0-bootstrap

1. Navigate into the Bootstrap repo. All subsequent
   steps assume you are running them from the `gcp-bootstrap` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-bootstrap
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout plan
   ```

1. Copy contents of foundation to cloned project (modify accordingly based on your current directory).

   ```bash
   mkdir -p envs/shared

   cp -RT ../terraform-example-foundation/0-bootstrap/ ./envs/shared
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/run_gcp_auth.sh .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./*.sh
   cd ./envs/shared
   ```

1. In the versions file `./versions.tf` un-comment the `gitlab` required provider
1. In the variables file `./variables.tf` un-comment variables in the section `Specific to gitlab_bootstrap`
1. In the outputs file `./outputs.tf` Comment-out outputs in the section `Specific to cloudbuild_module`
1. In the outputs file `./outputs.tf` un-comment outputs in the section `Specific to gitlab_bootstrap`
1. Rename file `./cb.tf` to `./cb.tf.example`

   ```bash
   mv ./cb.tf ./cb.tf.example
   ```

1. Rename file `./gitlab.tf.example` to `./gitlab.tf`

   ```bash
   mv ./gitlab.tf.example ./gitlab.tf
   ```

1. Rename file `terraform.example.tfvars` to `terraform.tfvars`

   ```bash
   mv ./terraform.example.tfvars ./terraform.tfvars
   ```

1. Update the file `terraform.tfvars` with values from your Google Cloud environment
1. Update the file `terraform.tfvars` with values from your GitLab projects
1. To prevent saving the `gitlab_token` in plain text in the `terraform.tfvars` file,
export the GitLab personal or group access token as an environment variable:

   ```bash
   export TF_VAR_gitlab_token="YOUR-PERSONAL-OR-GROUP-ACCESS-TOKEN"
   ```

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

1. To  validate your policies, run `gcloud beta terraform vet`. For installation instructions, see [Validate policies](https://cloud.google.com/docs/terraform/policy-validation/validate-policies) instructions for the Google Cloud CLI.

1. Run the following commands and check for violations:

   ```bash
   export VET_PROJECT_ID=A-VALID-PROJECT-ID

   terraform show -json bootstrap.tfplan > bootstrap.json
   gcloud beta terraform vet bootstrap.json --policy-library="../../policy-library" --project ${VET_PROJECT_ID}
   ```

   *`A-VALID-PROJECT-ID`* must be an existing project you have access to. This is necessary because `gcloud beta terraform vet` needs to link resources to a valid Google Cloud Platform project.

1. No violations and an output with `done` means the validation was successful.

1. Run `terraform apply`.

   ```bash
   terraform apply bootstrap.tfplan
   ```

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

1. Copy the backend and update `backend.tf` with the name of your Google Cloud Storage bucket for Terraform's state. Also update the `backend.tf` of all steps.

   ```bash
   export backend_bucket=$(terraform output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"

   cp backend.tf.example backend.tf
   cd ../../../

   for i in `find . -name 'backend.tf'`; do sed -i'' -e "s/UPDATE_ME/${backend_bucket}/" $i; done
   for i in `find . -name 'backend.tf'`; do sed -i'' -e "s/UPDATE_PROJECTS_BACKEND/${backend_bucket}/" $i; done

   cd gcp-bootstrap/envs/shared
   ```

1. Re-run `terraform init`. When you're prompted, agree to copy Terraform state to Cloud Storage.

   ```bash
   terraform init
   ```

1. (Optional) Run `terraform plan` to verify that state is configured correctly. You should see no changes from the previous state.
1. Save the Terraform configuration to `gcp-bootstrap` GitLab project:

   ```bash
   cd ../..
   git add .
   git commit -m 'Initialize bootstrap project'
   git push
   ```

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-BOOTSTRAP-REPO/-/merge_requests?scope=all&state=opened from the `plan` branch to the `production` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `production` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-BOOTSTRAP-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `production` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `production` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-BOOTSTRAP-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Before moving to the next step, go back to the parent directory.

   ```bash
   cd ..
   ```

**Note 1:** The stages after `0-bootstrap` use `terraform_remote_state` data source to read common configuration like the organization ID from the output of the `0-bootstrap` stage.
They will [fail](../docs/TROUBLESHOOTING.md#error-unsupported-attribute) if the state is not copied to the Cloud Storage bucket.

**Note 2:** After the deploy, to prevent the project quota error described in the [Troubleshooting guide](../docs/TROUBLESHOOTING.md#project-quota-exceeded),
we recommend that you request 50 additional projects for the **projects step service account** created in this step.

**Note 3:** In case GitLab variables are not being created on GitLab projects, it may be related to the existence of an Access Token in both User/Group profile and in the repo settings. The deploy will [fail](../docs/TROUBLESHOOTING.md#terraform-deploy-fails-due-to-gitlab-repositories-not-found).

**Note 4:** If the GitLab pipelines fail in 0-bootstrap or next steps with access denied in the runner image, you may need to add all projects to the [Token Access allow list in the CI/CD Runner repository](../docs/TROUBLESHOOTING.md#gitlab-pipelines-access-denied).

## Deploying step 1-org

1. Navigate into the repo. All subsequent steps assume you are running them from the `gcp-org` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-org
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/1-org/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/run_gcp_auth.sh .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./*.sh
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

    if [ ! -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i'' -e "s=//create_access_context_manager_access_policy=create_access_context_manager_access_policy=" ./envs/shared/terraform.tfvars; fi
    ```

1. Update the `remote_state_bucket` variable with the backend bucket from step Bootstrap.

   ```bash
   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw gcs_bucket_tfstate)

   echo "remote_state_bucket = ${backend_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars
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

1. Commit changes and Push your plan branch.

   ```bash
   git add .
   git commit -m 'Initialize org repo'
   git push
   ```

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ORGANIZATION-REPO/-/merge_requests?scope=all&state=opened from the `plan` branch to the `production` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `production` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ORGANIZATION-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `production` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `production` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ORGANIZATION-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

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
   git checkout plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/2-environments/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/run_gcp_auth.sh .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./*.sh
   ```

1. Rename `terraform.example.tfvars` to `terraform.tfvars`.

   ```bash
   mv terraform.example.tfvars terraform.tfvars
   ```

1. Update the file with values from your GCP environment.
See any of the envs folder [README.md](../2-environments/envs/production/README.md#inputs) files for additional information on the values in the `terraform.tfvars` file.

1. Update the `remote_state_bucket` variable with the backend bucket from step Bootstrap.

   ```bash
   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${backend_bucket}/" terraform.tfvars
   ```

1. Commit changes and push your plan branch.

   ```bash
   git add .
   git commit -m 'Initialize environments repo'
   git push
   ```

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/merge_requests?scope=all&state=opened from the `plan` branch to the `development` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `development` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `development` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `development` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/merge_requests?scope=all&state=opened from the `development` branch to the `nonproduction` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `nonproduction` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `nonproduction` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `nonproduction` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/merge_requests?scope=all&state=opened from the `nonproduction` branch to the `production` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `production` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `production` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `production` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-ENVIRONMENTS-REPO/-/pipelines under `tf-apply`.

1. Before moving to the next step, go back to the parent directory.

   ```bash
   cd ..
   ```

1. You can now move to the instructions in the network stage.
To use the [Dual Shared VPC](https://cloud.google.com/architecture/security-foundations/networking#vpcsharedvpc-id7-1-shared-vpc-) network mode go to [Deploying step 3-networks-dual-svpc](#deploying-step-3-networks-dual-svpc),
or go to [Deploying step 3-networks-hub-and-spoke](#deploying-step-3-networks-hub-and-spoke) to use the [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) network mode.

## Deploying step 3-networks-dual-svpc

1. Navigate into the repo. All subsequent steps assume you are running them from the `gcp-networks` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-networks
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/3-networks-dual-svpc/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/run_gcp_auth.sh .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./*.sh
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

   sed -i'' -e "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars
   ```

1. Update `common.auto.tfvars` file with values from your GCP environment.
See any of the envs folder [README.md](../3-networks-dual-svpc/envs/production/README.md#inputs) files for additional information on the values in the `common.auto.tfvars` file.
1. You must add your user email in the variable `perimeter_additional_members` to be able to see the resources created in the restricted project.
1. Update the `remote_state_bucket` variable with the backend bucket from step Bootstrap in the `common.auto.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw gcs_bucket_tfstate)

   echo "remote_state_bucket = ${backend_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars
   ```

1. Commit changes

   ```bash
   git add .
   git commit -m 'Initialize networks repo'
   ```

1. You must manually plan and apply the `shared` environment (only once) since the `development`, `nonproduction` and `production` environments depend on it.
1. Use `terraform output` to get the CI/CD project ID and the networks step Terraform Service Account from gcp-bootstrap output.
1. The CI/CD project ID will be used in the [validation](https://cloud.google.com/docs/terraform/policy-validation/quickstart) of the Terraform configuration

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}
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

1. Push your plan branch.

   ```bash
   git push
   ```

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/merge_requests?scope=all&state=opened from the `plan` branch to the `development` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `development` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `development` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `development` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/merge_requests?scope=all&state=opened from the `development` branch to the `nonproduction` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `nonproduction` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `nonproduction` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `nonproduction` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/merge_requests?scope=all&state=opened from the `nonproduction` branch to the `production` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `production` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `production` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `production` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines under `tf-apply`.

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

1. Navigate into the repo. All subsequent steps assume you are running them from the `gcp-networks` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-networks
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/3-networks-hub-and-spoke/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/run_gcp_auth.sh .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./*.sh
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
1. Update the `remote_state_bucket` variable with the backend bucket from step Bootstrap in the `common.auto.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw gcs_bucket_tfstate)

   echo "remote_state_bucket = ${backend_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars
   ```

1. Commit changes

   ```bash
   git add .
   git commit -m 'Initialize networks repo'
   ```

1. You must manually plan and apply the `shared` environment (only once) since the `development`, `nonproduction` and `production` environments depend on it.
1. Use `terraform output` to get the CI/CD project ID and the networks step Terraform Service Account from gcp-bootstrap output.
1. The CI/CD project ID will be used in the [validation](https://cloud.google.com/docs/terraform/policy-validation/quickstart) of the Terraform configuration

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}
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

1. Push your plan branch.

   ```bash
   git push
   ```

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/merge_requests?scope=all&state=opened from the `plan` branch to the `development` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `development` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `development` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `development` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/merge_requests?scope=all&state=opened from the `development` branch to the `nonproduction` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `nonproduction` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `nonproduction` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `nonproduction` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/merge_requests?scope=all&state=opened from the `nonproduction` branch to the `production` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `production` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `production` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `production` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-NETWORKS-REPO/-/pipelines under `tf-apply`.


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

1. Navigate into the repo. All subsequent
   steps assume you are running them from the `gcp-projects` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-projects
   ```

1. change to a nonproduction branch.

   ```bash
   git checkout plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/4-projects/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/run_gcp_auth.sh .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./*.sh
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

1. Use `terraform output` to get the backend bucket value from bootstrap output.

   ```bash
   export remote_state_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${remote_state_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars
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


1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize projects repo'
   ```

1. You need to manually plan and apply only once the `business_unit_1/shared` and `business_unit_2/shared` environments since `development`, `nonproduction`, and `production` depend on them.

1. Use `terraform output` to get the CI/CD project ID and the projects step Terraform Service Account from gcp-bootstrap output.
1. The CI/CD project ID will be used in the [validation](https://cloud.google.com/docs/terraform/policy-validation/quickstart) of the Terraform configuration

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}
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

1. Push your plan branch.

   ```bash
   git push
   ```

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/merge_requests?scope=all&state=opened from the `plan` branch to the `development` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `development` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `development` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `development` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/merge_requests?scope=all&state=opened from the `development` branch to the `nonproduction` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `nonproduction` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `nonproduction` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `nonproduction` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/pipelines under `tf-apply`.
1. If the GitLab pipelines is successful, apply the next environment.

1. Open a merge request in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/merge_requests?scope=all&state=opened from the `nonproduction` branch to the `production` branch and review the output.
1. The merge request will trigger a GitLab pipelines that will run Terraform `init`/`plan`/`validate` in the `production` environment.
1. Review the GitLab pipelines output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/pipelines.
1. If the GitLab pipelines is successful, merge the merge request in to the `production` branch.
1. The merge will trigger a GitLab pipelines that will apply the terraform configuration for the `production` environment.
1. Review merge output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-PROJECTS-REPO/-/pipelines under `tf-apply`.

1. Unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```
