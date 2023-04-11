# Deploying a GitHub actions compatible environment

The objective of the instructions below is to configure the infrastructure that allows you to run CI/CD deployments using
GitHub Actions for the Terraform Example Foundation stages (`0-bootstrap`, `1-org`, `2-environments`, `3-networks`, `4-projects`).
The infrastructure consists in two Google Cloud Platform projects (`prj-b-seed` and `prj-b-cicd-gh`).

It is a best practice to have two separate projects here (`prj-b-seed` and `prj-b-cicd-gh`) for separation of concerns.
On one hand, `prj-b-seed` stores terraform state and has the Service Accounts able to create / modify infrastructure.
On the other hand, the authentication infrastructure using [Workload identity federation](https://cloud.google.com/iam/docs/workload-identity-federation) is implemented in `prj-b-cicd-gh`.

## Requirements

To run the instructions described in this document, install the following:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0 or later
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.3.0

Also make sure that you have the following:

- A [GitHub account](https://docs.github.com/en/get-started/onboarding/getting-started-with-your-github-account) for your User or [Organization](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch).
- A [GitHub repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository) for each one of the stages of Foundation:
    - Bootstrap
    - Organization
    - Environments
    - Networks
    - Projects
- A [Fine grained](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token) personal access token configured with:
    - Repository access to Only select repositories, including all the repositories in the previous item.
    - Permissions:
        - Actions: Read and Write
        - Metadata: Read-only
        - Secrets: Read and Write
        - Variables: Read and Write
        - Workflows: Read and Write
- A Google Cloud [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
- A Google Cloud [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
- Cloud Identity or Google Workspace groups for organization and billing admins.
- Add the user who will use Terraform to the `group_org_admins` group.
They must be in this group, or they won't have `roles/resourcemanager.projectCreator` access.
- For the user who will run the procedures in this document, grant the following roles:
    - The `roles/resourcemanager.organizationAdmin` role on the Google Cloud organization.
    - The `roles/orgpolicy.policyAdmin` role on the Google Cloud organization.
    - The `roles/billing.admin` role on the billing account.
    - The `roles/resourcemanager.folderCreator` role.

If other users need to be able to run these procedures, add them to the group
represented by the `org_project_creators` variable.
For more information about the permissions that are required, and the resources
that are created, see the organization bootstrap module
[documentation.](https://github.com/terraform-google-modules/terraform-google-bootstrap)

## Instructions

### Deploying step 0-bootstrap

1. Clone [terraform-example-foundation](https://github.com/terraform-google-modules/terraform-example-foundation) into your local environment.

   ```bash
   git clone https://github.com/terraform-google-modules/terraform-example-foundation.git
   ```

1. Clone the repository you created to host the `0-bootstrap` terraform configuration at the same level of the `terraform-example-foundation` folder.

   ```bash
   git clone <GITHUB-BOOTSTRAP-REPO> gcp-bootstrap
   ```

1. The layout should be:

   ```bash
   gcp-bootstrap/
   terraform-example-foundation/
   ```

1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the `gcp-bootstrap` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-bootstrap
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo (modify accordingly based on your current directory).

   ```bash
   mkdir -p envs/shared

   cp -RT ../terraform-example-foundation/0-bootstrap/ ./envs/shared
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   mkdir -p .github/workflows
   cp ../terraform-example-foundation/build/github-tf-* ./.github/workflows/
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   cd ./envs/shared
   ```

1. Rename file `./cb.tf` to `./cb.tf.example`

   ```bash
   mv ./cb.tf ./cb.tf.example
   ```

1. Comment-out the `cloudbuild_bootstrap` outputs in `./outputs.tf`
1. Comment-out the `cloudbuild_bootstrap` outputs in `./variables.tf`
1. Rename file `./github.tf.example` to `./github.tf`

   ```bash
   mv ./github.tf.example ./github.tf
   ```

1. Un-comment the `github_bootstrap` variables in `./variables.tf`
1. Un-comment the `github_bootstrap` outputs in `./outputs.tf`
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment:

   ```bash
   mv ./terraform.example.tfvars ./terraform.tfvars
   ```

1. Use the helper script [validate-requirements.sh](../../../scripts/validate-requirements.sh) to validate your environment:

   ```bash
   ../../../scripts/validate-requirements.sh -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID> -u <END_USER_EMAIL>
   ```

   **Note:** The script is not able to validate if the user is in a Cloud Identity or Google Workspace group with the required roles.

1. Run `terraform init` and `terraform plan` and review the output.

   ```bash
   terraform init
   terraform plan -input=false -out bootstrap.tfplan
   ```

1. To  validate your policies, run `gcloud beta terraform vet`. For installation instructions, see [Validate policies](https://cloud.google.com/docs/terraform/policy-validation/validate-policies) instructions for the Gogle Cloud CLI.

1. Run the following commands and check for violations:

   ```bash
   export VET_PROJECT_ID=A-VALID-PROJECT-ID

   terraform show -json bootstrap.tfplan > bootstrap.json
   gcloud beta terraform vet bootstrap.json --policy-library="../../../policy-library" --project ${VET_PROJECT_ID}
   ```

   *`A-VALID-PROJECT-ID`* must be an existing project you have access to. This is necessary because Terraform-validator needs to link resources to a valid Google Cloud Platform project.

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
   cd ../../../..

   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME|UPDATE_PROJECTS_BACKEND/${backend_bucket}/" $i; done

   cd gcp-bootstrap/envs/shared
   ```

1. Re-run `terraform init`. When you're prompted, agree to copy Terraform state to Cloud Storage.

   ```bash
   terraform init
   ```

1. (Optional) Run `terraform plan` to verify that state is configured correctly. You should see no changes from the previous state.


1. Save the Terraform configuration to `gcp-bootstrap` github repository:

   ```bash
   cd ../..
   git add .
   git commit -m 'Initialize bootstrap repo'
   git push --set-upstream origin plan
   ```

**Note 1:** The stages after `0-bootstrap` use `terraform_remote_state` data source to read common configuration like the organization ID from the output of the `0-bootstrap` stage.
They will [fail](../docs/TROUBLESHOOTING.md#error-unsupported-attribute) if the state is not copied to the Cloud Storage bucket.

**Note 2:** After the deploy, to prevent the project quota error described in the [Troubleshooting guide](../docs/TROUBLESHOOTING.md#project-quota-exceeded),
we recommend that you request 50 additional projects for the **projects step service account** created in this step.

## Deploying step 1-org

1. Clone the repository you created to host the `1-org` terraform configuration at the same level of the `terraform-example-foundation` folder.

   ```bash
   git clone <GITHUB-ORGANIZATION-REPO> gcp-org
   ```

1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the `gcp-org` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-org
   git checkout -b plan
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../terraform-example-foundation/1-org/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   mkdir -p .github/workflows
   cp ../terraform-example-foundation/build/github-tf-* ./.github/workflows/
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```


1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars`

   ```bash
   mv ./envs/shared/terraform.example.tfvars ./envs/shared/terraform.tfvars
   ```

1. Check if a Security Command Center Notification with the default name, **scc-notify**, already exists. If it exists, choose a different value for the `scc_notification_name` variable in the `./envs/shared/terraform.tfvars` file.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -json common_config | jq '.org_id' --raw-output)
   gcloud scc notifications describe "scc-notify" --organization=${ORGANIZATION_ID}
   ```

1. Check if your organization already has an Access Context Manager Policy.

   ```bash
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```

1. Update the `envs/shared/terraform.tfvars` file with values from your environment and 0-bootstrap step. If the previous step showed a numeric value, make sure to un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](../1-org/envs/shared/README.md#inputs) for additional information on the values in the `terraform.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars

   if [ ! -z "${ACCESS_CONTEXT_MANAGER_ID}" ]; then sed -i "s=//create_access_context_manager_access_policy=create_access_context_manager_access_policy=" ./envs/shared/terraform.tfvars; fi
   ```

1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize org repo'
   ```

1. Push your plan branch.

   ```bash
   git push --set-upstream origin plan
   ```

1. Review the plan output in GitHub.
1. Merge changes to production branch.

   ```bash
   git checkout -b production
   git push --set-upstream origin production
   ```

## Deploying step 2-environments

1. Clone the repository you created to host the `2-environments` terraform configuration at the same level of the `terraform-example-foundation` folder.

   ```bash
   git clone <GITHUB-ENVIRONMENTS-REPO> gcp-environments
   ```

1. Navigate into the repo, change to the non-main branch and copy contents of foundation to new repo.
   All subsequent steps assume you are running them from the `gcp-environments` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-environments
   git checkout -b plan

   cp -RT ../terraform-example-foundation/2-environments/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   mkdir -p .github/workflows
   cp ../terraform-example-foundation/build/github-tf-* ./.github/workflows/
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `terraform.example.tfvars` to `terraform.tfvars`.

   ```bash
   mv terraform.example.tfvars terraform.tfvars
   ```

1. Update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values). See any of the envs folder [README.md](../2-environments/envs/production/README.md#inputs) files for additional information on the values in the `terraform.tfvars` file.

   ```bash
   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" terraform.tfvars
   ```

1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize environments repo'
   ```

1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_.

   ```bash
   git push --set-upstream origin plan
   ```

1. Review the plan output in GitHub.
1. Merge changes to development branch. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.

   ```bash
   git checkout -b development
   git push --set-upstream origin development
   ```

1. Review the apply output in GitHub.
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in GitHub.

   ```bash
   git checkout -b non-production
   git push --set-upstream origin non-production
   ```

1. Merge changes to production branch. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output GitHub.

   ```bash
   git checkout -b production
   git push --set-upstream origin production
   ```

1. You can now move to the instructions in the network stage.
To use the [Dual Shared VPC](https://cloud.google.com/architecture/security-foundations/networking#vpcsharedvpc-id7-1-shared-vpc-) network mode go to [Deploying step 3-networks-dual-svpc](#deploying-step-3-networks-dual-svpc),
or go to [Deploying step 3-networks-hub-and-spoke](#deploying-step-3-networks-hub-and-spoke) to use the [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) network mode.

## Deploying step 3-networks-dual-svpc

1. Clone the repository you created to host the `3-networks-dual-svpc` terraform configuration at the same level of the `terraform-example-foundation` folder.

   ```bash
   git clone <GITHUB-NETWORKS-REPO> gcp-networks
   ```

1. Navigate into the repo, change to the non-main branch and copy contents of foundation to new repo.
   All subsequent steps assume you are running them from the `gcp-networks` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-networks
   git checkout -b plan

   cp -RT ../terraform-example-foundation/3-networks-dual-svpc/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   mkdir -p .github/workflows
   cp ../terraform-example-foundation/build/github-tf-* ./.github/workflows/
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```

1. Update `common.auto.tfvars` file with values from your environment and bootstrap.
See any of the envs folder [README.md](../3-networks-dual-svpc/envs/production/README.md#inputs) files for additional information on the values in the `common.auto.tfvars` file.
Update `shared.auto.tfvars` file with the `target_name_server_addresses`.
Update `access_context.auto.tfvars` file with the `access_context_manager_policy_id`.
Use `terraform output` to get the backend bucket value from gcp-bootstrap output.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -json common_config | jq '.org_id' --raw-output)
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"

   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars

   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars
   ```

1. Commit changes

   ```bash
   git add .
   git commit -m 'Initialize networks repo'
   ```

1. You must manually plan and apply the `shared` environment (only once) since the `development`, `non-production` and `production` environments depend on it.
1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Use `terraform output` to get the CI/CD project ID and the networks step Terraform Service Account from gcp-bootstrap output.
An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw networks_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/policy-library ${CICD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```

1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_. Review the plan output in Github.

   ```bash
   git push --set-upstream origin plan
   ```

1. Merge changes to production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in Github.

   ```bash
   git checkout -b production
   git push --set-upstream origin production
   ```

1. After production has been applied, apply development.
1. Merge changes to development. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in Github.

   ```bash
   git checkout -b development
   git push --set-upstream origin development
   ```

1. After development has been applied, apply non-production.
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b non-production
   git push --set-upstream origin non-production
   ```

1. Before executing the next steps, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```

1. You can now move to the instructions in the [4-projects](#deploying-step-4-projects) stage.

## Deploying step 3-networks-hub-and-spoke

1. Clone the repository you created to host the `3-networks-hub-and-spoke` terraform configuration at the same level of the `terraform-example-foundation` folder.

   ```bash
   git clone <GITHUB-NETWORKS-REPO> gcp-networks
   ```

1. Navigate into the repo, change to the non-main branch and copy contents of foundation to new repo.
   All subsequent steps assume you are running them from the `gcp-networks` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-networks
   git checkout -b plan

   cp -RT ../terraform-example-foundation/3-networks-hub-and-spoke/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   mkdir -p .github/workflows
   cp ../terraform-example-foundation/build/github-tf-* ./.github/workflows/
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```

1. Update `common.auto.tfvars` file with values from your environment and bootstrap.
See any of the envs folder [README.md](../3-networks-dual-svpc/envs/production/README.md#inputs) files for additional information on the values in the `common.auto.tfvars` file.
Update `shared.auto.tfvars` file with the `target_name_server_addresses`.
Update `access_context.auto.tfvars` file with the `access_context_manager_policy_id`.
Use `terraform output` to get the backend bucket value from gcp-bootstrap output.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -json common_config | jq '.org_id' --raw-output)
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"

   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars

   export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars
   ```

1. Commit changes

   ```bash
   git add .
   git commit -m 'Initialize networks repo'
   ```

1. You must manually plan and apply the `shared` environment (only once) since the `development`, `non-production` and `production` environments depend on it.
1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Use `terraform output` to get the CI/CD project ID and the networks step Terraform Service Account from gcp-bootstrap output.
An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw networks_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/policy-library ${CICD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```

1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_. Review the plan output in Github.

   ```bash
   git push --set-upstream origin plan
   ```

1. Merge changes to production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in Github.

   ```bash
   git checkout -b production
   git push --set-upstream origin production
   ```

1. After production has been applied, apply development.
1. Merge changes to development. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in Github.

   ```bash
   git checkout -b development
   git push --set-upstream origin development
   ```

1. After development has been applied, apply non-production.
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b non-production
   git push --set-upstream origin non-production
   ```

1. Before executing the next steps, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```

1. You can now move to the instructions in the [4-projects](#deploying-step-4-projects) stage.

## Deploying step 4-projects

1. Clone the repository you created to host the `4-projects` terraform configuration at the same level of the `terraform-example-foundation` folder.

   ```bash
   git clone <GITHUB-NETWORKS-REPO> gcp-projects
   ```

1. Navigate into the repo, change to the non-main branch and copy contents of foundation to new repo.
   All subsequent steps assume you are running them from the `gcp-projects` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-projects
   git checkout -b plan

   cp -RT ../terraform-example-foundation/4-projects/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   mkdir -p .github/workflows
   cp ../terraform-example-foundation/build/github-tf-* ./.github/workflows/
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `auto.example.tfvars` files to `auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv development.auto.example.tfvars development.auto.tfvars
   mv non-production.auto.example.tfvars non-production.auto.tfvars
   mv production.auto.example.tfvars production.auto.tfvars
   ```

1. See any of the envs folder [README.md](../4-projects/business_unit_1/production/README.md#inputs) files for additional information on the values in the `common.auto.tfvars`, `development.auto.tfvars`, `non-production.auto.tfvars`, and `production.auto.tfvars` files.
1. See any of the shared folder [README.md](../4-projects/business_unit_1/shared/README.md#inputs) files for additional information on the values in the `shared.auto.tfvars` file.

1. Use `terraform output` to get the backend bucket value from 0-bootstrap output.

   ```bash
   export remote_state_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${remote_state_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars
   ```

1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize projects repo'
   ```

1. You need to manually plan and apply only once the `business_unit_1/shared` and `business_unit_2/shared` environments since `development`, `non-production`, and `production` depend on them.
1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Use `terraform output` to get the CI/CD project ID and the projects step Terraform Service Account from gcp-bootstrap output.
An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CICD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)
   echo ${CICD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw projects_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/policy-library ${CICD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```

1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_. Review the plan output in Github.

   ```bash
   git push --set-upstream origin plan
   ```

1. Merge changes to production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in Github.

   ```bash
   git checkout -b production
   git push --set-upstream origin production
   ```

1. After production has been applied, apply development.
1. Merge changes to development. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in Github.

   ```bash
   git checkout -b development
   git push --set-upstream origin development
   ```

1. After development has been applied, apply non-production.
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in Github.

   ```bash
   git checkout -b non-production
   git push --set-upstream origin non-production
   ```

1. Unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```
