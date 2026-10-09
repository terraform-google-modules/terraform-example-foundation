/**
 * Copyright 2026 Google LLC
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

variable "attachment_project_id" {
  type        = string
  description = "the Interconnect project ID."
}

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with shared VPC that will use the Interconnect."
}

variable "region1" {
  type        = string
  description = "First subnet region. The Partner Interconnect module only configures two regions."
}

variable "region2" {
  type        = string
  description = "Second subnet region. The Partner Interconnect module only configures two regions."
}

variable "partner_cross_cloud_config" {
  description = <<EOT
Partner Cross-Cloud Interconnect configuration containing remote provider settings and attachment definitions.

Top-level attributes:
  - remote_cloud_provider: Target cloud provider. Must be either 'aws' or 'oci'.
  - attachments:           Map of Partner Interconnect attachment configuration objects keyed by a unique identifier.

Attachment attributes (map values):
  - region:                   Google Cloud region where the attachment and Cloud Router reside (e.g., 'us-central1').
  - router:                   Name or resource reference of the Google Cloud Router to attach to.
  - cross_dc:                 Identifier for the remote cloud data center or facility location (e.g., 'aws-partner-dc1').
  - location:                 Google Cloud Interconnect edge location code or city code (e.g., 'iad').
  - cr_suffix:                Suffix identifier used when constructing Cloud Router interface and subinterface names (e.g., 'cr1').
  - edge_availability_domain: Edge availability domain assignment. Must be 'AVAILABILITY_DOMAIN_1', 'AVAILABILITY_DOMAIN_2', or 'AVAILABILITY_DOMAIN_ANY'.
  - preactivate:              (Optional) Whether to preactivate the attachment before the partner completes pairing (defaults to false).
EOT

  type = object({
    remote_cloud_provider = string
    attachments = map(object({
      region                   = string
      router                   = string
      cross_dc                 = string
      location                 = string
      cr_suffix                = string
      edge_availability_domain = string
      preactivate              = optional(bool, false)
    }))
  })

  # Validation 1: Allowed Cloud Providers for Partner Cross-Cloud Interconnect
  validation {
    condition     = contains(["aws", "oci"], lower(var.partner_cross_cloud_config.remote_cloud_provider))
    error_message = "The 'remote_cloud_provider' for Partner Cross-Cloud Interconnect must be either 'aws' or 'oci'."
  }


  validation {
    condition = alltrue([
      for k, att in var.partner_cross_cloud_config.attachments :
      contains(["AVAILABILITY_DOMAIN_1", "AVAILABILITY_DOMAIN_2", "AVAILABILITY_DOMAIN_ANY"], att.edge_availability_domain)
    ])
    error_message = "Every attachment must specify 'edge_availability_domain' as 'AVAILABILITY_DOMAIN_1', 'AVAILABILITY_DOMAIN_2' or 'AVAILABILITY_DOMAIN_ANY'."
  }
}

variable "ncc_hub_uri" {
  type        = string
  description = "The full URI (ID) of the existing Network Connectivity Center Hub where the spokes will be attached."
}

variable "ncc_hub_group" {
  type        = string
  description = "Network Connectivity Center Group to attach the spoke to"
}

variable "site_to_site_data_transfer" {
  type        = bool
  description = "Set to true to allow Google Cloud routing to act as a transit network between on-premises sites."
  default     = false
}
