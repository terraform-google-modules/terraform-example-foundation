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

### Setup to run via Cloud Build

1. Clone repo `gcloud source repos clone gcp-networks --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -R ../terraform-example-foundation/3-networks/* .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory)
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` (modify accordingly based on your current directory)
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Within each envs/ folder rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. You will need only once to manually plan + apply the `shared` environment since dev, nonprod and prod depend on it.
    1. cd to ./envs/shared/
    1. Update backend.tf with your bucket name from the bootstrap step.
    1. Run `terraform plan` and review output
    1. Run `terraform apply`
    1. If you would like the bucket to be replaced by cloud build at run time, change the bucket name back to `UPDATE_ME
1. Push your plan branch to trigger a plan `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `dev`, `nonprod` or `prod` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to prod with `git checkout -b prod` and `git push origin prod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After prod has been applied apply dev and nonprod
1. Merge changes to dev with `git checkout -b dev` and `git push origin dev`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to nonprod with `git checkout -b nonprod` and `git push origin nonprod`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Run tf-wrapper.sh script locally
1. Change into 3-networks folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Update backend.tf with your bucket from bootstrap. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.
You can run in the 0-bootstap folder `terraform output gcs_bucket_tfstate` to obtain the bucket name.

We will now deploy each of our environments(dev/prod/stage) using this script.
When checked into a VCS, each environment corresponds to a branch and only the corresponding environment is applied.

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

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`
