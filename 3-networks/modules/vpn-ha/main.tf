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

/******************************************
  AH VPN configuration
 *****************************************/

locals {
  interconnect_project_id = data.google_projects.interconnect_project.projects[0].project_id
}

data "google_projects" "interconnect_project" {
  filter = "labels.application_name=prj-interconnect"
}

module "vpn_ha_region1_router1" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = local.interconnect_project_id
  region     = var.default_region1
  network    = var.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region1}-cr1"
  peer_external_gateway = {
    redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_ip_address

    }]
  }
  router_name = var.region1_router1_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.remote0_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote0_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote0_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.remote1_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote1_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote1_secret
    }
  }
}

module "vpn_ha_region1_router2" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = local.interconnect_project_id
  region     = var.default_region1
  network    = var.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region1}-cr2"
  peer_external_gateway = {
    redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_ip_address

    }]
  }
  router_name = var.region1_router2_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.remote0_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote0_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote0_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.remote1_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote1_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote1_secret
    }
  }
}

module "vpn_ha_region2_router1" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = local.interconnect_project_id
  region     = var.default_region2
  network    = var.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region2}-cr1"
  peer_external_gateway = {
    redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_ip_address

    }]
  }
  router_name = var.region2_router1_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.remote0_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote0_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote0_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.remote1_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote1_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote1_secret
    }
  }
}

module "vpn_ha_region2_router2" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = local.interconnect_project_id
  region     = var.default_region2
  network    = var.network_name
  name       = "vpn-${var.vpc_name}-${var.default_region2}-cr2"
  peer_external_gateway = {
    redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
    interfaces = [{
      id         = 0
      ip_address = var.on_prem_ip_address

    }]
  }
  router_name = var.region2_router2_name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.remote0_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote0_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote0_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.remote1_ip
        asn     = var.bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.remote1_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 0
      shared_secret                   = var.remote1_secret
    }
  }
}
