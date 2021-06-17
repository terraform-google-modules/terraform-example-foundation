## Overview

The objective of this module is to deploy a Google Cloud Platform project `prj-b-cicd` to host a Jenkins Agent that can connect with your current Jenkins Master on-prem. This module is a replica of the [cloudbuild module](https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/cloudbuild), but re-purposed to use Jenkins instead. This module creates:
- The `prj-b-cicd` project, which includes:
    - GCE Instance for the Jenkins Agent, which you will configure to connect to your current Jenkins Master using SSH.
    - VPC to connect the Jenkins GCE Instance to
    - FW rules to allow communication over port 22
    - VPN connection with on-prem (or where ever your Jenkins Master is located)
    - Custom service account `sa-jenkins-agent-gce@prj-b-cicd-xxxx.iam.gserviceaccount.com` for the GCE instance. This service account is granted the access to generate tokens on the provided Terraform custom service account
Please note this module does not include an option to create a Jenkins Master. To deploy a Jenkins Master, you should follow one of the available user guides about [Jenkins in GCP](https://cloud.google.com/jenkins).

**If you don't have a Jenkins implementation and don't want one**, then we recommend you to [use the Cloud Build module](../../README.md) instead.

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
  terraform_service_account               = "<SERVICE_ACCOUNT_EMAIL>" # normally module.seed_bootstrap.terraform_sa_email
  terraform_sa_name                       = "<SERVICE_ACCOUNT_NAME>" # normally module.seed_bootstrap.terraform_sa_name
  terraform_state_bucket                  = "<GCS_STATE_BUCKET_NAME>" # normally module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation                 = true
  jenkins_master_subnetwork_cidr_range    = ["10.1.0.6/32"]
  jenkins_agent_gce_subnetwork_cidr_range = "172.16.1.0/24"
  jenkins_agent_gce_private_ip_address    = "172.16.1.6"
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
|------|-------------|------|---------|:--------:|
| activate\_apis | List of APIs to enable in the CICD project. | `list(string)` | <pre>[<br>  "serviceusage.googleapis.com",<br>  "servicenetworking.googleapis.com",<br>  "compute.googleapis.com",<br>  "logging.googleapis.com",<br>  "bigquery.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "cloudbilling.googleapis.com",<br>  "iam.googleapis.com",<br>  "admin.googleapis.com",<br>  "appengine.googleapis.com",<br>  "storage-api.googleapis.com"<br>]</pre> | no |
| bgp\_peer\_asn | BGP ASN for peer cloud routes. | `number` | `"64513"` | no |
| billing\_account | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| folder\_id | The ID of a folder to host this project | `string` | `""` | no |
| group\_org\_admins | Google Group for GCP Organization Administrators | `string` | n/a | yes |
| jenkins\_agent\_gce\_machine\_type | Jenkins Agent GCE Instance type. | `string` | `"n1-standard-1"` | no |
| jenkins\_agent\_gce\_name | Jenkins Agent GCE Instance name. | `string` | `"jenkins-agent-01"` | no |
| jenkins\_agent\_gce\_private\_ip\_address | The private IP Address of the Jenkins Agent. This IP Address must be in the CIDR range of `jenkins_agent_gce_subnetwork_cidr_range` and be reachable through the VPN that exists between on-prem (Jenkins Master) and GCP (CICD Project, where the Jenkins Agent is located). | `string` | n/a | yes |
| jenkins\_agent\_gce\_ssh\_pub\_key | SSH public key needed by the Jenkins Agent GCE Instance. The Jenkins Master holds the SSH private key. The correct format is `'ssh-rsa [KEY_VALUE] [USERNAME]'` | `string` | n/a | yes |
| jenkins\_agent\_gce\_ssh\_user | Jenkins Agent GCE Instance SSH username. | `string` | `"jenkins"` | no |
| jenkins\_agent\_gce\_subnetwork\_cidr\_range | The subnetwork to which the Jenkins Agent will be connected to (in CIDR range 0.0.0.0/0) | `string` | n/a | yes |
| jenkins\_agent\_sa\_email | Email for Jenkins Agent service account. | `string` | `"jenkins-agent-gce"` | no |
| jenkins\_master\_subnetwork\_cidr\_range | A list of CIDR IP ranges of the Jenkins Master in the form ['0.0.0.0/0']. Usually only one IP in the form '0.0.0.0/32'. Needed to create a FW rule that allows communication with the Jenkins Agent GCE Instance. | `list(string)` | n/a | yes |
| nat\_bgp\_asn | BGP ASN for NAT cloud route. This is needed to allow the Jenkins Agent to download packages and updates from the internet without having an external IP address. | `number` | n/a | yes |
| on\_prem\_vpn\_public\_ip\_address | The public IP Address of the Jenkins Master. | `string` | n/a | yes |
| on\_prem\_vpn\_public\_ip\_address2 | The secondpublic IP Address of the Jenkins Master. | `string` | n/a | yes |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| project\_labels | Labels to apply to the project. | `map(string)` | `{}` | no |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |
| router\_asn | BGP ASN for cloud routes. | `number` | `"64515"` | no |
| sa\_enable\_impersonation | Allow org\_admins group to impersonate service account & enable APIs required. | `bool` | `false` | no |
| service\_account\_prefix | Name prefix to use for service accounts. | `string` | `"sa"` | no |
| storage\_bucket\_labels | Labels to apply to the storage bucket. | `map(string)` | `{}` | no |
| storage\_bucket\_prefix | Name prefix to use for storage buckets. | `string` | `"bkt"` | no |
| terraform\_sa\_name | Fully-qualified name of the terraform service account. It must be supplied by the seed project | `string` | n/a | yes |
| terraform\_service\_account | Email for terraform service account. It must be supplied by the seed project | `string` | n/a | yes |
| terraform\_state\_bucket | Default state bucket, used in Cloud Build substitutions. It must be supplied by the seed project | `string` | n/a | yes |
| terraform\_version | Default terraform version. | `string` | `"0.13.7"` | no |
| terraform\_version\_sha256sum | sha256sum for default terraform version. | `string` | `"4a52886e019b4fdad2439da5ff43388bbcc6cce9784fde32c53dcd0e28ca9957"` | no |
| tunnel0\_bgp\_peer\_address | BGP peer address for tunnel 0 | `string` | n/a | yes |
| tunnel0\_bgp\_session\_range | BGP session range for tunnel 0 | `string` | n/a | yes |
| tunnel1\_bgp\_peer\_address | BGP peer address for tunnel 1 | `string` | n/a | yes |
| tunnel1\_bgp\_session\_range | BGP session range for tunnel 1 | `string` | n/a | yes |
| vpn\_shared\_secret | The shared secret used in the VPN | `string` | n/a | yes |

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
- [Terraform](https://www.terraform.io/downloads.html) = 0.13.7
    - The scripts in this codebase use Terraform v0.13.7. You should use the same version in the manual steps to avoid [Terraform State Snapshot Lock](https://github.com/hashicorp/terraform/issues/23290) errors caused by differences in terraform versions.

### Infrastructure

 - **Jenkins Master:** You need a Jenkins Master, since this module does not include an option to create one. To deploy a Jenkins Master, you should follow one of the available user guides about [Jenkins in GCP](https://cloud.google.com/jenkins). If you don't have a Jenkins implementation and don't want one, then we recommend you to [use the Cloud Build module](../../README.md) instead.

 - **VPN Connectivity with on-prem:** Once you run this module, a Jenkins Agent is created in the CICD project in GCP. Please add VPN connectivity manually by following our user guide about [how to deploy a VPN tunnel in GCP](https://cloud.google.com/network-connectivity/docs/vpn/how-to). This VPN is necessary to allow communication between the Jenkins Master (on prem or in a cloud environment) with the Jenkins Agent in the CICD project.

 - **Binaries and packages for the Jenkins Agent:** The Jenkins Agent is a new GCE instance created by this module. After creation, the startup script needs to fetch several binaries for later use, during pipelines execution. These binaries include `java`, `terraform`, `terraform-validator` and any other binary you use in your own scripts. You have several options to make these binaries and libraries available to the Jenkins Agent:
    - allow the Jenkins Agent Internet access (ideally through Cloud NAT, implemented by default).
    - allow the Jenkins Agent access to local package repositories on your premises, ideally through the VPN connection.
    - preparing a golden image for the Jenkins Agent (and assign the image to the `jenkins_agent_gce_instance.boot_disk.initialize_params.image` terraform variable). You can create the golden images with tools like Packer. Although, you might still need network access to download dependencies while running a pipeline.

### Permissions

An account that has the following [permissions](https://github.com/terraform-google-modules/terraform-google-bootstrap#permissions):

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
Error: Error setting billing account "aaaaaa-bbbbbb-cccccc" for project "projects/prj-jenkins-dc3a": googleapi: Error 400: Precondition check failed., failedPrecondition
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

## Contributing

Refer to the [contribution guidelines](../../../CONTRIBUTING.md) for
information on contributing to this module.
