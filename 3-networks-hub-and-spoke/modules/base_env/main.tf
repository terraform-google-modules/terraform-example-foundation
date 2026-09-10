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
  bgp_asn_number      = var.enable_partner_interconnect ? "16550" : "64514"
  enable_transitivity = var.enable_hub_and_spoke_transitivity

  subnet_aggregates = ["10.8.0.0/18", "10.9.0.0/18", "100.72.0.0/18", "100.73.0.0/18"]
  hub_subnet_ranges = ["10.8.0.0/24", "10.9.0.0/24"]
}


/******************************************
 Shared VPC
*****************************************/

module "shared_vpc" {
  source  = "terraform-google-modules/network/google//modules/foundation/network"
  version = "~> 18.2"

  project_id      = local.shared_vpc_project_id
  vpc_name        = "svpc-spoke"
  shared_vpc_host = true

  resource_code = var.environment_code

  private_service_cidr       = var.private_service_cidr
  private_service_connect_ip = var.private_service_connect_ip

  ncc_hub_config = {
    create_hub  = false
    uri         = local.ncc_hub_uri
    spoke_group = local.ncc_spoke_group
  }

  dns_config = {
    type                      = "spoke"
    domain                    = var.domain
    enable_logging            = true
    enable_inbound_forwarding = true
    onprem_forwarding         = true
    dns_hub_project_id        = local.net_hub_project_id
    dns_hub_network_name      = regex("networks/(.+)", local.net_hub_network_self_link)[0]
  }

  subnets = [
    {
      subnet_name                      = "sb-${var.environment_code}-svpc-${var.default_region1}"
      subnet_ip                        = var.subnet_primary_ranges[var.default_region1]
      subnet_region                    = var.default_region1
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.vpc_flow_logs.filter_expr
      description                      = "First ${var.env} subnet example."
    },
    {
      subnet_name                      = "sb-${var.environment_code}-svpc-${var.default_region2}"
      subnet_ip                        = var.subnet_primary_ranges[var.default_region2]
      subnet_region                    = var.default_region2
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.vpc_flow_logs.filter_expr
      description                      = "Second ${var.env} subnet example."
    },
    {
      subnet_name           = "sb-${var.environment_code}-svpc-${var.default_region1}-proxy"
      subnet_ip             = var.subnet_proxy_ranges[var.default_region1]
      subnet_region         = var.default_region1
      subnet_private_access = "false"
      subnet_flow_logs      = false
      description           = "First ${var.env} proxy-only subnet example."
      role                  = "ACTIVE"
      purpose               = "REGIONAL_MANAGED_PROXY"
    },
    {
      subnet_name           = "sb-${var.environment_code}-svpc-${var.default_region2}-proxy"
      subnet_ip             = var.subnet_proxy_ranges[var.default_region2]
      subnet_region         = var.default_region2
      subnet_private_access = "false"
      subnet_flow_logs      = false
      description           = "Second ${var.env} proxy-only subnet example."
      role                  = "ACTIVE"
      purpose               = "REGIONAL_MANAGED_PROXY"
    }
  ]
  secondary_ranges = {
    "sb-${var.environment_code}-svpc-${var.default_region1}" = var.subnet_secondary_ranges[var.default_region1]
  }
}
