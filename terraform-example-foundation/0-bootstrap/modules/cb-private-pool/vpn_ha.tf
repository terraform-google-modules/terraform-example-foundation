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


locals {
  psk_secret_data = var.vpn_configuration.enable_vpn ? chomp(data.google_secret_manager_secret_version.psk[0].secret_data) : ""
}

data "google_secret_manager_secret_version" "psk" {
  count = var.vpn_configuration.enable_vpn ? 1 : 0

  project = var.vpn_configuration.psk_secret_project_id
  secret  = var.vpn_configuration.psk_secret_name
}

module "vpn_ha_cb_to_onprem" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 2.3"
  count   = var.vpn_configuration.enable_vpn ? 1 : 0

  project_id = var.project_id
  region     = var.private_worker_pool.region
  network    = local.peered_network_id
  name       = "vpn-b-${var.private_worker_pool.region}-cb-on-prem"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = var.vpn_configuration.on_prem_public_ip_address0
      },
      {
        id         = 1
        ip_address = var.vpn_configuration.on_prem_public_ip_address1
    }]
  }
  router_asn = var.vpn_configuration.router_asn
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.vpn_configuration.tunnel0_bgp_peer_address
        asn     = var.vpn_configuration.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.vpn_configuration.tunnel0_bgp_session_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.psk_secret_data
    }
    remote-1 = {
      bgp_peer = {
        address = var.vpn_configuration.tunnel1_bgp_peer_address
        asn     = var.vpn_configuration.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.vpn_configuration.tunnel1_bgp_session_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.psk_secret_data
    }
  }
  router_advertise_config = {
    mode = "CUSTOM"
    ip_ranges = {
      (local.peered_ip_range) = "Peered private pool IP range."
    }
    groups = ["ALL_SUBNETS"]
  }
}
