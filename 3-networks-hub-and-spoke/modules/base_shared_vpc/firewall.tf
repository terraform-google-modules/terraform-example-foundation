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

/******************************************
  Mandatory firewall rules
 *****************************************/
module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/network-firewall-policy"
  version      = "~> 8.0"
  project_id   = var.project_id
  policy_name  = "fp-${var.environment_code}-dual-svpc-firewalls"
  description  = "Mandatory firewall rules for dual shared vpc."
  target_vpcs  = [module.main.network_name]

  rules = concat(
    [
      {
        priority       = "65530"
        direction      = "EGRESS"
        action         = "deny"
        rule_name      = "fw-${var.environment_code}-shared-base-65530-e-d-all-all-all"
        description    = "deny_all_egress #TODO: Fill description"
        enable_logging = var.firewall_enable_logging
        match = {
          dest_ip_ranges = ["0.0.0.0/0"]
          layer4_configs = [
            {
              ip_protocol = "all"
            },
          ]
        }
      },
      {
        priority       = "65430"
        direction      = "EGRESS"
        action         = "allow"
        rule_name      = "fw-${var.environment_code}-shared-base-65430-e-a-allow-google-apis-all-tcp-443"
        description    = "allow_private_api_egress #TODO: Fill description"
        enable_logging = var.firewall_enable_logging
        match = {
          dest_ip_ranges  = [local.private_googleapis_cidr]
          src_secure_tags = ["allow-google-apis"]
          layer4_configs = [
            {
              ip_protocol = "tcp"
              ports       = ["443"]
            },
          ]
        }
      }
    ], 
    !var.allow_all_egress_ranges ? [] : [
      {
        priority       = "1000"
        direction      = "EGRESS"
        action         = "allow"
        rule_name      = "fw-${var.environment_code}-shared-base-1000-e-a-all-all-all"
        description    = "allow_all_egress #TODO: Fill description"
        enable_logging = var.firewall_enable_logging
        match = {
          dest_ip_ranges = var.allow_all_egress_ranges
          layer4_configs = [
            {
              ip_protocol = "all"
            },
          ]
        }
      }
    ],
    !var.allow_all_ingress_ranges ? [] : [
      {
        priority       = "1001"
        direction      = "INGRESS"
        action         = "allow"
        rule_name      = "fw-${var.environment_code}-shared-base-1001-i-a-all"
        description    = "allow_all_ingress #TODO: Fill description"
        enable_logging = var.firewall_enable_logging
        match = {
          src_ip_ranges = var.allow_all_ingress_ranges
          layer4_configs = [
            {
              ip_protocol = "all"
            },
          ]
        }
      },
    ]
  )
}
