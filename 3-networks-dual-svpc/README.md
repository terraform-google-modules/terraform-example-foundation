# 3-networks-dual-svpc

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
<td><a>3-networks-dual-svpc (this file)</a></td>
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
<td><a href="../4-projects">4-projects</a></td>
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

The purpose of this step is to:

- Set up the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones).
- Set up base and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, on-premises Dedicated or Partner Interconnect, and baseline firewall rules for each environment.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. It can be obtained by running the following commands. We assume you are at the same level as directory `terraform-example-foundation`, If you run them from another directory, adjust your paths accordingly.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' --raw-output)
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```

1. For the manual step described in this document, you need [Terraform](https://www.terraform.io/downloads.html) version 1.3.0 or later to be installed.

**Note:** Make sure that you use version 1.3.0 or later of Terraform throughout this series. Otherwise, you might experience Terraform state snapshot lock errors.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

### Networking Architecture

This step makes use of the **Dual Shared VPC** architecture, and more details can be found described at the **Networking** section of the [Google cloud security foundations guide](https://cloud.google.com/architecture/security-foundations/networking). To see the version that makes use the Hub and Spoke mode, check the step [3-networks-hub-and-spoke](../3-networks-hub-and-spoke).

### Using Dedicated Interconnect

If you provisioned the prerequisites listed in the [Dedicated Interconnect README](./modules/dedicated_interconnect/README.md), follow these steps to enable Dedicated Interconnect to access on-premises resources.

1. Rename `interconnect.tf.example` to `interconnect.tf` in the shared envs folder in `3-networks-dual-svpc/envs/shared`
1. Update the file `interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.
1. Rename `interconnect.tf.example` to `interconnect.tf` in base_env folder in `3-networks-dual-svpc/modules/base_env`.
1. Update the file `interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.
1. Set variable `enable_dedicated_interconnect` to `true`
1. The candidate subnetworks and vlan_tag8021q variables can be set to `null` to allow the interconnect module to auto generate these values.

### Using Partner Interconnect

If you provisioned the prerequisites listed in the [Partner Interconnect README](./modules/partner_interconnect/README.md) follow this steps to enable Partner Interconnect to access on-premises resources.

1. Rename `partner_interconnect.tf.example` to `partner_interconnect.tf` in the shared envs folder in `3-networks-dual-svpc/envs/shared`
1. Rename `partner_interconnect.auto.tfvars.example` to `partner_interconnect.auto.tfvars` in the shared envs folder in `3-networks-dual-svpc/envs/shared`
1. Update the file `interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.
1. Rename `partner_interconnect.tf.example` to `partner_interconnect.tf` in the base-env folder in `3-networks-dual-svpc/modules/base_env` .
1. Update the `enable_partner_interconnect` to `true` in each `main.tf` file in the environment folder in `3-networks-dual-svpc/envs/<environment>` .
1. Update the file `partner_interconnect.tf` with values that are valid for your environment for the VLAN attachments, locations, and candidate subnetworks.
1. The candidate subnetworks variable can be set to `null` to allow the interconnect module to auto generate this value.

### OPTIONAL - Using High Availability VPN

If you are not able to use Dedicated or Partner Interconnect, you can also use an HA Cloud VPN to access on-premises resources.

1. Rename `vpn.tf.example` to `vpn.tf` in base-env folder in `3-networks-dual-svpc/modules/base_env`.
1. Create secret for VPN private pre-shared key and grant required roles to Networks terraform service account.

   ```bash
   echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_PRIVATE_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-

   gcloud secrets add-iam-policy-binding <VPN_PRIVATE_PSK_SECRET_NAME> --member='serviceAccount:<NETWORKS_TERRAFORM_SERVICE_ACCOUNT>' --role='roles/secretmanager.viewer' --project <ENV_SECRETS_PROJECT>
   gcloud secrets add-iam-policy-binding <VPN_PRIVATE_PSK_SECRET_NAME> --member='serviceAccount:<NETWORKS_TERRAFORM_SERVICE_ACCOUNT>' --role='roles/secretmanager.secretAccessor' --project <ENV_SECRETS_PROJECT>
   ```

