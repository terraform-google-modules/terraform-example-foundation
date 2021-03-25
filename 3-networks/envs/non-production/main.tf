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
  environment_code          = "n"
  env                       = "non-production"
  restricted_project_id     = data.google_projects.restricted_host_project.projects[0].project_id
  restricted_project_number = data.google_project.restricted_host_project.number
  base_project_id           = data.google_projects.base_host_project.projects[0].project_id
  parent_id                 = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  mode                      = var.enable_hub_and_spoke ? "spoke" : null
  bgp_asn_number            = var.enable_partner_interconnect ? "16550" : "64514"
  enable_transitivity       = var.enable_hub_and_spoke && var.enable_hub_and_spoke_transitivity
  /*
   * Base network ranges
   */
  base_subnet_aggregates    = ["10.0.0.0/16", "10.1.0.0/16", "100.64.0.0/16", "100.65.0.0/16"]
  base_hub_subnet_ranges    = ["10.0.0.0/24", "10.1.0.0/24"]
  base_private_service_cidr = "10.16.128.0/21"
  base_subnet_primary_ranges = {
    (var.default_region1) = "10.0.128.0/21"
    (var.default_region2) = "10.1.128.0/21"
  }
  base_subnet_secondary_ranges = {
    (var.default_region1) = [
      {
        range_name    = "rn-${local.environment_code}-shared-base-${var.default_region1}-gke-pod"
        ip_cidr_range = "100.64.128.0/21"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-base-${var.default_region1}-gke-svc"
        ip_cidr_range = "100.64.136.0/21"
      }
    ]
  }
  /*
   * Restricted network ranges
   */
  restricted_subnet_aggregates    = ["10.8.0.0/16", "10.9.0.0/16", "100.72.0.0/16", "100.73.0.0/16"]
  restricted_hub_subnet_ranges    = ["10.8.0.0/24", "10.9.0.0/24"]
  restricted_private_service_cidr = "10.24.128.0/21"
  restricted_subnet_primary_ranges = {
    (var.default_region1) = "10.8.128.0/21"
    (var.default_region2) = "10.9.128.0/21"
  }
  restricted_subnet_secondary_ranges = {
    (var.default_region1) = [
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-pod"
        ip_cidr_range = "100.72.128.0/21"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-svc"
        ip_cidr_range = "100.72.136.0/21"
      }
    ]
  }
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
  private_service_cidr             = local.restricted_private_service_cidr
  org_id                           = var.org_id
  parent_folder                    = var.parent_folder
  bgp_asn_subnet                   = local.bgp_asn_number
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
      subnet_ip             = local.restricted_subnet_primary_ranges[var.default_region1]
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.default_region2}"
      subnet_ip             = local.restricted_subnet_primary_ranges[var.default_region2]
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-restricted-${var.default_region1}" = local.restricted_subnet_secondary_ranges[var.default_region1]
  }
  allow_all_ingress_ranges = local.enable_transitivity ? local.restricted_hub_subnet_ranges : null
  allow_all_egress_ranges  = local.enable_transitivity ? local.restricted_subnet_aggregates : null
}

/******************************************
 Base shared VPC
*****************************************/

module "base_shared_vpc" {
  source                        = "../../modules/base_shared_vpc"
  project_id                    = local.base_project_id
  environment_code              = local.environment_code
  private_service_cidr          = local.base_private_service_cidr
  org_id                        = var.org_id
  parent_folder                 = var.parent_folder
  default_region1               = var.default_region1
  default_region2               = var.default_region2
  domain                        = var.domain
  bgp_asn_subnet                = local.bgp_asn_number
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
      subnet_ip             = local.base_subnet_primary_ranges[var.default_region1]
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-base-${var.default_region2}"
      subnet_ip             = local.base_subnet_primary_ranges[var.default_region2]
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-base-${var.default_region1}" = local.base_subnet_secondary_ranges[var.default_region1]
  }
  allow_all_ingress_ranges = local.enable_transitivity ? local.base_hub_subnet_ranges : null
  allow_all_egress_ranges  = local.enable_transitivity ? local.base_subnet_aggregates : null
}
