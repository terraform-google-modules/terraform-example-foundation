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
  environment_code          = "d"
  env                       = "dev"
  restricted_project_id     = data.google_projects.restricted_host_project.projects[0].project_id
  restricted_project_number = data.google_project.restricted_host_project.number
  private_project_id        = data.google_projects.private_project.projects[0].project_id
}

/******************************************
  VPC Host Projects
*****************************************/

data "google_projects" "restricted_host_project" {
  filter = "labels.application_name=restricted-shared-vpc-host-${local.env}"
}

data "google_project" "restricted_host_project" {
  project_id = data.google_projects.restricted_host_project.projects[0].project_id
}

data "google_projects" "private_project" {
  filter = "labels.application_name=base-shared-vpc-host-${local.env}"
}

/******************************************
 Restricted shared VPC
*****************************************/
module "restricted_shared_vpc" {
  source                           = "../../modules/restricted_shared_vpc"
  project_id                       = local.restricted_project_id
  project_number                   = local.restricted_project_number
  environment_code                 = local.environment_code
  access_context_manager_policy_id = var.access_context_manager_policy_id
  restricted_services              = ["bigquery.googleapis.com", "storage.googleapis.com"]
  members                          = ["serviceAccount:${var.terraform_service_account}"]
  private_service_cidr             = "10.0.176.0/20"
  org_id                           = var.org_id
  nat_enabled                      = false
  bgp_asn_subnet                   = "64514"
  default_region1                  = var.default_region1
  default_region2                  = var.default_region2

  subnets = [
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.default_region1}"
      subnet_ip             = "10.0.160.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.default_region2}"
      subnet_ip             = "10.0.168.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-restricted-${var.default_region1}" = [
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-pod"
        ip_cidr_range = "192.168.0.0/19"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.32.0/23"
      }
    ]
  }
}

/******************************************
 Base shared VPC
*****************************************/

module "private_shared_vpc" {
  source                     = "../../modules/standard_shared_vpc"
  project_id                 = local.private_project_id
  environment_code           = local.environment_code
  vpc_label                  = "private"
  private_service_cidr       = "10.0.144.0/20"
  nat_enabled                = true
  nat_bgp_asn                = "64514"
  default_region1            = var.default_region1
  default_region2            = var.default_region2
  bgp_asn_subnet             = "64514"
  windows_activation_enabled = true
  subnets = [
    {
      subnet_name           = "sb-${local.environment_code}-shared-private-${var.default_region1}"
      subnet_ip             = "10.0.128.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-private-${var.default_region2}"
      subnet_ip             = "10.0.136.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-private-${var.default_region1}" = [{
      range_name    = "rn-${local.environment_code}-shared-private-${var.default_region1}-gke-pod"
      ip_cidr_range = "192.168.96.0/19"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-private-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.128.0/23"
      }
    ]
  }
}
