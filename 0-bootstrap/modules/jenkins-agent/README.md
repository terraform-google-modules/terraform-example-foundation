## Overview

The objective of this module is to deploy a Google Cloud Platform project `prj-cicd` to host a Jenkins Agent that can be used to deploy your infrastructure changes. This module is a replica of the [cloudbuild module](https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/cloudbuild), but re-purposed to use jenkins instead of Cloud Build. This module creates:
- The `prj-cicd` project to hold the Jenkins Agent
- GCE Instance for the Jenkins Agent, assigning SSH public keys in the metadata to allow connectivity from the Jenkins Master.
- FW rules to allow communication over port 22
- VPN connection with on-prem (or where ever your Jenkins Master is located)
- The custom service account `sa-jenkins-agent-gce@prj-cicd-xxxx.com` used by the GCE instance, which is granted the access to generate tokens over the Terraform custom service account
Please note this module does not include an option to create a Jenkins Master. To deploy a Jenkins Master, you should follow one of the available user guides in https://cloud.google.com/jenkins.

**If you don't have a Jenkins implementation and don't want one**, then we recommend you to [use the Cloud Build module](../../README.md) instead of this Jenkins module.

## Usage

Basic usage of this sub-module is as follows:

```hcl
module "jenkins_bootstrap" {
  source                                  = "./modules/jenkins-agent"
  org_id                                  = "<ORGANIZATION_ID>"
  folder_id                               = "<FOLDER_ID>"
  billing_account                         = "<BILLING_ACCOUNT_ID>"
  group_org_admins                        = "gcp-organization-admins@example.com"
  default_region                          = "us-central1"
  terraform_sa_email                      = "<SERVICE_ACCOUNT_EMAIL>" # normally module.seed_bootstrap.terraform_sa_email
  terraform_sa_name                       = "<SERVICE_ACCOUNT_NAME>" # normally module.seed_bootstrap.terraform_sa_name
  terraform_state_bucket                  = "<GCS_STATE_BUCKET_NAME>" # normally module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation                 = true
  jenkins_master_ip_addresses             = ["10.1.0.6/32"]
  jenkins_agent_gce_subnetwork_cidr_range = "10.2.0.0/24"
  jenkins_agent_gce_private_ip_address    = "10.2.0.6"
  nat_bgp_asn                             = "BGP_ASN_FOR_NAT_CLOUD_ROUTE"
  jenkins_agent_sa_email                  = "jenkins-agent-gce" # service_account_prefix will be added
  jenkins_agent_gce_ssh_pub_key           = var.jenkins_agent_gce_ssh_pub_key
}
```

## Features

