/**
 * Copyright 2021 Google LLC
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

variable "business_code" {
  description = "The business code (ex. bu1)."
  type        = string
}

variable "business_unit" {
  description = "The business (ex. business_unit_1)."
  type        = string
}

variable "env" {
  description = "The environment to prepare (ex. development)."
  type        = string
}

variable "peering_module_depends_on" {
  description = "List of modules or resources peering module depends on."
  type        = list(any)
  default     = []
}

variable "firewall_enable_logging" {
  type        = bool
  description = "Toggle firewall logging for VPC Firewalls."
  default     = true
}

variable "optional_fw_rules_enabled" {
  type        = bool
  description = "Toggle creation of optional firewall rules: Internal & Global load balancing health check and load balancing IP ranges."
  default     = false
}

variable "windows_activation_enabled" {
  type        = bool
  description = "Enable Windows license activation for Windows workloads."
  default     = false
}

variable "vpc_flow_logs" {
  description = <<EOT
  aggregation_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN.
  flow_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].
  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, CUSTOM_METADATA.
  metadata_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM_METADATA.
  filter_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field.
EOT
  type = object({
    aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_sampling        = optional(string, "0.5")
    metadata             = optional(string, "INCLUDE_ALL_METADATA")
    metadata_fields      = optional(list(string), [])
    filter_expr          = optional(string, "true")
  })
  default = {}
}

variable "project_budget" {
  description = <<EOT
  Budget configuration.
  budget_amount: The amount to use as the budget.
  alert_spent_percents: A list of percentages of the budget to alert on when threshold is exceeded.
  alert_pubsub_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.
  alert_spend_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default).
  EOT
  type = object({
    budget_amount        = optional(number, 1000)
    alert_spent_percents = optional(list(number), [1.2])
    alert_pubsub_topic   = optional(string, null)
    alert_spend_basis    = optional(string, "FORECASTED_SPEND")
  })
  default = {}
}

variable "kms_prj_suffix" {
  description = "Name suffix to use for KMS project created."
  type        = string
  default     = "kms"
}

variable "location_kms" {
  description = "Case-Sensitive Location for KMS Keyring (Should be same region as the GCS Bucket)"
  type        = string
}

variable "location_gcs" {
  description = "Case-Sensitive Location for GCS Bucket (Should be same region as the KMS Keyring)"
  type        = string
}

variable "gcs_custom_placement_config" {
  description = "Configuration of the bucket's custom location in a dual-region bucket setup. If the bucket is designated a single or multi-region, the variable are null."
  type = object({
    data_locations = list(string)
  })
}

variable "keyring_name" {
  description = "Name to be used for KMS Keyring"
  type        = string
  default     = "sample-keyring"
}

variable "key_name" {
  description = "Name to be used for KMS Key"
  type        = string
  default     = "crypto-key-example"
}

variable "key_rotation_period" {
  description = "Rotation period in seconds to be used for KMS Key"
  type        = string
  default     = "7776000s"
}

variable "gcs_bucket_prefix" {
  description = "Name prefix to be used for GCS Bucket"
  type        = string
  default     = "bkt"
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
}

variable "peering_iap_fw_rules_enabled" {
  description = "Toggle creation of optional IAP firewall rules: SSH, RDP."
  type        = bool
  default     = false
}

variable "subnet_region" {
  description = "Region which the peered subnet will be created. If \"peering_iap_fw_rules_enabled\" is true, this field should not be null."
  type        = string
  default     = null
}

variable "subnet_ip_range" {
  description = "IP range for the peered subnetwork. If \"peering_iap_fw_rules_enabled\" is true, this field should not be null."
  type        = string
  default     = null
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "vpc_service_control_attach_enabled" {
  description = "Whether the project will be attached to a VPC Service Control Perimeter in ENFORCED MODE."
  type        = bool
  default     = false
}

variable "vpc_service_control_attach_dry_run" {
  description = "Whether the project will be attached to a VPC Service Control Perimeter with an explicit dry run spec flag, which may use different values for the dry run perimeter compared to the ENFORCED perimeter."
  type        = bool
  default     = false
}
