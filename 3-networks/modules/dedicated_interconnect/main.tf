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
  interconnect_project_id = data.google_projects.interconnect_project.projects[0].project_id
}

data "google_projects" "interconnect_project" {
  filter = "labels.application_name=prj-interconnect"
}

module "interconnect_attachment1_region1" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 0.2.0"

  name    = "vl-${var.interconnect_location1_region1}-${var.vpc_name}-${var.default_region1}-cr1"
  project = local.interconnect_project_id
  region  = var.default_region1
  router  = var.region1_router1_name

  interconnect = var.interconnect1_region1

  interface = {
    name = "if-${var.interconnect_location1_region1}-${var.vpc_name}-${var.default_region1}"
  }

  peer = {
    name            = var.peer_name
    peer_ip_address = var.peer_ip_address
    peer_asn        = var.peer_asn
  }
}

module "interconnect_attachment2_region1" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 0.2.0"

  name    = "vl-${var.interconnect_location2_region1}-${var.vpc_name}-${var.default_region1}-cr2"
  project = local.interconnect_project_id
  region  = var.default_region1
  router  = var.region1_router2_name

  interconnect = var.interconnect2_region1

  interface = {
    name = "if-${var.interconnect_location2_region1}-${var.vpc_name}-${var.default_region1}"
  }

  peer = {
    name            = var.peer_name
    peer_ip_address = var.peer_ip_address
    peer_asn        = var.peer_asn
  }
}

module "interconnect_attachment1_region2" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 0.2.0"

  name    = "vl-${var.interconnect_location1_region2}-${var.vpc_name}-${var.default_region2}-cr1"
  project = local.interconnect_project_id
  region  = var.default_region2
  router  = var.region2_router1_name

  interconnect = var.interconnect1_region2

  interface = {
    name = "if-${var.interconnect_location1_region2}-${var.vpc_name}-${var.default_region2}"
  }

  peer = {
    name            = var.peer_name
    peer_ip_address = var.peer_ip_address
    peer_asn        = var.peer_asn
  }
}

module "interconnect_attachment2_region2" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 0.2.0"

  name    = "vl-${var.interconnect_location2_region2}-${var.vpc_name}-${var.default_region2}-cr2"
  project = local.interconnect_project_id
  region  = var.default_region2
  router  = var.region2_router2_name

  interconnect = var.interconnect2_region2

  interface = {
    name = "if-${var.interconnect_location2_region2}-${var.vpc_name}-${var.default_region2}"
  }

  peer = {
    name            = var.peer_name
    peer_ip_address = var.peer_ip_address
    peer_asn        = var.peer_asn
  }
}