1. Creates a new GCP project using `project_prefix`
1. Enables APIs in the project using `activate_apis`
1. Creates a GCE Instance to run the Jenkins Agent with SSH access using the supplied public key
1. Creates a Service Account (`jenkins_agent_sa_email`) to run the Jenkins Agent GCE instance
1. Creates a GCS bucket for Jenkins Artifacts using `project_prefix`
1. Allows `jenkins_agent_sa_email` service account permissions to impersonate terraform service account (which exists in the `seed` project) using `sa_enable_impersonation` and supplied value for `terraform_sa_name`
1. Adds Cloud NAT for the Agent to be able to download updates and necessary binaries.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | List of APIs to enable in the CICD project. | list(string) | `<list>` | no |
| billing\_account | The ID of the billing account to associate projects with. | string | n/a | yes |
| default\_region | Default region to create resources where applicable. | string | `"us-central1"` | no |
| folder\_id | The ID of a folder to host this project | string | `""` | no |
| group\_org\_admins | Google Group for GCP Organization Administrators | string | n/a | yes |
| jenkins\_agent\_gce\_machine\_type | Jenkins Agent GCE Instance type. | string | `"n1-standard-1"` | no |
| jenkins\_agent\_gce\_name | Jenkins Agent GCE Instance name. | string | `"jenkins-agent-01"` | no |
| jenkins\_agent\_gce\_private\_ip\_address | The private IP Address of the Jenkins Agent. This IP Address must be in the CIDR range of `jenkins_agent_gce_subnetwork_cidr_range` and be reachable through the VPN that exists between on-prem (Jenkins Master) and GCP (CICD Project, where the Jenkins Agent is located). | string | n/a | yes |
| jenkins\_agent\_gce\_ssh\_pub\_key | SSH public key needed by the Jenkins Agent GCE Instance. The Jenkins Master holds the SSH private key. The correct format is `'ssh-rsa [KEY_VALUE] [USERNAME]'` | string | n/a | yes |
| jenkins\_agent\_gce\_ssh\_user | Jenkins Agent GCE Instance SSH username. | string | `"jenkins"` | no |
| jenkins\_agent\_gce\_subnetwork\_cidr\_range | The subnetwork to which the Jenkins Agent will be connected to (in CIDR range 0.0.0.0/0) | string | n/a | yes |
| jenkins\_agent\_sa\_email | Email for Jenkins Agent service account. | string | `"jenkins-agent-gce"` | no |
| jenkins\_master\_ip\_addresses | A list of CIDR IP ranges of the Jenkins Master in the form ['0.0.0.0/0']. Usually only one IP in the form '0.0.0.0/32'. Needed to create a FW rule that allows communication with the Jenkins Agent GCE Instance. | list(string) | n/a | yes |
| nat\_bgp\_asn | BGP ASN for NAT cloud route. This is needed to allow the Jenkins Agent to download packages and updates from the internet without having an external IP address. | number | n/a | yes |
| org\_id | GCP Organization ID | string | n/a | yes |
| project\_labels | Labels to apply to the project. | map(string) | `<map>` | no |
| project\_prefix | Name prefix to use for projects created. | string | `"prj"` | no |
| sa\_enable\_impersonation | Allow org_admins group to impersonate service account & enable APIs required. | bool | `"false"` | no |
| service\_account\_prefix | Name prefix to use for service accounts. | string | `"sa"` | no |
| skip\_gcloud\_download | Whether to skip downloading gcloud (assumes gcloud is already available outside the module) | bool | `"true"` | no |
| storage\_bucket\_labels | Labels to apply to the storage bucket. | map(string) | `<map>` | no |
| storage\_bucket\_prefix | Name prefix to use for storage buckets. | string | `"bkt"` | no |
| terraform\_sa\_email | Email for terraform service account. It must be supplied by the seed project | string | n/a | yes |
| terraform\_sa\_name | Fully-qualified name of the terraform service account. It must be supplied by the seed project | string | n/a | yes |
| terraform\_state\_bucket | Default state bucket, used in Cloud Build substitutions. It must be supplied by the seed project | string | n/a | yes |
| terraform\_version | Default terraform version. | string | `"0.12.24"` | no |
| terraform\_version\_sha256sum | sha256sum for default terraform version. | string | `"602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cicd\_project\_id | Project where the cicd pipeline (Jenkins Agents and terraform builder container image) reside. |
| gcs\_bucket\_jenkins\_artifacts | Bucket used to store Jenkins artifacts in Jenkins project. |
| jenkins\_agent\_gce\_instance\_id | Jenkins Agent GCE Instance id. |
| jenkins\_agent\_sa\_email | Email for privileged custom service account for Jenkins Agent GCE instance. |
| jenkins\_agent\_sa\_name | Fully qualified name for privileged custom service account for Jenkins Agent GCE instance. |
| jenkins\_agent\_vpc\_id | Jenkins Agent VPC name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

- [gcloud sdk](https://cloud.google.com/sdk/install) >= 206.0.0
- [Terraform](https://www.terraform.io/downloads.html) = 0.12.24
    - The scripts in this codebase use Terraform v0.12.24. You must use the same version in the manual steps to avoid [Terraform State Snapshot Lock](https://github.com/hashicorp/terraform/issues/23290) errors caused by differences in terraform versions.
- [terraform-provider-google](https://github.com/terraform-providers/terraform-provider-google) plugin 2.1.x
- [terraform-provider-google-beta](https://github.com/terraform-providers/terraform-provider-google-beta) plugin 2.1.x

### Infrastructure

 - **Jenkins Master:** You need a Jenkins Master. Please note this module does not include an option to create a Jenkins Master. To deploy a Jenkins Master, you should follow one of the available user guides about [Jenkins in GCP](https://cloud.google.com/jenkins). If you don't have a Jenkins implementation and don't want one, then we recommend you to use the Cloud Build module instead of this Jenkins module.

 - **VPN Connectivity with on-prem:** Once you run this module and your Jenkins Agent is created in the CICD project in GCP, please add VPN connectivity manually by following our user guide about [how to deploy a VPN tunnel in GCP](https://cloud.google.com/network-connectivity/docs/vpn/how-to). This VPN configuration is necessary to allow communication between the Jenkins Master (on prem or in a cloud environment) with the Jenkins Agent in the CICD project. The reason why you add this connection manually is because you need to keep the VPN secret away from any configuration file, such as the Terraform state.

 - **Binaries and packages:** The Jenkins Agent needs to fetch several binaries needed to execute pipelines. These include `java`, `terraform`, `terraform-validator` and the binaries you use in your own scripts. You have several options to have these binaries and libraries available:
    - having Internet access (ideally through Cloud NAT, implemented by default).
    - having local package repositories on your premises that the Agent can reach out to through the VPN connection.
    - preparing a golden image for `jenkins_agent_gce_instance.boot_disk.initialize_params.image` using tools like Packer. Although, you might still need network access to download dependencies while running a pipeline.

### Permissions

In step [2.1. Get the appropriate credentials](#2.1.gettheappropriatecredentials), run `$ gcloud auth application-default login` with an account that has the following [permissions](https://github.com/terraform-google-modules/terraform-google-bootstrap#permissions):

- `roles/billing.user` on supplied billing account
- `roles/resourcemanager.organizationAdmin` on GCP Organization
- `roles/resourcemanager.projectCreator` on GCP Organization or folder

This is especially important as you might face one of the errors below:
```
Error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
   on <empty> line 0:
  (source code not available)
