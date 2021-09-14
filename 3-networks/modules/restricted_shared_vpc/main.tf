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

locals {
  mode                       = var.mode == null ? "" : var.mode == "hub" ? "-hub" : "-spoke"
  vpc_name                   = "${var.environment_code}-shared-restricted${local.mode}"
  network_name               = "vpc-${local.vpc_name}"
  restricted_googleapis_cidr = "199.36.153.4/30"
}

/******************************************
  Restricted Network Hub
*****************************************/

data "google_projects" "restricted_net_hub" {
  count  = var.mode == "spoke" ? 1 : 0
  filter = "parent.id:${split("/", data.google_active_folder.common.name)[1]} labels.application_name=org-restricted-net-hub lifecycleState=ACTIVE"
}

data "google_compute_network" "vpc_restricted_net_hub" {
  count   = var.mode == "spoke" ? 1 : 0
  name    = "vpc-c-shared-restricted-hub"
  project = data.google_projects.restricted_net_hub[0].projects[0].project_id
}

/******************************************
  Shared VPC configuration
 *****************************************/

module "main" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 2.0"
  project_id                             = var.project_id
  network_name                           = local.network_name
  shared_vpc_host                        = "true"
  delete_default_internet_gateway_routes = "true"

  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges

  routes = concat(
    [{
      name              = "rt-${local.vpc_name}-1000-all-default-restricted-api"
      description       = "Route through IGW to allow restricted google api access."
      destination_range = local.restricted_googleapis_cidr
      next_hop_internet = "true"
      priority          = "1000"
    }],
    var.nat_enabled ?
    [
      {
        name              = "rt-${local.vpc_name}-1000-egress-internet-default"
        description       = "Tag based route through IGW to access internet"
        destination_range = "0.0.0.0/0"
        tags              = "egress-internet"
        next_hop_internet = "true"
        priority          = "1000"
      }
    ]
    : [],
    var.windows_activation_enabled ?
    [
      {
        name              = "rt-${local.vpc_name}-1000-all-default-windows-kms"
        description       = "Route through IGW to allow Windows KMS activation for GCP."
        destination_range = "35.190.247.13/32"
        next_hop_internet = "true"
        priority          = "1000"
      }
    ]
    : []
  )
}

/***************************************************************
  VPC Peering Configuration
 **************************************************************/

module "peering" {
  source                    = "terraform-google-modules/network/google//modules/network-peering"
  version                   = "~> 2.0"
  count                     = var.mode == "spoke" ? 1 : 0
  prefix                    = "np"
  local_network             = module.main.network_self_link
  peer_network              = data.google_compute_network.vpc_restricted_net_hub[0].self_link
  export_peer_custom_routes = true
}

/***************************************************************
  Configure Service Networking for Cloud SQL & future services.
 **************************************************************/

resource "google_compute_global_address" "private_service_access_address" {
  count         = var.private_service_cidr != null ? 1 : 0
  name          = "ga-${local.vpc_name}-vpc-peering-internal"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = element(split("/", var.private_service_cidr), 0)
  prefix_length = element(split("/", var.private_service_cidr), 1)
  network       = module.main.network_self_link

  depends_on = [module.peering]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count                   = var.private_service_cidr != null ? 1 : 0
  network                 = module.main.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_address[0].name]

  depends_on = [module.peering]
}

/************************************
  Router to advertise shared VPC
  subnetworks and Google Restricted API
************************************/

module "region1_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"
  count   = var.mode != "spoke" ? 1 : 0
  name    = "cr-${local.vpc_name}-${var.default_region1}-cr5"
  project = var.project_id
  network = module.main.network_name
  region  = var.default_region1
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}

module "region1_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"
  count   = var.mode != "spoke" ? 1 : 0
  name    = "cr-${local.vpc_name}-${var.default_region1}-cr6"
  project = var.project_id
  network = module.main.network_name
  region  = var.default_region1
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}

module "region2_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"
  count   = var.mode != "spoke" ? 1 : 0
  name    = "cr-${local.vpc_name}-${var.default_region2}-cr7"
  project = var.project_id
  network = module.main.network_name
  region  = var.default_region2
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}

module "region2_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"
  count   = var.mode != "spoke" ? 1 : 0
  name    = "cr-${local.vpc_name}-${var.default_region2}-cr8"
  project = var.project_id
  network = module.main.network_name
  region  = var.default_region2
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}
