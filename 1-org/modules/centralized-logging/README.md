# Centralized Logging Module

This module handles logging configuration enabling destination to: GCS bucket, Big Query, Pub/Sub, or Log Bucket.

## Usage

The following example exports just audit logs from two folders to the same storage destination:

```hcl
module "logging_storage" {
  source = "terraform-google-modules/terraform-example-foundation/google//1-org/modules/centralized-logging"

  resources = {
    fldr1 = "<folder1_id>"
    fldr2 = "<folder2_id>"
  }
  resource_type                  = "folder"
  logging_sink_filter            = local.all_logs_filter
  logging_sink_name              = "sk-c-logging-bkt"
  include_children               = true
  logging_target_type            = "storage"
  logging_destination_project_id = "<log_destination_project_id>"
  logging_target_name            = "bkt-audit-logs"
  uniform_bucket_level_access    = true
  logging_location               = "US"
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
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all contained objects in the logging destination. Applies to destinations: bigquery and storage. | `bool` | `false` | no |
| exclusions | (Optional) A list of sink exclusion filters. | <pre>list(object({<br>    name        = string,<br>    description = string,<br>    filter      = string,<br>    disabled    = bool<br>  }))</pre> | `[]` | no |
| expiration\_days | (Optional) Table expiration time. If null logs will never be deleted. Applies to destination: bigquery. | `number` | `null` | no |
| include\_children | Only valid if 'organization' or 'folder' is chosen as var.resource\_type. Determines whether or not to include children organizations/folders in the sink export. If true, logs associated with child projects are also exported; otherwise only logs relating to the provided organization/folder are included. | `bool` | `false` | no |
| kms\_key\_name | (Optional) ID of a Cloud KMS CryptoKey that will be used to encrypt the logging destination. Applies to destinations: bigquery, storage, and pubsub. | `string` | `null` | no |
| labels | (Optional) Labels attached to logging resources. | `map(string)` | `{}` | no |
| lifecycle\_rules | (Optional) List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. Applies to destination: storage. | <pre>set(object({<br>    # Object with keys:<br>    # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.<br>    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.<br>    action = map(string)<br><br>    # Object with keys:<br>    # - age - (Optional) Minimum age of an object in days to satisfy this condition.<br>    # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.<br>    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".<br>    # - matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.<br>    # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.<br>    # - days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.<br>    condition = map(string)<br>  }))</pre> | `[]` | no |
| logging\_destination\_project\_id | The ID of the project that will have the resources where the logs will be created. | `string` | n/a | yes |
| logging\_destination\_uri | The self\_link URI of the destination resource. If provided all needed permitions will be assinged and this resource will be used as log destination for all resources. | `string` | `""` | no |
| logging\_location | (Optional) The location of the logging destination. Applies to destinations: bigquery and storage. | `string` | `"US"` | no |
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
