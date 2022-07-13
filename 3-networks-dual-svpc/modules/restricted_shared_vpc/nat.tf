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
  NAT Cloud Router & NAT config
 *****************************************/

resource "google_compute_router" "nat_router_region1" {
  count   = var.nat_enabled ? 1 : 0
  name    = "cr-${local.vpc_name}-${var.default_region1}-nat-router"
  project = var.project_id
  region  = var.default_region1
  network = module.main.network_self_link

  bgp {
    asn = var.nat_bgp_asn
  }
}

resource "google_compute_address" "nat_external_addresses1" {
  count   = var.nat_enabled ? var.nat_num_addresses_region1 : 0
  project = var.project_id
  name    = "ca-${local.vpc_name}-${var.default_region1}-${count.index}"
  region  = var.default_region1
}

resource "google_compute_router_nat" "nat_external_addresses_region1" {
  count                              = var.nat_enabled ? 1 : 0
  name                               = "rn-${local.vpc_name}-${var.default_region1}-egress"
  project                            = var.project_id
  router                             = google_compute_router.nat_router_region1.0.name
  region                             = var.default_region1
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_external_addresses1.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}

resource "google_compute_router" "nat_router_region2" {
  count   = var.nat_enabled ? 1 : 0
  name    = "cr-${local.vpc_name}-${var.default_region2}-nat-router"
  project = var.project_id
  region  = var.default_region2
  network = module.main.network_self_link

  bgp {
    asn = var.nat_bgp_asn
  }
}

resource "google_compute_address" "nat_external_addresses_region2" {
  count   = var.nat_enabled ? var.nat_num_addresses_region2 : 0
  project = var.project_id
  name    = "ca-${local.vpc_name}-${var.default_region2}-${count.index}"
  region  = var.default_region2
}

resource "google_compute_router_nat" "egress_nat_region2" {
  count                              = var.nat_enabled ? 1 : 0
  name                               = "rn-${local.vpc_name}-${var.default_region2}-egress"
  project                            = var.project_id
  router                             = google_compute_router.nat_router_region2.0.name
  region                             = var.default_region2
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_external_addresses_region2.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}
