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
  filter = "labels.application_name=prj-interconnect lifecycleState=ACTIVE"
}

module "interconnect_attachment1_region1" {
  source  = "terraform-google-modules/cloud-router/google//modules/interconnect_attachment"
  version = "~> 0.2.0"

  name    = "vl-${var.region1_interconnect1_location}-${var.vpc_name}-${var.region1}-cr1"
  project = local.interconnect_project_id
  region  = var.region1
  router  = var.region1_router1_name

  interconnect = var.region1_interconnect1

  interface = {
    name = "if-${var.region1_interconnect1_location}-${var.vpc_name}-${var.region1}"
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

  name    = "vl-${var.region1_interconnect2_location}-${var.vpc_name}-${var.region1}-cr2"
  project = local.interconnect_project_id
  region  = var.region1
  router  = var.region1_router2_name

  interconnect = var.region1_interconnect2

  interface = {
    name = "if-${var.region1_interconnect2_location}-${var.vpc_name}-${var.region1}"
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

  name    = "vl-${var.region2_interconnect1_location}-${var.vpc_name}-${var.region2}-cr1"
  project = local.interconnect_project_id
  region  = var.region2
  router  = var.region2_router1_name

  interconnect = var.region2_interconnect1

  interface = {
    name = "if-${var.region2_interconnect1_location}-${var.vpc_name}-${var.region2}"
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

  name    = "vl-${var.region2_interconnect2_location}-${var.vpc_name}-${var.region2}-cr2"
  project = local.interconnect_project_id
  region  = var.region2
  router  = var.region2_router2_name

  interconnect = var.region2_interconnect2

  interface = {
    name = "if-${var.region2_interconnect2_location}-${var.vpc_name}-${var.region2}"
  }

  peer = {
    name            = var.peer_name
    peer_ip_address = var.peer_ip_address
    peer_asn        = var.peer_asn
  }
}
