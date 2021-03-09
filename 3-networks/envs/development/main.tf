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
  environment_code          = "d"
  env                       = "development"
  restricted_project_id     = data.google_projects.restricted_host_project.projects[0].project_id
  restricted_project_number = data.google_project.restricted_host_project.number
  base_project_id           = data.google_projects.base_host_project.projects[0].project_id
  parent_id                 = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  mode                      = var.enable_hub_and_spoke ? "spoke" : null
}

data "google_active_folder" "env" {
  display_name = "${var.folder_prefix}-${local.env}"
  parent       = local.parent_id
}

/******************************************
  VPC Host Projects
*****************************************/

data "google_projects" "restricted_host_project" {
  filter = "parent.id:${split("/", data.google_active_folder.env.name)[1]} labels.application_name=restricted-shared-vpc-host labels.environment=${local.env} lifecycleState=ACTIVE"
}

data "google_project" "restricted_host_project" {
  project_id = data.google_projects.restricted_host_project.projects[0].project_id
}

data "google_projects" "base_host_project" {
  filter = "parent.id:${split("/", data.google_active_folder.env.name)[1]} labels.application_name=base-shared-vpc-host labels.environment=${local.env} lifecycleState=ACTIVE"
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
  parent_folder                    = var.parent_folder
  bgp_asn_subnet                   = "64514"
  default_region1                  = var.default_region1
  default_region2                  = var.default_region2
  domain                           = var.domain
  windows_activation_enabled       = var.windows_activation_enabled
  dns_enable_inbound_forwarding    = var.dns_enable_inbound_forwarding
  dns_enable_logging               = var.dns_enable_logging
  firewall_enable_logging          = var.firewall_enable_logging
  optional_fw_rules_enabled        = var.optional_fw_rules_enabled
  nat_enabled                      = var.nat_enabled
  nat_bgp_asn                      = var.nat_bgp_asn
  nat_num_addresses_region1        = var.nat_num_addresses_region1
  nat_num_addresses_region2        = var.nat_num_addresses_region2
  folder_prefix                    = var.folder_prefix
  mode                             = local.mode

  subnets = [
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.default_region1}"
      subnet_ip             = "10.0.160.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.default_region2}"
      subnet_ip             = "10.0.168.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-restricted-${var.default_region1}" = [
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-pod"
        ip_cidr_range = "192.168.0.0/21"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.8.0/21"
      }
    ]
  }
}

/******************************************
 Base shared VPC
*****************************************/

module "base_shared_vpc" {
  source                        = "../../modules/base_shared_vpc"
  project_id                    = local.base_project_id
  environment_code              = local.environment_code
  private_service_cidr          = "10.0.144.0/20"
  org_id                        = var.org_id
  parent_folder                 = var.parent_folder
  default_region1               = var.default_region1
  default_region2               = var.default_region2
  domain                        = var.domain
  bgp_asn_subnet                = "64514"
  windows_activation_enabled    = var.windows_activation_enabled
  dns_enable_inbound_forwarding = var.dns_enable_inbound_forwarding
  dns_enable_logging            = var.dns_enable_logging
  firewall_enable_logging       = var.firewall_enable_logging
  optional_fw_rules_enabled     = var.optional_fw_rules_enabled
  nat_enabled                   = var.nat_enabled
  nat_bgp_asn                   = var.nat_bgp_asn
  nat_num_addresses_region1     = var.nat_num_addresses_region1
  nat_num_addresses_region2     = var.nat_num_addresses_region2
  nat_num_addresses             = var.nat_num_addresses
  folder_prefix                 = var.folder_prefix
  mode                          = local.mode

  subnets = [
    {
      subnet_name           = "sb-${local.environment_code}-shared-base-${var.default_region1}"
      subnet_ip             = "10.0.128.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-base-${var.default_region2}"
      subnet_ip             = "10.0.136.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-base-${var.default_region1}" = [
      {
        range_name    = "rn-${local.environment_code}-shared-base-${var.default_region1}-gke-pod"
        ip_cidr_range = "192.168.16.0/21"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-base-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.24.0/21"
      }
    ]
  }
}

resource "google_compute_address" "external_ip_for_http_load_balancing" {
  name         = var.address_name
  project      = local.base_project_id
  address_type = var.address_type
  description  = var.description
  region       = var.region
}
