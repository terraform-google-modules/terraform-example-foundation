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

variable "logging_target_type" {
  description = "Resource type of the resource that will store the logs. Must be: logbucket, bigquery, storage, or pubsub."
  type        = string

  validation {
    condition     = contains(["bigquery", "storage", "pubsub", "logbucket"], var.logging_target_type)
    error_message = "The logging_target_type value must be: logbucket, bigquery, storage, or pubsub."
  }
}

variable "logging_target_name" {
  description = "The name of the logging container (logbucket, bigquery-dataset, storage, or pubsub-topic) that will store the logs."
  type        = string
  default     = ""
}

variable "logging_destination_uri" {
  description = "The self_link URI of the destination resource. If provided all needed permissions will be assigned and this resource will be used as log destination for all resources."
  type        = string
  default     = ""
}

variable "logging_sink_name" {
  description = "The name of the log sink to be created."
  type        = string
  default     = ""
}

variable "logging_sink_filter" {
  description = "The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs."
  type        = string
  default     = ""
}

variable "include_children" {
  description = "Only valid if 'organization' or 'folder' is chosen as var.resource_type. Determines whether or not to include children organizations/folders in the sink export. If true, logs associated with child projects are also exported; otherwise only logs relating to the provided organization/folder are included."
  type        = bool
  default     = false
}

variable "exclusions" {
  description = "(Optional) A list of sink exclusion filters."
  type = list(object({
    name        = string,
    description = string,
    filter      = string,
    disabled    = bool
  }))
  default = []
}

variable "bigquery_options" {
  description = "(Optional) Options that affect sinks exporting data to BigQuery. use_partitioned_tables - (Required) Whether to use BigQuery's partition tables. Applies to logging target type: bigquery."
  type = object({
    use_partitioned_tables = bool
  })
  default = null
}

variable "labels" {
  description = "(Optional) Labels attached to logging resources."
  type        = map(string)
  default     = {}
}
variable "kms_key_name" {
  description = "(Optional) ID of a Cloud KMS CryptoKey that will be used to encrypt the logging destination. Applies to logging target types: bigquery, storage, and pubsub."
  type        = string
  default     = null
}

variable "logging_location" {
  description = "(Optional) The location of the logging destination. Applies to logging target types: bigquery and storage."
  type        = string
  default     = "US"
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all contained objects in the logging destination. Applies to logging target types: bigquery and storage."
  type        = bool
  default     = false
}

#----------------------------- #
# Logbucket specific variables #
#----------------------------- #
variable "retention_days" {
  description = "(Optional) The number of days data should be retained for the log bucket. Applies to logging target type: logbucket."
  type        = number
  default     = 30
}

#----------------------------- #
# Big Query specific variables #
#----------------------------- #
variable "dataset_description" {
  description = "(Optional) A user-friendly description of the dataset. Applies to logging target type: bigquery."
  type        = string
  default     = ""
}

variable "expiration_days" {
  description = "(Optional) Table expiration time. If null logs will never be deleted. Applies to logging target type: bigquery."
  type        = number
  default     = null
}

#--------------------------- #
# Storage specific variables #
#--------------------------- #
variable "storage_class" {
  description = "(Optional) The storage class of the storage bucket. Applies to logging target type: storage."
  type        = string
  default     = "STANDARD"
}

variable "uniform_bucket_level_access" {
  description = "(Optional) Enables Uniform bucket-level access to a bucket. Applies to logging target type: storage."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  type = set(object({
    # Object with keys:
    # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.
    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
    action = map(string)

    # Object with keys:
    # - age - (Optional) Minimum age of an object in days to satisfy this condition.
    # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
    # - matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
    # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
    # - days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.
    condition = map(string)
  }))
  description = "(Optional) List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string. Applies to logging target type: storage."
  default     = []
}

variable "retention_policy" {
  description = "(Optional) Configuration of the bucket's data retention policy for how long objects in the bucket should be retained. Applies to logging target type: storage."
  type = object({
    is_locked             = bool
    retention_period_days = number
  })
  default = null
}

variable "versioning" {
  description = "(Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted. Applies to logging target type: storage."
  type        = bool
  default     = false
}

#-------------------------- #
# Pubsub specific variables #
#-------------------------- #
variable "create_subscriber" {
  description = "(Optional) Whether to create a subscription to the topic that was created and used for log entries matching the filter. If 'true', a pull subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic. Applies to logging target type: pubsub."
  type        = bool
  default     = false
}

variable "subscriber_id" {
  description = "(Optional) The ID to give the pubsub pull subscriber service account. Applies to logging target type: pubsub."
  type        = string
  default     = ""
}

variable "subscription_labels" {
  description = "(Optional) A set of key/value label pairs to assign to the pubsub subscription. Applies to logging target type: pubsub."
  type        = map(string)
  default     = {}
}

variable "create_push_subscriber" {
  description = "(Optional) Whether to add a push configuration to the subcription. If 'true', a push subscription is created along with a service account that is granted roles/pubsub.subscriber and roles/pubsub.viewer to the topic. Applies to logging target type: pubsub."
  type        = bool
  default     = false
}

variable "push_endpoint" {
  description = "(Optional) The URL locating the endpoint to which messages should be pushed. Applies to logging target type: pubsub."
  type        = string
  default     = ""
}
