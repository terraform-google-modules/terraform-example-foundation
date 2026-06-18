# Overview

The objective of this module is to deploy a Google Cloud Platform project `prj-b-cicd` to host a Jenkins Agent that can connect with your current Jenkins Controller on-prem. This module is a replica of the deprecated [cloudbuild module](https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/cloudbuild), but re-purposed to use Jenkins instead. This module creates:

- The `prj-b-cicd` project, which includes:
  - GCE Instance for the Jenkins Agent, which you will configure to connect to your current Jenkins Controller using SSH.
  - VPC to connect the Jenkins GCE Instance to
  - FW rules to allow communication over port 22
  - VPN connection with on-prem (or where ever your Jenkins Controller is located)
  - Custom service account `sa-jenkins-agent-gce@prj-b-cicd-xxxx.iam.gserviceaccount.com` for the GCE instance. This service account is granted the access to generate tokens on the provided Terraform custom service account
Please note this module does not include an option to create a Jenkins Controller. To deploy a Jenkins Controller, you should follow one of the available user guides about [Jenkins in GCP](https://cloud.google.com/jenkins).

**If you don't have a Jenkins implementation and don't want one**, then we recommend you to [use the Cloud Build module](../../README.md#deploying-with-cloud-build) instead.

## Usage

Basic usage of this sub-module is as follows:

```hcl
module "jenkins_bootstrap" {
  source                                    = "./modules/jenkins-agent"
  org_id                                    = "<ORGANIZATION_ID>"
  folder_id                                 = "<FOLDER_ID>"
  billing_account                           = "<BILLING_ACCOUNT_ID>"
  group_org_admins                          = "gcp-organization-admins@example.com"
  default_region                            = "us-central1"
  terraform_sa_names                        = "<SERVICE_ACCOUNT_NAMES>"
  terraform_state_bucket                    = "<GCS_STATE_BUCKET_NAME>"
  sa_enable_impersonation                   = true
  jenkins_controller_subnetwork_cidr_range  = ["10.1.0.6/32"]
  jenkins_agent_gce_subnetwork_cidr_range   = "172.16.1.0/24"
  jenkins_agent_gce_private_ip_address      = "172.16.1.6"
  nat_bgp_asn                               = "BGP_ASN_FOR_NAT_CLOUD_ROUTE"
  jenkins_agent_sa_email                    = "jenkins-agent-gce" # service_account_prefix will be added
  jenkins_agent_gce_ssh_pub_key             = var.jenkins_agent_gce_ssh_pub_key
}
```

## Features

1. Creates a new GCP project using `project_prefix`
1. Enables APIs in the project using `activate_apis`
1. Creates a GCE Instance to run the Jenkins Agent with SSH access using the supplied public key
1. Creates a Service Account (`jenkins_agent_sa_email`) to run the Jenkins Agent GCE instance
1. Creates a GCS bucket for Jenkins Artifacts using `project_prefix`
1. Allows `jenkins_agent_sa_email` service account permissions to impersonate terraform service account (which exists in the `seed` project) using `sa_enable_impersonation` and supplied value for `terraform_sa_names`
1. Adds Cloud NAT for the Agent to be able to download updates and necessary binaries.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| cicd\_project\_id | Project where the [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline) (Jenkins Agents and terraform builder container image) reside. |
| cicd\_project\_number | Project number of the CI/CD project. |
| gcs\_bucket\_jenkins\_artifacts | Bucket used to store Jenkins artifacts in Jenkins project. |
| jenkins\_agent\_gce\_instance\_id | Jenkins Agent GCE Instance id. |
| jenkins\_agent\_sa\_email | Email for privileged custom service account for Jenkins Agent GCE instance. |
| jenkins\_agent\_sa\_name | Fully qualified name for privileged custom service account for Jenkins Agent GCE instance. |
| jenkins\_agent\_vpc\_id | Jenkins Agent VPC name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

- [gcloud sdk](https://cloud.google.com/sdk/install) >= 393.0.0
- [Terraform](https://www.terraform.io/downloads.html) = 1.5.7
  - The scripts in this codebase use Terraform v1.5.7. You should use the same version in the manual steps to avoid [Terraform State Snapshot Lock](https://github.com/hashicorp/terraform/issues/23290) errors caused by differences in terraform versions.

### Infrastructure

- **Jenkins Controller:** You need a Jenkins Controller, since this module does not include an option to create one. To deploy a Jenkins Controller, you should follow one of the available user guides about [Jenkins in GCP](https://cloud.google.com/jenkins). If you don't have a Jenkins implementation and don't want one, then we recommend you to [use the Cloud Build module](../../README.md#deploying-with-cloud-build) instead.

- **VPN Connectivity with on-prem:** Once you run this module, a Jenkins Agent is created in the CI/CD project in GCP. Please add VPN connectivity manually by following our user guide about [how to deploy a VPN tunnel in GCP](https://cloud.google.com/network-connectivity/docs/vpn/how-to/adding-a-tunnel). This VPN is necessary to allow communication between the Jenkins Controller (on prem or in a cloud environment) with the Jenkins Agent in the CI/CD project.

- **Binaries and packages for the Jenkins Agent:** The Jenkins Agent is a new GCE instance created by this module. After creation, the startup script needs to fetch several binaries for later use, during pipelines execution. These binaries include `java`, `terraform` and any other binary you use in your own scripts. You have several options to make these binaries and libraries available to the Jenkins Agent:
  - allow the Jenkins Agent Internet access (ideally through Cloud NAT, implemented by default).
  - allow the Jenkins Agent access to local package repositories on your premises, ideally through the VPN connection.
  - preparing a golden image for the Jenkins Agent (and assign the image to the `jenkins_agent_gce_instance.boot_disk.initialize_params.image` terraform variable). You can create the golden images with tools like Packer. Although, you might still need network access to download dependencies while running a pipeline.

### Permissions

An account that has the following [permissions](https://github.com/terraform-google-modules/terraform-google-bootstrap#permissions):

- `roles/billing.user` on supplied billing account
- `roles/resourcemanager.organizationAdmin` on GCP Organization
- `roles/resourcemanager.projectCreator` on GCP Organization or folder

This is especially important as you might face one of the errors below:

```text
Error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
   on <empty> line 0:
  (source code not available)
```

```text
Error: Error setting billing account "aaaaaa-bbbbbb-cccccc" for project "projects/prj-jenkins-dc3a": googleapi: Error 400: Precondition check failed., failedPrecondition
      on .terraform/modules/jenkins/terraform-google-project-factory-7.1.0/modules/core_project_factory/main.tf line 96, in resource "google_project" "main":
      96: resource "google_project" "main" {
```

```text
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

## Contributing

Refer to the [contribution guidelines](../../../CONTRIBUTING.md) for
information on contributing to this module.
