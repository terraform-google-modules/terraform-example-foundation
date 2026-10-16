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
  attachments_by_region = {
    for k, v in var.partner_interconnect_config.attachments : v.region => [
      for att_key, att_val in google_compute_interconnect_attachment.partner_attachment : att_val.id
      if var.partner_interconnect_config.attachments[att_key].region == v.region
    ]...
  }
}

resource "google_compute_interconnect_attachment" "partner_attachment" {
  for_each = var.partner_interconnect_config.attachments

  name                     = "vl-${each.value.location}-${var.vpc_name}-${each.value.region}-${each.value.cr_suffix}"
  project                  = var.attachment_project_id
  region                   = each.value.region
  router                   = each.value.router
  type                     = "PARTNER"
  edge_availability_domain = each.value.edge_availability_domain
  admin_enabled            = var.partner_interconnect_config.preactivate
}

# Dynamic Network Connectivity Center (NCC) Spokes (One per Region)
resource "google_network_connectivity_spoke" "partner_ic_spoke" {
  for_each = local.attachments_by_region

  name        = "pic-spoke-${var.vpc_name}-${each.key}"
  project     = var.attachment_project_id
  location    = each.key
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing Partner Interconnects for region ${each.key}"

  linked_interconnect_attachments {
    uris                       = each.value
    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}
