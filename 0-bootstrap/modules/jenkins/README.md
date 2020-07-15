## Overview

The objective of this module is to deploy a Google Cloud Platform project `prj-cicd` to host a Jenkins Agent that can be used to deploy your infrastructure changes. This module is a replica of the [cloudbuild module](https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/cloudbuild), but re-purposed to use jenkins instead of Cloud Build. This module creates:
- The `prj-cicd` project to hold the Jenkins Agent
- GCE Instance for the Jenkins Agent, assigning SSH public keys in the metadata to allow connectivity from the Jenkins Master.
- FW rules to allow communication over port 22
  - TODO: use a fixed IP or no public IP at all
-  Custom Service account to run the Jenkins Agent's GCE Instance

Please note this module does not include an option to create a Jenkins Master. To deploy a Jenkins Master, you should follow one of the available user guides in https://cloud.google.com/jenkins.

If you don't have a Jenkins implementation and don't want one, then we recommend you to use the Cloud Build module instead of this Jenkins module.

## Usage

1. While developing only - Run `$ gcloud auth application-default login` before running `$ terraform plan` to avoid the errors below:
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

Run `$ gcloud auth application-default login` before running `$ terraform plan` to avoid the error below:
```
Error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
   on <empty> line 0:
  (source code not available)
```

Run `$ gcloud auth application-default login` before running `$ terraform plan` to avoid the error below:
```
Error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
   on <empty> line 0:
  (source code not available)
```

## Features

1. Creates a new GCP project using `project_prefix`
1. Enables APIs in the project using `activate_apis`
1. Creates a GCE Instance to run the Jenkins Agent with SSH access using the supplied public key
1. Creates a Service Account (`jenkins_agent_sa_email`) to run the Jenkins Agent GCE instance
1. Creates a GCS bucket for Jenkins Artifacts using `project_prefix`
1. Allows `jenkins_agent_sa_email` service account permissions to impersonate terraform service account (which exists in the `seed` project) using `sa_enable_impersonation` and supplied value for `terraform_sa_name`
1. TODO:
    1.  Add Cloud NAT for the Agent to reach internet and download updates and necessary binaries (not needed if user has a golden image with all necessary packages)

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
| jenkins\_agent\_gce\_ssh\_pub\_key | SSH public key needed by the Jenkins Agent GCE Instance. The Jenkins Master holds the SSH private key. The correct format is `'ssh-rsa [KEY_VALUE] [USERNAME]'` | string | `""` | no |
| jenkins\_agent\_gce\_ssh\_user | Jenkins Agent GCE Instance SSH username. | string | `"jenkins"` | no |
| jenkins\_agent\_gce\_subnetwork\_cidr\_range | The subnetwork to which the Jenkins Agent will be connected to (in CIDR range 0.0.0.0/0) | string | n/a | yes |
| jenkins\_agent\_sa\_email | Email for Jenkins Agent service account. | string | `"jenkins-agent-gce"` | no |
| jenkins\_master\_ip\_addresses | A list of IP Addresses and masks of the Jenkins Master in the form ['0.0.0.0/0']. Needed to create a FW rule that allows communication with the Jenkins Agent GCE Instance. | list(string) | n/a | yes |
| nat\_bgp\_asn | BGP ASN for NAT cloud route. This is needed to allow the Jenkins Agent to download packages and updates from the internet without having an external IP address. | number | n/a | yes |
| org\_id | GCP Organization ID | string | n/a | yes |
| project\_labels | Labels to apply to the project. | map(string) | `<map>` | no |
| project\_prefix | Name prefix to use for projects created. | string | `"prj"` | no |
| sa\_enable\_impersonation | Allow org_admins group to impersonate service account & enable APIs required. | bool | `"false"` | no |
| service\_account\_prefix | Name prefix to use for service accounts. | string | `"sa"` | no |
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

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

-   [gcloud sdk](https://cloud.google.com/sdk/install) >= 206.0.0
-   [Terraform](https://www.terraform.io/downloads.html) >= 0.12.6
-   [terraform-provider-google] plugin 2.1.x
-   [terraform-provider-google-beta] plugin 2.1.x

### Infrastructure

 - **Jenkins Master:** You need a Jenkins Master. Please note this module does not include an option to create a Jenkins Master. To deploy a Jenkins Master, you should follow one of the available user guides about [Jenkins in GCP](https://cloud.google.com/jenkins). If you don't have a Jenkins implementation and don't want one, then we recommend you to use the Cloud Build module instead of this Jenkins module.

 - **VPN Connectivity with on-prem:** Once you run this module and your Jenkins Agent is created in the CICD project in GCP, please add VPN connectivity manually by following our user guide about [how to deploy a VPN tunnel in GCP](https://cloud.google.com/network-connectivity/docs/vpn/how-to). This VPN configuration is necessary to allow communication between the Jenkins Master (on prem or in a cloud environment) with the Jenkins Agent in the CICD project. The reason why you add this connection manually is because you need to keep the VPN secret away from any configuration file, such as the Terraform state.

 - **Binaries and packages:** The Jenkins Agent needs to fetch several binaries needed to execute pipelines. These include `java`, `terraform`, `terraform-validator` and the terraform modules used by the scripts provided here and the terraform modules you use in your own scripts. You have several options to have these binaries and libraries available:
    - having Internet access (ideally through Cloud NAT).
    - having a local repository on your premises that the Agent can reach out to.
    - preparing a golden image for `jenkins_agent_gce_instance.boot_disk.initialize_params.image` (although, you might still need network access to download dependencies while running a pipeline).

### Permissions

- `roles/billing.user` on supplied billing account
- `roles/resourcemanager.organizationAdmin` on GCP Organization
- `roles/resourcemanager.projectCreator` on GCP Organization or folder

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
