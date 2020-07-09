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

variable "project_id" {
  type        = string
  description = "VPC Project ID"
}

variable "default_region1" {
  type        = string
  description = "Default region 1 for Cloud Routers"
}

variable "default_region2" {
  type        = string
  description = "Default region 2 for Cloud Routers"
}

variable "vpc_label" {
  type        = string
  description = "Label for VPC."
}

variable "environment_code" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization."
}

variable "bgp_peer_secret" {
  type        = string
  description = "Shared secret used to set the secure session between the Cloud VPN gateway and the peer VPN gateway."
}

variable "on_prem_router_ip_address1" {
  type        = string
  description = "On-Prem Router IP address"
}

variable "on_prem_router_ip_address2" {
  type        = string
  description = "On-Prem Router IP address"
}

variable "bgp_peer_asn" {
  type        = number
  description = "BGP ASN for cloud routes."
}

variable "bgp_peer_address0" {
  type        = string
  description = "Remote 0 IP"
}

variable "bgp_peer_range0" {
  type        = string
  description = "Remote 0 IP range"
}

variable "bgp_peer_address1" {
  type        = string
  description = "Remote 1 IP"
}

variable "bgp_peer_range1" {
  type        = string
  description = "Remote 1 IP range"
}

variable "bgp_peer_address2" {
  type        = string
  description = "Remote 2 IP"
}

variable "bgp_peer_range2" {
  type        = string
  description = "Remote 2 IP range"
}

variable "bgp_peer_address3" {
  type        = string
  description = "Remote 3 IP"
}

variable "bgp_peer_range3" {
  type        = string
  description = "Remote 3 IP range"
}

variable "bgp_peer_address4" {
  type        = string
  description = "Remote 4 IP"
}

variable "bgp_peer_range4" {
  type        = string
  description = "Remote 4 IP range"
}

variable "bgp_peer_address5" {
  type        = string
  description = "Remote 5 IP"
}

variable "bgp_peer_range5" {
  type        = string
  description = "Remote 5 IP range"
}


variable "bgp_peer_address6" {
  type        = string
  description = "Remote 6 IP"
}

variable "bgp_peer_range6" {
  type        = string
  description = "Remote 6 IP range"
}

variable "bgp_peer_address7" {
  type        = string
  description = "Remote 7 IP"
}

variable "bgp_peer_range7" {
  type        = string
  description = "Remote 7 IP range"
}
