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
  base_net_hub_project_id           = try(data.google_projects.base_net_hub[0].projects[0].project_id, null)
  restricted_net_hub_project_id     = try(data.google_projects.restricted_net_hub[0].projects[0].project_id, null)
  restricted_net_hub_project_number = try(data.google_projects.restricted_net_hub[0].projects[0].number, null)
  /*
   * Base network ranges
   */
  base_subnet_primary_ranges = {
    (var.default_region1) = "10.0.0.0/24"
    (var.default_region2) = "10.1.0.0/24"
  }
  /*
   * Restricted network ranges
   */
  restricted_subnet_primary_ranges = {
    (var.default_region1) = "10.8.0.0/24"
    (var.default_region2) = "10.9.0.0/24"
  }
}

/******************************************
  Base Network Hub Project
*****************************************/

data "google_projects" "base_net_hub" {
  count  = var.enable_hub_and_spoke ? 1 : 0
  filter = "parent.id:${split("/", data.google_active_folder.common.name)[1]} labels.application_name=org-base-net-hub lifecycleState=ACTIVE"
}

/******************************************
  Restricted Network Hub Project
*****************************************/

data "google_projects" "restricted_net_hub" {
  count  = var.enable_hub_and_spoke ? 1 : 0
  filter = "parent.id:${split("/", data.google_active_folder.common.name)[1]} labels.application_name=org-restricted-net-hub lifecycleState=ACTIVE"
}

/******************************************
  Base Network VPC
*****************************************/

module "base_shared_vpc" {
  source                        = "../../modules/base_shared_vpc"
  count                         = var.enable_hub_and_spoke ? 1 : 0
  project_id                    = local.base_net_hub_project_id
  environment_code              = local.environment_code
  org_id                        = var.org_id
  parent_folder                 = var.parent_folder
  bgp_asn_subnet                = local.bgp_asn_number
  default_region1               = var.default_region1
  default_region2               = var.default_region2
  domain                        = var.domain
  windows_activation_enabled    = var.base_hub_windows_activation_enabled
  dns_enable_inbound_forwarding = var.base_hub_dns_enable_inbound_forwarding
  dns_enable_logging            = var.base_hub_dns_enable_logging
  firewall_enable_logging       = var.base_hub_firewall_enable_logging
  optional_fw_rules_enabled     = var.base_hub_optional_fw_rules_enabled
  nat_enabled                   = var.base_hub_nat_enabled
  nat_bgp_asn                   = var.base_hub_nat_bgp_asn
  nat_num_addresses_region1     = var.base_hub_nat_num_addresses_region1
  nat_num_addresses_region2     = var.base_hub_nat_num_addresses_region2
  folder_prefix                 = var.folder_prefix
  mode                          = "hub"

  subnets = [
    {
      subnet_name           = "sb-c-shared-base-hub-${var.default_region1}"
      subnet_ip             = local.base_subnet_primary_ranges[var.default_region1]
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Base network hub subnet for ${var.default_region1}"
    },
    {
      subnet_name           = "sb-c-shared-base-hub-${var.default_region2}"
      subnet_ip             = local.base_subnet_primary_ranges[var.default_region2]
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Base network hub subnet for ${var.default_region2}"
    }
  ]
  secondary_ranges = {}

  depends_on = [module.dns_hub_vpc]
}

/******************************************
  Restricted Network VPC
*****************************************/

module "restricted_shared_vpc" {
  source                           = "../../modules/restricted_shared_vpc"
  count                            = var.enable_hub_and_spoke ? 1 : 0
  project_id                       = local.restricted_net_hub_project_id
  project_number                   = local.restricted_net_hub_project_number
  environment_code                 = local.environment_code
  access_context_manager_policy_id = var.access_context_manager_policy_id
  restricted_services              = ["bigquery.googleapis.com", "storage.googleapis.com"]
  members                          = ["serviceAccount:${var.terraform_service_account}"]
  org_id                           = var.org_id
  parent_folder                    = var.parent_folder
  bgp_asn_subnet                   = local.bgp_asn_number
  default_region1                  = var.default_region1
  default_region2                  = var.default_region2
  domain                           = var.domain
  windows_activation_enabled       = var.restricted_hub_windows_activation_enabled
  dns_enable_inbound_forwarding    = var.restricted_hub_dns_enable_inbound_forwarding
  dns_enable_logging               = var.restricted_hub_dns_enable_logging
  firewall_enable_logging          = var.restricted_hub_firewall_enable_logging
  optional_fw_rules_enabled        = var.restricted_hub_optional_fw_rules_enabled
  nat_enabled                      = var.restricted_hub_nat_enabled
  nat_bgp_asn                      = var.restricted_hub_nat_bgp_asn
  nat_num_addresses_region1        = var.restricted_hub_nat_num_addresses_region1
  nat_num_addresses_region2        = var.restricted_hub_nat_num_addresses_region2
  folder_prefix                    = var.folder_prefix
  mode                             = "hub"

  subnets = [
    {
      subnet_name           = "sb-c-shared-restricted-hub-${var.default_region1}"
      subnet_ip             = local.restricted_subnet_primary_ranges[var.default_region1]
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Restricted network hub subnet for ${var.default_region1}"
    },
    {
      subnet_name           = "sb-c-shared-restricted-hub-${var.default_region2}"
      subnet_ip             = local.restricted_subnet_primary_ranges[var.default_region2]
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Restricted network hub subnet for ${var.default_region2}"
    }
  ]
  secondary_ranges = {}

  depends_on = [module.dns_hub_vpc]
}
