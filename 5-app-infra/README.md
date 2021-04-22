# 5-app-infra

The purpose of this step is to deploy a simple [Compute Engine](https://cloud.google.com/compute/) instance in one of the business unit projects using the infra pipeline setup in 4-projects.
The infra pipeline is created in step 4-projects within the shared env and has a [Cloudbuild](https://cloud.google.com/build/docs) pipeline configured to manage infrastructure within projects. To enable deployment via this pipeline, the projects deployed should [enable](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects/business_unit_1/development/example_base_shared_vpc_project.tf#L31-L32) `enable_cloudbuild_deploy` flag and provide the Cloud Build service account value via`cloudbuild_sa`.

This enables the Cloud Build service account to impersonate the project service account and use it to deploy infrastructure. The roles required for project SA can also be [managed](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects/business_unit_1/development/example_base_shared_vpc_project.tf#L30) via `sa_roles`. (Note: This requires per project SA impersonation, if you would like to have a single SA managing an environment and all associated projects, that is also possible by [granting](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects/modules/single_project/main.tf#L62-L68) `roles/iam.serviceAccountTokenCreator` to an SA with the right roles in `4-projects/env`.)

There is also a [Source Repository](https://cloud.google.com/source-repositories) configured with build triggers similar to [foundation pipeline](https://github.com/terraform-google-modules/terraform-example-foundation#0-bootstrap) setup in `0-bootstrap`.
This Compute Engine instance will be created using the base network created during step 3-networks to access private services.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. 3-networks executed successfully.
1. 4-projects executed successfully.

## Usage

### Setup to run via Cloud Build

1. Clone repo `gcloud source repos clone gcp-policies --project=prj-bu1-c-infra-pipeline-<random>`. (this is from the terraform output from the previous section, run `terraform output cloudbuild_project_id` in the `4-projects/business_unit_1/shared` folder).
1. Navigate into the repo `cd gcp-policies`.
1. Copy contents of policy-library to new repo `cp -RT ../terraform-example-foundation/policy-library/ .` (modify accordingly based on your current directory).
1. Commit changes with `git add .` and `git commit -m 'Your message'`.
1. Push your master branch to the new repo `git push --set-upstream origin master`.
1. Navigate out of the repo `cd ..`.
1. Clone repo `gcloud source repos clone bu1-example-app --project=prj-bu1-c-infra-pipeline-<random>`. (this is from the terraform output from the previous section, run `terraform output cloudbuild_project_id` in the `4-projects/business_unit_1/shared` folder)
1. Navigate into the repo `cd bu1-example-app`.
1. Change freshly cloned repo and change to non-master branch `git checkout -b plan`.
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/5-app-infra/ .` (modify accordingly based on your current directory).
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment.
1. Rename `bu1-development.auto.example.tfvars` to `bu1-development.auto.tfvars` and update the file with values from your environment.
1. Rename `bu1-non-production.auto.example.tfvars` to `bu1-non-production.auto.tfvars` and update the file with values from your environment.
1. Rename `bu1-production.auto.example.tfvars` to `bu1-production.auto.tfvars` and update the file with values from your environment.
1. Commit changes with `git add .` and `git commit -m 'Your message'`.
1. Push your plan branch to trigger a plan for all environments `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to development with `git checkout -b development` and `git push origin development`.
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to non-production with `git checkout -b non-production` and `git push origin non-production`.
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`.
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Run terraform locally

1. Change into 5-app-infra folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Update backend.tf with your bucket from infra pipeline example. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 5-app-infra step and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, the latest version of `terraform-validator` must be [installed](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator) in your system and in your `PATH`.

1. Run `./tf-wrapper.sh init production`.
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh validate production $(pwd)/../policy-library <YOUR_INFRA_PIPELINE_PROJECT>` and check for violations.
1. Run `./tf-wrapper.sh apply production`.
1. Run `./tf-wrapper.sh init non-production`.
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh validate non-production $(pwd)/../policy-library <YOUR_INFRA_PIPELINE_PROJECT>` and check for violations.
1. Run `./tf-wrapper.sh apply non-production`.
1. Run `./tf-wrapper.sh init development`.
1. Run `./tf-wrapper.sh plan development` and review output.
1. Run `./tf-wrapper.sh validate development $(pwd)/../policy-library <YOUR_INFRA_PIPELINE_PROJECT>` and check for violations.
1. Run `./tf-wrapper.sh apply development`.

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`.
