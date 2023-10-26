# Deploying a GitLab CI/CD compatible environment

The objective of the following instructions is to configure the infrastructure that allows CI/CD deployments using
GitLab CI/CD for the deploy of the Terraform Example Foundation stages (`0-bootstrap`, `1-org`, `2-environments`, `3-networks`, `4-projects`).
The infrastructure consists in two Google Cloud Platform projects (`prj-b-seed` and `prj-b-cicd-wif-gl`).

It is a best practice to have two separate projects here (`prj-b-seed` and `prj-b-cicd-wif-gl`) for separation of concerns.
On one hand, `prj-b-seed` stores terraform state and has the Service Accounts able to create / modify infrastructure.
On the other hand, the authentication infrastructure using [Workload identity federation](https://cloud.google.com/iam/docs/workload-identity-federation) is implemented in `prj-b-cicd-wif-gl`.

To run the instructions described in this document, install the following:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0 or later
    - [terraform-tools](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) component
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0 or later
- [GLab](https://gitlab.com/gitlab-org/cli) version 1.32.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.3.0  or later

Also make sure that you have the following:

- A [GitLab](https://docs.gitlab.com/ee/user/profile/account/create_accounts.html) account for your User or Group.
- A private GitLab project (repository) for each one of the stages of Foundation:
    - Bootstrap
    - Organization
    - Environments
    - Networks
    - Projects
- A [Personal](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) access token or a [Group](https://docs.gitlab.com/ee/user/group/settings/group_access_tokens.html) access token configured with the following [scopes](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#personal-access-token-scopes):
    - read_api
    - create_runner
    - read_repository
    - write_repository
    - read_registry
    - write_registry
- A [Runner](https://docs.gitlab.com/ee/tutorials/create_register_first_runner/) with the name `gl_runner` should be created in your GitLab account. Save the token of the runner once it has been created. It will be used in the next steps.
- A Google Cloud [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
- A Google Cloud [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
- Cloud Identity or Google Workspace groups for organization and billing admins.
- Add the Identity (user or Service Account) who will run Terraform to the `group_org_admins` group.
They must be in this group, or they won't have `roles/resourcemanager.projectCreator` access.
- For the Identity who will run the procedures in this document, grant the following roles:
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

### Clone Terraform Example Foundation repo

1. Clone [terraform-example-foundation](https://github.com/terraform-google-modules/terraform-example-foundation) into your local environment.

   ```bash
   git clone https://github.com/terraform-google-modules/terraform-example-foundation.git
   ```

### Build CI/CD runner image

1. Clone the private project you created to host the docker configuration for the CI/CD runner at the same level of the `terraform-example-foundation` folder.
You must have [SSH keys](https://docs.gitlab.com/ee/user/ssh.html) configured with GitLab.

   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-RUNNER-REPO>.git gcp-cicd-runner
   ```

1. Navigate into the repo. All subsequent
   steps assume you are running them from the `gcp-cicd-runner` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-cicd-runner
   ```

1. Copy contents of foundation to cloned project (modify accordingly based on your current directory).

   ```bash
   cp ../terraform-example-foundation/build/gitlab/gitlab-build-image-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/gitlab/Dockerfile ./Dockerfile
   ```

1. Save the CI/CD runner configuration to `gcp-cicd-runner` GitLab project:

   ```bash
   git add .
   git commit -m 'Initialize CI/CD runner project'
   git push --set-upstream origin main
   ```

1. Review the CI/CD Job output in GitLab https://gitlab.com/GITLAB-OWNER/GITLAB-RUNNER-REPO/-/jobs under name `build-image`.
1. If the CI/CD Job is successful proceed with the next steps

### Deploying step 0-bootstrap

1. Clone the private project you created to host the `0-bootstrap` terraform configuration at the same level of the `terraform-example-foundation` folder.
You must have [SSH keys](https://docs.gitlab.com/ee/user/ssh.html) configured with GitLab.

   ```bash
   git clone git@gitlab.com:<GITLAB-OWNER>/<GITLAB-BOOTSTRAP-REPO>.git gcp-bootstrap
   ```

1. The layout should be:

   ```bash
   gcp-bootstrap/
   gcp-cicd-runner/
   terraform-example-foundation/
   ```

1. Navigate into the repo. All subsequent
   steps assume you are running them from the `gcp-bootstrap` directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd gcp-bootstrap
   ```

1. change to a non-production branch.

   ```bash
   git checkout -b plan
   ```

1. Copy contents of foundation to cloned project (modify accordingly based on your current directory).

   ```bash
   mkdir -p envs/shared

   cp -RT ../terraform-example-foundation/0-bootstrap/ ./envs/shared
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
   cp ../terraform-example-foundation/build/run_gcp_sts.sh .
   chmod 755 ./run_gcp_sts.sh
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
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
   ../../../terraform-example-foundation/scripts/validate-requirements.sh  -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID> -u <END_USER_EMAIL> -t GitHub
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

   *`A-VALID-PROJECT-ID`* must be an existing project you have access to. This is necessary because Terraform-validator needs to link resources to a valid Google Cloud Platform project.

1. No violations and an output with `done` means the validation was successful.

1. Run `terraform apply`.

   ```bash
   terraform apply bootstrap.tfplan
   ```

1. Once `terraform apply` has finished, access the Gitlab instance by ssh that has been created and update following fields in the file `/etc/gitlab-runner/config.toml` using the values showed during the Gitlab Runner creation.

```bash
name = "xxxx"
token = "glrt-XXX"
```

1. Copy the file `gitlab-ci.yml` to the 0-bootstrap directory.
```bash
cp ./modules/gitlab-runner/gitlab-ci.yml .
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

   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_PROJECTS_BACKEND/${backend_bucket}/" $i; done

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
   git push --set-upstream origin plan
   ```


TODO

**Note 1:** The stages after `0-bootstrap` use `terraform_remote_state` data source to read common configuration like the organization ID from the output of the `0-bootstrap` stage.
They will [fail](../docs/TROUBLESHOOTING.md#error-unsupported-attribute) if the state is not copied to the Cloud Storage bucket.

**Note 2:** After the deploy, to prevent the project quota error described in the [Troubleshooting guide](../docs/TROUBLESHOOTING.md#project-quota-exceeded),
we recommend that you request 50 additional projects for the **projects step service account** created in this step.


