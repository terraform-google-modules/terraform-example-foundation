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

locals {

  subnet_primary_ranges = {
    (local.default_region1) = "10.8.0.0/18"
    (local.default_region2) = "10.9.0.0/18"
  }
  subnet_proxy_ranges = {
    (local.default_region1) = "10.26.0.0/23"
    (local.default_region2) = "10.27.0.0/23"
  }

}

/******************************************
  Shared Network VPC
*****************************************/

module "shared_vpc" {
  source = "../../modules/shared_vpc"

  project_id                       = local.net_hub_project_id
  project_number                   = local.net_hub_project_number
  environment_code                 = local.environment_code
  private_service_connect_ip       = "10.17.0.5"
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bgp_asn_subnet                   = local.bgp_asn_number
  default_region1                  = local.default_region1
  default_region2                  = local.default_region2
  domain                           = var.domain
  dns_enable_inbound_forwarding    = var.hub_dns_enable_inbound_forwarding
  dns_enable_logging               = var.hub_dns_enable_logging
  firewall_enable_logging          = var.hub_firewall_enable_logging
  nat_enabled                      = var.hub_nat_enabled
  nat_bgp_asn                      = var.hub_nat_bgp_asn
  nat_num_addresses_region1        = var.hub_nat_num_addresses_region1
  nat_num_addresses_region2        = var.hub_nat_num_addresses_region2
  windows_activation_enabled       = var.hub_windows_activation_enabled
  target_name_server_addresses     = var.target_name_server_addresses
  mode                             = "hub"

  subnets = [
    {
      subnet_name                      = "sb-c-svpc-hub-${local.default_region1}"
      subnet_ip                        = local.subnet_primary_ranges[local.default_region1]
      subnet_region                    = local.default_region1
      subnet_private_access            = "true"
      subnet_flow_logs                 = var.vpc_flow_logs.enable_logging
      subnet_flow_logs_interval        = var.vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.vpc_flow_logs.filter_expr
      description                      = "Network hub subnet for ${local.default_region1}"
    },
    {
      subnet_name                      = "sb-c-svpc-hub-${local.default_region2}"
      subnet_ip                        = local.subnet_primary_ranges[local.default_region2]
      subnet_region                    = local.default_region2
      subnet_private_access            = "true"
      subnet_flow_logs                 = var.vpc_flow_logs.enable_logging
      subnet_flow_logs_interval        = var.vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.vpc_flow_logs.filter_expr
      description                      = "Network hub subnet for ${local.default_region2}"
    },
    {
      subnet_name      = "sb-c-svpc-hub-${local.default_region1}-proxy"
      subnet_ip        = local.subnet_proxy_ranges[local.default_region1]
      subnet_region    = local.default_region1
      subnet_flow_logs = false
      description      = "Network hub proxy-only subnet for ${local.default_region1}"
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    },
    {
      subnet_name      = "sb-c-svpc-hub-${local.default_region2}-proxy"
      subnet_ip        = local.subnet_proxy_ranges[local.default_region2]
      subnet_region    = local.default_region2
      subnet_flow_logs = false
      description      = "Network hub proxy-only subnet for ${local.default_region2}"
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    }
  ]
  secondary_ranges = {}
}
