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

# Dynamic Local Grouping of Attachments by Region for NCC Spokes
locals {
  attachments_by_region = {
    for k, v in var.dedicated_interconnect_config.attachments : v.region => [
      for mod_key, mod_val in module.interconnect_attachments : mod_val.attachment.id
      if var.dedicated_interconnect_config.attachments[mod_key].region == v.region
    ]...
  }
}

module "interconnect_attachments" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 9.0"

  for_each = var.dedicated_interconnect_config.attachments

  name    = "vl-${each.value.onprem_dc}-${each.value.location}-${var.vpc_name}-${each.value.region}-${each.value.cr_suffix}"
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
    name     = var.dedicated_interconnect_config.peer_name
    peer_asn = var.dedicated_interconnect_config.peer_asn
  }
}


# Dynamic Network Connectivity Center (NCC) Spokes (One per Region)
resource "google_network_connectivity_spoke" "interconnect_spoke" {
  for_each = local.attachments_by_region

  name        = "ic-spoke-${var.vpc_name}-${each.key}"
  project     = var.interconnect_project_id
  location    = each.key
  hub         = var.ncc_hub_uri
  group       = var.ncc_hub_group
  description = "NCC Spoke containing Dedicated Interconnects for region ${each.key}"

  linked_interconnect_attachments {
    uris                       = each.value
    site_to_site_data_transfer = var.enable_site_to_site_data_transfer
  }
}
