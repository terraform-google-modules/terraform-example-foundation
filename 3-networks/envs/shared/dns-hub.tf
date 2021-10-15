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
  dns_hub_project_id = data.google_projects.dns_hub.projects[0].project_id
}

data "google_active_folder" "bootstrap" {
  display_name = "${var.folder_prefix}-bootstrap"
  parent       = local.parent_id
}

data "google_active_folder" "development" {
  display_name = "${var.folder_prefix}-development"
  parent       = local.parent_id
}

data "google_active_folder" "production" {
  display_name = "${var.folder_prefix}-production"
  parent       = local.parent_id
}

data "google_active_folder" "non-production" {
  display_name = "${var.folder_prefix}-non-production"
  parent       = local.parent_id
}

/******************************************
  DNS Hub Project
*****************************************/

data "google_projects" "dns_hub" {
  filter = "parent.id:${split("/", data.google_active_folder.common.name)[1]} labels.application_name=org-dns-hub lifecycleState=ACTIVE"
}


/******************************************
  DNS Hub VPC
*****************************************/

module "dns_hub_vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 2.0"
  project_id                             = local.dns_hub_project_id
  network_name                           = "vpc-c-dns-hub"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "true"

  subnets = [{
    subnet_name           = "sb-c-dns-hub-${var.default_region1}"
    subnet_ip             = "172.16.0.0/25"
    subnet_region         = var.default_region1
    subnet_private_access = "true"
    subnet_flow_logs      = var.subnetworks_enable_logging
    description           = "DNS hub subnet for region 1."
    }, {
    subnet_name           = "sb-c-dns-hub-${var.default_region2}"
    subnet_ip             = "172.16.0.128/25"
    subnet_region         = var.default_region2
    subnet_private_access = "true"
    subnet_flow_logs      = var.subnetworks_enable_logging
    description           = "DNS hub subnet for region 2."
  }]

  routes = [{
    name              = "rt-c-dns-hub-1000-all-default-private-api"
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
  version = "3.0.2"

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
  version = "~> 0.4.0"
  name    = "cr-c-dns-hub-${var.default_region1}-cr1"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = var.default_region1
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region1_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"
  name    = "cr-c-dns-hub-${var.default_region1}-cr2"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = var.default_region1
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region2_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"
  name    = "cr-c-dns-hub-${var.default_region2}-cr3"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = var.default_region2
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}

module "dns_hub_region2_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"
  name    = "cr-c-dns-hub-${var.default_region2}-cr4"
  project = local.dns_hub_project_id
  network = module.dns_hub_vpc.network_name
  region  = var.default_region2
  bgp = {
    asn                  = var.bgp_asn_dns
    advertised_ip_ranges = [{ range = "35.199.192.0/19" }]
  }
}
