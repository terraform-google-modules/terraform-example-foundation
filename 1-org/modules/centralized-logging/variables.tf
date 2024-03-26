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

variable "billing_account" {
  description = "Billing Account ID used in case sinks are under billing account level. Format 000000-000000-000000."
  type        = string
  default     = null
}

variable "enable_billing_account_sink" {
  description = "If true, a log router sink will be created for the billing account. The billing_account variable cannot be null."
  type        = bool
  default     = false
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

variable "project_options" {
  description = <<EOT
Destination Project options:
- logging_sink_name: The name of the log sink to be created.
- logging_sink_filter: The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is "" which exports all logs.
- log_bucket_id: Id of the log bucket create to store the logs exported to the project.
- log_bucket_description: Description of the log bucket create to store the logs exported to the project.
- location: The location of the log bucket. Default: global.
- enable_analytics: Whether or not Log Analytics is enabled in the _Default log bucket. A Log bucket with Log Analytics enabled can be queried in the Log Analytics page using SQL queries. Cannot be disabled once enabled.
- retention_days: The number of days data should be retained for the _Default log bucket. Default 30.
- linked_dataset_id: The ID of the linked BigQuery dataset for the _Default log bucket. A valid link dataset ID must only have alphanumeric characters and underscores within it and have up to 100 characters.
- linked_dataset_description: A use-friendly description of the linked BigQuery dataset for the _Default log bucket. The maximum length of the description is 8000 characters.
EOT
  type = object({
    logging_sink_name          = optional(string, null)
    logging_sink_filter        = optional(string, "")
    log_bucket_id              = optional(string, null)
    log_bucket_description     = optional(string, null)
    location                   = optional(string, "global")
    enable_analytics           = optional(bool, true)
    retention_days             = optional(number, 30)
    linked_dataset_id          = optional(string, null)
    linked_dataset_description = optional(string, null)
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
