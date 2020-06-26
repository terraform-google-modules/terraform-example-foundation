## Overview

The objective of this module is to deploy a Google Cloud Platform project `prj-cicd` to host a Jenkins Agent that can be used to deploy your infrastructure changes. This module is a replica of the [cloudbuild module](https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/cloudbuild), but re-purposed to use jenkins instead of Cloud Build. This module creates:
- The `prj-cicd` project to hold the Jenkins Agent
- GCE Instance for the Jenkins Agent, assigning SSH public keys in the metadata to allow connectivity from the Jenkins Master.
- FW rules to allow communication over port 22
  - TODO: use a fixed IP or no public IP at all
-  Custom Service account to run the Jenkins Agent's GCE Instance

## Usage

1. Add the SSH public keys of your Jenkins Agent in the file `./jenkins-agent-ssh-pub-keys/metadata-ssh-pub-keys`

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

## Features

1. Create a new GCP project using `project_prefix`
1. Enable APIs in the project using `activate_apis`
1. Create a GCE Instance to run the Jenkins Agent with SSH access using the supplied public key
1. TODO:
    1. Create a GCS bucket for Jenkins Artifacts using `project_prefix`
    1. Create KMS Keyring and key for encryption
        1. Grant access to decrypt to `terraform_sa_email` and to `jenkins_sa_email` (Jenkins GCE Instance custom service account)
        1. Grant access to encrypt to `group_org_admins`
    1. Optionally give `jenkins_sa_email` service account permissions to impersonate terraform service account using `sa_enable_impersonation` and supplied value for `terraform_sa_name`



## Resources created

- TODO
    - KMS Keyring and key for secrets, including IAM for Cloudbuild, Org Admins and Terraform service acocunt
    - (optional) Cloudbuild impersonation permissions for a service account
    - (optional) Cloud Source Repos, with triggers for terraform plan (all other branches) & terraform apply (master)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | List of APIs to enable in the Cloudbuild project. | list(string) | `<list>` | no |
| billing\_account | The ID of the billing account to associate projects with. | string | n/a | yes |
| default\_region | Default region to create resources where applicable. | string | `"europe-west2"` | no |
| folder\_id | The ID of a folder to host this project | string | `""` | no |
| jenkins\_agent\_gce\_machine\_type | Jenkins Agent GCE Instance type. | string | `"n1-standard-1"` | no |
| jenkins\_agent\_gce\_name | Jenkins Agent GCE Instance name. | string | `"jenkins-agent-01"` | no |
| jenkins\_agent\_gce\_ssh\_pub\_key\_file | File with the SSH public key needed by the Jenkins Agent GCE Instance. The Jenkins Master holds the SSH private key. | string | `"./jenkins-agent-ssh-pub-keys/metadata-ssh-pub-keys"` | no |
| jenkins\_agent\_gce\_ssh\_user | Jenkins Agent GCE Instance SSH username. | string | `"jenkins"` | no |
| jenkins\_master\_ip\_addresses | A list of IP Addresses and masks of the Jenkins Master in the form ['0.0.0.0/0']. Needed to create a FW rule that allows communication with the Jenkins Agent GCE Instance. | list(string) | n/a | yes |
| jenkins\_sa\_email | Email for Jenkins Agent service account. | string | `"jenkins-agent-gce-sa"` | no |
| org\_id | GCP Organization ID | string | n/a | yes |
| project\_labels | Labels to apply to the project. | map(string) | `<map>` | no |
| project\_prefix | Name prefix to use for projects created. | string | `"prj"` | no |
| sa\_enable\_impersonation | Allow org_admins group to impersonate service account & enable APIs required. | bool | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cicd\_project\_id | Project where the cicd pipeline (Jenkins Agents and terraform builder container image) reside. |
| jenkins\_agent\_gce\_instance\_id | Jenkins Agent GCE Instance id. |
| jenkins\_sa\_email | Email for privileged custom service account for Jenkins Agent GCE instance. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

-   [gcloud sdk](https://cloud.google.com/sdk/install) >= 206.0.0
-   [Terraform](https://www.terraform.io/downloads.html) >= 0.12.6
-   [terraform-provider-google] plugin 2.1.x
-   [terraform-provider-google-beta] plugin 2.1.x

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
