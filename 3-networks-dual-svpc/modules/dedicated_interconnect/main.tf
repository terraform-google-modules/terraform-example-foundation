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
  suffix1 = lookup(var.cloud_router_labels, "vlan_1", "cr1")
  suffix2 = lookup(var.cloud_router_labels, "vlan_2", "cr2")
  suffix3 = lookup(var.cloud_router_labels, "vlan_3", "cr3")
  suffix4 = lookup(var.cloud_router_labels, "vlan_4", "cr4")
}

module "interconnect_attachment1_region1" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 3.0"

  name    = "vl-${var.region1_interconnect1_onprem_dc}-${var.region1_interconnect1_location}-${var.vpc_name}-${var.region1}-${local.suffix1}"
  project = var.interconnect_project_id
  region  = var.region1
  router  = var.region1_router1_name

  interconnect      = var.region1_interconnect1
  candidate_subnets = var.region1_interconnect1_candidate_subnets
  vlan_tag8021q     = var.region1_interconnect1_vlan_tag8021q

  interface = {
    name = "if-${var.region1_interconnect1_location}-${var.vpc_name}-${var.region1}-${local.suffix1}"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
  }
}

module "interconnect_attachment2_region1" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 3.0"

  name    = "vl-${var.region1_interconnect2_onprem_dc}-${var.region1_interconnect2_location}-${var.vpc_name}-${var.region1}-${local.suffix2}"
  project = var.interconnect_project_id
  region  = var.region1
  router  = var.region1_router2_name

  interconnect      = var.region1_interconnect2
  candidate_subnets = var.region1_interconnect2_candidate_subnets
  vlan_tag8021q     = var.region1_interconnect2_vlan_tag8021q

  interface = {
    name = "if-${var.region1_interconnect2_location}-${var.vpc_name}-${var.region1}-${local.suffix2}"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
  }
}

module "interconnect_attachment1_region2" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 3.0"

  name    = "vl-${var.region2_interconnect1_onprem_dc}-${var.region2_interconnect1_location}-${var.vpc_name}-${var.region2}-${local.suffix3}"
  project = var.interconnect_project_id
  region  = var.region2
  router  = var.region2_router1_name

  interconnect      = var.region2_interconnect1
  candidate_subnets = var.region2_interconnect1_candidate_subnets
  vlan_tag8021q     = var.region2_interconnect1_vlan_tag8021q

  interface = {
    name = "if-${var.region2_interconnect1_location}-${var.vpc_name}-${var.region2}-${local.suffix3}"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
  }
}

module "interconnect_attachment2_region2" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 3.0"

  name    = "vl-${var.region2_interconnect2_onprem_dc}-${var.region2_interconnect2_location}-${var.vpc_name}-${var.region2}-${local.suffix4}"
  project = var.interconnect_project_id
  region  = var.region2
  router  = var.region2_router2_name

  interconnect      = var.region2_interconnect2
  candidate_subnets = var.region2_interconnect2_candidate_subnets
  vlan_tag8021q     = var.region2_interconnect2_vlan_tag8021q

  interface = {
    name = "if-${var.region2_interconnect2_location}-${var.vpc_name}-${var.region2}-${local.suffix4}"
  }

  peer = {
    name     = var.peer_name
    peer_asn = var.peer_asn
  }
}
