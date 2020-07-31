# 3-networks

The purpose of this step is to :

- Setup the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones).
- Setup private and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, onprem dedicated interconnect and baseline firewall rules for each environment.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`.

## Usage

### OPTIONAL - Using High Availability VPN

If you are not able to use dedicated interconnect, you can also use an HA VPN to access onprem.

1. Rename `vpn.tf.example` to `vpn.tf` in each environment folder in `3-networks/envs/<ENV>`
1. Create secret for VPN private preshared key `echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_PRIVATE_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-`
1. Create secret for VPN restricted preshared key `echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_RESTRICTED_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-`
1. Update in the file `vpn.tf` the values for `environment`, `vpn_psk_secret_name`, `on_prem_router_ip_address1`, `on_prem_router_ip_address2` and `bgp_peer_asn`.
1. Verify other default values are valid for your environment.


### Setup to run via Cloud Build

1. Clone repo `gcloud source repos clone gcp-networks --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/3-networks/ .` (modify accordingly based on your current directory).
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory)
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . `1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository  (modify accordingly based on your current directory). to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with the `target_name_server_addresses`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. You will need to manually plan + apply the `shared` environment (only once) since dev, nonprod and prod depend on it.
    1. cd to ./envs/shared/
    1. Update backend.tf with your bucket name from the bootstrap step.
    1. Run `terraform init`
    1. Run `terraform plan` and review output
    1. Run `terraform apply`
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`
1. Push your plan branch to trigger a plan `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `dev`, `nonprod` or `prod` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to prod with `git checkout -b prod` and `git push origin prod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After prod has been applied apply dev and nonprod
1. Merge changes to dev with `git checkout -b dev` and `git push origin dev`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to nonprod with `git checkout -b nonprod` and `git push origin nonprod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Setup to run via Jenkins
1. Clone the repo you created manually in bootstrap: `git clone <YOUR_NEW_REPO-3-networks>`
1. Navigate into the repo `cd YOUR_NEW_REPO_CLONE-3-networks` and change to a non prod branch `git checkout -b plan` (the branch `plan` is not a special one. Any branch which name is different from `dev`, `nonprod` or `prod` will trigger a terraform plan).
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/3-networks/ .` (modify accordingly based on your current directory).
1. Copy the Jenkinsfile script `cp ../terraform-example-foundation/build/Jenkinsfile .` to the root of your new repository (modify accordingly based on your current directory).
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _POLICY_REPO (optional)
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    ```
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . `1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository  (modify accordingly based on your current directory). to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with the `target_name_server_addresses`.
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. You will need to manually plan + apply the `shared` environment (only once) since dev, nonprod and prod depend on it.
    1. cd to ./envs/shared/
    1. Update backend.tf with your bucket name from the bootstrap step.
    1. Run `terraform init`
    1. Run `terraform plan` and review output
    1. Run `terraform apply`
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME`
1. Push your plan branch `git push --set-upstream origin plan`. The branch `plan` is not a special one. Any branch which name is different from `dev`, `nonprod` or `prod` will trigger a terraform plan.
    - Assuming you configured an automatic trigger in your Jenkins Master (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](http://www.jenkins.io) for more details.
    1. Review the plan output in your Master's web UI.
1. Merge changes to prod branch with `git checkout -b prod` and `git push origin prod`
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. After prod has been applied apply dev and nonprod
1. Merge changes to dev with `git checkout -b dev` and `git push origin dev`
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. Merge changes to nonprod with `git checkout -b nonprod` and `git push origin nonprod`
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

1. You can now move to the instructions in the step [4-projects](../4-projects/README.md).

### Run terraform locally

1. Change into 3-networks folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`
1. Rename common.auto.example.tfvars to common.auto.tfvars and update the file with values from your environment and bootstrap.
1. Rename shared.auto.example.tfvars to shared.auto.tfvars and update the file with the target_name_server_addresses.
1. Rename access_context.auto.example.tfvars to access_context.auto.tfvars and update the file with the access_context_manager_policy_id.
1. Update backend.tf with your bucket from bootstrap. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.
You can run `terraform output gcs_bucket_tfstate` in the 0-bootstap folder to obtain the bucket name.

We will now deploy each of our environments(dev/prod/nonprod) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch in the repository for 3-networks step
and only the corresponding environment is applied.

1. Run `./tf-wrapper.sh init shared`
1. Run `./tf-wrapper.sh plan shared` and review output.
1. Run `./tf-wrapper.sh apply shared`
1. Run `./tf-wrapper.sh init prod`
1. Run `./tf-wrapper.sh plan prod` and review output.
1. Run `./tf-wrapper.sh apply prod`
1. Run `./tf-wrapper.sh init nonprod`
1. Run `./tf-wrapper.sh plan nonprod` and review output.
1. Run `./tf-wrapper.sh apply nonprod`
1. Run `./tf-wrapper.sh init dev`
1. Run `./tf-wrapper.sh plan dev` and review output.
1. Run `./tf-wrapper.sh apply dev`

If you received any errors or made any changes to the Terraform config or any `.tfvars`you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`
