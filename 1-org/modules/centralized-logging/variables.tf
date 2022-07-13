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

variable "resource_type" {
  description = "Resource type of the resource that will export logs to destination. Must be: project, organization or folder"
  type        = string

  validation {
    condition     = contains(["project", "folder", "organization"], var.resource_type)
    error_message = "The resource_type value must be: project, organization or folder."
  }
}

variable "resources" {
  description = "Export logs from the specified resources."
  type        = map(string)

  validation {
    condition     = length(var.resources) > 0
    error_message = "The resources map should have at least 1 item."
  }
}

variable "logging_destination_project_id" {
  description = "The ID of the project that will have the resources where the logs will be created."
  type        = string
}

variable "logging_target_type" {
  description = "Resource type of the resource that will store the logs. Must be: bigquery, storage, or pubsub"
  type        = string

  validation {
    condition     = contains(["bigquery", "storage", "pubsub"], var.logging_target_type)
    error_message = "The logging_target_type value must be: bigquery, storage, or pubsub."
  }
}

variable "logging_location" {
  description = "A valid location for the bucket and KMS key that will be deployed."
  type        = string
  default     = "us-east4"
}

variable "logging_sink_name" {
  description = "The name of the log sink to be created."
  type        = string
}

variable "logging_sink_filter" {
  description = "The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs."
  type        = string
  default     = ""
}

variable "logging_target_name" {
  description = "The name of the logging container (bigquery, storage, or pubsub) that will store the logs."
  type        = string
  default     = ""
}

variable "logging_destination_uri" {
  description = "The self_link URI of the destination resource (This is available as an output coming from one of the destination submodules)"
  type        = string
}

variable "kms_project_id" {
  description = "The ID of the project in which the Cloud KMS keys will be created."
  type        = string
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, disable the prevent destroy protection in the KMS keys."
  type        = bool
  default     = false
}

variable "key_rotation_period_seconds" {
  description = "Rotation period for keys. The default value is 30 days."
  type        = string
  default     = "2592000s"
}

variable "kms_key_protection_level" {
  description = "The protection level to use when creating a key. Possible values: [\"SOFTWARE\", \"HSM\"]"
  type        = string
  default     = "HSM"
}

variable "data_access_logs_enabled" {
  description = "Enable Data Access logs of types DATA_READ, DATA_WRITE for all GCP services in the projects specified in the provided `projects_ids` map. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access The ADMIN_READ logs are enabled by default."
  type        = bool
  default     = false
}

variable "audit_logs_table_expiration_days" {
  description = "Period before tables expire for all audit logs in milliseconds. Default is 30 days."
  type        = number
  default     = 30
}

variable "log_export_storage_force_destroy" {
  description = "(Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present."
  type        = bool
  default     = false
}

variable "log_export_storage_versioning" {
  description = "(Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted."
  type        = bool
  default     = false
}

variable "audit_logs_table_delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "log_export_storage_retention_policy" {
  description = "Configuration of the bucket's data retention policy for how long objects in the bucket should be retained."
  type = object({
    is_locked             = bool
    retention_period_days = number
  })
  default = null
}

variable "bigquery_options" {
  description = "(Optional) Options that affect sinks exporting data to BigQuery. use_partitioned_tables - (Required) Whether to use BigQuery's partition tables."
  type = object({
    use_partitioned_tables = bool
  })
  default = null
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

variable "labels" {
  description = "(Optional) Labels attached to Data Warehouse resources."
  type        = map(string)
  default     = {}
}
