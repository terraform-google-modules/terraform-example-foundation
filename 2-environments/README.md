# 2-environments

The purpose of this step is to set up development, non-production and production environments within the GCP organization.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. Cloud Identity / Google Workspace group for monitoring admins.
1. Membership in the monitoring admins group for user running terraform.

## Usage

### Setup to run via Cloud Build

1. Clone repo `gcloud source repos clone gcp-environments --project=YOUR_CLOUD_BUILD_PROJECT_ID`.
1. Navigate into the repo `cd gcp-environments` and change to non master branch `git checkout -b plan`.
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/2-environments/ .` (modify accordingly based on your current directory).
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values). See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `terraform.tfvars` file.
1. Commit changes with `git add .` and `git commit -m 'Your message'`.
1. Push your plan branch to trigger a plan for all environments `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to development with `git checkout -b development` and `git push origin development`.
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to non-production with `git checkout -b non-production` and `git push origin non-production`.
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`.
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Setup to run via Jenkins

1. Clone the repo you created manually in bootstrap: `git clone <YOUR_NEW_REPO-2-environments>`.
1. Navigate into the repo `cd YOUR_NEW_REPO_CLONE-2-environments` and change to a non production branch `git checkout -b plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/2-environments/ .` (modify accordingly based on your current directory).
1. Copy the Jenkinsfile script `cp ../terraform-example-foundation/build/Jenkinsfile .` to the root of your new repository (modify accordingly based on your current directory).
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the cicd project id)
    ```
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values). See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `terraform.tfvars` file.
1. Commit changes with `git add .` and `git commit -m 'Your message'`.
1. Push your plan branch `git push --set-upstream origin plan`. The branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan.
    - Assuming you configured an automatic trigger in your Jenkins Master (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](http://www.jenkins.io) for more details.
    1. Review the plan output in your Master's web UI.
1. Merge changes to development with `git checkout -b development` and `git push origin development`.
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. Merge changes to non-production with `git checkout -b non-production` and `git push origin non-production`.
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`.
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

1. You can now move to the instructions in the step [3-networks](../3-networks/README.md).

### Run terraform locally

1. Change into 2-environments folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`.
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `terraform.tfvars` file.
1. Update backend.tf with your bucket from bootstrap. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.
You can run `terraform output gcs_bucket_tfstate` in the 0-bootstap folder to obtain the bucket name.

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 2-environments step and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, the latest version of `terraform-validator` must be [installed](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator) in your system and in you `PATH`.

1. Run `./tf-wrapper.sh init development`.
1. Run `./tf-wrapper.sh plan development` and review output.
1. Run `./tf-wrapper.sh validate development $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply development`.
1. Run `./tf-wrapper.sh init non-production`.
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh validate non-production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply non-production`.
1. Run `./tf-wrapper.sh init production`.
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh validate production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply production`.

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`.
