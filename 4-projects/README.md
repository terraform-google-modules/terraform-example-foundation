# 4-projects

The purpose of this step is to set up folder structure, projects and infrastructure pipelines for applications, which are connected as service projects to the shared VPC created in the previous stage. For each business unit, a shared `infra-pipeline` project is created along with Cloud Build triggers, CSRs for application infrastructure code, GCS buckets for state storage and follows the same [conventions](https://github.com/terraform-google-modules/terraform-example-foundation#branching-strategy) as the foundation pipeline deployed in [0-bootstrap](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README.md). The cloudbuild SA used by this pipeline can impersonate the project SA by enabling the `enable_cloudbuild_deploy` flag and necessary roles can be granted to this SA via `sa_roles` as show in this [example](business_unit_1/development/example_base_shared_vpc_project.tf). This pipeline can be utilized for deploying resources in projects across development/non-production/production with granular permissions.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. 3-networks executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`.
1. Obtain the values for the `perimeter_name` for each environment variable by running `gcloud access-context-manager perimeters list --policy ACCESS_CONTEXT_MANAGER_POLICY_ID --format="value(name)"`.

**Troubleshooting:**
If your user does not have access to run the commands above and you are in the organization admins group, you can append `--impersonate-service-account=org-terraform@<SEED_PROJECT_ID>.iam.gserviceaccount.com` to run the command as the terraform service account.

**Note:** If you have more then one service perimeter for each environment you can also get the values from the `restricted_service_perimeter_name` output from each of the`3-networks` environments.

If you are using Cloud Build you can also search for the values in the outputs in the build logs:

```console
gcloud builds list \
 --project=YOUR_CLOUD_BUILD_PROJECT_ID \
 --filter="status=SUCCESS \
 AND source.repoSource.repoName=gcp-networks \
 AND substitutions.BRANCH_NAME=development" \
 --format="value(id)"
```

Use the result of this command as the `BUILD_ID` value in the next command:

```console
gcloud builds log BUILD_ID \
 --project=YOUR_CLOUD_BUILD_PROJECT_ID | \
 grep "restricted_service_perimeter_name = "
```

Change the `BRANCH_NAME` from `development` to `non-production` or `production` for the other two service perimeters.

## Usage

### Setup to run via Cloud Build

1. Clone repo `gcloud source repos clone gcp-projects --project=YOUR_CLOUD_BUILD_PROJECT_ID`.
1. Change freshly cloned repo and change to non master branch `git checkout -b plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/4-projects/ .` (modify accordingly based on your current directory).
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `development.auto.example.tfvars` to `development.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_d_shared_restricted`.
1. Rename `non-production.auto.example.tfvars` to `non-production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_n_shared_restricted`.
1. Rename `production.auto.example.tfvars` to `production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_p_shared_restricted`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. You will need only once to manually plan + apply the `business_unit_1/shared` environment since `development`, `non-production` and `production` depend on it.
    1. Run `cd ./business_unit_1/shared/`.
    1. Update `backend.tf` with your bucket name from the bootstrap step.
    1. Run `terraform init`.
    1. Run `terraform plan` and review output.
    1. Run `terraform apply`.
    1. Run `terraform output cloudbuild_sa` to get the cloudbuild service account from the apply step.
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`
1. Once you have done the instructions for the `business_unit_1`, you need to repeat same steps for `business_unit_2` folder.
1. Rename `business_unit_1.auto.example.tfvars` to `business_unit_1.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_1` shared steps.
1. Rename `business_unit_2.auto.example.tfvars` to `business_unit_2.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_2` shared steps.
1. Commit changes with `git add .` and `git commit -m 'Your message'`.
1. Push your plan branch to trigger a plan `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production with `git checkout -b production` and `git push origin production`.
    1. Review the apply output in your cloud build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to development with `git checkout -b development` and `git push origin development`.
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to non-production with `git checkout -b non-production` and `git push origin non-production`.
    1. Review the apply output in your cloud build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Setup to run via Jenkins

1. Clone the repo you created manually in bootstrap: `git clone <YOUR_NEW_REPO-4-projects>`.
1. Navigate into the repo `cd YOUR_NEW_REPO_CLONE-4-projects` and change to a non production branch `git checkout -b plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/4-projects/ .` (modify accordingly based on your current directory).
1. Copy the Jenkinsfile script `cp ../terraform-example-foundation/build/Jenkinsfile .` to the root of your new repository (modify accordingly based on your current directory).
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the cicd project id)
    ```
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `development.auto.example.tfvars` to `development.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_d_shared_restricted`.
1. Rename `non-production.auto.example.tfvars` to `non-production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_n_shared_restricted`.
1. Rename `production.auto.example.tfvars` to `production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_p_shared_restricted`.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your plan branch `git push --set-upstream origin plan`. The branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan.
    - Assuming you configured an automatic trigger in your Jenkins Master (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](http://www.jenkins.io) for more details.
    1. Review the plan output in your Master's web UI.
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`.
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. After production has been applied apply development and non-production.
1. Merge changes to development branch with `git checkout -b development` and `git push origin development`.
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. Merge changes to non-production branch with `git checkout -b non-production` and `git push origin non-production`.
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

1. You can now move to the instructions in the step [4-projects](../4-projects/README.md).

### Run terraform locally

1. Change into 4-projects folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `development.auto.example.tfvars` to `development.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_d_shared_restricted`.
1. Rename `non-production.auto.example.tfvars` to `non-production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_n_shared_restricted`.
1. Rename `production.auto.example.tfvars` to `production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_p_shared_restricted`.
1. Update backend.tf with your bucket from bootstrap. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.
You can run `terraform output gcs_bucket_tfstate` in the 0-bootstrap folder to obtain the bucket name.

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 4-projects step and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, the latest version of `terraform-validator` must be [installed](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator) in your system and in you `PATH`.

1. Run `./tf-wrapper.sh init shared`.
1. Run `./tf-wrapper.sh plan shared` and review output.
1. Run `./tf-wrapper.sh validate shared $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply shared`.
1. Run `./tf-wrapper.sh init production`.
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh validate production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply production`.
1. Run `./tf-wrapper.sh init non-production`.
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh validate non-production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply non-production`.
1. Run `./tf-wrapper.sh init development`.
1. Run `./tf-wrapper.sh plan development` and review output.
1. Run `./tf-wrapper.sh validate development $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply development`.

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`.
