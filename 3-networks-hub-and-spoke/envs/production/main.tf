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
  env              = "production"
  environment_code = substr(local.env, 0, 1)

  private_service_cidr = "10.16.56.0/21"
  subnet_primary_ranges = {
    (local.default_region1) = "10.8.192.0/18"
    (local.default_region2) = "10.9.192.0/18"
  }
  subnet_proxy_ranges = {
    (local.default_region1) = "10.26.6.0/23"
    (local.default_region2) = "10.27.6.0/23"
  }
  subnet_secondary_ranges = {
    (local.default_region1) = [
      {
        range_name    = "rn-${local.environment_code}-svpc-${local.default_region1}-gke-pod"
        ip_cidr_range = "100.72.192.0/18"
      },
      {
        range_name    = "rn-${local.environment_code}-svpc-${local.default_region1}-gke-svc"
        ip_cidr_range = "100.73.192.0/18"
      }
    ]
  }
}

module "base_env" {
  source = "../../modules/base_env"

  env                               = local.env
  environment_code                  = local.environment_code
  access_context_manager_policy_id  = var.access_context_manager_policy_id
  default_region1                   = local.default_region1
  default_region2                   = local.default_region2
  domain                            = var.domain
  enable_partner_interconnect       = false
  enable_hub_and_spoke_transitivity = var.enable_hub_and_spoke_transitivity
  private_service_cidr              = local.private_service_cidr
  subnet_primary_ranges             = local.subnet_primary_ranges
  subnet_proxy_ranges               = local.subnet_proxy_ranges
  subnet_secondary_ranges           = local.subnet_secondary_ranges
  private_service_connect_ip        = "10.17.0.8"
  remote_state_bucket               = var.remote_state_bucket
  tfc_org_name                      = var.tfc_org_name
}
