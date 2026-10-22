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

/******************************************
  HA VPN configuration
 *****************************************/

locals {
  network_name = "vpc-${var.vpc_name}"

  tunnels_by_region = {
    for k, v in var.ha_vpn_config.gateways : v.region => flatten([
      for mod_key, mod_val in module.vpn_ha : mod_val.tunnel_self_links
      if var.ha_vpn_config.gateways[mod_key].region == v.region
    ])...
  }
}

data "google_secret_manager_secret_version" "psk" {
  project = var.env_secret_project_id
  secret  = var.vpn_psk_secret_name
}

# ------------------------------------------------------------------------------
# Dynamic HA VPN Module Invocation
# ------------------------------------------------------------------------------

module "vpn_ha" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 7.0"

  for_each = var.ha_vpn_config.gateways

  project_id  = var.project_id
  region      = each.value.region
  network     = local.network_name
  name        = "vpn-${var.vpc_name}-${each.value.region}-${each.value.cr_suffix}"
  router_name = each.value.router

  peer_external_gateway = {
    redundancy_type = length(each.value.peer_external_gateway_interfaces) > 1 ? "TWO_IPS_REDUNDANT" : "SINGLE_IP_INTERNALLY_REDUNDANT"
    interfaces = [
      for idx, ip in each.value.peer_external_gateway_interfaces : {
        id         = idx
        ip_address = ip
      }
    ]
  }

  tunnels = {
    for tunnel_key, tunnel_val in each.value.tunnels : tunnel_key => {
      bgp_peer = {
        address = tunnel_val.bgp_peer_address
        asn     = tunnel_val.bgp_peer_asn
      }
      bgp_session_range = tunnel_val.bgp_session_range
      shared_secret     = data.google_secret_manager_secret_version.psk.secret_data
    }
  }
}

# ------------------------------------------------------------------------------
# Dynamic Network Connectivity Center (NCC) Spokes (One per Region)
# ------------------------------------------------------------------------------

resource "google_network_connectivity_spoke" "vpn_spoke" {
  for_each = local.tunnels_by_region

  name        = "vpn-spoke-${var.vpc_name}-${each.key}"
  project     = var.project_id
  location    = each.key
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing HA VPN tunnels for region ${each.key}"

  linked_vpn_tunnels {
    uris                       = each.value
    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}
