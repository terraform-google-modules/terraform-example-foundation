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

module "partner_interconnect_attachments" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 9.0"

  for_each = var.partner_cross_cloud_config.attachments

  name    = "vl-${each.value.cross_dc}-${each.value.location}-${var.vpc_name}-${each.value.region}-${each.value.cr_suffix}"
  project = var.attachment_project_id
  region  = each.value.region
  router  = each.value.router

  type                     = "PARTNER"
  edge_availability_domain = each.value.edge_availability_domain
  admin_enabled            = each.value.preactivate
  create_interface         = false
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
    uris = [
      for k, v in module.partner_interconnect_attachments : v.attachment.id
      if var.partner_cross_cloud_config.attachments[k].region == var.region1
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
      for k, v in module.partner_interconnect_attachments : v.attachment.id
      if var.partner_cross_cloud_config.attachments[k].region == var.region2
    ]

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}
