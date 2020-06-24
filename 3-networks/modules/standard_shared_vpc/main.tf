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
  Shared VPC configuration
 *****************************************/

locals {
  vpc_type       = "shared"
  vpc_label      = (var.vpc_label != "" ? var.vpc_label : "private")
  vpc_name       = "${var.environment_code}-${local.vpc_type}-${local.vpc_label}"
  network_name   = "vpc-${local.vpc_name}"
  subnets = [
    for subnet in var.subnets : {
      subnet_name           = "sb-${local.vpc_name}-${subnet.subnet_region}"
      subnet_ip             = subnet.subnet_ip
      subnet_region         = subnet.subnet_region
      subnet_private_access = subnet.subnet_private_access
      subnet_flow_logs      = subnet.subnet_flow_logs
      description           = subnet.description
    }
  ]

  temp_secondary_ranges = [
    for subnet in var.subnets : {
      sub_name =  "sb-${local.vpc_name}-${subnet.subnet_region}"
      ranges = [
        for range in subnet.secondary_ranges : {
          range_name    = "rn-${local.vpc_name}-${subnet.subnet_region}-${range.range_label}"
          ip_cidr_range = range.ip_cidr_range
        }
      ]
    }
  ]

  secondary_ranges = {
    for ranges in local.temp_secondary_ranges :
      ranges.sub_name => ranges.ranges
  }
}

module "main" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 2.0"
  project_id                             = var.project_id
  network_name                           = local.network_name
  shared_vpc_host                        = "true"
  delete_default_internet_gateway_routes = "true"

  subnets          = local.subnets
  secondary_ranges = local.secondary_ranges

  routes = [
    {
      name              = "rt-${local.vpc_name}-1000-egress-internet-default"
      description       = "Tag based route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-internet"
      next_hop_internet = "true"
      priority          = "1000"
    },
    {
      name              = "rt-${local.vpc_name}-1000-all-default-private-api"
      description       = "Route through IGW to allow private google api access."
      destination_range = "199.36.153.8/30"
      next_hop_internet = "true"
      priority          = "1000"
    },
    {
      name              = "rt-${local.vpc_name}-1000-all-default-windows-kms"
      description       = "Route through IGW to allow Windows KMS activation for GCP."
      destination_range = "35.190.247.13/32"
      next_hop_internet = "true"
      priority          = "1000"
    },
  ]
}

/***************************************************************
  Configure Service Networking for Cloud SQL & future services.
 **************************************************************/

resource "google_compute_global_address" "private_service_access_address" {
  provider = google-beta

  name          = "ga-${local.vpc_name}-vpc-peering-internal"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = element(split("/", var.private_service_cidr), 0)
  prefix_length = element(split("/", var.private_service_cidr), 1)
  network       = module.main.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = module.main.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_address.name]
}

/******************************************
  NAT Cloud Router & NAT config
 *****************************************/

resource "google_compute_router" "nat_router" {
  name    = "cr-${local.vpc_name}-${var.default_region}-nat-router"
  project = var.project_id
  region  = var.default_region
  network = module.main.network_self_link

  bgp {
    asn = var.bgp_asn[0]
  }
}

resource "google_compute_address" "nat_external_addresses" {
  count   = var.nat_num_addresses
  project = var.project_id
  name    = "ca-${local.vpc_name}-${var.default_region}-${count.index}"
  region  = var.default_region
}

resource "google_compute_router_nat" "default_nat" {
  name                               = "rn-${local.vpc_name}-${var.default_region}-default"
  project                            = var.project_id
  router                             = google_compute_router.nat_router.name
  region                             = var.default_region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_external_addresses.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}
