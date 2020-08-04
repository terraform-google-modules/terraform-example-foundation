# 1-org

The purpose of this step is to setup top level shared folders, monitoring & networking projects, org level logging and set baseline security settings through organizational policy.

## Prerequisites

1. 0-bootstrap executed successfully.
2. Cloud Identity / G Suite group for security admins
3. Membership in the security admins group for user running terraform

## Usage

**Disclaimer:** This step enables [Data Access logs](https://cloud.google.com/logging/docs/audit#data-access) for all services in your organization.
Enabling Data Access logs might result in your project being charged for the additional logs usage.
For details on costs you might incur, go to [Pricing](https://cloud.google.com/stackdriver/pricing).
You can choose not to enable the Data Access logs by setting variable `data_access_logs_enabled` to false.

### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-org --project=YOUR_CLOUD_BUILD_PROJECT_ID` (this is from terraform output from the previous section, 0-bootstrap).
1. Navigate into the repo `cd gcp-org` and change to a non production branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/1-org/ .` (modify accordingly based on your current directory).
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values). Make sure that `default_region` is set to a valid [BigQuery dataset region](https://cloud.google.com/bigquery/docs/locations).
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your plan branch to trigger a plan `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Setup to run via Jenkins
1. Clone repo you created manually in Bootstrap: `git clone <YOUR_NEW_REPO-1-org>`
1. Navigate into the repo `cd YOUR_NEW_REPO_CLONE-1-org` and change to a non production branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/1-org/* .` (modify accordingly based on your current directory).
1. Copy the `Jenkinsfile` to the root of your new repository and replace the `_TF_SA_EMAIL` with the name of your Terraform Service Account in the `seed` project. (modify accordingly based on your current directory):
   ```
   cp ../terraform-example-foundation/build/Jenkinsfile .
   sed -i 's/_TF_SA_EMAIL/TF_SERVICE_ACCOUNT_EMAIL/' Jenkinsfile
   ```
   **If using MacOS:**
    ```
    cp ../terraform-example-foundation/build/Jenkinsfile .
    sed -i '.bak' 's/_TF_SA_EMAIL/TF_SERVICE_ACCOUNT_EMAIL/' Jenkinsfile
    rm Jenkinsfile.bak
    ```
1. Copy the `tf-wrapper.sh` configuration file to the root of your new repository (modify accordingly based on your current directory):
    ```
    cp ../terraform-example-foundation/build/tf-wrapper.sh .
    ```
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment. (you can re-run `terraform output` in the 0-bootstrap directory to find these values). Make sure that `default_region` is set to a valid [BigQuery dataset region](https://cloud.google.com/bigquery/docs/locations).
    ```
    # Rename file
    mv envs/shared/terraform.example.tfvars envs/shared/terraform.tfvars
    # Edit the file to provide the necessary values
    vi envs/shared/terraform.tfvars
    ```

1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your plan branch `git push --set-upstream origin plan`. The branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan.
    - Assuming you configured an automatic trigger in your Jenkins Master (see [Jenkins sub-module README](../../../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](www.jenkins.io) for more details.
    1. Review the plan output in your Master's web UI.
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

### Run terraform locally
1. Change into 1-org folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`
1. Change into 1-org/envs/shared/ folder.
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Update backend.tf with your bucket from bootstrap. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.
You can run `terraform output gcs_bucket_tfstate` in the 0-bootstap folder to obtain the bucket name.

We will now deploy our environment (production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 1-org step and only the corresponding environment is applied.

1. Run `./tf-wrapper.sh init production`
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh apply production`

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan production` before run `./tf-wrapper.sh apply production`
