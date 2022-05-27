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
  parent_id = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  suffix1   = lookup(var.cloud_router_labels, "vlan_1", "cr1")
  suffix2   = lookup(var.cloud_router_labels, "vlan_2", "cr2")
  suffix3   = lookup(var.cloud_router_labels, "vlan_3", "cr3")
  suffix4   = lookup(var.cloud_router_labels, "vlan_4", "cr4")

  attachment_project_id = data.google_projects.attachment_project.projects[0].project_id

  app_label         = var.enable_hub_and_spoke ? "org-${var.vpc_type}-net-hub" : "${var.vpc_type}-shared-vpc-host"
  environment_label = var.enable_hub_and_spoke ? "production" : var.environment
}

data "google_active_folder" "environment" {
  display_name = "${var.folder_prefix}-${var.environment}"
  parent       = local.parent_id
}

data "google_projects" "attachment_project" {
  filter = "parent.id:${split("/", data.google_active_folder.environment.name)[1]} labels.application_name=${local.app_label} labels.environment=${local.environment_label} lifecycleState=ACTIVE"
}

resource "google_compute_interconnect_attachment" "interconnect_attachment1_region1" {
  name    = "vl-${var.region1_interconnect1_location}-${var.vpc_name}-${var.region1}-${local.suffix1}"
  project = local.attachment_project_id
  region  = var.region1
  router  = var.region1_router1_name

  admin_enabled            = var.preactivate
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  type                     = "PARTNER"
}

resource "google_compute_interconnect_attachment" "interconnect_attachment2_region1" {
  name    = "vl-${var.region1_interconnect2_location}-${var.vpc_name}-${var.region1}-${local.suffix2}"
  project = local.attachment_project_id
  region  = var.region1
  router  = var.region1_router2_name

  admin_enabled            = var.preactivate
  edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  type                     = "PARTNER"
}

resource "google_compute_interconnect_attachment" "interconnect_attachment1_region2" {
  name    = "vl-${var.region2_interconnect1_location}-${var.vpc_name}-${var.region2}-${local.suffix1}"
  project = local.attachment_project_id
  region  = var.region2
  router  = var.region2_router1_name

  admin_enabled            = var.preactivate
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  type                     = "PARTNER"
}

resource "google_compute_interconnect_attachment" "interconnect_attachment2_region2" {
  name    = "vl-${var.region2_interconnect2_location}-${var.vpc_name}-${var.region2}-${local.suffix2}"
  project = local.attachment_project_id
  region  = var.region2
  router  = var.region2_router2_name

  admin_enabled            = var.preactivate
  edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  type                     = "PARTNER"
}
