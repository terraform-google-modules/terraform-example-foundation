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

variable "scc_notification_name" {
  description = "Name of SCC Notification"
  type        = string
}

variable "skip_gcloud_download" {
  description = "Whether to skip downloading gcloud (assumes gcloud is already available outside the module. If set to true you, must ensure that Gcloud Alpha module is installed.)"
  type        = bool
  default     = true
}

variable "scc_notification_filter" {
  description = "Filter used to SCC Notification, you can see more details how to create filters in https://cloud.google.com/security-command-center/docs/how-to-api-filter-notifications#create-filter"
  type        = string
  default     = "state=\\\"ACTIVE\\\""
}

variable "parent_folder" {
  description = "Optional - if using a folder for testing."
  type        = string
  default     = ""
}

variable "dns_default_region1" {
  type        = string
  description = "First subnet region for DNS Hub network."
}

variable "dns_default_region2" {
  type        = string
  description = "Second subnet region for DNS Hub network."
}

variable "dns_enable_logging" {
  type        = bool
  description = "Toggle DNS logging for VPC DNS."
  default     = true
}

variable "domain" {
  type        = string
  description = "The DNS name of forwarding managed zone, for instance 'example.com'"
}

variable "bgp_asn_dns" {
  type        = number
  description = "BGP Autonomous System Number (ASN)."
  default     = 64667
}

variable "target_name_server_addresses" {
  description = "List of target name servers for forwarding zone."
  type        = list(string)
}

variable "bgp_peer_secret" {
  type        = string
  description = "Shared secret used to set the secure session between the Cloud VPN gateway and the peer VPN gateway for the DNS hub. Only necessary if you are using the VPN example code."
  default     = ""
}
