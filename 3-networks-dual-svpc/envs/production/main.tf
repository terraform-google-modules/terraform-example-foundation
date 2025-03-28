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
  env              = "production"
  environment_code = substr(local.env, 0, 1)
  /*
   * Base network ranges
   */
  base_private_service_cidr = "10.16.24.0/21"
  base_subnet_primary_ranges = {
    (local.default_region1) = "10.0.192.0/18"
    (local.default_region2) = "10.1.192.0/18"
  }
  base_subnet_proxy_ranges = {
    (local.default_region1) = "10.18.6.0/23"
    (local.default_region2) = "10.19.6.0/23"
  }
  base_subnet_secondary_ranges = {
    (local.default_region1) = [
      {
        range_name    = "rn-${local.environment_code}-shared-base-${local.default_region1}-gke-pod"
        ip_cidr_range = "100.64.192.0/18"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-base-${local.default_region1}-gke-svc"
        ip_cidr_range = "100.65.192.0/18"
      }
    ]
  }
  /*
   * Restricted network ranges
   */
  restricted_private_service_cidr = "10.16.56.0/21"
  restricted_subnet_primary_ranges = {
    (local.default_region1) = "10.8.192.0/18"
    (local.default_region2) = "10.9.192.0/18"
  }
  restricted_subnet_proxy_ranges = {
    (local.default_region1) = "10.26.6.0/23"
    (local.default_region2) = "10.27.6.0/23"
  }
  restricted_subnet_secondary_ranges = {
    (local.default_region1) = [
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${local.default_region1}-gke-pod"
        ip_cidr_range = "100.72.192.0/18"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${local.default_region1}-gke-svc"
        ip_cidr_range = "100.73.192.0/18"
      }
    ]
  }
}

module "base_env" {
  source = "../../modules/base_env"

  env                                   = local.env
  environment_code                      = local.environment_code
  access_context_manager_policy_id      = var.access_context_manager_policy_id
  perimeter_additional_members          = var.perimeter_additional_members
  perimeter_additional_members_dry_run  = var.perimeter_additional_members_dry_run
  default_region1                       = local.default_region1
  default_region2                       = local.default_region2
  domain                                = var.domain
  ingress_policies                      = var.ingress_policies
  ingress_policies_dry_run              = var.ingress_policies_dry_run
  egress_policies                       = var.egress_policies
  egress_policies_dry_run               = var.egress_policies_dry_run
  enable_partner_interconnect           = false
  base_private_service_cidr             = local.base_private_service_cidr
  base_subnet_primary_ranges            = local.base_subnet_primary_ranges
  base_subnet_proxy_ranges              = local.base_subnet_proxy_ranges
  base_subnet_secondary_ranges          = local.base_subnet_secondary_ranges
  base_private_service_connect_ip       = "10.17.0.4"
  restricted_private_service_cidr       = local.restricted_private_service_cidr
  restricted_subnet_proxy_ranges        = local.restricted_subnet_proxy_ranges
  restricted_subnet_primary_ranges      = local.restricted_subnet_primary_ranges
  restricted_subnet_secondary_ranges    = local.restricted_subnet_secondary_ranges
  restricted_private_service_connect_ip = "10.17.0.8"
  remote_state_bucket                   = var.remote_state_bucket
  tfc_org_name                          = var.tfc_org_name
  target_name_server_addresses          = var.target_name_server_addresses
}
