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

variable "project_id" {
  type        = string
  description = "VPC Project ID"
}

variable "env_secret_project_id" {
  type        = string
  description = "the environment secrets project ID"
}

variable "default_region1" {
  type        = string
  description = "Default region 1 for Cloud Routers"
}

variable "default_region2" {
  type        = string
  description = "Default region 2 for Cloud Routers"
}

variable "vpn_psk_secret_name" {
  type        = string
  description = "The name of the secret to retrieve from secret manager. This will be retrieved from the environment secrets project."
}

variable "on_prem_router_ip_address1" {
  type        = string
  description = "On-Prem Router IP address"
}

variable "on_prem_router_ip_address2" {
  type        = string
  description = "On-Prem Router IP address"
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

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with shared VPC that will use the Interconnect."
}

variable "bgp_peer_asn" {
  type        = number
  description = "BGP ASN for cloud routes."
}

variable "region1_router1_tunnel0_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 1 in region 1 tunnel 0"
}

variable "region1_router1_tunnel0_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 1 in region 1 tunnel 0"
}

variable "region1_router1_tunnel1_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 1 in region 1 tunnel 1"
}

variable "region1_router1_tunnel1_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 1 in region 1 tunnel 1"
}

variable "region1_router2_tunnel0_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 2 in region 1 tunnel 0"
}

variable "region1_router2_tunnel0_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 2 in region 1 tunnel 0"
}

variable "region1_router2_tunnel1_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 2 in region 1 tunnel 1"
}

variable "region1_router2_tunnel1_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 2 in region 1 tunnel 1"
}

variable "region2_router1_tunnel0_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 1 in region 2 tunnel 0"
}

variable "region2_router1_tunnel0_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 1 in region 2 tunnel 0"
}

variable "region2_router1_tunnel1_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 1 in region 2 tunnel 2"
}

variable "region2_router1_tunnel1_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 1 in region 2 tunnel 2"
}

variable "region2_router2_tunnel0_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 2 in region 2 tunnel 0"
}

variable "region2_router2_tunnel0_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 2 in region 2 tunnel 0"
}

variable "region2_router2_tunnel1_bgp_peer_address" {
  type        = string
  description = "BGP session address for router 2 in region 1 tunnel 1"
}

variable "region2_router2_tunnel1_bgp_peer_range" {
  type        = string
  description = "BGP session range for router 2 in region 1 tunnel 1"
}
