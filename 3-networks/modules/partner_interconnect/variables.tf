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

variable "org_id" {
  type        = string
  description = "Organization ID"
}

variable "parent_folder" {
  description = "Optional - if using a folder for testing."
  type        = string
  default     = ""
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

variable "folder_prefix" {
  description = "Name prefix to use for folders created."
  type        = string
  default     = "fldr"
}

variable "preactivate" {
  description = "Preactivate Partner Interconnect attachments, works only for level3 Partner Interconnect"
  type        = string
  default     = false
}

variable "environment" {
  description = "Environment in which to deploy the Partner Interconnect, must be 'common' if enable_hub_and_spoke=true"
  type        = string
  default     = null
}

variable "vpc_type" {
  description = "To which Shared VPC Host attach the Partner Interconnect - base/restricted"
  type        = string
  default     = null
}

variable "enable_hub_and_spoke" {
  description = "Support hub and spoke architecture"
  type        = string
  default     = false
}

