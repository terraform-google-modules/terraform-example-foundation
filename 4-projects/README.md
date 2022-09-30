# 4-projects

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="../0-bootstrap">0-bootstrap</a></td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a <a href="../docs/GLOSSARY.md#foundation-cicd-pipeline">CI/CD Pipeline</a> for foundations code in subsequent
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
<td><a href="../3-networks-dual-svpc">3-networks-dual-svpc</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect, and baseline firewall rules for each environment. It also sets
up the global DNS hub.</td>
</tr>
<tr>
<td><a href="../3-networks-hub-and-spoke">3-networks-hub-and-spoke</a></td>
<td>Sets up base and restricted shared VPCs with all the default configuration
found on step 3-networks-dual-svpc, but here the architecture will be based on the
Hub and Spoke network model. It also sets up the global DNS hub</td>
</tr>
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
This step follows the same [conventions](https://github.com/terraform-google-modules/terraform-example-foundation#branching-strategy) as the CI/CD Pipeline deployed in [0-bootstrap](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README.md).
The Cloud Build SA used by this pipeline can impersonate the project SA by enabling the `enable_cloudbuild_deploy` flag and necessary roles can be granted to this SA via `sa_roles` as shown in this [example](business_unit_1/development/example_base_shared_vpc_project.tf).
This pipeline can be utilized for deploying resources in projects across development/non-production/production with granular permissions.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. 3-networks executed successfully.

1. For the manual step described in this document, you need [Terraform](https://www.terraform.io/downloads.html) version 1.3.0 or later to be installed.

   **Note:** Make sure that you use version 1.3.0 or later of Terraform throughout this series. Otherwise, you might experience Terraform state snapshot lock errors.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

### Deploying with Cloud Build

1. Clone repo.
   ```
   gcloud source repos clone gcp-projects --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```
1. Change freshly cloned repo and change to non-main branch.
   ```
   cd gcp-projects
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
1. Rename `development.auto.example.tfvars` to `development.auto.tfvars`.
1. Rename `non-production.auto.example.tfvars` to `non-production.auto.tfvars`.
1. Rename `production.auto.example.tfvars` to `production.auto.tfvars`.
1. You need to manually plan and apply only once the `business_unit_1/shared` environment since `development`, `non-production`, and `production` depend on it.
    1. Run `cd ./business_unit_1/shared/`.
    1. Update `backend.tf` with your bucket name from the 0-bootstrap step.
    1. Export the projects (`terraform-proj-sa`) service account for impersonation `export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="<IMPERSONATE_SERVICE_ACCOUNT>"`
    1. Run `terraform init`.
    1. Run `terraform plan` and review output.
    1. Run `terraform apply`.
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`
1. Once you have done the instructions for the `business_unit_1`, you need to repeat same steps for `business_unit_2` folder.
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch)), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After production has been applied, apply development.
1. Merge changes to development. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After development has been applied, apply non-production.
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. You can now move to the instructions in the step [5-app-infra](../5-app-infra/README.md).

### Deploying with Jenkins

See `0-bootstrap` [README-Jenkins.md](../0-bootstrap/README-Jenkins.md#deploying-step-4-projects)

### Run Terraform locally

1. Change into `4-projects` folder, copy the Terraform wrapper script and ensure it can be executed.
   ```
   cd 4-projects
   cp ../build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `auto.example.tfvars` files to `auto.tfvars`.
   ```
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv development.auto.example.tfvars development.auto.tfvars
   mv non-production.auto.example.tfvars non-production.auto.tfvars
   mv production.auto.example.tfvars production.auto.tfvars
   ```
1. See any of the envs folder [README.md](./business_unit_1/production/README.md) files for additional information on the values in the `common.auto.tfvars`, `development.auto.tfvars`, `non-production.auto.tfvars`, and `production.auto.tfvars` files.
1. See any of the shared folder [README.md](./business_unit_1/shared/README.md) files for additional information on the values in the `shared.auto.tfvars` file.
1. Use `terraform output` to get the backend bucket value from 0-bootstrap output.
   ```
   export backend_bucket=$(terraform -chdir="../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"
   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars
   ```
1. Also update `backend.tf` with your backend bucket from 0-bootstrap output.
   ```
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   ```

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 4-projects step and only the corresponding environment is applied. Environment shared must be applied first because development, non-production, and production depend on it.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.

1. Use `terraform output` to get the Cloud Build project ID and the environment step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.
   ```
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../0-bootstrap/" output -raw projects_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```
1. Run `init` and `plan` and review output for environment shared.
   ```
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate shared $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` shared.
   ```
   ./tf-wrapper.sh apply shared
   ```
1. Run `init` and `plan` and review output for environment production.
   ```
   ./tf-wrapper.sh init production
   ./tf-wrapper.sh plan production
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` production.
   ```
   ./tf-wrapper.sh apply production
   ```
1. Run `init` and `plan` and review output for environment non-production.
   ```
   ./tf-wrapper.sh init non-production
   ./tf-wrapper.sh plan non-production
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate non-production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` non-production.
   ```
   ./tf-wrapper.sh apply non-production
   ```
1. Run `init` and `plan` and review output for environment development.
   ```
   ./tf-wrapper.sh init development
   ./tf-wrapper.sh plan development
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate development $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` development.
   ```
   ./tf-wrapper.sh apply development
   ```

If you received any errors or made any changes to the Terraform config or any `.tfvars`, you must re-run `./tf-wrapper.sh plan <env>` before running `./tf-wrapper.sh apply <env>`.

Before executing the next stages, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.
```
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```
