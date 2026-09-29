/**
 * Copyright 2026 Google LLC
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
  input_regions = var.nat_config.regions != null ? var.nat_config.regions : []
  nat_regions   = { for r in local.input_regions : r.name => r }
  nat_ips_flat_list = flatten([
    for r in local.input_regions : [
      for i in range(r.num_addresses) : {
        region_name = r.name
        idx         = i
        key         = "${r.name}-${i}"
      }
    ]
  ])
  nat_ips_map = {
    for item in local.nat_ips_flat_list : item.key => {
      name  = item.region_name
      index = item.idx
    }
  }
}

resource "google_compute_address" "nat_external_addresses" {
  for_each = local.nat_ips_map

  project = var.project_id
  name    = "ca-${var.resource_code}-${var.vpc_name}-${each.value.name}-${each.value.index}"
  region  = each.value.name
}

module "cloud_router" {
  source   = "terraform-google-modules/cloud-router/google"
  version  = "~> 9.0"
  for_each = local.nat_regions

  name       = "cr-${var.resource_code}-${var.vpc_name}-${each.key}-nat-router"
  project_id = var.project_id
  region     = each.key
  network    = var.network_self_link

  bgp = {
    asn = var.nat_config.bgp_asn
  }

  nats = [
    {
      name                               = "rn-${var.resource_code}-${var.vpc_name}-${each.key}-egress"
      nat_ip_allocate_option             = "MANUAL_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

      nat_ips = [
        for addr in google_compute_address.nat_external_addresses :
        addr.self_link
        if addr.region == each.key
      ]

      log_config = {
        enable = true
        filter = "TRANSLATIONS_ONLY"
      }
    }
  ]
}
