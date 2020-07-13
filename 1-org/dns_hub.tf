/**
 * Copyright 2020 Google LLC
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
  DNS Hub VPC
*****************************************/

module "dns_hub_vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 2.0"
  project_id                             = module.dns_hub.project_id
  network_name                           = "vpc-dns-hub"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "true"

  subnets = [{
    subnet_name           = "sb-dns-hub-${var.dns_default_region1}"
    subnet_ip             = "172.16.0.0/25"
    subnet_region         = var.dns_default_region1
    subnet_private_access = "true"
    subnet_flow_logs      = "false"
    description           = "DNS hub subnet for region 1."
    }, {
    subnet_name           = "sb-dns-hub-${var.dns_default_region2}"
    subnet_ip             = "172.16.0.128/25"
    subnet_region         = var.dns_default_region2
    subnet_private_access = "true"
    subnet_flow_logs      = "false"
    description           = "DNS hub subnet for region 2."
  }]

  routes = [{
    name              = "rt-dns-hub-1000-all-default-private-api"
    description       = "Route through IGW to allow private google api access."
    destination_range = "199.36.153.8/30"
    next_hop_internet = "true"
    priority          = "1000"
  }]
}

/******************************************
  Default DNS Policy
 *****************************************/

resource "google_dns_policy" "default_policy" {
  project                   = module.dns_hub.project_id
  name                      = "dp-dns-hub-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = var.dns_enable_logging
  networks {
    network_url = module.dns_hub_vpc.network_self_link
  }
}

/******************************************
 DNS Forwarding
*****************************************/

module "dns-forwarding-zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "3.0.2"

  project_id = module.dns_hub.project_id
  type       = "forwarding"
  name       = "fz-dns-hub"
  domain     = var.domain

  private_visibility_config_networks = [
    module.dns_hub_vpc.network_self_link
  ]
  target_name_server_addresses = var.target_name_server_addresses
}

/*********************************************************
  Routers to advertise DNS proxy range "35.199.192.0/19"
*********************************************************/

module "dns_hub_region1_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-dns-hub-${var.dns_default_region1}-cr1"
  project = module.dns_hub.project_id
  network = module.dns_hub_vpc.network_name
  region  = var.dns_default_region1
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region1_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-dns-hub-${var.dns_default_region1}-cr2"
  project = module.dns_hub.project_id
  network = module.dns_hub_vpc.network_name
  region  = var.dns_default_region1
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region2_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-dns-hub-${var.dns_default_region2}-cr3"
  project = module.dns_hub.project_id
  network = module.dns_hub_vpc.network_name
  region  = var.dns_default_region2
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region2_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-dns-hub-${var.dns_default_region2}-cr4"
  project = module.dns_hub.project_id
  network = module.dns_hub_vpc.network_name
  region  = var.dns_default_region2
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}


/******************************************
 Dedicated Interconnect
*****************************************/

# uncommnet if you have done the requirement steps listed in ../3-networks/modules/dedicated_interconnect/README.md
# update the interconnect, interconnect locations, and peer fields in the locals with actual values before running the script.

# locals {
#   peer_asn        = "64515"
#   peer_ip_address = "8.8.8.8" # on-prem router ip address
#   peer_name       = "interconnect-peer"

#   region1_interconnect1_location = "las-zone1-770"
#   region1_interconnect1          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-1"

#   region1_interconnect2_location = "las-zone1-770"
#   region1_interconnect2          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-2"

#   region2_interconnect1_location = "lax-zone2-19"
#   region2_interconnect1          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-3"

#   region2_interconnect2_location = "lax-zone1-403"
#   region2_interconnect2          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-4"
# }

# module "interconnect_attachment1_region1" {
#   source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
#   version = "~> 0.2.0"

#   name    = "vl-${local.region1_interconnect1_location}-dns-hub-${var.dns_default_region1}-cr1"
#   project = module.interconnect.project_id
#   region  = var.dns_default_region1
#   router  = module.dns_hub_region1_router1.router.name

#   interconnect = local.region1_interconnect1

#   interface = {
#     name = "if-${local.region1_interconnect1_location}-dns-hub-${var.dns_default_region1}"
#   }

#   peer = {
#     name            = local.peer_name
#     peer_ip_address = local.peer_ip_address
#     peer_asn        = local.peer_asn
#   }
# }

# module "interconnect_attachment2_region1" {
#   source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
#   version = "~> 0.2.0"

#   name    = "vl-${local.region1_interconnect2_location}-dns-hub-${var.dns_default_region1}-cr2"
#   project = module.interconnect.project_id
#   region  = var.dns_default_region1
#   router  = module.dns_hub_region1_router2.router.name

#   interconnect = local.region1_interconnect2

#   interface = {
#     name = "if-${local.region1_interconnect2_location}-dns-hub-${var.dns_default_region1}"
#   }

#   peer = {
#     name            = local.peer_name
#     peer_ip_address = local.peer_ip_address
#     peer_asn        = local.peer_asn
#   }
# }

# module "interconnect_attachment1_region2" {
#   source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
#   version = "~> 0.2.0"

#   name    = "vl-${local.region2_interconnect1_location}-dns-hub-${var.dns_default_region2}-cr3"
#   project = module.interconnect.project_id
#   region  = var.dns_default_region2
#   router  = module.dns_hub_region2_router1.router.name

#   interconnect = local.region2_interconnect1

