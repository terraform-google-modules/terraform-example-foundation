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

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with shared VPC that will use the Interconnect."
}

variable "default_region1" {
  type        = string
  description = "First subnet region. The dedicated Interconnect module only configures two regions."
}

variable "default_region2" {
  type        = string
  description = "Second subnet region. The dedicated Interconnect module only configures two regions."
}

variable "peer_name" {
  type        = string
  description = "Name of this BGP peer. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "peer_ip_address" {
  type        = string
  description = "IP address of the BGP interface outside Google Cloud Platform. Only IPv4 is supported."
}

variable "peer_asn" {
  type        = number
  description = "Peer BGP Autonomous System Number (ASN)."
}

variable "interconnect_location1_region1" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the first location of region1"
}

variable "interconnect_location2_region1" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the second location of region1"
}

variable "interconnect_location1_region2" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the first location of region2"
}

variable "interconnect_location2_region2" {
  type        = string
  description = "Name of the interconnect location used in the creation of the Interconnect for the second location of region2"
}

variable "interconnect1_region1" {
  type        = string
  description = "URL of the underlying Interconnect object that this attachment's traffic will traverse through."
}

variable "interconnect2_region1" {
  type        = string
  description = "URL of the underlying Interconnect object that this attachment's traffic will traverse through."
}

variable "interconnect1_region2" {
  type        = string
  description = "URL of the underlying Interconnect object that this attachment's traffic will traverse through."
}

variable "interconnect2_region2" {
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
