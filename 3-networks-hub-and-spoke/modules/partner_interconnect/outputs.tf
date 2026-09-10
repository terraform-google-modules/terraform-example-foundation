/**
 * Copyright 2022 Google LLC
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

output "interconnect_attachment1_region1" {
  value       = google_compute_interconnect_attachment.interconnect_attachment1_region1
  description = "The interconnect attachment 1 for region 1"
}

output "interconnect_attachment1_region1_customer_router_ip_address" {
  value       = google_compute_interconnect_attachment.interconnect_attachment1_region1.customer_router_ip_address
  description = "IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment."
}

output "interconnect_attachment2_region1" {
  value       = google_compute_interconnect_attachment.interconnect_attachment2_region1
  description = "The interconnect attachment 2 for region 1"
}

output "interconnect_attachment2_region1_customer_router_ip_address" {
  value       = google_compute_interconnect_attachment.interconnect_attachment2_region1.customer_router_ip_address
  description = "IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment."
}

output "interconnect_attachment1_region2" {
  value       = google_compute_interconnect_attachment.interconnect_attachment1_region2
  description = "The interconnect attachment 1 for region 2"
}

output "interconnect_attachment1_region2_customer_router_ip_address" {
  value       = google_compute_interconnect_attachment.interconnect_attachment1_region2.customer_router_ip_address
  description = "IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment."
}

output "interconnect_attachment2_region2" {
  value       = google_compute_interconnect_attachment.interconnect_attachment2_region2
  description = "The interconnect attachment 2 for region 2"
}

output "interconnect_attachment2_region2_customer_router_ip_address" {
  value       = google_compute_interconnect_attachment.interconnect_attachment2_region2.customer_router_ip_address
  description = "IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment."
}

# ---------------------------------------------------------
# NCC Spoke for Partner Interconnects - Region 1
# ---------------------------------------------------------
resource "google_network_connectivity_spoke" "region1_partner_ic_spoke" {
  name        = "pic-spoke-${var.vpc_name}-${var.region1}"
  project     = var.attachment_project_id
  location    = var.region1
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing Partner Interconnects for region 1"

  linked_interconnect_attachments {
    # Reference the IDs natively from the google_compute_interconnect_attachment resources
    uris = [
      google_compute_interconnect_attachment.interconnect_attachment1_region1.id,
      google_compute_interconnect_attachment.interconnect_attachment2_region1.id
    ]

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}

# ---------------------------------------------------------
# NCC Spoke for Partner Interconnects - Region 2
# ---------------------------------------------------------
resource "google_network_connectivity_spoke" "region2_partner_ic_spoke" {
  name        = "pic-spoke-${var.vpc_name}-${var.region2}"
  project     = var.attachment_project_id
  location    = var.region2
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing Partner Interconnects for region 2"

  linked_interconnect_attachments {
    uris = [
      google_compute_interconnect_attachment.interconnect_attachment1_region2.id,
      google_compute_interconnect_attachment.interconnect_attachment2_region2.id
    ]

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}