#   interface = {
#     name = "if-${local.region2_interconnect1_location}-dns-hub-${var.dns_default_region2}"
#   }

#   peer = {
#     name            = local.peer_name
#     peer_ip_address = local.peer_ip_address
#     peer_asn        = local.peer_asn
#   }
# }

# module "interconnect_attachment2_region2" {
#   source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
#   version = "~> 0.2.0"

#   name    = "vl-${local.region2_interconnect2_location}-dns-hub-${var.dns_default_region2}-cr4"
#   project = module.interconnect.project_id
#   region  = var.dns_default_region2
#   router  = module.dns_hub_region2_router2.router.name

#   interconnect = local.region2_interconnect2

#   interface = {
#     name = "if-${local.region2_interconnect2_location}-dns-hub-${var.dns_default_region2}"
#   }

#   peer = {
#     name            = local.peer_name
#     peer_ip_address = local.peer_ip_address
#     peer_asn        = local.peer_asn
#   }
# }



/******************************************
 HA VPN (optional)
*****************************************/
# update the on_prem_router_ip_addresses, bgp_peer_asn and bgp_peer_secret in the locals 
# with actual values before running the script.

locals {
  on_prem_router_ip_address1 = "8.8.8.8" # on-prem router ip address
  on_prem_router_ip_address2 = "8.8.8.8" # on-prem router ip address

  bgp_peer_asn    = "64515"
  bgp_peer_secret = "<my-secret-value>"

  region1_router1_tunnel0_bgp_peer_address = "169.254.1.1"
  region1_router1_tunnel0_bgp_peer_range   = "169.254.1.2/30"

  region1_router1_tunnel1_bgp_peer_address = "169.254.2.1"
  region1_router1_tunnel1_bgp_peer_range   = "169.254.2.2/30"

  region1_router2_tunnel0_bgp_peer_address = "169.254.4.1"
  region1_router2_tunnel0_bgp_peer_range   = "169.254.4.2/30"

  region1_router2_tunnel1_bgp_peer_address = "169.254.6.1"
  region1_router2_tunnel1_bgp_peer_range   = "169.254.6.2/30"

  region2_router1_tunnel0_bgp_peer_address = "169.254.8.1"
  region2_router1_tunnel0_bgp_peer_range   = "169.254.8.2/30"

  region2_router1_tunnel1_bgp_peer_address = "169.254.10.1"
  region2_router1_tunnel1_bgp_peer_range   = "169.254.10.2/30"

  region2_router2_tunnel0_bgp_peer_address = "169.254.12.1"
  region2_router2_tunnel0_bgp_peer_range   = "169.254.12.2/30"

  region2_router2_tunnel1_bgp_peer_address = "169.254.14.1"
  region2_router2_tunnel1_bgp_peer_range   = "169.254.14.2/30"
}

module "vpn_ha_region1_router1" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = module.dns_hub.project_id
  region     = var.dns_default_region1
  network    = module.dns_hub_vpc.network_name
  name       = "vpn-dns-hub-${var.dns_default_region1}-cr1"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [
      {
        id         = 0
        ip_address = local.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = local.on_prem_router_ip_address2
    }]
  }
  router_name = module.dns_hub_region1_router1.router.name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = local.region1_router1_tunnel0_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region1_router1_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = local.region1_router1_tunnel1_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region1_router1_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.bgp_peer_secret
    }
  }
}

module "vpn_ha_region1_router2" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = module.dns_hub.project_id
  region     = var.dns_default_region1
  network    = module.dns_hub_vpc.network_name
  name       = "vpn-dns-hub-${var.dns_default_region1}-cr2"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [
      {
        id         = 0
        ip_address = local.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = local.on_prem_router_ip_address2
    }]
  }
  router_name = module.dns_hub_region1_router2.router.name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = local.region1_router2_tunnel0_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region1_router2_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = local.region1_router2_tunnel1_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region1_router2_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.bgp_peer_secret
    }
  }
}

module "vpn_ha_region2_router1" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = module.dns_hub.project_id
  region     = var.dns_default_region2
  network    = module.dns_hub_vpc.network_name
  name       = "vpn-dns-hub-${var.dns_default_region2}-cr3"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [
      {
        id         = 0
        ip_address = local.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = local.on_prem_router_ip_address2
    }]
  }
  router_name = module.dns_hub_region2_router1.router.name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = local.region2_router1_tunnel0_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region2_router1_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = local.region2_router1_tunnel1_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region2_router1_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.bgp_peer_secret
    }
  }
}

module "vpn_ha_region2_router2" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = module.dns_hub.project_id
  region     = var.dns_default_region2
  network    = module.dns_hub_vpc.network_name
  name       = "vpn-dns-hub-${var.dns_default_region2}-cr4"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [
      {
        id         = 0
        ip_address = local.on_prem_router_ip_address1
      },
      {
        id         = 1
        ip_address = local.on_prem_router_ip_address2
    }]
  }
  router_name = module.dns_hub_region2_router2.router.name
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = local.region2_router2_tunnel0_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region2_router2_tunnel0_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.bgp_peer_secret
    }
    remote-1 = {
      bgp_peer = {
        address = local.region2_router2_tunnel1_bgp_peer_address
        asn     = local.bgp_peer_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = local.region2_router2_tunnel1_bgp_peer_range
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.bgp_peer_secret
    }
  }
}
