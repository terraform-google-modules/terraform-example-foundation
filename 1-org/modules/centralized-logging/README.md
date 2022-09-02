# Centralized Logging Module

This module handles logging configuration enabling one or more resources such as organization, folders, or projects to send logs to multiple destinations: [GCS bucket](https://cloud.google.com/logging/docs/export/using_exported_logs#gcs-overview), [Big Query](https://cloud.google.com/logging/docs/export/bigquery), [Pub/Sub](https://cloud.google.com/logging/docs/export/using_exported_logs#pubsub-overview), and [Log Buckets](https://cloud.google.com/logging/docs/routing/overview#buckets).

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

  bigquery_options = {
    dataset_name               = "ds_logs"
    logging_sink_name          = "sk-c-logging-bq"
    logging_sink_filter        = <<EOF
    logName: /logs/cloudaudit.googleapis.com%2Factivity OR
    logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR
    logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR
    logName: /logs/compute.googleapis.com%2Fvpc_flows OR
    logName: /logs/compute.googleapis.com%2Ffirewall OR
    logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency
EOF
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
| bigquery\_options | Destination BigQuery options:<br>- logging\_sink\_name: The name of the log sink to be created.<br>- logging\_sink\_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.<br>- dataset\_name: The name of the bigquery dataset to be created and used for log entries.<br>- expiration\_days: (Optional) Table expiration time. If null logs will never be deleted.<br>- partitioned\_tables: (Optional) Options that affect sinks exporting data to BigQuery. use\_partitioned\_tables - (Required) Whether to use BigQuery's partition tables.<br>- delete\_contents\_on\_destroy: (Optional) If set to true, delete all contained objects in the logging destination.<br><br>Destination BigQuery options example:<pre>bigquery_options = {<br>  logging_sink_name          = "sk-c-logging-bq"<br>  dataset_name               = "audit_logs"<br>  partitioned_tables         = "true"<br>  expiration_days            = 30<br>  delete_contents_on_destroy = false<br>  logging_sink_filter        = <<EOF<br>  logName: /logs/cloudaudit.googleapis.com%2Factivity OR<br>  logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR<br>  logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR<br>  logName: /logs/compute.googleapis.com%2Fvpc_flows OR<br>  logName: /logs/compute.googleapis.com%2Ffirewall OR<br>  logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency<br>EOF<br>}</pre> | `map(string)` | `null` | no |
| logbucket\_options | Destination LogBucket options:<br>- logging\_sink\_name: The name of the log sink to be created.<br>- logging\_sink\_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.<br>- name: The name of the log bucket to be created and used for log entries matching the filter.<br>- location: The location of the log bucket. Default: global.<br>- retention\_days: (Optional) The number of days data should be retained for the log bucket. Default 30.<br><br>Destination LogBucket options example:<pre>logbucket_options = {<br>  logging_sink_name   = "sk-c-logging-logbkt"<br>  logging_sink_filter = ""<br>  name                = "logbkt-org-logs"<br>  retention_days      = "30"<br>  location            = "global"<br>}</pre> | `map(any)` | `null` | no |
| logging\_destination\_project\_id | The ID of the project that will have the resources where the logs will be created. | `string` | n/a | yes |
| logging\_project\_key | (Optional) The key of logging destination project if it is inside resources map. It is mandatory when resource\_type = project and logging\_target\_type = logbucket. | `string` | `""` | no |
| pubsub\_options | Destination Pubsub options:<br>- logging\_sink\_name: The name of the log sink to be created.<br>- logging\_sink\_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.<br>- topic\_name: The name of the pubsub topic to be created and used for log entries matching the filter.<br>- create\_subscriber: (Optional) Whether to create a subscription to the topic that was created and used for log entries matching the filter. If 'true', a pull subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic.<br><br>Destination Storage options example:<pre>pubsub_options = {<br>  logging_sink_name   = "sk-c-logging-pub"<br>  topic_name          = "tp-org-logs"<br>  create_subscriber   = true<br>  logging_sink_filter = <<EOF<br>  logName: /logs/cloudaudit.googleapis.com%2Factivity OR<br>  logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR<br>  logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR<br>  logName: /logs/compute.googleapis.com%2Fvpc_flows OR<br>  logName: /logs/compute.googleapis.com%2Ffirewall OR<br>  logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency<br>EOF<br>}</pre> | `map(any)` | `null` | no |
| resource\_type | Resource type of the resource that will export logs to destination. Must be: project, organization, or folder. | `string` | n/a | yes |
| resources | Export logs from the specified resources. | `map(string)` | n/a | yes |
| storage\_options | Destination Storage options:<br>- logging\_sink\_name: The name of the log sink to be created.<br>- logging\_sink\_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.<br>- storage\_bucket\_name: The name of the storage bucket to be created and used for log entries matching the filter.<br>- location: (Optional) The location of the logging destination. Default: US.<br>- Retention Policy variables: (Optional) Configuration of the bucket's data retention policy for how long objects in the bucket should be retained.<br>  - retention\_policy\_is\_locked: Set if policy is locked.<br>  - retention\_policy\_period\_days: Set the period of days for log retention. Default: 30.<br>- versioning: (Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted.<br>- force\_destroy: When deleting a bucket, this boolean option will delete all contained objects.<br><br>Destination Storage options example:<pre>storage_options = {<br>  logging_sink_name   = "sk-c-logging-bkt"<br>  logging_sink_filter = ""<br>  storage_bucket_name = "bkt-org-logs"<br>  location            = "US"<br>  force_destroy       = false<br>  versioning          = false<br>}</pre> | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bigquery\_destination\_name | The resource name for the destination BigQuery. |
| logbucket\_destination\_name | The resource name for the destination Log Bucket. |
| pubsub\_destination\_name | The resource name for the destination Pub/Sub. |
| storage\_destination\_name | The resource name for the destination Storage. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
