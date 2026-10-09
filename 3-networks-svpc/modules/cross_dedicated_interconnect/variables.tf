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

variable "interconnect_project_id" {
  type        = string
  description = "Interconnect project ID."
}

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with shared VPC that will use the Interconnect."
}

variable "region1" {
  type        = string
  description = "First subnet region. The Dedicated Interconnect module only configures two regions."
}

variable "region2" {
  type        = string
  description = "Second subnet region. The Dedicated Interconnect module only configures two regions."
}

variable "cross_cloud_config" {
  description = <<EOT
  Cross-Cloud Interconnect configuration containing remote provider settings and attachment definitions.

  Top-level attributes:
    - remote_cloud_provider: Target cloud provider. Must be one of: 'aws', 'azure', or 'oci'.
    - peer_asn:              (Optional) Default BGP Autonomous System Number (ASN) of the remote cloud peer router.
    - peer_name:             (Optional) Default name for the remote BGP peer configuration.
    - attachments:           Map of interconnect attachment configuration objects keyed by a unique identifier.

  Attachment attributes (map values):
    - region:            Google Cloud region where the attachment and Cloud Router reside (e.g., 'us-central1').
    - router:            Name or resource reference of the Google Cloud Router to attach to.
    - cross_dc:          Identifier for the remote cloud data center or facility location (e.g., 'aws-dc1').
    - location:          Google Cloud Interconnect edge location code (e.g., 'iad-zone1-1').
    - cr_suffix:         Suffix identifier used when constructing Cloud Router interface and subinterface names (e.g., 'cr1').
    - interconnect:      Resource URL or ID of the underlying physical Dedicated Interconnect connection.
    - candidate_subnets: (Optional) List of link-local IPv4 CIDR ranges (e.g., /29 or /30) for candidate BGP IP allocation.
    - vlan_tag8021q:     (Optional) Explicit 802.1Q VLAN encapsulation tag (required to be >= 100 for OCI).
    - peer_name:         (Optional) Override for the remote BGP peer name on this specific attachment.
    - peer_asn:          (Optional) Override for the remote BGP peer ASN on this specific attachment.
    - md5_key:           (Optional) BGP MD5 authentication secret key (required for AWS Cross-Cloud Interconnect).
  EOT
  type = object({
    remote_cloud_provider = string
    peer_asn              = optional(number)
    peer_name             = optional(string)
    attachments = map(object({
      region            = string
      router            = string
      cross_dc          = string
      location          = string
      cr_suffix         = string
      interconnect      = string
      candidate_subnets = optional(list(string))
      vlan_tag8021q     = optional(number)
      peer_name         = optional(string)
      peer_asn          = optional(number)
      md5_key           = optional(string)
    }))
  })

  validation {
    condition     = contains(["aws", "azure", "oci"], lower(var.cross_cloud_config.remote_cloud_provider))
    error_message = "The 'remote_cloud_provider' must be one of: 'aws', 'azure', or 'oci'."
  }

  validation {
    condition = lower(var.cross_cloud_config.remote_cloud_provider) != "aws" || alltrue([
      for k, att in var.cross_cloud_config.attachments : att.md5_key != null && att.md5_key != ""
    ])
    error_message = "AWS Cross-Cloud Interconnect requires every attachment to specify a non-empty 'md5_key' for BGP authentication."
  }

  validation {
    condition = lower(var.cross_cloud_config.remote_cloud_provider) != "oci" || alltrue([
      for k, att in var.cross_cloud_config.attachments : att.vlan_tag8021q != null && att.vlan_tag8021q >= 100
    ])
    error_message = "OCI Cross-Cloud Interconnect requires 'vlan_tag8021q >= 100' on all attachments."
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
