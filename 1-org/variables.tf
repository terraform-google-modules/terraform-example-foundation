/**
 * Copyright 2020 Google LLC
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

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "default_region" {
  description = "Default region for BigQuery resources."
  type        = string
}

variable "billing_data_users" {
  description = "Gsuite or Cloud Identity group that have access to billing data set."
  type        = string
}

variable "audit_data_users" {
  description = "Gsuite or Cloud Identity group that have access to audit logs."
  type        = string
}

variable "monitoring_workspace_users" {
  description = "Gsuite or Cloud Identity group that have access to Monitoring Workspaces."
  type        = string
}

variable "domains_to_allow" {
  description = "The list of domains to allow users from in IAM."
  type        = list(string)
}

variable "access_table_expiration_ms" {
  description = "Period before tables expire for access logs in milliseconds. Default is 400 days."
  type        = number
  default     = 34560000000
}

variable "system_event_table_expiration_ms" {
  description = "Period before tables expire for system event logs in milliseconds. Default is 400 days."
  type        = number
  default     = 34560000000
}

variable "data_access_table_expiration_ms" {
  description = "Period before tables expire for data access logs in milliseconds. Default is 30 days."
  type        = number
  default     = 2592000000
}

variable "parent_folder" {
  description = "Optional - if using a folder for testing."
  type        = string
  default     = ""
}
