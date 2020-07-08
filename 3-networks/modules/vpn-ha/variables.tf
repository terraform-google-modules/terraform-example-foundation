/**
 * Copyright 2019 Google LLC
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

variable "default_region1" {
  type        = string
  description = "Default region 1 for Cloud Routers"
}

variable "default_region2" {
  type        = string
  description = "Default region 2 for Cloud Routers"
}

variable "network_name" {
  type        = string
  description = "Network Name"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "on_prem_ip_address" {
  type        = string
  description = "On-Prem IP address"
}

variable "bgp_asn" {
  type        = number
  description = "BGP ASN for cloud routes."
  default     = 0
}

variable "remote0_ip" {
  type        = string
  description = "Remote 0 IP"
}

variable "remote0_range" {
  type        = string
  description = "Remote 0 IP range"
}

variable "remote0_secret" {
  type        = string
  description = "Remote 0 secret name"
}

variable "remote1_ip" {
  type        = string
  description = "Remote 1 IP"
}

variable "remote1_range" {
  type        = string
  description = "Remote 1 IP range"
}

variable "remote1_secret" {
  type        = string
  description = "Remote 1 secret name"
}

variable "region1_router1_name" {
  type        = string
  description = "Cloud Router 1 name for region 1"
}

variable "region1_router2_name" {
  type        = string
  description = "Cloud Router 2 name for region 1"
}

variable "region2_router1_name" {
  type        = string
  description = "Cloud Router 1 name for region 2"
}

variable "region2_router2_name" {
  type        = string
  description = "Cloud Router 2 name for region 2"
}
