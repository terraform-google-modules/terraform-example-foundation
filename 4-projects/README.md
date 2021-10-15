# 4-projects

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
<td><a href="../1-org">1-org</a></td>
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
<td>4-projects (this file)</td>
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

The purpose of this step is to set up the folder structure, projects, and infrastructure pipelines for applications that are connected as service projects to the shared VPC created in the previous stage.
For each business unit, a shared `infra-pipeline` project is created along with Cloud Build triggers, CSRs for application infrastructure code and Google Cloud Storage buckets for state storage.
This step follows the same [conventions](https://github.com/terraform-google-modules/terraform-example-foundation#branching-strategy) as the foundation pipeline deployed in [0-bootstrap](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README.md).
The Cloud Build SA used by this pipeline can impersonate the project SA by enabling the `enable_cloudbuild_deploy` flag and necessary roles can be granted to this SA via `sa_roles` as shown in this [example](business_unit_1/development/example_base_shared_vpc_project.tf).
This pipeline can be utilized for deploying resources in projects across development/non-production/production with granular permissions.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. 3-networks executed successfully.
1. Obtain the value for the `access_context_manager_policy_id` variable.

   ```bash
   gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"
   ```

1. For the manual step described in this document, you need [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 to be installed.

   **Note:** Make sure that you use the same version of Terraform throughout this series. Otherwise, you might experience Terraform state snapshot lock errors.

1. Obtain the values for the `perimeter_name` for each environment variable.

   ```bash
   gcloud access-context-manager perimeters list --policy ACCESS_CONTEXT_MANAGER_POLICY_ID --format="value(name)"
   ```

   **Note:** If you have more than one service perimeter for each environment, you can also get the values from the `restricted_service_perimeter_name` output from each of the`3-networks` environments.

   If you are using Cloud Build you can also search for the values in the outputs from the build logs:

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

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Note:** You need to set variable `enable_hub_and_spoke` to `true` to be able to use the **Hub-and-Spoke** architecture detailed in the **Networking** section of the [google cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf).

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

### Deploying with Cloud Build

1. Clone repo.
   ```
   gcloud source repos clone gcp-projects --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```
1. Change freshly cloned repo and change to non-main branch.
   ```
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/4-projects/ .
   ```
1. Copy Cloud Build configuration files for Terraform.
   ```
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   ```
1. Copy Terraform wrapper script to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap. See any of the business unit envs folders [README.md](./business_unit_1/development/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with values from your environment and bootstrap. See any of the business unit shared envs folders [README.md](./business_unit_1/shared/README.md) files for additional information on the values in the `shared.auto.example.tfvars`.
1. Rename `development.auto.example.tfvars` to `development.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_d_shared_restricted`.
1. Rename `non-production.auto.example.tfvars` to `non-production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_n_shared_restricted`.
1. Rename `production.auto.example.tfvars` to `production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_p_shared_restricted`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. You need to manually plan and apply only once the `business_unit_1/shared` environment since `development`, `non-production`, and `production` depend on it.
    1. Run `cd ./business_unit_1/shared/`.
    1. Update `backend.tf` with your bucket name from the 0-bootstrap step.
    1. Run `terraform init`.
    1. Run `terraform plan` and review output.
    1. Run `terraform apply`.
    1. Run `terraform output cloudbuild_sa` to get the cloud build service account from the apply step.
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`
1. Once you have done the instructions for the `business_unit_1`, you need to repeat same steps for `business_unit_2` folder.
1. Rename `business_unit_1.auto.example.tfvars` to `business_unit_1.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_1/shared` steps.
1. Rename `business_unit_2.auto.example.tfvars` to `business_unit_2.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_2/shared` steps.
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
1. Review the plan output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production. Because this is a [named environment branch](./docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After production has been applied, apply development.
1. Merge changes to development. Because this is a [named environment branch](./docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After development has been applied, apply non-production.
1. Merge changes to non-production. Because this is a [named environment branch](./docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. You can now move to the instructions in the step [5-app-infra](../5-app-infra/README.md).

### Deploying with Jenkins

1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-4-projects>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the gcp-environments directory. If
   you run them from another directory, adjust your copy paths accordingly.
   ```
   cd YOUR_NEW_REPO_CLONE-4-projects
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/4-projects/ .
   ```
1. Copy the Jenkinsfile script to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/Jenkinsfile .
   ```
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the cicd project id)
    ```
1. Copy Terraform wrapper script  to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `development.auto.example.tfvars` to `development.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_d_shared_restricted`.
1. Rename `non-production.auto.example.tfvars` to `non-production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_n_shared_restricted`.
1. Rename `production.auto.example.tfvars` to `production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_p_shared_restricted`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. You need to manually plan and apply only once the `business_unit_1/shared` environment since `development`, `non-production`, and `production` depend on it.
    1. Run `cd ./business_unit_1/shared/`.
    1. Update `backend.tf` with your bucket name from the 0-bootstrap step.
    1. Run `terraform init`.
    1. Run `terraform plan` and review output.
    1. Run `terraform apply`.
    1. Run `terraform output cloudbuild_sa` to get the cloud build service account from the apply step.
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`
1. Once you have done the instructions for the `business_unit_1`, you need to repeat same steps for `business_unit_2` folder.
1. Rename `business_unit_1.auto.example.tfvars` to `business_unit_1.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_1/shared` steps.
1. Rename `business_unit_2.auto.example.tfvars` to `business_unit_2.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_2/shared` steps.
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch.
   ```
   git push --set-upstream origin plan
   ```
    - Assuming you configured an automatic trigger in your Jenkins Master (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](http://www.jenkins.io) for more details.
1. Review the plan output in your Master's web UI.
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Master's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. After production has been applied, apply development.
1. Merge changes to development branch.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Master's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. After development has been applied, apply non-production.
1. Merge changes to non-production branch.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Master's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

### Run Terraform locally

1. Change into 4-projects folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `development.auto.example.tfvars` to `development.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_d_shared_restricted`.
1. Rename `non-production.auto.example.tfvars` to `non-production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_n_shared_restricted`.
1. Rename `production.auto.example.tfvars` to `production.auto.tfvars` and update the file with the `perimeter_name` that starts with `sp_p_shared_restricted`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. Update `backend.tf` with your bucket from the bootstrap step.
   ```
   for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done
   ```
   You can run `terraform output gcs_bucket_tfstate` in the 0-bootstrap folder to obtain the bucket name.

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 4-projects step and only the corresponding environment is applied. Environment shared must be applied first because development, non-production, and production depend on it.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://github.com/GoogleCloudPlatform/terraform-validator/blob/main/docs/install.md) in the **Install Terraform Validator** section and install version `v0.4.0` in your system. You will also need to rename the binary from `terraform-validator-<your-platform>` to `terraform-validator` and the `terraform-validator` binary must be in your `PATH`.

1. Run `./tf-wrapper.sh init shared`.
1. Run `./tf-wrapper.sh plan shared` and review output.
1. Run `./tf-wrapper.sh validate shared $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply shared`.
1. Rename `business_unit_1.auto.example.tfvars` to `business_unit_1.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_1/shared` steps.
1. Rename `business_unit_2.auto.example.tfvars` to `business_unit_2.auto.tfvars` and update the file with the `app_infra_pipeline_cloudbuild_sa` which is the output of `cloudbuild_sa` from `business_unit_2/shared` steps.
1. Run `./tf-wrapper.sh init production`.
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh validate production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply production`.
1. Run `./tf-wrapper.sh init non-production`.
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh validate non-production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply non-production`.
1. Run `./tf-wrapper.sh init development`.
1. Run `./tf-wrapper.sh plan development` and review output.
1. Run `./tf-wrapper.sh validate development $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply development`.

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before running `./tf-wrapper.sh apply <env>`.
