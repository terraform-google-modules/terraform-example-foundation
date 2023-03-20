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

This step follows the same [conventions](https://github.com/terraform-google-modules/terraform-example-foundation#branching-strategy) as the Foundation pipeline deployed in [0-bootstrap](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README.md).
A custom [workspace](https://github.com/terraform-google-modules/terraform-google-bootstrap/blob/master/modules/tf_cloudbuild_workspace/README.md) (`bu1-example-app`) is created by this pipeline and necessary roles are granted to the Terraform Service Account of this workspace by enabling variable `sa_roles` as shown in this [example](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects/modules/base_env/example_base_shared_vpc_project.tf).

This pipeline is utilized to deploy resources in projects across development/non-production/production in step [5-app-infra](../5-app-infra/README.md).
Other Workspaces can also be created to isolate deployments if needed.

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

1. Clone the `gcp-projects` repo based on the Terraform output from the `0-bootstrap` step.
Clone the repo at the same level of the `terraform-example-foundation` folder, the following instructions assume this layout.
Run `terraform output cloudbuild_project_id` in the `0-bootstrap` folder to get the Cloud Build Project ID.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   gcloud source repos clone gcp-projects --project=${CLOUD_BUILD_PROJECT_ID}
   ```

1. Change to the freshly cloned repo, change to the non-main branch and copy contents of foundation to new repo.

   ```bash
   cd gcp-projects
   git checkout -b plan

   cp -RT ../terraform-example-foundation/4-projects/ .
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
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

1. See any of the envs folder [README.md](./business_unit_1/production/README.md) files for additional information on the values in the `common.auto.tfvars`, `development.auto.tfvars`, `non-production.auto.tfvars`, and `production.auto.tfvars` files.
1. See any of the shared folder [README.md](./business_unit_1/shared/README.md) files for additional information on the values in the `shared.auto.tfvars` file.

1. Use `terraform output` to get the backend bucket value from 0-bootstrap output.

   ```bash
   export remote_state_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
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
1. Use `terraform output` to get the Cloud Build project ID and the projects step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw projects_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/../gcp-policies ${CLOUD_BUILD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```

1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch)), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_. Review the plan output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git push --set-upstream origin plan
   ```

1. Merge changes to production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b production
   git push origin production
   ```

1. After production has been applied, apply development.
1. Merge changes to development. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b development
   git push origin development
   ```

1. After development has been applied, apply non-production.
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b non-production
   git push origin non-production
   ```

1. Before executing the next step, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```

1. You can now move to the instructions in the [5-app-infra](../5-app-infra/README.md) step.

### Deploying with Jenkins

See `0-bootstrap` [README-Jenkins.md](../0-bootstrap/README-Jenkins.md#deploying-step-4-projects)

### Run Terraform locally

1. The next instructions assume that you are at the same level of the `terraform-example-foundation` folder. Change into `4-projects` folder, copy the Terraform wrapper script and ensure it can be executed.

   ```bash
   cd terraform-example-foundation/4-projects
   cp ../build/tf-wrapper.sh .
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

1. See any of the envs folder [README.md](./business_unit_1/production/README.md) files for additional information on the values in the `common.auto.tfvars`, `development.auto.tfvars`, `non-production.auto.tfvars`, and `production.auto.tfvars` files.
   See any of the shared folder [README.md](./business_unit_1/shared/README.md) files for additional information on the values in the `shared.auto.tfvars` file.
   Use `terraform output` to get the remote state bucket (the backend bucket used by previous steps) value from `0-bootstrap` output.

   ```bash
   export remote_state_bucket=$(terraform -chdir="../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${remote_state_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars
   ```

We will now deploy each of our environments(development/production/non-production) using the `tf-wrapper.sh` script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 4-projects step and only the corresponding environment is applied. Environment shared must be applied first because development, non-production, and production depend on it.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.

1. Use `terraform output` to get the Cloud Build Project ID and the environment step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../0-bootstrap/" output -raw projects_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```

1. Run `init` and `plan` and review output for environment shared.

   ```bash
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate shared $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```

1. Run `apply` shared.

   ```bash
   ./tf-wrapper.sh apply shared
   ```

1. Run `init` and `plan` and review output for environment production.

   ```bash
   ./tf-wrapper.sh init production
   ./tf-wrapper.sh plan production
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```

1. Run `apply` production.

   ```bash
   ./tf-wrapper.sh apply production
   ```

1. Run `init` and `plan` and review output for environment non-production.

   ```bash
   ./tf-wrapper.sh init non-production
   ./tf-wrapper.sh plan non-production
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate non-production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```

1. Run `apply` non-production.

   ```bash
   ./tf-wrapper.sh apply non-production
   ```

1. Run `init` and `plan` and review output for environment development.

   ```bash
   ./tf-wrapper.sh init development
   ./tf-wrapper.sh plan development
   ```

1. Run `validate` and check for violations.

   ```bash
   ./tf-wrapper.sh validate development $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```

1. Run `apply` development.

   ```bash
   ./tf-wrapper.sh apply development
   ```

If you received any errors or made any changes to the Terraform config or any `.tfvars`, you must re-run `./tf-wrapper.sh plan <env>` before running `./tf-wrapper.sh apply <env>`.

Before executing the next stages, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

```bash
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```
