/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "resources" {
  description = "Export logs from the specified resources."
  type        = map(string)

  validation {
    condition     = length(var.resources) > 0
    error_message = "The resources map should have at least 1 item."
  }
}

variable "resource_type" {
  description = "Resource type of the resource that will export logs to destination. Must be: project, organization, or folder."
  type        = string

  validation {
    condition     = contains(["project", "folder", "organization"], var.resource_type)
    error_message = "The resource_type value must be: project, organization, or folder."
  }
}

variable "logging_project_key" {
  description = "(Optional) The key of logging destination project if it is inside resources map. It is mandatory when resource_type = project and logging_target_type = logbucket."
  type        = string
  default     = ""
}

variable "logging_destination_project_id" {
  description = "The ID of the project that will have the resources where the logs will be created."
  type        = string
}


#----------------------------- #
# Logbucket specific variables #
#----------------------------- #
variable "logbucket_options" {
  description = <<EOT
Destination LogBucket options:
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.
- include_children: Only valid if 'organization' or 'folder' is chosen as var.resource_type. Determines whether or not to include children organizations/folders in the sink export. If true, logs associated with child projects are also exported; otherwise only logs relating to the provided organization/folder are included.
- name: The name of the log bucket to be created and used for log entries matching the filter.
- location: The location of the log bucket. Default: global.
- retention_days: (Optional) The number of days data should be retained for the log bucket. Default 30.

Destination LogBucket options example:
```
logbucket_options = {
  logging_sink_name   = "sk-c-logging-logbkt"
  logging_sink_filter = ""
  name                = "logbkt-org-logs"
  retention_days      = "30"
  include_children    = "true"
  location            = "global"
}
```
EOT
  type        = map(any)
  default     = null

  validation {
    condition     = var.logbucket_options == null ? true : !contains(keys(var.logbucket_options), "retention_days") ? true : can(tonumber(var.logbucket_options["retention_days"]))
    error_message = "Retention days must be a number. Default 30 days."
  }

  validation {
    condition     = var.logbucket_options == null ? true : !contains(keys(var.logbucket_options), "include_children") ? true : can(tobool(var.logbucket_options["include_children"]))
    error_message = "Include_children option must be a bool (true or false). Default false."
  }
}


#----------------------------- #
# Big Query specific variables #
#----------------------------- #
variable "bigquery_options" {
  description = <<EOT
Destination BigQuery options:
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.
- include_children: Only valid if 'organization' or 'folder' is chosen as var.resource_type. Determines whether or not to include children organizations/folders in the sink export. If true, logs associated with child projects are also exported; otherwise only logs relating to the provided organization/folder are included.
- dataset_name: The name of the bigquery dataset to be created and used for log entries.
- expiration_days: (Optional) Table expiration time. If null logs will never be deleted.
- partitioned_tables: (Optional) Options that affect sinks exporting data to BigQuery. use_partitioned_tables - (Required) Whether to use BigQuery's partition tables.
- delete_contents_on_destroy: (Optional) If set to true, delete all contained objects in the logging destination.

Destination BigQuery options example:
```
bigquery_options = {
  logging_sink_name          = "sk-c-logging-bq"
  dataset_name               = "audit_logs"
  partitioned_tables         = "true"
  include_children           = "true"
  expiration_days            = 30
  delete_contents_on_destroy = false
  logging_sink_filter        = <<EOF
  logName: /logs/cloudaudit.googleapis.com%2Factivity OR
  logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR
  logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR
  logName: /logs/compute.googleapis.com%2Fvpc_flows OR
  logName: /logs/compute.googleapis.com%2Ffirewall OR
  logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency
EOF
}
```
EOT
  type        = map(string)
  default     = null

  validation {
    condition     = var.bigquery_options == null ? true : !contains(keys(var.bigquery_options), "include_children") ? true : can(tobool(var.bigquery_options["include_children"]))
    error_message = "Include_children option must be a bool (true or false). Default false."
  }
}

#--------------------------- #
# Storage specific variables #
#--------------------------- #
variable "storage_options" {
  description = <<EOT
Destination Storage options:
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.
- include_children: Only valid if 'organization' or 'folder' is chosen as var.resource_type. Determines whether or not to include children organizations/folders in the sink export. If true, logs associated with child projects are also exported; otherwise only logs relating to the provided organization/folder are included.
- storage_bucket_name: The name of the storage bucket to be created and used for log entries matching the filter.
- location: (Optional) The location of the logging destination. Default: US.
- Retention Policy variables: (Optional) Configuration of the bucket's data retention policy for how long objects in the bucket should be retained.
  - retention_policy_is_locked: Set if policy is locked.
  - retention_policy_period_days: Set the period of days for log retention. Default: 30.
- versioning: (Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted.
- force_destroy: When deleting a bucket, this boolean option will delete all contained objects.

Destination Storage options example:
```
storage_options = {
  logging_sink_name   = "sk-c-logging-bkt"
  logging_sink_filter = ""
  include_children    = "true"
  storage_bucket_name = "bkt-org-logs"
  location            = "US"
  force_destroy       = false
  versioning          = false
}
```
EOT
  type        = map(any)
  default     = null

  validation {
    condition     = var.storage_options == null ? true : !contains(keys(var.storage_options), "include_children") ? true : can(tobool(var.storage_options["include_children"]))
    error_message = "Include_children option must be a bool (true or false). Default false."
  }
}


#-------------------------- #
# Pubsub specific variables #
#-------------------------- #
variable "pubsub_options" {
  description = <<EOT
Destination Pubsub options:
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs.
- include_children: Only valid if 'organization' or 'folder' is chosen as var.resource_type. Determines whether or not to include children organizations/folders in the sink export. If true, logs associated with child projects are also exported; otherwise only logs relating to the provided organization/folder are included.
- topic_name: The name of the pubsub topic to be created and used for log entries matching the filter.
- create_subscriber: (Optional) Whether to create a subscription to the topic that was created and used for log entries matching the filter. If 'true', a pull subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic.

Destination Storage options example:
```
pubsub_options = {
  logging_sink_name   = "sk-c-logging-pub"
  include_children    = true
  topic_name          = "tp-org-logs"
  create_subscriber   = true
  logging_sink_filter = <<EOF
  logName: /logs/cloudaudit.googleapis.com%2Factivity OR
  logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR
  logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR
  logName: /logs/compute.googleapis.com%2Fvpc_flows OR
  logName: /logs/compute.googleapis.com%2Ffirewall OR
  logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency
EOF
}
```
EOT
  type        = map(any)
  default     = null
}
