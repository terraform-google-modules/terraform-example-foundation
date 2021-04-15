# 3-networks

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf)
(PDF). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/0-bootstrap">0-bootstrap</a></td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a CI/CD pipeline for foundations code in subsequent
stages.</td>
</tr>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/1-org">1-org</a></td>
<td>Sets up top level shared folders, monitoring and networking projects, and
organization-level logging, and sets baseline security settings through
organizational policy.</td>
</tr>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/2-environments">2-environments</a></td>
<td>Sets up development, non-production, and production environments within the
Google Cloud organization that you've created.</td>
</tr>
<tr>
<td>3-networks (this file)</td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, Dedicated or Partner
Interconnect, and baseline firewall rules for each environment. Also sets
up the global DNS hub.</td>
</tr>
<tr>
<td><a
href="https://github.com/terraform-google-modules/terraform-example-foundation/tree/master/4-projects">4-projects</a></td>
<td>Set up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
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
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`.

## Usage

### Using Dedicated Interconnect

If you have the prerequisites listed in the [Dedicated Interconnect README](./modules/dedicated_interconnect/README.md), follow these steps to enable Dedicated Interconnect to access on-premises resources.

1. Rename `interconnect.tf.example` to `interconnect.tf` in each environment folder in `3-networks/envs/<ENV>`.
1. Update the file `interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.
1. The candidate subnetworks and vlan_tag8021q variables can be set to `null` to allow the interconnect module to auto generate these values.

### Using Partner Interconnect

If you have the prerequisites listed in the [Partner Interconnect README](./modules/partner_interconnect/README.md) follow this steps to enable Partner Interconnect to access on-premises resources.

1. Rename `partner_interconnect.tf.example` to `partner_interconnect.tf` and `interconnect.auto.tfvars.example` to `interconnect.auto.tfvars` in the environment folder in `3-networks/envs/<environment>` .
1. Update the file `partner_interconnect.tf` with values that are valid for your environment for the VLAN attachments, locations, candidate subnetworks.
1. The candidate subnetworks variable can be set to `null` to allow the interconnect module to auto generate this value.

### OPTIONAL - Using High Availability VPN

If you are not able to use Dedicated or Partner Interconnect, you can also use an HA Cloud VPN to access on-premises resources.

1. Rename `vpn.tf.example` to `vpn.tf` in each environment folder in `3-networks/envs/<ENV>`.
1. Create secret for VPN private preshared key.
   ```
   echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_PRIVATE_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-
   ```
1. Create secret for VPN restricted preshared key.
   ```
   echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_RESTRICTED_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-
   ```
1. In the file `vpn.tf`, update the values for `environment`, `vpn_psk_secret_name`, `on_prem_router_ip_address1`, `on_prem_router_ip_address2` and `bgp_peer_asn`.
1. Verify other default values are valid for your environment.

### Deploying with Jenkins

1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-3-networks>
   ```
1. Navigate into the repo and change to a non-production branch.
   ```
   cd YOUR_NEW_REPO_CLONE-3-networks
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/3-networks/ .
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
1. Copy terraform wrapper script to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with the `target_name_server_addresses`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. You must manually plan and apply the `shared` environment (only once) since development, non-production and production depend on it.
    1. Run `cd ./envs/shared/`.
    1. Update backend.tf with your bucket name from the bootstrap step.
    1. Run `terraform init`.
    1. Run `terraform plan` and review output.
    1. Run `terraform apply`.
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`.
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
1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. After production has been applied, apply development and non-production.
1. Merge changes to development
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. Merge changes to non-production.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

1. You can now move to the instructions in the step [4-projects](../4-projects/README.md).

### Deplying with Cloud Build

1. Clone repo.
   ```
   gcloud source repos clone gcp-networks --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```
1. Change to the freshly cloned repo and change to non-master branch.
   ```
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/3-networks/ .
   ```
1. Copy cloud build configuration files for Terraform.
   ```
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   ```
1. Copy terraform wrapper script to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with the target_name_server_addresses (the list of target name servers for the DNS forwarding zone in the DNS Hub).
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. Commit changes
   ```
   git add .
   git commit -m 'Your message'
   ```
1. You need to manually plan and apply only once the `shared` environment since `development`, `non-production` and `production` depend on it.
    1. Run `cd ./envs/shared/`.
    1. Update `backend.tf` with your bucket name from the bootstrap step.
    1. Run `terraform init`.
    1. Run `terraform plan` and review output.
    1. Run `terraform apply`.
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`.
1. Push your plan branch to trigger a plan.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After production has been applied, apply development and non-production.
1. Merge changes to development.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to non-production.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Run Terraform locally

1. Change into the 3-networks folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with the `target_name_server_addresses`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. Update `backend.tf` with your bucket from bootstrap.
   ```
   for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done
   ```
   You can run `terraform output gcs_bucket_tfstate` in the 0-bootstrap folder to obtain the bucket name.

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch in the repository for 3-networks step
and only the corresponding environment is applied.

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
1. Run `./tf-wrapper.sh validate non-production $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply non-production`.
1. Run `./tf-wrapper.sh init development`.
1. Run `./tf-wrapper.sh plan development` and review output.
1. Run `./tf-wrapper.sh validate development $(pwd)/../policy-library <YOUR_CLOUD_BUILD_PROJECT_ID>` and check for violations.
1. Run `./tf-wrapper.sh apply development`.

If you received any errors or made any changes to the Terraform config or any `.tfvars`you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`.
