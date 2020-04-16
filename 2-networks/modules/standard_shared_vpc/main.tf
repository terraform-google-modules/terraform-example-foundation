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

module "main" {
  source          = "terraform-google-modules/network/google"
  version         = "~> 2.0"
  project_id      = var.project_id
  network_name    = var.network_name
  shared_vpc_host = "true"

  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges

  routes = [
    {
      name              = "gcp-windows-activation"
      description       = "Route through IGW to allow Windows kms activation."
      destination_range = "35.190.247.13/32"
      next_hop_internet = "true"
    },
  ]
}

/******************************************
  Default DNS Policy
 *****************************************/

resource "google_dns_policy" "default_policy" {
  provider                  = google-beta
  project                   = var.project_id
  name                      = "default-policy"
  enable_inbound_forwarding = true
  enable_logging            = true
  networks {
    network_url = module.main.network_self_link
  }
}


/***************************************************************
  Configure Service Networking for Cloud SQL & future services.
 **************************************************************/

resource "google_compute_global_address" "private_service_access_address" {
  provider = google-beta

  name          = "private-service-access-address"
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
  Default Cloud Router & NAT config
 *****************************************/

resource "google_compute_router" "default_router" {
  name    = "default-router"
  project = var.project_id
  region  = var.default_region
  network = module.main.network_self_link

  bgp {
    asn = var.bgp_asn
  }
}

resource "google_compute_address" "nat_external_addresses" {
  count   = 2
  project = var.project_id
  name    = "nat-external-address-${count.index}"
  region  = var.default_region
}

resource "google_compute_router_nat" "default_nat" {
  name                               = "nat-config"
  project                            = var.project_id
  router                             = google_compute_router.default_router.name
  region                             = var.default_region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_external_addresses.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}

/******************************************
  Default firewall rules
 *****************************************/


// Allow SSH when using the allow-ssh tag for Linux workloads.
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = module.main.network_name
  project = var.project_id

  // Cloud IAP's TCP forwarding netblock
  source_ranges = concat(data.google_netblock_ip_ranges.iap_forwarders.cidr_blocks_ipv4)

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["allow-ssh"]
}

// Allow RDP when using the allow-rdp tag for Windows workloads.
resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"
  network = module.main.network_name
  project = var.project_id

  // Cloud IAP's TCP forwarding netblock
  source_ranges = concat(data.google_netblock_ip_ranges.iap_forwarders.cidr_blocks_ipv4)

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  target_tags = ["allow-rdp"]
}

// Allow traffic for Internal & Global load balancing health check and load balancing IP ranges.
resource "google_compute_firewall" "allow_lb" {
  name    = "lb-healthcheck"
  network = module.main.network_name
  project = var.project_id

  source_ranges = concat(data.google_netblock_ip_ranges.health_checkers.cidr_blocks_ipv4, data.google_netblock_ip_ranges.legacy_health_checkers.cidr_blocks_ipv4)

  // Allow common app ports by default.
  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  target_tags = ["allow-lb"]
}
