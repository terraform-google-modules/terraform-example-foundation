# Centralized Logging Module

This module handles logging configuration enabling one or more resources such as organization, folders, or projects to send logs to multiple destinations: [GCS bucket](https://cloud.google.com/logging/docs/export/using_exported_logs#gcs-overview), [Pub/Sub](https://cloud.google.com/logging/docs/export/using_exported_logs#pubsub-overview), and [Log Buckets](https://cloud.google.com/logging/docs/routing/overview#buckets) with [Log Analytics](https://cloud.google.com/logging/docs/log-analytics#analytics).

## Usage

Before using this module, get familiar with the [log-export](https://registry.terraform.io/modules/terraform-google-modules/log-export/google/latest) module that is the base for it.

The following example exports audit logs from two folders to the same storage destination:

```hcl
module "logs_export" {
  source = "terraform-google-modules/terraform-example-foundation/google//1-org/modules/centralized-logging"

  resources = {
    fldr1 = "<folder1_id>"
    fldr2 = "<folder2_id>"
  }
  resource_type                  = "folder"
  logging_destination_project_id = "<log_destination_project_id>"

  storage_options = {
    logging_sink_filter = ""
    logging_sink_name   = "sk-c-logging-bkt"
    storage_bucket_name = "bkt-logs"
    location            = "us-central1"
  }
}
```

**Note:** When the destination is a Log Bucket and a sink is been created in the same project, set variable `logging_project_key` with the **key** used to map the Log Bucket project in the `resources` map.
Get more details at [Configure and manage sinks](https://cloud.google.com/logging/docs/export/configure_export_v2#dest-auth:~:text=If%20you%27re%20using%20a%20sink%20to%20route%20logs%20between%20Logging%20buckets%20in%20the%20same%20Cloud%20project%2C%20no%20new%20service%20account%20is%20created%3B%20the%20sink%20works%20without%20the%20unique%20writer%20identity.).

The following example exports all logs from three projects - including the logging destination project - to a Log Bucket destination. As it exports all logs be aware of additional charges for this amount of logs:

```hcl
module "logging_logbucket" {
  source = "terraform-google-modules/terraform-example-foundation/google//1-org/modules/centralized-logging"

  resources = {
    prj1 = "<log_destination_project_id>"
    prj2 = "<prj2_id>"
    prjx = "<prjx_id>"
  }
  resource_type                  = "project"
  logging_destination_project_id = "<log_destination_project_id>"
  logging_project_key            = "prj1"

  logbucket_options = {
    logging_sink_name   = "sk-c-logging-logbkt"
    logging_sink_filter = ""
    name                = "logbkt-logs"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | Billing Account ID used in case sinks are under billing account level. Format 000000-000000-000000. | `string` | `null` | no |
| enable\_billing\_account\_sink | If true, a log router sink will be created for the billing account. The billing\_account variable cannot be null. | `bool` | `false` | no |
| logging\_destination\_project\_id | The ID of the project that will have the resources where the logs will be created. | `string` | n/a | yes |
| logging\_project\_key | (Optional) The key of logging destination project if it is inside resources map. It is mandatory when resource\_type = project and logging\_target\_type = logbucket. | `string` | `""` | no |
| project\_options | Destination Project options:<br>- logging\_sink\_name: The name of the log sink to be created.<br>- logging\_sink\_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.<br>- log\_bucket\_id: Id of the log bucket create to store the logs exported to the project.<br>- log\_bucket\_description: Description of the log bucket create to store the logs exported to the project.<br>- location: The location of the log bucket. Default: global.<br>- enable\_analytics: Whether or not Log Analytics is enabled in the \_Default log bucket. A Log bucket with Log Analytics enabled can be queried in the Log Analytics page using SQL queries. Cannot be disabled once enabled.<br>- retention\_days: The number of days data should be retained for the \_Default log bucket. Default 30.<br>- linked\_dataset\_id: The ID of the linked BigQuery dataset for the \_Default log bucket. A valid link dataset ID must only have alphanumeric characters and underscores within it and have up to 100 characters.<br>- linked\_dataset\_description: A use-friendly description of the linked BigQuery dataset for the \_Default log bucket. The maximum length of the description is 8000 characters. | <pre>object({<br>    logging_sink_name          = optional(string, null)<br>    logging_sink_filter        = optional(string, "")<br>    log_bucket_id              = optional(string, null)<br>    log_bucket_description     = optional(string, null)<br>    location                   = optional(string, "global")<br>    enable_analytics           = optional(bool, true)<br>    retention_days             = optional(number, 30)<br>    linked_dataset_id          = optional(string, null)<br>    linked_dataset_description = optional(string, null)<br>  })</pre> | `null` | no |
| pubsub\_options | Destination Pubsub options:<br>- topic\_name: The name of the pubsub topic to be created and used for log entries matching the filter.<br>- logging\_sink\_name: The name of the log sink to be created.<br>- logging\_sink\_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.<br>- create\_subscriber: Whether to create a subscription to the topic that was created and used for log entries matching the filter. If 'true', a pull subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic. | <pre>object({<br>    topic_name          = optional(string, null)<br>    logging_sink_name   = optional(string, null)<br>    logging_sink_filter = optional(string, "")<br>    create_subscriber   = optional(bool, true)<br>  })</pre> | `null` | no |
| resource\_type | Resource type of the resource that will export logs to destination. Must be: project, organization, or folder. | `string` | n/a | yes |
| resources | Export logs from the specified resources. | `map(string)` | n/a | yes |
| storage\_options | Destination Storage options:<br>- storage\_bucket\_name: The name of the storage bucket to be created and used for log entries matching the filter.<br>- logging\_sink\_name: The name of the log sink to be created.<br>- logging\_sink\_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.<br>- location: The location of the logging destination. Default: US.<br>- Retention Policy variables: (Optional) Configuration of the bucket's data retention policy for how long objects in the bucket should be retained.<br>  - retention\_policy\_enabled: if a retention policy should be enabled in the bucket.<br>  - retention\_policy\_is\_locked: Set if policy is locked.<br>  - retention\_policy\_period\_days: Set the period of days for log retention. Default: 30.<br>- versioning: Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted.<br>- force\_destroy: When deleting a bucket, this boolean option will delete all contained objects. | <pre>object({<br>    storage_bucket_name          = optional(string, null)<br>    logging_sink_name            = optional(string, null)<br>    logging_sink_filter          = optional(string, "")<br>    location                     = optional(string, "US")<br>    retention_policy_enabled     = optional(bool, false)<br>    retention_policy_is_locked   = optional(bool, false)<br>    retention_policy_period_days = optional(number, 30)<br>    versioning                   = optional(bool, false)<br>    force_destroy                = optional(bool, false)<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| billing\_sink\_names | Map of log sink names with billing suffix |
| project\_linked\_dataset\_name | The resource name of the Log Bucket linked BigQuery dataset for the project destination. |
| project\_logbucket\_name | The resource name for the Log Bucket created for the project destination. |
| pubsub\_destination\_name | The resource name for the destination Pub/Sub. |
| storage\_destination\_name | The resource name for the destination Storage. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
