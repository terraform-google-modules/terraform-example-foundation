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

variable "interconnect_project_id" {
  type        = string
  description = "Interconnect project ID."
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

variable "enable_site_to_site_data_transfer" {
  type        = bool
  description = "Set to true to enable site-to-site data transfer on NCC spokes."
  default     = false
}

variable "dedicated_interconnect_config" {
  description = <<EOT
Dedicated Interconnect configuration map and default settings.

Top-level attributes:
  - peer_asn:   (Optional) Default BGP Autonomous System Number (ASN) of the on-premises peer.
  - peer_name:  (Optional) Default name for the on-premises BGP peer.
  - attachments: Map of Dedicated Interconnect attachment objects keyed by a unique identifier.

Attachment attributes (map values):
  - region:            Google Cloud region where the attachment and Cloud Router reside.
  - router:            Name of the Google Cloud Router.
  - onprem_dc:         Identifier for the on-premises data center (e.g., 'equinix-dc1').
  - location:          Google Cloud Interconnect edge location code (e.g., 'iad-zone1-1').
  - cr_suffix:         Suffix used for interface/subinterface naming (e.g., 'cr5', 'cr6').
  - interconnect:      Resource URL or ID of the physical Dedicated Interconnect port.
  - candidate_subnets: (Optional) Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc).
  - vlan_tag8021q:     (Optional) The IEEE 802.1Q VLAN tag for this attachment, in the range (2-4094).
EOT

  type = object({
    peer_asn  = optional(number)
    peer_name = optional(string)
    attachments = map(object({
      region            = string
      router            = string
      onprem_dc         = string
      location          = string
      cr_suffix         = string
      interconnect      = string
      candidate_subnets = optional(list(string))
      vlan_tag8021q     = optional(number)
    }))
  })
}