```

```
Error: Error setting billing account "aaaaaa-bbbbbb-cccccc" for project "projects/cft-jenkins-dc3a": googleapi: Error 400: Precondition check failed., failedPrecondition
      on .terraform/modules/jenkins/terraform-google-project-factory-7.1.0/modules/core_project_factory/main.tf line 96, in resource "google_project" "main":
      96: resource "google_project" "main" {
```

```
Error: failed pre-requisites: missing permission on "billingAccounts/aaaaaa-bbbbbb-cccccc": billing.resourceAssociations.create
  on .terraform/modules/jenkins/terraform-google-project-factory-7.1.0/modules/core_project_factory/main.tf line 96, in resource "google_project" "main":
  96: resource "google_project" "main" {
```

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
- Google Cloud Billing API: `cloudbilling.googleapis.com`
- Google Cloud IAM API: `iam.googleapis.com`
- Google Cloud Storage API `storage-api.googleapis.com`
- Google Cloud Service Usage API: `serviceusage.googleapis.com`
- Google Cloud Compute API: `compute.googleapis.com`
- Google Cloud KMS API: `cloudkms.googleapis.com`

This API can be enabled in the default project created during establishing an organization.

## Bootstrap instructions using the jenkins_module

You arrived to these instructions because you are using the `jenkins_bootstrap` to run the bootstrap step instead of `cloudbuild_bootstrap`. Please follow the indications below:

### 1. Bootstrap Manual steps before running any terraform script
  - Required information:
     - Access to the Jenkins Master host to run `ssh-keygen` command
     - Access to the Jenkins Master Web UI
     - [SSH Agent Jenkins plugin](https://plugins.jenkins.io/ssh-agent) installed in your Jenkins Master
     - Private IP address for the Jenkins Agent: usually assigned by your network administrator. You will use this IP for the GCE instance that will be created in the `cicd` GCP Project in step [2.2. Run terraform commands](#2.2.RunTerraformCommands).
     - Access to create five Git repositories, one for each directory in this [monorepo](https://github.com/terraform-google-modules/terraform-example-foundation) (`0-bootstrap, 1-org, 2-environments, 3-networks, 4-projects`). These are usually private repositories that might be on-prem.

#### 1.1. Generate a SSH key pair

In the Jenkins Master host, use the `ssh-keygen` command to generate a SSH key pair. You will need this key pair to enable authentication between the Master and Agent. Although the key pair can be generated in any linux machine. It is recommended not to copy the secret private key from one host to another, so you may want to do this from the Jenkins Master host. Note the `ssh-keygen` command uses the `-N` option to protect the private key with a password.

- In this example, we are using `-N ""` which means we are not setting a password to protect this private key.
    ```
    SSH_LOCAL_CONFIG_DIR="$HOME/.ssh"
    JENKINS_USER="jenkins"
    JENKINS_AGENT_NAME="AgentGCE1"
    SSH_KEY_FILE_PATH="$SSH_LOCAL_CONFIG_DIR/$JENKINS_USER-${JENKINS_AGENT_NAME}_rsa"
    mkdir "$SSH_LOCAL_CONFIG_DIR"
    ssh-keygen -t rsa -m PEM -N "" -C $JENKINS_USER -f $SSH_KEY_FILE_PATH
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

#### 1.2. Configure a new SSH Jenkins Agent

In the Jenkins Master’s Web UI, use the following information to configure a new [SSH Jenkins Agent](https://plugins.jenkins.io/ssh-agent/):
- SSH private key you just generated
- The passphrase that protects the private key if you used the `-N ""` option
- The Jenkins Agent’s private IP address assigned by your Network Administrator

#### 1.3. Clone this repository in multiple repositories

- Required information:
  - Public SSH key generated in the Jenkins Master (this is not a secret and can be in your repository code). Show the public key using `cat "${SSH_KEY_FILE_PATH}.pub"`, you will have to copy / paste it in the the `terraform.tfvars` file.

Although this infrastructure code is distributed to you as a [monorepo](https://github.com/terraform-google-modules/terraform-example-foundation), you will store it in five different repositories, one for each directory (`0-bootstrap, 1-org, 2-environments, 3-networks, 4-projects`). Here we will work with the first of these repositories <YOUR_NEW_REPO_CLONE-0-bootstrap>.

1. Clone this repository:
    ```
    git clone https://github.com/terraform-google-modules/terraform-example-foundation
    ```

1. Clone the repository you created to host the `0-bootstrap` directory:
    ```
    git clone <YOUR_NEW_REPO-0-bootstrap>
    ```

1. Change to freshly cloned repo and change to non master branch:
    ```
    cd <YOUR_NEW_REPO_CLONE-0-bootstrap>
    git checkout -b plan
    ```

1. Copy contents of foundation to the new repo (modify accordingly based on your current directory):
    ```
    cp -R ../terraform-example-foundation/0-bootstrap/* .
    ```

1. Copy the `Jenkinsfile` to the root of your new repository (modify accordingly based on your current directory):
   ```
   cp ../terraform-example-foundation/build/Jenkinsfile .
   ```

1. Copy the `tf-wrapper` configuration file to the root of your new repository (modify accordingly based on your current directory):
    ```
    cp ../terraform-example-foundation/build/tf-wrapper.sh .
    ```

1. Make sure the `tf-wrapper.sh` file has the appropriate executable permissions, since Jenkins might not be able to use during the pipeline (modify accordingly based on your current directory):
    ```
    chmod +x tf-wrapper.sh
    ```

1. Activate the Jenkins module and disable the Cloud Build module:
    1. Comment-out the `cloudbuild_bootstrap` module in `main.tf`, its variables in `variables.tf` and its outputs in `outputs.tf`
    1. Un-comment the `jenkins_bootstrap` module in `main.tf`, its variables in `variables.tf` and its outputs in `outputs.tf`

1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment:
    ```
    # Rename file
    mv terraform.example.tfvars terraform.tfvars
    # Edit the file to provide the necessary values
    vi terraform.tfvars
    ```

1. Commit changes and push to the `plan` branch in your repository <YOUR_NEW_REPO_CLONE-0-bootstrap> (the branch plan is not a special one. Any branch which name is different from dev, nonprod or prod will trigger a terraform plan):
    ```
    git add .
    git commit -m "Your message - Bootstrap configuration using jenkins_module"
    git push --set-upstream origin plan
    ```

While working with the other directories (`1-org, 2-environments, 3-networks, 4-projects`), you will need to clone and copy them to your other new on-prem repositories. The instructions above can help you as well.

### 2. Bootstrap scripted steps using terraform

- Required information:
  - Terraform version 0.12.24 - See [Requirements](#requirements) section for more details.
  - Access to the five Git repositories created in previous step (`0-bootstrap, 1-org, 2-environments, 3-networks, 4-projects`)
  - VPN details from your Network administrator:
     - VPN (on-prem end) public IP
     - VPN PSK secret
     - Private IP address for the Jenkins Agent (which will be created in the `cicd` GCP Project in step [2.2. Run terraform commands](#2.2.RunTerraformCommands)). This private IP will be reachable through the VPN connection that you will create in step [3.2. Configure VPN Network tunnel](#3.2.ConfigureVPNNetworktunnel).

#### 2.1. Get the appropriate credentials

- Run the following command to make sure you [have the appropriate permissions](#Permissions), which will offer to open a link in your browser:
    ```
    gcloud auth application-default login
    ```

#### 2.2. Run terraform commands.

After the credentials are configured, we will create the `cicd` project (with the Jenkins Agent and its custom service account) and the `seed` project (with GCS state bucket and Terraform custom service account).
- **Use Terraform 0.12.24** to run the terraform script with the commands below:
    ```
    terraform init
    terraform plan
    terraform apply
    ```

The Terraform script will take about 10 to 15 minutes. Once it completes, note that communication between on-prem and the `cicd` project won’t happen yet - you will configure the VPN network connectivity in step [3. Manual steps after running bootstrap terraform script](3.Manualstepsafterrunningbootstrapterraformscript).

### 3. Manual steps after running bootstrap terraform script
- Required information:
  - From previous step [2.2. Run terraform commands](#2.2.RunTerraformCommands) (you can run `terraform output` to find these values):
    - CICD project ID
    - Default region (see it in the `variables.tf` file or in `terraform.tfvars` if you changed it)
    - Jenkins Agent VPC name, which was created in the `cicd` project
    - Terraform State bucket name, which was created in the `seed` project
  - Usually, from your network administrator:
    - On-prem VPN public IP Address
    - Jenkins Master’s network CIDR
    - Jenkins Agent network CIDR
    - VPN PSK (pre-shared secret key)

#### 3.1. Update Jenkinsfile and move Terraform state to the GCS bucket created in the seed project

1. Update the `Jenkinsfile` by replacing the `_TF_SA_EMAIL` text with the name of your Terraform Service Account in the `seed` project (you can run `terraform output` to find this value). Modify accordingly based on your current directory:
   ```
   TF_SERVICE_ACCOUNT_EMAIL=`(terraform output terraform_sa_email)`
   sed -i "s/_TF_SA_EMAIL/$TF_SERVICE_ACCOUNT_EMAIL/" Jenkinsfile
   ```

   **If using MacOS:**
    ```
    TF_SERVICE_ACCOUNT_EMAIL=`(terraform output terraform_sa_email)`
    sed -i ".bak" "s/_TF_SA_EMAIL/$TF_SERVICE_ACCOUNT_EMAIL/" Jenkinsfile
    rm Jenkinsfile.bak
    ```

1. Run this command to copy the `backend.tf` file and update the GCS bucket name. Replace the `TF_STATE_GCS_BUCKET_NAME` with the name of your bucket (you can run `terraform output` to find these values).
    ```
    TF_STATE_GCS_BUCKET_NAME=`(terraform output gcs_bucket_tfstate)`
    mv backend.tf.example backend.tf
    sed -i "s/UPDATE_ME/$TF_STATE_GCS_BUCKET_NAME/" backend.tf
    ```

   **If using MacOS:**
    ```
    TF_STATE_GCS_BUCKET_NAME=`(terraform output gcs_bucket_tfstate)`
    mv backend.tf.example backend.tf
    sed -i ".bak" "s/UPDATE_ME/$TF_STATE_GCS_BUCKET_NAME/" backend.tf
    rm backend.tf.bak
    ```

1. Re-run `terraform init` and agree to copy state to gcs when prompted
    ```
    terraform init
    ```
    - (Optional) Run `terraform apply` to verify state is configured correctly. You can confirm the terraform state is now in that bucket by visiting the bucket url in your seed project.

1. Commit changes and push to the `plan` branch in your repository <YOUR_NEW_REPO_CLONE-0-bootstrap> (the branch plan is not a special one. Any branch which name is different from dev, nonprod or prod will trigger a terraform plan):
    ```
    git add backend.tf
    git commit -m "Your message - Terraform Backend configuration using GCS"
    git push
    ```

#### 3.2. Configure VPN Network tunnel

Configure VPN Network tunnel to enable connectivity between the `cicd` project and your on-prem environment. Learn more about [how to deploy a VPN tunnel in GCP](https://cloud.google.com/network-connectivity/docs/vpn/how-to).

1. Supply the required values for the bash variables below:
    ```
    # Project variables:
    CICD_PROJECT_ID=`(terraform output cicd_project_id)`
    DEFAULT_REGION="us-central1"

    # Jenkins Network environment variables:
    ONPREM_VPN_PUBLIC_IP_ADDRESS="x.x.x.x"
    JENKINS_MASTER_NETWORK_CIDR="10.1.0.0/24"
    JENKINS_AGENT_NETWORK_CIDR="10.2.0.0/24"
    JENKINS_AGENT_VPC_NAME="vpc-b-jenkinsagents"

    # New VPN variables
    VPN_PSK_SECRET="my-secret"
    CICD_VPN_PUBLIC_IP_NAME="cicd-vpn-external-static-ip"
    CICD_VPN_NAME="vpn-from-onprem-to-cicd"
    ```

1. Reserve an `EXTERNAL` IP address for the VPN:
    ```
    # Reserve a new external IP for the VPN in the cicd project
    gcloud compute addresses create $CICD_VPN_PUBLIC_IP_NAME \
    --project="${CICD_PROJECT_ID}" --region="${DEFAULT_REGION}"

    gcloud compute addresses list  --project="${CICD_PROJECT_ID}" \
   | grep $CICD_VPN_PUBLIC_IP_NAME
   ```

1. The above command will show the `EXTERNAL` static IP addresses that have been reserved for your VPN in the `cicd` project. You need to do two things with this IP Address:
    1. Inform your Network administrator of the IP address so they configure the on-prem side of the VPN tunnel.
    1. Set the variable below with the IP address you just obtained so you can create the GCP side of the VPN tunnel in the `cicd` project:
        ```
        # New VPN variables
        CICD_VPN_PUBLIC_IP_ADDRESS="x.x.x.x"
        ```

1. We now have all the necessary information to create the VPN in the `cicd` project.
    ```
    # Create the new VPN gateway
    gcloud compute --project $CICD_PROJECT_ID \
      target-vpn-gateways create $CICD_VPN_NAME \
      --region $DEFAULT_REGION \
      --network $JENKINS_AGENT_VPC_NAME

    # Create the forwarding rules
    gcloud compute --project $CICD_PROJECT_ID \
      forwarding-rules create "${CICD_VPN_NAME}-rule-esp" \
      --region $DEFAULT_REGION \
      --address $CICD_VPN_PUBLIC_IP_ADDRESS \
      --ip-protocol "ESP" \
      --target-vpn-gateway $CICD_VPN_NAME

    gcloud compute --project $CICD_PROJECT_ID \
      forwarding-rules create "${CICD_VPN_NAME}-rule-udp500" \
      --region $DEFAULT_REGION \
      --address $CICD_VPN_PUBLIC_IP_ADDRESS \
      --ip-protocol "UDP" --ports "500" \
      --target-vpn-gateway $CICD_VPN_NAME

    gcloud compute --project $CICD_PROJECT_ID \
      forwarding-rules create "${CICD_VPN_NAME}-rule-udp4500" \
      --region $DEFAULT_REGION \
      --address $CICD_VPN_PUBLIC_IP_ADDRESS \
      --ip-protocol "UDP" --ports "4500" \
      --target-vpn-gateway $CICD_VPN_NAME

    # Create a Route Based VPN tunnel
    gcloud compute --project $CICD_PROJECT_ID \
      vpn-tunnels create "${CICD_VPN_NAME}-tunnel-1" \
      --region $DEFAULT_REGION \
      --peer-address $ONPREM_VPN_PUBLIC_IP_ADDRESS \
      --shared-secret $VPN_PSK_SECRET  \
      --ike-version "2" \
      --local-traffic-selector="0.0.0.0/0" \
      --remote-traffic-selector="0.0.0.0/0" \
      --target-vpn-gateway $CICD_VPN_NAME

    # Create the necessary Route
    gcloud compute --project $CICD_PROJECT_ID \
      routes create "${CICD_VPN_NAME}-tunnel-1-route-1" \
      --network $JENKINS_AGENT_VPC_NAME \
      --next-hop-vpn-tunnel "${CICD_VPN_NAME}-tunnel-1" \
      --next-hop-vpn-tunnel-region $DEFAULT_REGION \
      --destination-range $JENKINS_MASTER_NETWORK_CIDR
    ```

    Assuming your network administrator already configured the on-prem end of the VPN, the CICD end of the VPN might show the message `First Handshake` for around 5 minutes. When the VPN is ready, the status will show `Tunnel is up and running`. At this point, your Jenkins Master (on-prem) and Jenkins Agent (in cicd project) must have network connectivity through the VPN.

1. Using the Jenkins Web UI:
    1. Connect to the [SSH Agent](https://plugins.jenkins.io/ssh-agent) and troubleshoot network connectivity if needed.
    1. Test that your Master can deploy a pipeline to the Jenkins Agent in GCP (you can test by running with a simple `echo "Hello World"` project / job) from the Jenkins Web UI.

#### 3.3. Configure the Git repositories and Multibranch Pipeline in your Jenkins Master

Note that this is section is considered out of the scope of this document, since there are multiple options on how to configure the Git repositories and **Multibranch Pipeline** in your Jenkins Master. Here we provide some guidance that you should keep in mind while completing this step. Visit the [Jenkins website](www.jenkins.io) for more information, there are plenty of Jenkins Plugins that could help with the task.

1. Assuming your new five Git repositories are private, you will need to configure new "credentials" In your Jenkins Master web UI, so it can connect to the repositories.
1. You will need to configure a "**Multibranch Pipeline**" for each one of the repositories. Note that the `Jenkinsfile` and `tf-wrapper.sh` files use the `$BRANCH_NAME` environment variable, which is **only available in Multibranch Pipelines** in Jenkins.
1. You will also want to configure automatic triggers in each one of the Jenkins Multibranch Pipelines, unless you want to run the pipelines manually from the Jenkins Web UI after each commit to your repositories.

## Contributing

Refer to the [contribution guidelines](../../../CONTRIBUTING.md) for
information on contributing to this module.
