# 5-app-infra

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
<td>Sets up top-level shared folders, monitoring and networking projects,
organization-level logging, and baseline security settings through
organizational policies.</td>
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
<td><a href="../4-projects">4-projects</a></td>
<td>Sets up a folder structure, projects, and an application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td>5-app-infra (this file)</td>
<td>Deploy a simple [Compute Engine](https://cloud.google.com/compute/) instance in one of the business unit projects using the infra pipeline set up in 4-projects.</td>
</tr>
</tbody>
</table>

For an overview of the architecture and the parts, see the
[terraform-example-foundation README](https://github.com/terraform-google-modules/terraform-example-foundation)
file.

## Purpose

The purpose of this step is to deploy a simple [Compute Engine](https://cloud.google.com/compute/) instance in one of the business unit projects using the infra pipeline set up in 4-projects.
The infra pipeline is created in step `4-projects` within the shared env and has a [Cloud Build](https://cloud.google.com/build/docs) pipeline configured to manage infrastructure within projects.
To enable deployment via this pipeline, the projects deployed should [enable](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects/business_unit_1/development/example_base_shared_vpc_project.tf#L31-L32) the `enable_cloudbuild_deploy` flag and provide the Cloud Build service account value via `cloudbuild_sa`.

This enables the Cloud Build service account to impersonate the project service account and use it to deploy infrastructure. The roles required for the project SA can also be [managed](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects/business_unit_1/development/example_base_shared_vpc_project.tf#L30) via `sa_roles`. (Note: This requires per project SA impersonation. If you would like to have a single SA managing an environment and all associated projects, that is also possible by [granting](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects/modules/single_project/main.tf#L62-L68) `roles/iam.serviceAccountTokenCreator` to an SA with the right roles in `4-projects/env`.)

There is also a [Source Repository](https://cloud.google.com/source-repositories) configured with build triggers similar to the [foundation pipeline](https://github.com/terraform-google-modules/terraform-example-foundation#0-bootstrap) setup in `0-bootstrap`.
This Compute Engine instance is created using the base network from step `3-networks` and is used to access private services.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. 3-networks executed successfully.
1. 4-projects executed successfully.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

### Deploying with Cloud Build

1. Get the Infra Pipeline project ID from the previous step. Run the following in the
   `gcp-projects/business_unit_1/shared` folder.
   ```
   terraform output cloudbuild_project_id
   ```
1. Clone the policies repo. (This repo has the same name of the repo created in step 1-org, but it is from a different project, you may need to rename the previous one to prevent a collision if you are cloning it in the same folder).
   ```
   gcloud source repos clone gcp-policies --project=YOUR_INFRA_PIPELINE_PROJECT_ID
   ```
1. Navigate into the repo. All subsequent steps assume you are running them
   from the gcp-environments directory. If you run them from another directory,
   adjust your copy paths accordingly.
   ```
   cd gcp-policies
   ```
1. Copy contents of policy-library to new repo.
   ```
   cp -RT ../terraform-example-foundation/policy-library/ .
   ```
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your master branch to the new repo.
   ```
   git push --set-upstream origin master
   ```
1. Navigate out of the repo.
   ```
   cd ..
   ```
1. Clone the `bu1-example-app` repo.
   ```
   gcloud source repos clone bu1-example-app --project=YOUR_INFRA_PIPELINE_PROJECT_ID
   ```
1. Navigate into the repo. All subsequent steps assume you are running them
   from the gcp-environments directory. If you run them from another directory,
   adjust your copy paths accordingly.
   ```
   cd bu1-example-app
   ```
1. Change freshly cloned repo and change to non-main branch.
   ```
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/5-app-infra/ .
   ```
1. Copy Cloud Build configuration files for Terraform.
   ```
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   ```
1. Copy the Terraform wrapper script to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and 0-bootstrap. See any of the business unit 1 envs folders [README.md](./business_unit_1/development/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Rename `bu1-development.auto.example.tfvars` to `bu1-development.auto.tfvars` and update the file with values from your environment.
1. Rename `bu1-non-production.auto.example.tfvars` to `bu1-non-production.auto.tfvars` and update the file with values from your environment.
1. Rename `bu1-production.auto.example.tfvars` to `bu1-production.auto.tfvars` and update the file with values from your environment.
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
 1. Review the plan output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_INFRA_PIPELINE_PROJECT_ID
1. Merge changes to development. Because this is a [named environment branch](./docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_INFRA_PIPELINE_PROJECT_ID
1. Merge changes to non-production. Because this is a [named environment branch](./docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_INFRA_PIPELINE_PROJECT_ID
1. Merge changes to production branch. Because this is a [named environment branch](./docs/FAQ.md#what-is-a-named-branch),
      pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_INFRA_PIPELINE_PROJECT_ID

### Run Terraform locally

1. Change into the  `5-app-infra` folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and 0-bootstrap.
1. Rename `bu1-development.auto.example.tfvars` to `bu1-development.auto.tfvars` and update the file with values from your environment.
1. Rename `bu1-non-production.auto.example.tfvars` to `bu1-non-production.auto.tfvars` and update the file with values from your environment.
1. Rename `bu1-production.auto.example.tfvars` to `bu1-production.auto.tfvars` and update the file with values from your environment.
1. Provide the user that will be running `./tf-wrapper.sh` the Service Account Token Creator role to the bu1 project service accounts
1. Provide the user permissions to run the terraform locally with the `serviceAccountTokenCreator` permission.
   ```
   gcloud iam service-accounts add-iam-policy-binding $PROJECT_SERVICE_ACCOUNT --project $PROJECT --member="user:$(gcloud auth list --format="value(account)")" --role="roles/iam.serviceAccountTokenCreator"
   ```
3. Update `backend.tf` with your bucket from the infra pipeline example.
   ```
   for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done
   ```

We will now deploy each of our environments (development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool, each environment corresponds to a branch in the repository for the `5-app-infra` step. Only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://github.com/GoogleCloudPlatform/terraform-validator/blob/main/docs/install.md) in the **Install Terraform Validator** section and install version `v0.4.0` in your system. You will also need to rename the binary from `terraform-validator-<your-platform>` to `terraform-validator` and the `terraform-validator` binary must be in your `PATH`.

1. Run `./tf-wrapper.sh init production`.
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh validate production $(pwd)/../policy-library <YOUR_INFRA_PIPELINE_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply production`.
1. Run `./tf-wrapper.sh init non-production`.
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh validate non-production $(pwd)/../policy-library <YOUR_INFRA_PIPELINE_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply non-production`.
1. Run `./tf-wrapper.sh init development`.
1. Run `./tf-wrapper.sh plan development` and review output.
1. Run `./tf-wrapper.sh validate development $(pwd)/../policy-library <YOUR_INFRA_PIPELINE_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply development`.

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before running `./tf-wrapper.sh apply <env>`.
