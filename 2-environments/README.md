# 2-environments

The purpose of this step is to set up development, non-production and production environments within the GCP organization.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. Cloud Identity / G Suite group for monitoring admins.
1. Membership in the monitoring admins group for user running terraform

## Usage

### Setup to run via Cloud Build
1. Clone repo `gcloud source repos clone gcp-environments --project=YOUR_CLOUD_BUILD_PROJECT_ID`
1. Change freshly cloned repo and change to non master branch `git checkout -b plan`
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/2-environments/ .` (modify accordingly based on your current directory)
1. Copy cloud build configuration files for terraform `cp ../terraform-example-foundation/build/cloudbuild-tf-* . ` (modify accordingly based on your current directory).
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values).
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your plan branch to trigger a plan for all environments `git push --set-upstream origin plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to development with `git checkout -b development` and `git push origin development`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to non-production with `git checkout -b non-production` and `git push origin non-production`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`
    1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

### Setup to run via Jenkins
1. Clone the repo you created manually in bootstrap: `git clone <YOUR_NEW_REPO-2-environments>`
1. Navigate into the repo `cd YOUR_NEW_REPO_CLONE-2-environments` and change to a non production branch `git checkout -b plan` (the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan).
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/2-environments/ .` (modify accordingly based on your current directory).
1. Copy the Jenkinsfile script `cp ../terraform-example-foundation/build/Jenkinsfile .` to the root of your new repository (modify accordingly based on your current directory).
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _POLICY_REPO (optional)
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    ```
1. Copy terraform wrapper script `cp ../terraform-example-foundation/build/tf-wrapper.sh . ` to the root of your new repository (modify accordingly based on your current directory).
1. Ensure wrapper script can be executed `chmod 755 ./tf-wrapper.sh`.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values).
1. Commit changes with `git add .` and `git commit -m 'Your message'`
1. Push your plan branch `git push --set-upstream origin plan`. The branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a terraform plan.
    - Assuming you configured an automatic trigger in your Jenkins Master (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](http://www.jenkins.io) for more details.
    1. Review the plan output in your Master's web UI.
1. Merge changes to development with `git checkout -b development` and `git push origin development`
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. Merge changes to non-production with `git checkout -b non-production` and `git push origin non-production`
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).
1. Merge changes to production branch with `git checkout -b production` and `git push origin production`
    1. Review the apply output in your Master's web UI (You might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Master UI).

1. You can now move to the instructions in the step [3-networks](../3-networks/README.md).

### Run terraform locally
1. Change into 2-environments folder.
1. Run `cp ../build/tf-wrapper.sh .`
1. Run `chmod 755 ./tf-wrapper.sh`
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Update backend.tf with your bucket from bootstrap. You can run
```for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/<YOUR-BUCKET-NAME>/' $i; done```.
You can run `terraform output gcs_bucket_tfstate` in the 0-bootstap folder to obtain the bucket name.

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 2-environments step and only the corresponding environment is applied.

1. Run `./tf-wrapper.sh init development`
1. Run `./tf-wrapper.sh plan development` and review output.
1. Run `./tf-wrapper.sh apply development`
1. Run `./tf-wrapper.sh init non-production`
1. Run `./tf-wrapper.sh plan non-production` and review output.
1. Run `./tf-wrapper.sh apply non-production`
1. Run `./tf-wrapper.sh init production`
1. Run `./tf-wrapper.sh plan production` and review output.
1. Run `./tf-wrapper.sh apply production`

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`

### Optional Variables

Some variables used to deploy the step have default values. Check if you want to change those values before doing the deploy:

- **skip_gcloud_download:** By default this option is `true`. The default value assumes gcloud is already available outside the module, if you change to false it will download gcloud.
- **base_network_project_alert_spent_percents:** By default this value is this list of percentages `[0.5, 0.75, 0.9, 0.95]`. This is a list of percentages of the budget to alert on when threshold is exceeded for the base networks project
- **base_network_project_alert_pubsub_topic:** By default this value is `null`. This is the name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the base networks project
- **base_network_project_budget_amount:** By default this value is `1000`. This is the amount to use as the budget for the base networks project
- **restricted_network_project_alert_spent_percents:** By default this value is this list of percentages `[0.5, 0.75, 0.9, 0.95]`. This is a list of percentages of the budget to alert on when threshold is exceeded for the restricted networks project.
- **restricted_network_project_alert_pubsub_topic:** By default this value is `null`. This is the name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the restricted networks project
- **restricted_network_project_budget_amount:** By default this value is `1000`. This is the amount to use as the budget for the restricted networks project.
- **monitoring_project_alert_spent_percents:** By default this value is this list of percentages `[0.5, 0.75, 0.9, 0.95]`. This is a list of percentages of the budget to alert on when threshold is exceeded for the monitoring project.
- **monitoring_project_alert_pubsub_topic:** By default this value is `null`. This is the name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the monitoring project.
- **monitoring_project_budget_amount:** By default this value is `1000`. This is the amount to use as the budget for the monitoring project.
- **secret_project_alert_spent_percents:** By default this value is this list of percentages `[0.5, 0.75, 0.9, 0.95]`. This is a list of percentages of the budget to alert on when threshold is exceeded for the secrets project.
- **secret_project_alert_pubsub_topic:** By default this value is `null`. This is the name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the secrets project.
- **secret_project_budget_amount:** By default this value is `1000`. This is the amount to use as the budget for the secrets project.
