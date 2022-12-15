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

variable "peer_name" {
  type        = string
  description = "Name of this BGP peer. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "peer_asn" {
  type        = number
  description = "Peer BGP Autonomous System Number (ASN)."
}

variable "region1_interconnect1_onprem_dc" {
  type        = string
  description = "Name of the on premisses data center used in the creation of the Interconnect for the first location of region1."
}

variable "region1_interconnect2_onprem_dc" {
  type        = string
  description = "Name of the on premisses data center used in the creation of the Interconnect for the second location of region1."
}

variable "region2_interconnect1_onprem_dc" {
  type        = string
  description = "Name of the on premisses data center used in the creation of the Interconnect for the first location of region2."
}

variable "region2_interconnect2_onprem_dc" {
  type        = string
  description = "Name of the on premisses data center used in the creation of the Interconnect for the second location of region2."
}

variable "region1_interconnect1_location" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the first location of region1"
}

variable "region1_interconnect2_location" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the second location of region1"
}

variable "region2_interconnect1_location" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the first location of region2"
}

variable "region2_interconnect2_location" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the second location of region2"
}

variable "region1_interconnect1" {
  type        = string
  description = "URL of the underlying Interconnect object that this attachment's traffic will traverse through."
}

variable "region1_interconnect2" {
  type        = string
  description = "URL of the underlying Interconnect object that this attachment's traffic will traverse through."
}

variable "region2_interconnect1" {
  type        = string
  description = "URL of the underlying Interconnect object that this attachment's traffic will traverse through."
}

variable "region2_interconnect2" {
  type        = string
  description = "URL of the underlying Interconnect object that this attachment's traffic will traverse through."
}

variable "region1_router1_name" {
  type        = string
  description = "Name of the Router 1 for Region 1 where the attachment resides."
}

variable "region1_router2_name" {
  type        = string
  description = "Name of the Router 2 for Region 1 where the attachment resides."
}

variable "region2_router1_name" {
  type        = string
  description = "Name of the Router 1 for Region 2 where the attachment resides."
}

variable "region2_router2_name" {
  type        = string
  description = "Name of the Router 2 for Region 2 where the attachment resides"
}

variable "cloud_router_labels" {
  type        = map(string)
  description = "A map of suffixes for labelling vlans with four entries like \"vlan_1\" => \"suffix1\" with keys from `vlan_1` to `vlan_4`."
  default     = {}
}

variable "region1_interconnect1_candidate_subnets" {
  type        = list(string)
  description = "Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc)."
  default     = null
}

variable "region1_interconnect2_candidate_subnets" {
  type        = list(string)
  description = "Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc)."
  default     = null
}
variable "region2_interconnect1_candidate_subnets" {
  type        = list(string)
  description = "Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc)."
  default     = null
}
variable "region2_interconnect2_candidate_subnets" {
  type        = list(string)
  description = "Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc)."
  default     = null
}

variable "region1_interconnect1_vlan_tag8021q" {
  type        = string
  description = "The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094."
  default     = null
}

variable "region1_interconnect2_vlan_tag8021q" {
  type        = string
  description = "The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094."
  default     = null
}

variable "region2_interconnect1_vlan_tag8021q" {
  type        = string
  description = "The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094."
  default     = null
}

variable "region2_interconnect2_vlan_tag8021q" {
  type        = string
  description = "The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094."
  default     = null
}
