# 0-bootstrap - deploying a Jenkins-compatible environment

The purpose of this step is to bootstrap a GCP organization, creating all the required resources & permissions to start using the Cloud Foundation Toolkit (CFT). This step also guides you on how to configure a CICD project to host a Jenkins Agent, which connects to your existing Jenkins Controller infrastructure & your own Git repos (which might live on-prem). The Jenkins Agent will run [CI/CD Pipelines](/docs/GLOSSARY.md#foundation-cicd-pipeline) for foundations code in subsequent stages.

Another CICD option is to use Cloud Build & Cloud Source Repos. If you don't have a Jenkins implementation and don't want one, then we recommend you to [use the Cloud Build module](./README.md) instead.

## Overview

The objective of the instructions below is to configure the infrastructure that allows you to run CICD deployments for the next stages (`1-org, 2-environments, 3-networks, 4-projects`) using Jenkins. The infrastructure consists in two Google Cloud Platform projects (`prj-b-seed` and `prj-b-cicd`) and VPN configuration to connect to your on-prem environment.

It is a best practice to have two separate projects here (`prj-b-seed` and `prj-b-cicd`) for separation of concerns. On one hand, `prj-b-seed` stores terraform state and has the Service Account able to create / modify infrastructure. On the other hand, the deployment of that infrastructure is coordinated by Jenkins, which is implemented in `prj-b-cicd` and connected to your Controller on-prem.

**After following the instructions below, you will have:**
- The `prj-b-seed` project, which contains:
  - Terraform state bucket
  - Custom Service Account used by Terraform to create new resources in GCP
- The `prj-b-cicd` project, which contains:
  - GCE Instance for the Jenkins Agent, connected to your current Jenkins Controller using SSH.
  - VPC to connect the Jenkins GCE Instance to
  - FW rules to allow communication over port 22
  - VPN connection with on-prem (or where ever your Jenkins Controller is located)
  - Custom service account `sa-jenkins-agent-gce@prj-b-cicd-xxxx.iam.gserviceaccount.com` for the GCE instance.
      - This service account is granted the access to generate tokens on the Terraform custom service account in the `prj-b-seed` project

- **Note: these instructions do not indicate how to create a Jenkins Controller.** To deploy a Jenkins Controller, you should follow [Jenkins Architecture](https://www.jenkins.io/doc/book/architecting-for-scale/) recommendations.

**If you don't have a Jenkins implementation and don't want one**, then we recommend you to [use the Cloud Build module](./README.md) instead.

## Requirements

Please see the **[requirements](./modules/jenkins-agent/README.md#Requirements)** of Software, Infrastructure and Permissions before following the instructions below.

## Usage

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

## Instructions

You arrived to these instructions because you are using the `jenkins_bootstrap` to run the 0-bootstrap step instead of `cloudbuild_bootstrap`. Please follow the indications below:
- Make sure you cover all the [requirements](./modules/jenkins-agent/README.md#Requirements) of Software, Infrastructure and Permissions before following the instructions below.

### I. Setup your environment
  - Required information:
     - Access to the Jenkins Controller host to run `ssh-keygen` command
     - Access to the Jenkins Controller Web UI
     - [SSH Agent Jenkins plugin](https://plugins.jenkins.io/ssh-agent) installed in your Jenkins Controller
     - Private IP address for the Jenkins Agent: usually assigned by your network administrator. You will use this IP for the GCE instance that will be created in the `prj-b-cicd` GCP Project in step [II. Create the SEED and CICD projects using Terraform](#II-Create-the-SEED-and-CICD-projects-using-Terraform).
     - Access to create five Git repositories, one for each directory in this [monorepo](https://github.com/terraform-google-modules/terraform-example-foundation) (`0-bootstrap, 1-org, 2-environments, 3-networks, 4-projects`). These are usually private repositories that might be on-prem.

1. Generate a SSH key pair. In the Jenkins Controller host, use the `ssh-keygen` command to generate a SSH key pair.
   - You will need this key pair to enable authentication between the Controller and Agent. Although the key pair can be generated in any linux machine, it is recommended not to copy the secret private key from one host to another, so you probably want to do this in the Jenkins Controller host command line.

    - Note the `ssh-keygen` command uses the `-N` option to protect the private key with a password. In this example, we are using `-N "my-password"`. This is important because you will need both, the private key and the password when configuring the SSH Agent in you Jenkins Controller Web UI.
        ```
        SSH_LOCAL_CONFIG_DIR="$HOME/.ssh"
        JENKINS_USER="jenkins"
        JENKINS_AGENT_NAME="AgentGCE1"
        SSH_KEY_FILE_PATH="$SSH_LOCAL_CONFIG_DIR/$JENKINS_USER-${JENKINS_AGENT_NAME}_rsa"

        mkdir "$SSH_LOCAL_CONFIG_DIR"
        ssh-keygen -t rsa -m PEM -N "my-password" -C $JENKINS_USER -f $SSH_KEY_FILE_PATH
        cat $SSH_KEY_FILE_PATH
        ```

    - You will see an output similar to this:
      ```
      -----BEGIN RSA PRIVATE KEY-----
            copy your private key
              from BEGIN to END
        And configure a new
        Jenkins Agent in the Web UI
      -----END RSA PRIVATE KEY-----
      ```

1. Configure a new SSH Jenkins Agent in the Jenkins Controller’s Web UI. You need the following information:
    - [SSH Agent Jenkins plugin](https://plugins.jenkins.io/ssh-agent/) installed in your Controller
    - SSH private key you just generated in the previous step
    - Passphrase that protects the private key (the one you used in the `-N` option)
    - Jenkins Agent’s private IP address (usually assigned by your Network Administrator. In the provided examples this IP is "172.16.1.6"). This private IP will be reachable through the VPN connection that you will create later.

1. Create five individual Git repositories in your Git server (This might be a task delegated to your infrastructure team)
    - Note that although this infrastructure code is distributed to you as a [monorepo](https://github.com/terraform-google-modules/terraform-example-foundation), you will store the code in five different repositories, one for each directory:
        ```
        ./0-bootstrap
        ./1-org
        ./2-environments
        ./3-networks
        ./4-projects
       ```
    - For simplicity, let's name your five repositories as follows:
        ```
        YOUR_NEW_REPO-0-bootstrap
        YOUR_NEW_REPO-1-org
        YOUR_NEW_REPO-2-environments
        YOUR_NEW_REPO-3-networks
        YOUR_NEW_REPO-4-projects
        ```
    - **Note:** Towards the end of these instructions, you will configure your Jenkins Controller with **new automatic pipelines only for the following repositories:**
         ```
         YOUR_NEW_REPO-1-org
         YOUR_NEW_REPO-2-environments
         YOUR_NEW_REPO-3-networks
         YOUR_NEW_REPO-4-projects
         ```
        - **Note: there is no automatic pipeline needed for `YOUR_NEW_REPO-0-bootstrap`**
    - In this 0-bootstrap section we only work with your new repository that is a copy of the directory `./0-bootstrap` (`YOUR_NEW_REPO-0-bootstrap`)

1. Clone this mono-repository with `git clone https://github.com/terraform-google-modules/terraform-example-foundation`
1. Clone the repository you created to host the `0-bootstrap` directory with `git clone <YOUR_NEW_REPO-0-bootstrap>`
1. Navigate into the freshly cloned repo `cd <YOUR_NEW_REPO-0-bootstrap>` and change to a new branch `git checkout -b my-0-bootstrap`
1. Copy contents of foundation to new repo `cp -RT ../terraform-example-foundation/0-bootstrap/ .` (modify accordingly based on your current directory).
1. Activate the Jenkins module and disable the Cloud Build module. This implies manually editing the following files:
    1. Comment-out the `cloudbuild_bootstrap` module in `./main.tf`
    1. Comment-out the `cloudbuild_bootstrap` outputs in `./outputs.tf`
    1. Un-comment the `jenkins_bootstrap` module in `./main.tf`
    1. Un-comment the `jenkins_bootstrap` variables in `./variables.tf`
    1. Un-comment the `jenkins_bootstrap` outputs in `./outputs.tf`
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment.
    - One of the value to supply (variable `jenkins_agent_gce_ssh_pub_key`) is the **public SSH key** you generated in the first step.
        - **Note: this is not the secret private key**. The public SSH key can be in your repository code.
    1. Show the public key using `cat "${SSH_KEY_FILE_PATH}.pub"`, you will copy / paste it in the `terraform.tfvars` file (variable `jenkins_agent_gce_ssh_pub_key`).
    1. Provide the rest of the values needed in `terraform.tfvars`

1. Commit changes with `git add .` and `git commit -m 'Your message - Bootstrap configuration using jenkins_module'`
1. Push my-0-bootstrap branch to your repository YOUR_NEW_REPO-0-bootstrap with `git push --set-upstream origin my-0-bootstrap`

### II. Create the SEED and CICD projects using Terraform

- Required information:
  - Terraform version 1.0.0 - See [Requirements](#requirements) section for more details.
  - The `terraform.tfvars` file with all the necessary values.

1. Get the appropriate credentials: run the following command with an account that has the [necessary permissions](./modules/jenkins-agent/README.md#Permissions).
    ```
    gcloud auth application-default login
    ```
    1. Open the link in your browser and accept.

1. Run terraform commands.
    - After the credentials are configured, we will create the `prj-b-seed` project (which contains the GCS state bucket and Terraform custom service account) and the `prj-b-cicd` project (which contains the Jenkins Agent, its custom service account and where we will add VPN configuration)
    - **WARNING: Make sure you have commented-out the `cloudbuild_bootstrap` module and enabled the `jenkins_bootstrap` module in the `./main.tf` file**
    - **Use Terraform 1.0.0** to run the terraform script with the commands below
    ```
    terraform init
    terraform plan
    terraform apply
    ```
    - The Terraform script will take about 10 to 15 minutes. Once it finishes, note that communication between on-prem and the `prj-b-cicd` project won’t happen yet - you will configure the VPN network connectivity in step [III. Create VPN connection](#III-Create-VPN-connection).

1. Move Terraform State to the GCS bucket created in the Seed Project
   1. Run `terraform output gcs_bucket_tfstate` to get the tfstate bucket name
   1. Rename `backend.tf.example` to `backend.tf`
   1. Edit file `backend.tf` and replace `UPDATE_ME` with the tfstate bucket name

1. Re-run `terraform init` and agree to copy state to gcs when prompted
    - (Optional) Run `terraform apply` to verify state is configured correctly. You can confirm the terraform state is now in that bucket by visiting the bucket url in your Seed Project.

1. Commit changes with `git add backend.tf` and `git commit -m 'Your message - Terraform Backend configuration using GCS'`
1. Push my-0-bootstrap branch to your repository YOUR_NEW_REPO-0-bootstrap with `git push`

### III. Configure VPN connection

Here you will configure a VPN Network tunnel to enable connectivity between the `prj-b-cicd` project and your on-prem environment. Learn more about [a VPN tunnel in GCP](https://cloud.google.com/network-connectivity/docs/vpn/how-to).
- Required information:
    - On-prem VPN public IP Address
    - Jenkins Controller’s network CIDR (the example code uses "10.1.0.0/24")
    - Jenkins Agent network CIDR (the example code uses "172.16.1.0/24")
    - VPN PSK (pre-shared secret key)

1. Check in the `prj-b-cicd` project for the VPN gateway static IP addresses which have been reserved. These addresses are required by the Network Administrator for the configuration of the on-prem side of the VPN tunnels to GCP.

  - Assuming your network administrator already configured the on-prem end of the VPN, the CICD end of the VPN might show the message `First Handshake` for around 5 minutes.
  - When the VPN is ready, the status will show `Tunnel is up and running`. At this point, your Jenkins Controller (on-prem) and Jenkins Agent (in `prj-b-cicd` project) must have network connectivity through the VPN.

1. Test a pipeline using the Jenkins Controller Web UI:
    1. Make sure your [SSH Agent](https://plugins.jenkins.io/ssh-agent) is online and troubleshoot network connectivity if needed.
    1. Test that your Jenkins Controller can deploy a [pipeline](https://www.jenkins.io/doc/book/pipeline/getting-started/) to the Jenkins Agent located in the `prj-b-cicd` project (you can test this by running with a simple `echo "Hello World"` pipeline build).

### IV. Configure the Git repositories and Multibranch Pipelines in your Jenkins Controller

- **Note:** this section is considered out of the scope of this document. Since there are multiple options on how to configure the Git repositories and **Multibranch Pipeline** in your Jenkins Controller, here we can only provide some guidance that you should keep in mind while completing this step. Visit the [Jenkins website](https://jenkins.io) for more information, there are plenty of Jenkins Plugins that could help with the task.
    - You need to configure a **"Multibranch Pipeline"**. Note that the `Jenkinsfile` and `tf-wrapper.sh` files use the `$BRANCH_NAME` environment variable. **the `$BRANCH_NAME` variable is only available in Jenkins' Multibranch Pipelines**.


- **Jenkinsfile:** A [Jenkinsfile](../build/Jenkinsfile) has been included which closely aligns with the Cloud Build pipeline. Additionally, the stage `TF wait for approval` which lets you confirm via Jenkins UI before proceeding with `terraform apply` has been disabled by default. It can be enabled by un-commenting that stage in the file.

1. Create Multibranch pipelines for your new repos (`YOUR_NEW_REPO-1-org, YOUR_NEW_REPO-2-environments, YOUR_NEW_REPO-3-networks, YOUR_NEW_REPO-4-projects`).
    - **DO NOT configure an automatic pipeline for your `YOUR_NEW_REPO-0-bootstrap` repository**

1. In your Jenkins Controller Web UI, **create Multibranch Pipelines only for the following repositories:**
    ```
    YOUR_NEW_REPO-1-org
    YOUR_NEW_REPO-2-environments
    YOUR_NEW_REPO-3-networks
    YOUR_NEW_REPO-4-projects
    ```
1. Assuming your new Git repositories are private, you may need to configure new credentials In your Jenkins Controller web UI, so it can connect to the repositories.

1. You will also want to configure automatic triggers in each one of the Jenkins Multibranch Pipelines, unless you want to run the pipelines manually from the Jenkins Web UI after each commit to your repositories.

1. You can now move to the instructions for step 1-org.

## Deploying step 1-org

1. Clone the repo you created manually in 0-bootstrap instructions.
   ```
   git clone <YOUR_NEW_REPO-1-org>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the <YOUR_NEW_REPO-1-org> directory. If
   you run them from another directory, adjust your copy paths accordingly.
   ```
   cd YOUR_NEW_REPO_CLONE-1-org
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/1-org/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/Jenkinsfile .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from 0-bootstrap:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the CI/CD project ID)
    ```
1. You can re-run `terraform output` in the 0-bootstrap directory to find these values.
   ```
   BACKEND_STATE_BUCKET_NAME=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "_STATE_BUCKET_NAME = ${BACKEND_STATE_BUCKET_NAME}"
   sed -i "s/STATE_BUCKET_NAME/${BACKEND_STATE_BUCKET_NAME}/" ./Jenkinsfile

   TERRAFORM_SA_EMAIL=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw organization_step_terraform_service_account_email)
   echo "_TF_SA_EMAIL = ${TERRAFORM_SA_EMAIL}"
   sed -i "s/TERRAFORM_SA_EMAIL/${TERRAFORM_SA_EMAIL}/" ./Jenkinsfile

   CICD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo "_PROJECT_ID = ${CICD_PROJECT_ID}"
   sed -i "s/CICD_PROJECT_ID/${CICD_PROJECT_ID}/" ./Jenkinsfile
   ```
1. Check if your organization already has an Access Context Manager Policy.
   ```
   export ORGANIZATION_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' | tr -d '"')
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   ```
1. Rename `./envs/shared/terraform.example.tfvars` to `./envs/shared/terraform.tfvars` and update the file with values from your environment and 0-bootstrap.
   ```
   mv ./envs/shared/terraform.example.tfvars ./envs/shared/terraform.tfvars
   ```
1. You can re-run `terraform output` in the 0-bootstrap directory to find these values. If the previous step showed a numeric value, make sure to un-comment the variable `create_access_context_manager_access_policy = false`. See the shared folder [README.md](./envs/shared/README.md) for additional information on the values in the `terraform.tfvars` file.
   ```
   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"
   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./envs/shared/terraform.tfvars
   ```
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch.
    - Assuming you configured an automatic trigger in your Jenkins Controller (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](https://www.jenkins.io) for more details.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your Controller's web UI.
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Controller's web UI. (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).

## Deploying step 2-environments


1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-2-environments>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the <YOUR_NEW_REPO-2-environments> directory. If
   you run them from another directory, adjust your copy paths accordingly.

   ```
   cd YOUR_NEW_REPO_CLONE-2-environments
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/2-environments/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/Jenkinsfile .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the CI/CD project ID)
    ```
1. You can re-run `terraform output` in the 0-bootstrap directory to find these values.
   ```
   BACKEND_STATE_BUCKET_NAME=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "_STATE_BUCKET_NAME = ${BACKEND_STATE_BUCKET_NAME}"
   sed -i "s/STATE_BUCKET_NAME/${BACKEND_STATE_BUCKET_NAME}/" ./Jenkinsfile

   TERRAFORM_SA_EMAIL=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw environment_step_terraform_service_account_email)
   echo "_TF_SA_EMAIL = ${TERRAFORM_SA_EMAIL}"
   sed -i "s/TERRAFORM_SA_EMAIL/${TERRAFORM_SA_EMAIL}/" ./Jenkinsfile

   CICD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo "_PROJECT_ID = ${CICD_PROJECT_ID}"
   sed -i "s/CICD_PROJECT_ID/${CICD_PROJECT_ID}/" ./Jenkinsfile
   ```
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment and 0-bootstrap.
   ```
   mv terraform.example.tfvars terraform.tfvars
   ```
1. You can re-run `terraform output` in the 0-bootstrap directory to find these values. See any of the envs folder [README.md](./envs/production/README.md#inputs) files for additional information on the values in the `terraform.tfvars` file.
   ```
   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"
   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./terraform.tfvars
   ```
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch.
   ```
   git push --set-upstream origin plan
   ```
    - Assuming you configured an automatic trigger in your Jenkins Controller (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent/README.md)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](https://www.jenkins.io) for more details.
1. Review the plan output in your Controller's web UI.
1. Merge changes to development.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. Merge changes to non-production with.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. You can now move to the instructions in the next step, go to [3-networks-dual-svpc](#deploying-step-3-networks-dual-svpc) to use the Dual Shared VPC mode, or go to [3-networks-hub-and-spoke](#deploying-step-3-networks-hub-and-spoke) to use the Hub and Spoke network mode.

## Deploying step 3-networks-dual-svpc

1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-3-networks>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the <YOUR_NEW_REPO-3-networks> directory. If
   you run them from another directory, adjust your copy paths accordingly.
   ```
   cd YOUR_NEW_REPO_CLONE-3-networks
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/3-networks-dual-svpc/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/Jenkinsfile .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the CI/CD project ID)
    ```
1. You can re-run `terraform output` in the 0-bootstrap directory to find these values.
   ```
   BACKEND_STATE_BUCKET_NAME=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "_STATE_BUCKET_NAME = ${BACKEND_STATE_BUCKET_NAME}"
   sed -i "s/STATE_BUCKET_NAME/${BACKEND_STATE_BUCKET_NAME}/" ./Jenkinsfile

   TERRAFORM_SA_EMAIL=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw networks_step_terraform_service_account_email)
   echo "_TF_SA_EMAIL = ${TERRAFORM_SA_EMAIL}"
   sed -i "s/TERRAFORM_SA_EMAIL/${TERRAFORM_SA_EMAIL}/" ./Jenkinsfile

   CICD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo "_PROJECT_ID = ${CICD_PROJECT_ID}"
   sed -i "s/CICD_PROJECT_ID/${CICD_PROJECT_ID}/" ./Jenkinsfile
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.
   ```
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```
1. Update `common.auto.tfvars` file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Update `shared.auto.tfvars` file with the `target_name_server_addresses`.
1. Update `access_context.auto.tfvars` file with the `access_context_manager_policy_id`.
1. Use `terraform output` to get the backend bucket and networks step Terraform Service Account values from 0-bootstrap output.
   ```
   export ORGANIZATION_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' | tr -d '"')
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars

   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"
   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars

   export NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw networks_step_terraform_service_account_email)
   echo "terraform_service_account = ${NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL}"
   sed -i "s/NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL/${NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL}/" ./common.auto.tfvars
   ```
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. You must manually plan and apply the `shared` environment (only once) since the `development`, `non-production` and `production` environments depend on it.
1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Also update `backend.tf` with your backend bucket from 0-bootstrap output.
   ```
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   ```
1. Use `terraform output` to get the Cloud Build project ID and the networks step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.
   ```
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw networks_step_terraform_service_account_email)
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
1. Push your plan branch.
   ```
    git push --set-upstream origin plan
    ```
    - Assuming you configured an automatic trigger in your Jenkins Controller (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](https://www.jenkins.io) for more details.
1. Review the plan output in your Controller's web UI.
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. After production has been applied, apply development and non-production.
1. Merge changes to development
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. Merge changes to non-production.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).

## Deploying step 3-networks-hub-and-spoke

1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-3-networks>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the <YOUR_NEW_REPO-3-networks> directory. If
   you run them from another directory, adjust your copy paths accordingly.
   ```
   cd YOUR_NEW_REPO_CLONE-3-networks
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/3-networks-hub-and-spoke/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/Jenkinsfile .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the CI/CD project ID)
    ```
1. You can re-run `terraform output` in the 0-bootstrap directory to find these values.
   ```
   BACKEND_STATE_BUCKET_NAME=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "_STATE_BUCKET_NAME = ${BACKEND_STATE_BUCKET_NAME}"
   sed -i "s/STATE_BUCKET_NAME/${BACKEND_STATE_BUCKET_NAME}/" ./Jenkinsfile

   TERRAFORM_SA_EMAIL=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw networks_step_terraform_service_account_email)
   echo "_TF_SA_EMAIL = ${TERRAFORM_SA_EMAIL}"
   sed -i "s/TERRAFORM_SA_EMAIL/${TERRAFORM_SA_EMAIL}/" ./Jenkinsfile

   CICD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo "_PROJECT_ID = ${CICD_PROJECT_ID}"
   sed -i "s/CICD_PROJECT_ID/${CICD_PROJECT_ID}/" ./Jenkinsfile
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.
   ```
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```
1. Update `common.auto.tfvars` file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Update `shared.auto.tfvars` file with the `target_name_server_addresses`.
1. Update `access_context.auto.tfvars` file with the `access_context_manager_policy_id`.
1. Use `terraform output` to get the backend bucket and networks step Terraform Service Account values from 0-bootstrap output.
   ```
   export ORGANIZATION_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -json common_config | jq '.org_id' | tr -d '"')
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars

   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"
   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars

   export NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw networks_step_terraform_service_account_email)
   echo "terraform_service_account = ${NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL}"
   sed -i "s/NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL/${NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL}/" ./common.auto.tfvars
   ```
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. You must manually plan and apply the `shared` environment (only once) since the `development`, `non-production` and `production` environments depend on it.
1. To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.
1. Also update `backend.tf` with your backend bucket from 0-bootstrap output.
   ```
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   ```
1. Use `terraform output` to get the Cloud Build project ID and the networks step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.
   ```
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw networks_step_terraform_service_account_email)
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
1. Push your plan branch.
   ```
    git push --set-upstream origin plan
    ```
    - Assuming you configured an automatic trigger in your Jenkins Controller (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](https://www.jenkins.io) for more details.
1. Review the plan output in your Controller's web UI.
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. After production has been applied, apply development and non-production.
1. Merge changes to development
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. Merge changes to non-production.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).

## Deploying step 4-projects

1. Clone the repo you created manually in 0-bootstrap.
   ```
   git clone <YOUR_NEW_REPO-4-projects>
   ```
1. Navigate into the repo and change to a non-production branch. All subsequent
   steps assume you are running them from the <YOUR_NEW_REPO-4-projects> directory. If
   you run them from another directory, adjust your copy paths accordingly.
   ```
   cd YOUR_NEW_REPO_CLONE-4-projects
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/4-projects/ .
   cp -RT ../terraform-example-foundation/policy-library/ ./policy-library
   cp ../terraform-example-foundation/build/Jenkinsfile .
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Update the variables located in the `environment {}` section of the `Jenkinsfile` with values from your environment:
    ```
    _TF_SA_EMAIL
    _STATE_BUCKET_NAME
    _PROJECT_ID (the CI/CD project ID)
    ```
1. You can re-run `terraform output` in the 0-bootstrap directory to find these values.
   ```
   BACKEND_STATE_BUCKET_NAME=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "_STATE_BUCKET_NAME = ${BACKEND_STATE_BUCKET_NAME}"
   sed -i "s/STATE_BUCKET_NAME/${BACKEND_STATE_BUCKET_NAME}/" ./Jenkinsfile

   TERRAFORM_SA_EMAIL=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw projects_step_terraform_service_account_email)
   echo "_TF_SA_EMAIL = ${TERRAFORM_SA_EMAIL}"
   sed -i "s/TERRAFORM_SA_EMAIL/${TERRAFORM_SA_EMAIL}/" ./Jenkinsfile

   CICD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo "_PROJECT_ID = ${CICD_PROJECT_ID}"
   sed -i "s/CICD_PROJECT_ID/${CICD_PROJECT_ID}/" ./Jenkinsfile
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
   export backend_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "backend_bucket = ${backend_bucket}"
   sed -i "s/TERRAFORM_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars
   ```
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Also update `backend.tf` with your backend bucket from 0-bootstrap output.
   ```
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   ```
1. You need to manually plan and apply only once the `shared` environments since `development`, `non-production`, and `production` depend on it.
1. Use `terraform output` to get the Cloud Build project ID and the projects step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.
   ```
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw projects_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```
1. Run `init` and `plan` and review output for environments `shared`.
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
1. Push your plan branch.
   ```
   git push --set-upstream origin plan
   ```
    - Assuming you configured an automatic trigger in your Jenkins Controller (see [Jenkins sub-module README](../0-bootstrap/modules/jenkins-agent)), this will trigger a plan. You can also trigger a Jenkins job manually. Given the many options to do this in Jenkins, it is out of the scope of this document see [Jenkins website](https://www.jenkins.io) for more details.
1. Review the plan output in your Controller's web UI.
1. Merge changes to production branch.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. After production has been applied, apply development.
1. Merge changes to development branch.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).
1. After development has been applied, apply non-production.
1. Merge changes to non-production branch.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Controller's web UI (you might want to use the option to "Scan Multibranch Pipeline Now" in your Jenkins Controller UI).

## Contributing

Refer to the [contribution guidelines](../CONTRIBUTING.md) for
information on contributing to this module.
