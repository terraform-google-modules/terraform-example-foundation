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
  DNS Hub VPC
*****************************************/

module "dns_hub_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id                             = local.dns_hub_project_id
  network_name                           = "vpc-net-dns"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "true"

  subnets = [{
    subnet_name                      = "sb-net-dns-${local.default_region1}"
    subnet_ip                        = "172.16.0.0/25"
    subnet_region                    = local.default_region1
    subnet_private_access            = "true"
    subnet_flow_logs                 = var.vpc_flow_logs.enable_logging
    subnet_flow_logs_interval        = var.vpc_flow_logs.aggregation_interval
    subnet_flow_logs_sampling        = var.vpc_flow_logs.flow_sampling
    subnet_flow_logs_metadata        = var.vpc_flow_logs.metadata
    subnet_flow_logs_metadata_fields = var.vpc_flow_logs.metadata_fields
    subnet_flow_logs_filter          = var.vpc_flow_logs.filter_expr
    description                      = "DNS hub subnet for region 1."
    }, {
    subnet_name                      = "sb-net-dns-${local.default_region2}"
    subnet_ip                        = "172.16.0.128/25"
    subnet_region                    = local.default_region2
    subnet_private_access            = "true"
    subnet_flow_logs                 = var.vpc_flow_logs.enable_logging
    subnet_flow_logs_interval        = var.vpc_flow_logs.aggregation_interval
    subnet_flow_logs_sampling        = var.vpc_flow_logs.flow_sampling
    subnet_flow_logs_metadata        = var.vpc_flow_logs.metadata
    subnet_flow_logs_metadata_fields = var.vpc_flow_logs.metadata_fields
    subnet_flow_logs_filter          = var.vpc_flow_logs.filter_expr
    description                      = "DNS hub subnet for region 2."
  }]

  routes = [{
    name              = "rt-net-dns-1000-all-default-private-api"
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
  project                   = local.dns_hub_project_id
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
  version = "~> 5.0"

  project_id = local.dns_hub_project_id
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
  version = "~> 6.0"

  name    = "cr-net-dns-${local.default_region1}-cr1"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = local.default_region1
  bgp = {
    asn                  = local.dns_bgp_asn_number
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region1_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"

  name    = "cr-net-dns-${local.default_region1}-cr2"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = local.default_region1
  bgp = {
    asn                  = local.dns_bgp_asn_number
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region2_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"

  name    = "cr-net-dns-${local.default_region2}-cr3"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = local.default_region2
  bgp = {
    asn                  = local.dns_bgp_asn_number
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region2_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"

  name    = "cr-net-dns-${local.default_region2}-cr4"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = local.default_region2
  bgp = {
    asn                  = local.dns_bgp_asn_number
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}
