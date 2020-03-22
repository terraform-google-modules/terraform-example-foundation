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

locals {
    enable_apis = var.enable_networking ? ["dns.googleapis.com", "compute.googleapis.com"] : []
    dns_zone = "${var.application_name}.${var.environment}.${var.domain}."
}
/******************************************
  Private DNS Management
 *****************************************/
resource "google_compute_network" "ghost_dns_vpc" {
  count                           = var.enable_networking ? 1 : 0
  name                            = "dns-ghost-vpc"
  project                         = var.project_id
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  depends_on                      = [google_project_service.enable_apis]
}

resource "google_dns_managed_zone" "dns_producer_zone" {
  provider    = google-beta
  count       = var.enable_networking ? 1 : 0

  project     = var.project_id
  name        = "${var.application_name}-${var.environment}-producer-dns-zone"
  dns_name    = local.dns_zone
  description = "Terraform managed zone."
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.ghost_dns_vpc[0].self_link
    }
  }
  depends_on = [google_project_service.enable_apis]
}

resource "google_dns_managed_zone" "dns_consumer_zone" {
  count       = var.enable_networking ? 1 : 0
  provider    = google-beta
  project     = var.shared_vpc_project_id
  name        = "${var.application_name}-${var.environment}-consumer-dns-zone"
  dns_name    = local.dns_zone
  description = "Terraform managed zone."
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = var.shared_vpc_self_link
    }
  }
  peering_config {
    target_network {
      network_url = google_compute_network.ghost_dns_vpc[0].self_link
    }
  }
}

/******************************************
  Enable API
 *****************************************/
resource "google_project_service" "enable_apis" {
    for_each = toset(local.enable_apis)
    
    project            = var.project_id
    service            = each.value

    disable_on_destroy = false
}

