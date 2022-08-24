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
  restricted_project_id     = data.google_projects.restricted_host_project.projects[0].project_id
  restricted_project_number = data.google_project.restricted_host_project.number
  base_project_id           = data.google_projects.base_host_project.projects[0].project_id
  parent_id                 = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  bgp_asn_number            = var.enable_partner_interconnect ? "16550" : "64514"
  /*
   * Base network ranges
   */
  base_subnet_aggregates = ["10.0.0.0/16", "10.1.0.0/16", "100.64.0.0/16", "100.65.0.0/16"]
  base_hub_subnet_ranges = ["10.0.0.0/24", "10.1.0.0/24"]
  /*
   * Restricted network ranges
   */
  restricted_subnet_aggregates = ["10.8.0.0/16", "10.9.0.0/16", "100.72.0.0/16", "100.73.0.0/16"]
  restricted_hub_subnet_ranges = ["10.8.0.0/24", "10.9.0.0/24"]
}

data "google_active_folder" "env" {
  display_name = "${var.folder_prefix}-${var.env}"
  parent       = local.parent_id
}

/******************************************
  VPC Host Projects
*****************************************/

data "google_projects" "restricted_host_project" {
  filter = "parent.id:${split("/", data.google_active_folder.env.name)[1]} labels.application_name=restricted-shared-vpc-host labels.environment=${var.env} lifecycleState=ACTIVE"
}

data "google_project" "restricted_host_project" {
  project_id = data.google_projects.restricted_host_project.projects[0].project_id
}

data "google_projects" "base_host_project" {
  filter = "parent.id:${split("/", data.google_active_folder.env.name)[1]} labels.application_name=base-shared-vpc-host labels.environment=${var.env} lifecycleState=ACTIVE"
}

/******************************************
 Restricted shared VPC
*****************************************/
module "restricted_shared_vpc" {
  source                           = "../restricted_shared_vpc"
  project_id                       = local.restricted_project_id
  project_number                   = local.restricted_project_number
  environment_code                 = var.environment_code
  access_context_manager_policy_id = var.access_context_manager_policy_id
  restricted_services              = ["bigquery.googleapis.com", "storage.googleapis.com"]
  members                          = var.members
  private_service_cidr             = var.restricted_private_service_cidr
  org_id                           = var.org_id
  parent_folder                    = var.parent_folder
  bgp_asn_subnet                   = local.bgp_asn_number
  default_region1                  = var.default_region1
  default_region2                  = var.default_region2
  domain                           = var.domain

  subnets = [
    {
      subnet_name           = "sb-${var.environment_code}-shared-restricted-${var.default_region1}"
      subnet_ip             = var.restricted_subnet_primary_ranges[var.default_region1]
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = true
      description           = "First ${var.env} subnet example."
    },
    {
      subnet_name           = "sb-${var.environment_code}-shared-restricted-${var.default_region2}"
      subnet_ip             = var.restricted_subnet_primary_ranges[var.default_region2]
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = true
      description           = "Second ${var.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${var.environment_code}-shared-restricted-${var.default_region1}" = var.restricted_subnet_secondary_ranges[var.default_region1]
  }
  allow_all_ingress_ranges = null
  allow_all_egress_ranges  = null
}

/******************************************
 Base shared VPC
*****************************************/

module "base_shared_vpc" {
  source               = "../base_shared_vpc"
  project_id           = local.base_project_id
  environment_code     = var.environment_code
  private_service_cidr = var.base_private_service_cidr
  org_id               = var.org_id
  parent_folder        = var.parent_folder
  default_region1      = var.default_region1
  default_region2      = var.default_region2
  domain               = var.domain
  bgp_asn_subnet       = local.bgp_asn_number

  subnets = [
    {
      subnet_name           = "sb-${var.environment_code}-shared-base-${var.default_region1}"
      subnet_ip             = var.base_subnet_primary_ranges[var.default_region1]
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = true
      description           = "First ${var.env} subnet example."
    },
    {
      subnet_name           = "sb-${var.environment_code}-shared-base-${var.default_region2}"
      subnet_ip             = var.base_subnet_primary_ranges[var.default_region2]
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = true
      description           = "Second ${var.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${var.environment_code}-shared-base-${var.default_region1}" = var.base_subnet_secondary_ranges[var.default_region1]
  }
  allow_all_ingress_ranges = null
  allow_all_egress_ranges  = null
}
