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

module "vpn_ha_agent_to_onprem" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 4.0"

  project_id = module.cicd_project.project_id
  region     = var.default_region
  network    = google_compute_network.jenkins_agents.name
  name       = "vpn-b-${var.default_region}-cr1"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_vpn_public_ip_address
      },
      {
        id         = 1
        ip_address = var.on_prem_vpn_public_ip_address2
    }]
  }
  router_asn = var.router_asn
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.tunnel0_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.tunnel0_bgp_session_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.vpn_shared_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.tunnel1_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.tunnel1_bgp_session_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = var.vpn_shared_secret
    }
  }
}
