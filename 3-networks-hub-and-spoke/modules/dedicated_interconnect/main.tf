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

module "interconnect_attachment1_region1" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 9.0"

  name    = "vl-${var.region1_interconnect1_onprem_dc}-${var.region1_interconnect1_location}-${var.vpc_name}-${var.region1}-cr5"
  project = var.interconnect_project_id
  region  = var.region1
  router  = var.region1_router1_name

  interconnect      = var.region1_interconnect1
  candidate_subnets = var.region1_interconnect1_candidate_subnets
  vlan_tag8021q     = var.region1_interconnect1_vlan_tag8021q

  interface = {
    name = "if-${var.region1_interconnect1_location}-${var.vpc_name}-${var.region1}-cr5"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
  }
}

module "interconnect_attachment2_region1" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 9.0"

  name    = "vl-${var.region1_interconnect2_onprem_dc}-${var.region1_interconnect2_location}-${var.vpc_name}-${var.region1}-cr6"
  project = var.interconnect_project_id
  region  = var.region1
  router  = var.region1_router2_name

  interconnect      = var.region1_interconnect2
  candidate_subnets = var.region1_interconnect2_candidate_subnets
  vlan_tag8021q     = var.region1_interconnect2_vlan_tag8021q

  interface = {
    name = "if-${var.region1_interconnect2_location}-${var.vpc_name}-${var.region1}-cr6"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
  }
}

module "interconnect_attachment1_region2" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 9.0"

  name    = "vl-${var.region2_interconnect1_onprem_dc}-${var.region2_interconnect1_location}-${var.vpc_name}-${var.region2}-cr7"
  project = var.interconnect_project_id
  region  = var.region2
  router  = var.region2_router1_name

  interconnect      = var.region2_interconnect1
  candidate_subnets = var.region2_interconnect1_candidate_subnets
  vlan_tag8021q     = var.region2_interconnect1_vlan_tag8021q

  interface = {
    name = "if-${var.region2_interconnect1_location}-${var.vpc_name}-${var.region2}-cr7"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
  }
}

module "interconnect_attachment2_region2" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 9.0"

  name    = "vl-${var.region2_interconnect2_onprem_dc}-${var.region2_interconnect2_location}-${var.vpc_name}-${var.region2}-cr8"
  project = var.interconnect_project_id
  region  = var.region2
  router  = var.region2_router2_name

  interconnect      = var.region2_interconnect2
  candidate_subnets = var.region2_interconnect2_candidate_subnets
  vlan_tag8021q     = var.region2_interconnect2_vlan_tag8021q

  interface = {
    name = "if-${var.region2_interconnect2_location}-${var.vpc_name}-${var.region2}-cr8"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
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
  description = "NCC Spoke containing Dedicated Interconnects for region 1"

  linked_interconnect_attachments {
    uris = [
      module.interconnect_attachment1_region1.attachment.id,
      module.interconnect_attachment2_region1.attachment.id
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
  description = "NCC Spoke containing Dedicated Interconnects for region 2"

  linked_interconnect_attachments {
    uris = [
      module.interconnect_attachment1_region2.attachment.id,
      module.interconnect_attachment2_region2.attachment.id
    ]

    site_to_site_data_transfer = var.site_to_site_data_transfer
  }
}
