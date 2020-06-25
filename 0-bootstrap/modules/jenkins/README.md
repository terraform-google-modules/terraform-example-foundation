## Overview

The objective of this module is to deploy a Google Cloud Platform project `prj-cicd` to host a Jenkins Agent that can be used to deploy your infrastructure changes. This module is a replica of the [cloudbuild module](https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/cloudbuild), but re-purposed to use jenkins instead of Cloud Build. This module creates:
- The `prj-cicd` project to hold the Jenkins Agent
- GCE Instance for the Jenkins Agent, assigning SSH public keys in the metadata to allow connectivity from the Jenkins Master.
- FW rules to allow communication over port 22
  - TODO: use a fixed IP or no public IP at all
-  Custom Service account to run the Jenkins Agent's GCE Instance

## Usage

1. Add the SSH public keys of your Jenkins Agent in the file `./jenkins-agent-ssh-pub-keys/metadata-ssh-pub-keys`

1. Run `$ gcloud auth application-default login` before running `$ terraform plan` to avoid the errors below:
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
| cloud\_source\_repos | List of Cloud Source Repo's to create with CloudBuild triggers. | list(string) | `<list>` | no |
| default\_region | Default region to create resources where applicable. | string | `"us-central1"` | no |
| jenkins\_agent\_gce\_name | Jenkins Agent GCE Instance name | string | jenkins-agent-01 | yes |
| jenkins\_agent\_gce\_ssh\_user | Jenkins Agent GCE Instance SSH username | string | jenkins | yes | 
| jenkins\_agent\_gce\_ssh\_pub\_key\_file | Jenkins Agent GCE Instance SSH Public Key | string | `./jenkins-agent-ssh-pub-keys/metadata-ssh-pub-keys` | yes |
| folder\_id | The ID of a folder to host this project | string | `""` | no |
| group\_org\_admins | Google Group for GCP Organization Administrators | string | n/a | yes |
| org\_id | GCP Organization ID | string | n/a | yes |
| project\_labels | Labels to apply to the project. | map(string) | `<map>` | no |
| project\_prefix | Name prefix to use for projects created. | string | `"cft"` | no |
| sa\_enable\_impersonation | Allow org_admins group to impersonate service account & enable APIs required. | bool | `"false"` | no |
| storage\_bucket\_labels | Labels to apply to the storage bucket. | map(string) | `<map>` | no |
| terraform\_sa\_email | Email for terraform service account. | string | n/a | yes |
| terraform\_sa\_name | Fully-qualified name of the terraform service account. | string | n/a | yes |
| terraform\_state\_bucket | Default state bucket, used in Cloud Build substitutions. | string | n/a | yes |
| terraform\_version | Default terraform version. | string | `"0.12.24"` | no |
| terraform\_version\_sha256sum | sha256sum for default terraform version. | string | `"602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11"` | no |

## Outputs

| Name | Description |
|------|-------------|
| jenkins\_project\_id | Project where Jenkins Agent and terraform container image will reside. |
| TODO csr\_repos | List of Cloud Source Repos created by the module, linked to Cloud Build triggers. |
| TODO gcs\_bucket\_jenkins\_artifacts | Bucket used to store Jenkins artifacts in CICD project. |
| TODO kms\_crypto\_key | KMS key created by the module. |
| TODO kms\_keyring | KMS Keyring created by the module. |

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

### Troubleshooting

When running `terraform apply` for the first time, you might see an message like this in the logs:
```
module.cicd_project.module.project-factory.null_resource.preconditions (local-exec): googleapiclient.errors.HttpError: <HttpError 403 when requesting https://cloudbilling.googleapis.com/v1/billingAccounts/000000-000000-000000:testIamPermissions?alt=json returned "Cloud Billing API has not been used in project 0123456789 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/cloudbilling.googleapis.com/overview?project=0123456789 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.". 
```

Just go to the link above and click "Enable" to activate billing in the project. Terraform will wait a few seconds for you to go to that link. However, it could happen that the terraform script times out and fail. If it fails, just enable the billing before running the terraform script again.

## Contributing

Refer to the [contribution guidelines](../../CONTRIBUTING.md) for
information on contributing to this module.
