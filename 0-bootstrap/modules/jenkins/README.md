# Copying the code from terraform-google-bootstrap/modules/cloudbuild/

This initial commit contains a copy of the code in [terraform-google-bootstrap/modules/cloudbuild](https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/cloudbuild) as well as additional directories `jenkins-agent-ssh` and `jenkins-master`
--------------------------------------------------------------------------------
## Overview


## Usage

Basic usage of this module is as follows:

```hcl
module "bootstrap" {
  source  = "terraform-google-modules/bootstrap/google//modules/cloudbuild"
  version = "~> 0.1"

  org_id         = "<ORGANIZATION_ID>"
  billing_account         = "<BILLING_ACCOUNT_ID>"
  group_org_admins        = "gcp-organization-admins@example.com"
  default_region          = "australia-southeast1"
  sa_enable_impersonation = true
  terraform_sa_email      = "<SERVICE_ACCOUNT_EMAIL>"
  terraform_sa_name       = "<SERVICE_ACCOUNT_NAME>"
  terraform_state_bucket  = "<GCS_STATE_BUCKET_NAME>"
}
```

Functional examples and sample Cloud Build definitions are included in the [examples](../../examples/) directory.

Run `$ gcloud auth application-default login` before running `$ terraform plan` to avoid the error below:
```
Error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
   on <empty> line 0:
  (source code not available)
```

## Features

1. Create a new GCP cloud build project using `project_prefix`
1. Enable APIs in the cloud build project using `activate_apis`
1. Build a Terraform docker image for Cloud Build
1. Create a GCS bucket for Cloud Build Artifacts using `project_prefix`
1. Create Cloud Source Repos for pipelines using list of repos in `cloud_source_repos`
    1. Create Cloud Build trigger for terraform apply on master branch
    1. Create Cloud Build trigger for terrafor plan on all other branches
1. Create KMS Keyring and key for encryption
    1. Grant access to decrypt to Cloud Build service account and `terraform_sa_email`
    1. Grant access to encrypt to `group_org_admins`
1. Optionally give Cloud Build service account permissions to impersonate terraform service account using `sa_enable_impersonation` and supplied value for `terraform_sa_name`



## Resources created

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
| cloudbuild\_project\_id | Project where CloudBuild configuration and terraform container image will reside. |
| csr\_repos | List of Cloud Source Repos created by the module, linked to Cloud Build triggers. |
| gcs\_bucket\_cloudbuild\_artifacts | Bucket used to store Cloud/Build artefacts in CloudBuild project. |
| kms\_crypto\_key | KMS key created by the module. |
| kms\_keyring | KMS Keyring created by the module. |

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
- Google Cloud Build API: `cloudbuild.googleapis.com`
- Google Cloud Source Repo API: `sourcerepo.googleapis.com`
- Google Cloud KMS API: `cloudkms.googleapis.com`

This API can be enabled in the default project created during establishing an organization.

## Contributing

Refer to the [contribution guidelines](../../CONTRIBUTING.md) for
information on contributing to this module.