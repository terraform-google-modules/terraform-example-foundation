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
  vpc_name     = "${var.environment_code}-shared-${var.vpc_label}"
  network_name = "vpc-${local.vpc_name}"
}


module "vpn_ha_region1_router1" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = var.project_id
  region     = var.default_region1
  network    = local.network_name
  name       = "vpn-${local.vpc_name}-${var.default_region1}-cr1"
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
  router_name = "cr-${local.vpc_name}-${var.default_region1}-cr1"
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.bgp_peer_address0
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range0
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.bgp_peer_address1
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range1
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = var.bgp_peer_secret
    }
  }
}

module "vpn_ha_region1_router2" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = var.project_id
  region     = var.default_region1
  network    = local.network_name
  name       = "vpn-${local.vpc_name}-${var.default_region1}-cr2"
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
  router_name = "cr-${local.vpc_name}-${var.default_region1}-cr2"
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.bgp_peer_address2
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range2
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.bgp_peer_address3
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range3
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = var.bgp_peer_secret
    }
  }
}

module "vpn_ha_region2_router1" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = var.project_id
  region     = var.default_region2
  network    = local.network_name
  name       = "vpn-${local.vpc_name}-${var.default_region2}-cr1"
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
  router_name = "cr-${local.vpc_name}-${var.default_region2}-cr1"
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.bgp_peer_address4
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range4
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.bgp_peer_address5
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range5
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = var.bgp_peer_secret
    }
  }
}

module "vpn_ha_region2_router2" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = var.project_id
  region     = var.default_region2
  network    = local.network_name
  name       = "vpn-${local.vpc_name}-${var.default_region2}-cr2"
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
  router_name = "cr-${local.vpc_name}-${var.default_region2}-cr2"
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.bgp_peer_address6
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range6
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = var.bgp_peer_address7
        asn     = var.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.bgp_peer_range7
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = var.bgp_peer_secret
    }
  }
}
