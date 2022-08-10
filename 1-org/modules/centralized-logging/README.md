# Centralized Logging Module

This module handles logging configuration enabling destination to: buckets, Big Query or Pub/Sub.

## Usage

Before using this module, one should get familiar with the `google_dataflow_flex_template_job`’s [Note on "destroy"/"apply"](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataflow_flex_template_job#note-on-destroy--apply) as the behavior is atypical when compared to other resources.

## Requirements

These sections describe requirements for running this module.

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 357.0.0 or later.
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 or later.

### Deployer entity

To provision the resources of this module, create a service account
with the following IAM roles:

- Dataflow Developer:`roles/dataflow.developer`.

### APIs

The following APIs must be enabled in the project where the service account was created:

- BigQuery API: `bigquery.googleapis.com`.
- Cloud Key Management Service (KMS) API: `cloudkms.googleapis.com`.
- Google Cloud Storage JSON API:`storage-api.googleapis.com`.
- Compute Engine API: `compute.googleapis.com`.
- Dataflow API: `dataflow.googleapis.com`.

Any others APIs you pipeline may need.

### Assumption

One assumption is that, before using this module, you already have a working Dataflow flex job template(s) in a GCS location.
If you are not using public IPs, you need to [Configure Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access)
on the VPC used by Dataflow.

This is a simple usage:

```hcl
module "dataflow-flex-job" {
  source  = "terraform-google-modules/secured-data-warehouse/google//modules/dataflow-flex-job"
  version = "~> 0.1"

  project_id              = "<project_id>"
  region                  = "us-east4"
  name                    = "dataflow-flex-job-00001"
  container_spec_gcs_path = "gs://<path-to-template>"
  staging_location        = "gs://<gcs_path_staging_data_bucket>"
  temp_location           = "gs://<gcs_path_temp_data_bucket>"
  subnetwork_self_link    = "<subnetwork-self-link>"
  kms_key_name            = "<fully-qualified-kms-key-id>"
  service_account_email   = "<dataflow-controller-service-account-email>"

  parameters = {
    firstParameter  = "ONE",
    secondParameter = "TWO
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bigquery\_options | (Optional) Options that affect sinks exporting data to BigQuery. use\_partitioned\_tables - (Required) Whether to use BigQuery's partition tables. | <pre>object({<br>    use_partitioned_tables = bool<br>  })</pre> | `null` | no |
| create\_push\_subscriber | (Optional) Whether to add a push configuration to the subcription. If 'true', a push subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic. Applies to destination: pubsub. | `bool` | `false` | no |
| create\_subscriber | (Optional) Whether to create a subscription to the topic that was created and used for log entries matching the filter. If 'true', a pull subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic. Applies to destination: pubsub. | `bool` | `false` | no |
| dataset\_description | (Optional) A user-friendly description of the dataset. Applies to destination: bigquery. | `string` | `""` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all contained objects in the logging destination. Applies to destination: bigquery and storage. | `bool` | `false` | no |
| exclusions | (Optional) A list of sink exclusion filters. | <pre>list(object({<br>    name        = string,<br>    description = string,<br>    filter      = string,<br>    disabled    = bool<br>  }))</pre> | `[]` | no |
| expiration\_days | (Optional) Table expiration time. If null logs will never be deleted. Applies to destination: bigquery. | `number` | `null` | no |
| include\_children | Only valid if 'organization' or 'folder' is chosen as var.resource\_type. Determines whether or not to include children organizations/folders in the sink export. If true, logs associated with child projects are also exported; otherwise only logs relating to the provided organization/folder are included. | `bool` | `false` | no |
| kms\_key\_name | (Optional) ID of a Cloud KMS CryptoKey that will be used to encrypt the logging destination. | `string` | `null` | no |
| labels | (Optional) Labels attached to logging resources. | `map(string)` | `{}` | no |
| lifecycle\_rules | (Optional) List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. Applies to destination: storage. | <pre>set(object({<br>    # Object with keys:<br>    # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.<br>    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.<br>    action = map(string)<br><br>    # Object with keys:<br>    # - age - (Optional) Minimum age of an object in days to satisfy this condition.<br>    # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.<br>    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".<br>    # - matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.<br>    # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.<br>    # - days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.<br>    condition = map(string)<br>  }))</pre> | `[]` | no |
| logging\_destination\_project\_id | The ID of the project that will have the resources where the logs will be created. | `string` | n/a | yes |
| logging\_destination\_uri | The self\_link URI of the destination resource. If provided all needed permitions will be assinged and this resource will be used as log destination for all resources. | `string` | `""` | no |
| logging\_location | (Optional) The location of the logging destination. Applies to destination: bigquery and storage. | `string` | `"US"` | no |
| logging\_project\_key | (Optional) The key of logging destination project if it is inside resources map. It is mandatory when resource\_type = project and logging\_target\_type = logbucket. | `string` | `""` | no |
| logging\_sink\_filter | The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs. | `string` | `""` | no |
| logging\_sink\_name | The name of the log sink to be created. | `string` | `""` | no |
| logging\_target\_name | The name of the logging container (logbucket, bigquery-dataset, storage, or pubsub-topic) that will store the logs. | `string` | `""` | no |
| logging\_target\_type | Resource type of the resource that will store the logs. Must be: logbucket, bigquery, storage, or pubsub | `string` | n/a | yes |
| push\_endpoint | (Optional) The URL locating the endpoint to which messages should be pushed. Applies to destination: pubsub. | `string` | `""` | no |
| resource\_type | Resource type of the resource that will export logs to destination. Must be: project, organization, or folder | `string` | n/a | yes |
| resources | Export logs from the specified resources. | `map(string)` | n/a | yes |
| retention\_days | (Optional) The number of days data should be retained for the log bucket. Applies to destination: logbucket. | `number` | `30` | no |
| retention\_policy | (Optional) Configuration of the bucket's data retention policy for how long objects in the bucket should be retained. Applies to destination: storage. | <pre>object({<br>    is_locked             = bool<br>    retention_period_days = number<br>  })</pre> | `null` | no |
| storage\_class | (Optional) The storage class of the storage bucket. Applies to destination: storage. | `string` | `"STANDARD"` | no |
| subscriber\_id | (Optional) The ID to give the pubsub pull subscriber service account. Applies to destination: pubsub. | `string` | `""` | no |
| subscription\_labels | (Optional) A set of key/value label pairs to assign to the pubsub subscription. Applies to destination: pubsub. | `map(string)` | `{}` | no |
| uniform\_bucket\_level\_access | (Optional) Enables Uniform bucket-level access to a bucket. Applies to destination: storage. | `bool` | `true` | no |
| versioning | (Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted. Applies to destination: storage. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| destination\_uri | n/a |
| filter | The filter to be applied when exporting logs. |
| log\_sinks\_id | The resource ID of the log sink that was created. |
| log\_sinks\_name | The resource name of the log sink that was created. |
| parent\_resource\_ids | The ID of the GCP resource in which you create the log sink. |
| resource\_name | The resource name for the destination |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
