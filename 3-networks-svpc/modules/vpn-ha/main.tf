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
  network_name    = "vpc-${var.vpc_name}"
  psk_secret_data = chomp(data.google_secret_manager_secret_version.psk.secret_data)
}

data "google_secret_manager_secret_version" "psk" {
  project = var.env_secret_project_id
  secret  = var.vpn_psk_secret_name
}

module "vpn_ha_region1_router1" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 7.0"

  project_id = var.project_id
  region     = var.default_region1
  network    = local.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region1}-cr1"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = var.on_prem_router_ip_address2
    }]
  }
  router_name = var.region1_router1_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.region1_router1_tunnel0_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region1_router1_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.psk_secret_data
    }
    remote-1 = {
      bgp_peer = {
        address = var.region1_router1_tunnel1_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region1_router1_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.psk_secret_data
    }
  }
}

module "vpn_ha_region1_router2" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 7.0"

  project_id = var.project_id
  region     = var.default_region1
  network    = local.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region1}-cr2"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = var.on_prem_router_ip_address2
    }]
  }
  router_name = var.region1_router2_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.region1_router2_tunnel0_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region1_router2_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.psk_secret_data
    }
    remote-1 = {
      bgp_peer = {
        address = var.region1_router2_tunnel1_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region1_router2_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.psk_secret_data
    }
  }
}

module "vpn_ha_region2_router1" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 7.0"

  project_id = var.project_id
  region     = var.default_region2
  network    = local.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region2}-cr1"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = var.on_prem_router_ip_address2
    }]
  }
  router_name = var.region2_router1_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.region2_router1_tunnel0_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region2_router1_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.psk_secret_data
    }
    remote-1 = {
      bgp_peer = {
        address = var.region2_router1_tunnel1_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region2_router1_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.psk_secret_data
    }
  }
}

module "vpn_ha_region2_router2" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 7.0"

  project_id = var.project_id
  region     = var.default_region2
  network    = local.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region2}-cr2"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = var.on_prem_router_ip_address2
    }]
  }
  router_name = var.region2_router2_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.region2_router2_tunnel0_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region2_router2_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.psk_secret_data
    }
    remote-1 = {
      bgp_peer = {
        address = var.region2_router2_tunnel1_bgp_peer_address
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.region2_router2_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.psk_secret_data
    }
  }
}

# ---------------------------------------------------------
# NCC Spoke for Region 1
# ---------------------------------------------------------
resource "google_network_connectivity_spoke" "region1_vpn_spoke" {
  name        = "vpn-spoke-${var.vpc_name}-${var.default_region1}"
  project     = var.project_id
  location    = var.default_region1
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing HA VPNs for region 1"

  linked_vpn_tunnels {
    # Combine the tunnel URIs from both VPN modules in Region 1
    uris = concat(
      module.vpn_ha_region1_router1.tunnel_self_links,
      module.vpn_ha_region1_router2.tunnel_self_links
    )

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}

# ---------------------------------------------------------
# NCC Spoke for Region 2
# ---------------------------------------------------------
resource "google_network_connectivity_spoke" "region2_vpn_spoke" {
  name        = "vpn-spoke-${var.vpc_name}-${var.default_region2}"
  project     = var.project_id
  location    = var.default_region2
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing HA VPNs for region 2"
  linked_vpn_tunnels {
    uris = concat(
      module.vpn_ha_region2_router1.tunnel_self_links,
      module.vpn_ha_region2_router2.tunnel_self_links
    )

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}
