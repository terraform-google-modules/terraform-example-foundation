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
  description = "Toggle creation of optional firewall rules: IAP SSH, IAP RDP and Internal & Global load balancing health check and load balancing IP ranges."
  default     = false
}

variable "windows_activation_enabled" {
  type        = bool
  description = "Enable Windows license activation for Windows workloads."
  default     = false
}

variable "project_budget" {
  description = <<EOT
  Budget configuration.
  budget_amount: The amount to use as the budget.
  alert_spent_percents: A list of percentages of the budget to alert on when threshold is exceeded.
  alert_pubsub_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.
  EOT
  type = object({
    budget_amount        = optional(number, 1000)
    alert_spent_percents = optional(list(number), [0.5, 0.75, 0.9, 0.95])
    alert_pubsub_topic   = optional(string, null)
  })
  default = {}
}

variable "secrets_prj_suffix" {
  description = "Name suffix to use for secrets project created."
  type        = string
  default     = "env-secrets"
}

variable "location_kms" {
  description = "Case-Sensitive Location for KMS Keyring (Should be same region as the GCS Bucket)"
  type        = string
  default     = "us"
}

variable "location_gcs" {
  description = "Case-Sensitive Location for GCS Bucket (Should be same region as the KMS Keyring)"
  type        = string
  default     = "US"
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
