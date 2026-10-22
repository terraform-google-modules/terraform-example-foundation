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

variable "attachment_project_id" {
  type        = string
  description = "The Interconnect Google Cloud project ID."
}

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with shared VPC that will use the Interconnect."
}

variable "ncc_hub_uri" {
  type        = string
  description = "The full URI of the existing Network Connectivity Center Hub."
}

variable "ncc_hub_group" {
  type        = string
  description = "Network Connectivity Center Group name to attach spokes to."
}

variable "site_to_site_data_transfer" {
  type        = bool
  description = "Set to true to allow Google Cloud routing to act as a transit network between on-premises sites."
  default     = false
}

variable "partner_interconnect_config" {
  description = <<EOT
Partner Interconnect configuration map containing attachment definitions and default settings.

Top-level attributes:
  - preactivate: (Optional) Default preactivate setting for all Partner Interconnect attachments (defaults to false).
  - attachments: Map of Partner Interconnect attachment configuration objects keyed by a unique identifier.

Attachment attributes (map values):
  - region:                   Google Cloud region where the attachment and Cloud Router reside.
  - router:                   Name or resource ID of the Google Cloud Router to attach to.
  - location:                 Google Cloud Interconnect edge location or city code.
  - cr_suffix:                Suffix used for interface naming (e.g., 'cr1', 'cr2').
  - edge_availability_domain: Edge availability domain assignment ('AVAILABILITY_DOMAIN_1', 'AVAILABILITY_DOMAIN_2', or 'AVAILABILITY_DOMAIN_ANY').
  - onprem_dc:                 (Optional) On-premises data center identifier.
  - preactivate:              (Optional) Override preactivate setting for this specific attachment.
EOT

  type = object({
    preactivate = optional(bool, false)
    attachments = map(object({
      region                   = string
      router                   = string
      location                 = string
      cr_suffix                = string
      edge_availability_domain = string
      onprem_dc                = optional(string)
    }))
  })
}
