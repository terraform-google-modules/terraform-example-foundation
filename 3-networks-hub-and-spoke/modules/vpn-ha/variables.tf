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
  description = "VPC Project ID where HA VPN gateways will be created."
}

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with shared VPC that will use the HA VPN."
}

variable "ncc_hub_uri" {
  type        = string
  description = "The full URI of the existing Network Connectivity Center Hub."
}

variable "ncc_hub_group" {
  type        = string
  description = "Network Connectivity Center Group name to attach spokes to."
}

variable "env_secret_project_id" {
  type        = string
  description = "Project ID where Secret Manager holds the PSK secret."
}

variable "vpn_psk_secret_name" {
  type        = string
  description = "Name of the pre-shared key secret in Secret Manager."
}

variable "site_to_site_data_transfer" {
  type        = bool
  description = "Set to true to allow Google Cloud routing to act as a transit network between on-premises sites."
  default     = false
}

variable "ha_vpn_config" {
  description = <<EOT
HA VPN configuration map containing gateway definitions.

Top-level attributes:
  - gateways: Map of HA VPN gateway objects keyed by a unique identifier.

Gateway attributes (map values):
  - region:                           Google Cloud region where the HA VPN gateway and Cloud Router reside.
  - router:                           Name of the Google Cloud Router.
  - cr_suffix:                        Suffix used for gateway naming (e.g., 'cr1', 'cr2').
  - peer_external_gateway_interfaces: List of on-premises / external peer IP addresses.
  - tunnels:                          Map of tunnel configurations (keyed by tunnel index or identifier).
EOT

  type = object({
    gateways = map(object({
      region                           = string
      router                           = string
      cr_suffix                        = string
      peer_external_gateway_interfaces = list(string)
      tunnels = map(object({
        bgp_peer_address  = string
        bgp_peer_asn      = number
        bgp_session_range = string
      }))
    }))
  })
}
