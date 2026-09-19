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

module "interconnect_attachments" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 9.0"

  for_each = var.cross_cloud_config.attachments

  name    = "vl-${each.value.cross_dc}-${each.value.location}-${var.vpc_name}-${each.value.region}-${each.value.cr_suffix}"
  project = var.interconnect_project_id
  region  = each.value.region
  router  = each.value.router

  interconnect      = each.value.interconnect
  candidate_subnets = lookup(each.value, "candidate_subnets", null)
  vlan_tag8021q     = lookup(each.value, "vlan_tag8021q", null)

  interface = {
    name = "if-${each.value.location}-${var.vpc_name}-${each.value.region}-${each.value.cr_suffix}"
  }

  peer = {
    name     = lookup(each.value, "peer_name", var.cross_cloud_config.peer_name)
    peer_asn = lookup(each.value, "peer_asn", var.cross_cloud_config.peer_asn)

    # Automatically set if md5_key is present
    md5_authentication_key = lookup(each.value, "md5_key", null) != null ? {
      name = "bgp-md5-${each.key}"
      key  = each.value.md5_key
    } : null
  }
}

# ---------------------------------------------------------
# NCC Spoke for Interconnects - Region 1
# ---------------------------------------------------------
resource "google_network_connectivity_spoke" "region1_interconnect_spoke" {
  name        = "ic-spoke-${var.vpc_name}-${var.region1}"
  project     = var.interconnect_project_id
  location    = var.region1
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing Cross Dedicated Interconnects for region 1"

  linked_interconnect_attachments {
    uris = [
      for k, v in module.interconnect_attachments : v.attachment.id
      if var.cross_cloud_config.attachments[k].region == var.region1
    ]

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}

# ---------------------------------------------------------
# NCC Spoke for Interconnects - Region 2
# ---------------------------------------------------------
resource "google_network_connectivity_spoke" "region2_interconnect_spoke" {
  name        = "ic-spoke-${var.vpc_name}-${var.region2}"
  project     = var.interconnect_project_id
  location    = var.region2
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing Cross Dedicated Interconnects for region 2"

  linked_interconnect_attachments {
    uris = [
      for k, v in module.interconnect_attachments : v.attachment.id
      if var.cross_cloud_config.attachments[k].region == var.region2
    ]

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}