1. Create secret for VPN restricted pre-shared key and grant required roles to Networks terraform service account.

   ```bash
   echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_RESTRICTED_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-

   gcloud secrets add-iam-policy-binding <VPN_RESTRICTED_PSK_SECRET_NAME> --member='serviceAccount:<NETWORKS_TERRAFORM_SERVICE_ACCOUNT>' --role='roles/secretmanager.viewer' --project <ENV_SECRETS_PROJECT>
   gcloud secrets add-iam-policy-binding <VPN_RESTRICTED_PSK_SECRET_NAME> --member='serviceAccount:<NETWORKS_TERRAFORM_SERVICE_ACCOUNT>' --role='roles/secretmanager.secretAccessor' --project <ENV_SECRETS_PROJECT>
   ```

1. In the file `vpn.tf`, update the values for `environment`, `vpn_psk_secret_name`, `on_prem_router_ip_address1`, `on_prem_router_ip_address2` and `bgp_peer_asn`.
1. Verify other default values are valid for your environment.

### Deploying with Cloud Build

1. Clone the `gcp-networks` repo based on the Terraform output from the `0-bootstrap` step.
Clone the repo at the same level of the `terraform-example-foundation` folder, the following instructions assume this layout.
Run `terraform output cloudbuild_project_id` in the `0-bootstrap` folder to get the Cloud Build Project ID.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   gcloud source repos clone gcp-networks --project=${CLOUD_BUILD_PROJECT_ID}
   ```

1. Change to the freshly cloned repo, change to the non-main branch and copy contents of foundation to new repo.

   ```bash
   cd gcp-networks/
   git checkout -b plan

   cp -RT ../terraform-example-foundation/3-networks-dual-svpc/ .
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```

1. Update `common.auto.tfvars` file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
   Update `shared.auto.tfvars` file with the `target_name_server_addresses`.
   Update `access_context.auto.tfvars` file with the `access_context_manager_policy_id`.
   Use `terraform output` to get the backend bucket value from 0-bootstrap output.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' --raw-output)
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"

   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars

   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
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
1. Use `terraform output` to get the Cloud Build project ID and the networks step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw networks_step_terraform_service_account_email)
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
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_. Review the plan output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git push --set-upstream origin plan
   ```

1. Merge changes to production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

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
   pushing to this branch triggers both _terraform plan_ and _terraform apply_. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds;region=DEFAULT_REGION?project=YOUR_CLOUD_BUILD_PROJECT_ID

   ```bash
   git checkout -b non-production
   git push origin non-production
   ```

1. Before executing the next steps, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

   ```bash
   unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
   ```

1. You can now move to the instructions in the [4-projects](../4-projects/README.md) step.

### Deploying with Jenkins

See `0-bootstrap` [README-Jenkins.md](../0-bootstrap/README-Jenkins.md#deploying-step-3-networks-dual-svpc)

### Run Terraform locally

1. The next instructions assume that you are at the same level of the `terraform-example-foundation` folder. Change into `3-networks-dual-svpc` folder, copy the Terraform wrapper script and ensure it can be executed.

   ```bash
   cd terraform-example-foundation/3-networks-dual-svpc
   cp ../build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.

   ```bash
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```

1. Update `common.auto.tfvars` file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Update `shared.auto.tfvars` file with the `target_name_server_addresses`.
1. Update `access_context.auto.tfvars` file with the `access_context_manager_policy_id`.
1. Use `terraform output` to get the backend bucket value from 0-bootstrap output.

   ```bash
   export ORGANIZATION_ID=$(terraform -chdir="../0-bootstrap/" output -json common_config | jq '.org_id' --raw-output)
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"

   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars

   export backend_bucket=$(terraform -chdir="../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"

   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars
   ````

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch in the repository for 3-networks-dual-svpc step
and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.

1. Use `terraform output` to get the Cloud Build project ID and the environment step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.

   ```bash
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../0-bootstrap/" output -raw networks_step_terraform_service_account_email)
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

If you received any errors or made any changes to the Terraform config or any `.tfvars`, you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`.

Before executing the next stages, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.

```bash
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```
