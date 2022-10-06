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
- name: The name of the log bucket to be created and used for log entries matching the filter.
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.
- location: The location of the log bucket. Default: global.
- retention_days: The number of days data should be retained for the log bucket. Default 30.
EOT
  type = object({
    name                = optional(string, null)
    logging_sink_name   = optional(string, null)
    logging_sink_filter = optional(string, "")
    location            = optional(string, "global")
    retention_days      = optional(number, 30)
  })
  default = null
}

#----------------------------- #
# Big Query specific variables #
#----------------------------- #
variable "bigquery_options" {
  description = <<EOT
Destination BigQuery options:
- dataset_name: The name of the bigquery dataset to be created and used for log entries.
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.
- expiration_days: Table expiration time. If null logs will never be deleted.
- partitioned_tables: Options that affect sinks exporting data to BigQuery. use_partitioned_tables - (Required) Whether to use BigQuery's partition tables.
- delete_contents_on_destroy: If set to true, delete all contained objects in the logging destination.
EOT
  type = object({
    dataset_name               = optional(string, null)
    logging_sink_name          = optional(string, null)
    logging_sink_filter        = optional(string, "")
    expiration_days            = optional(number, null)
    partitioned_tables         = optional(bool, true)
    delete_contents_on_destroy = optional(bool, false)
  })
  default = null
}

#--------------------------- #
# Storage specific variables #
#--------------------------- #
variable "storage_options" {
  description = <<EOT
Destination Storage options:
- storage_bucket_name: The name of the storage bucket to be created and used for log entries matching the filter.
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.
- location: The location of the logging destination. Default: US.
- Retention Policy variables: (Optional) Configuration of the bucket's data retention policy for how long objects in the bucket should be retained.
  - retention_policy_enabled: if a retention policy should be enabled in the bucket.
  - retention_policy_is_locked: Set if policy is locked.
  - retention_policy_period_days: Set the period of days for log retention. Default: 30.
- versioning: Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted.
- force_destroy: When deleting a bucket, this boolean option will delete all contained objects.
EOT
  type = object({
    storage_bucket_name          = optional(string, null)
    logging_sink_name            = optional(string, null)
    logging_sink_filter          = optional(string, "")
    location                     = optional(string, "US")
    retention_policy_enabled     = optional(bool, false)
    retention_policy_is_locked   = optional(bool, false)
    retention_policy_period_days = optional(number, 30)
    versioning                   = optional(bool, false)
    force_destroy                = optional(bool, false)
  })
  default = null
}

#-------------------------- #
# Pubsub specific variables #
#-------------------------- #
variable "pubsub_options" {
  description = <<EOT
Destination Pubsub options:
- topic_name: The name of the pubsub topic to be created and used for log entries matching the filter.
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.
- create_subscriber: Whether to create a subscription to the topic that was created and used for log entries matching the filter. If 'true', a pull subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic.
EOT
  type = object({
    topic_name          = optional(string, null)
    logging_sink_name   = optional(string, null)
    logging_sink_filter = optional(string, "")
    create_subscriber   = optional(bool, true)
  })
  default = null
}
