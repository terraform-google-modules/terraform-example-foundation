# Cloud Asset Inventory Notification
Uses Google Cloud Asset Inventory to create a feed of IAM Policy change events, then process them to detect when a roles (from a preset list) is given to a member (service account, user or group). Then generates a SCC Finding with the member, role, resource where it was granted and the time that was granted.

## Usage

```hcl
module "secure_cai_notification" {
  source = "terraform-google-modules/terraform-example-foundation/google//1-org/modules/cai-monitoring"

  org_id               = <ORG ID>
  billing_account      = <BILLING ACCOUNT ID>
  project_id           = <PROJECT ID>
  region               = <REGION>
  encryption_key       = <CMEK KEY>
  labels               = <LABELS>
  roles_to_monitor     = <ROLES TO MONITOR>
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| build\_service\_account | Cloud Function Build Service Account Id. This is The fully-qualified name of the service account to be used for building the container. | `string` | n/a | yes |
| enable\_cmek | The KMS Key to Encrypt Artifact Registry repository, Cloud Storage Bucket and Pub/Sub. | `bool` | `false` | no |
| encryption\_key | The KMS Key to Encrypt Artifact Registry repository, Cloud Storage Bucket and Pub/Sub. | `string` | `null` | no |
| labels | Labels to be assigned to resources. | `map(any)` | `{}` | no |
| location | Default location to create resources where applicable. | `string` | `"us-central1"` | no |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| project\_id | The Project ID where the resources will be created | `string` | n/a | yes |
| random\_suffix | Adds a suffix of 4 random characters to the created resources names. | `bool` | `true` | no |
| roles\_to\_monitor | List of roles that will save a SCC Finding if granted to any member (service account, user or group) on an update in the IAM Policy. | `list(string)` | <pre>[<br>  "roles/owner",<br>  "roles/editor",<br>  "roles/resourcemanager.organizationAdmin",<br>  "roles/compute.networkAdmin",<br>  "roles/compute.orgFirewallPolicyAdmin"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| artifact\_registry\_name | Artifact Registry Repo to store the Cloud Function image. |
| asset\_feed\_name | Organization Asset Feed. |
| bucket\_name | Storage bucket where the source code is. |
| function\_uri | URI of the Cloud Function. |
| scc\_source | SCC Findings Source. |
| topic\_name | Pub/Sub Topic for the Asset Feed. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html) >= 1.3
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) >= 3.77

### APIs

A project with the following APIs enabled must be used to host the resources of this module:

* Project
  * Google Cloud Key Management Service: `cloudkms.googleapis.com`
  * Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
  * Cloud Functions API: `cloudfunctions.googleapis.com`
  * Cloud Build API: `cloudbuild.googleapis.com`
  * Cloud Asset API`cloudasset.googleapis.com`
  * Clouod Pub/Sub API: `pubsub.googleapis.com`
  * Identity and Access Management (IAM) API: `iam.googleapis.com`
  * Cloud Billing API: `cloudbilling.googleapis.com`
