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

module "hierarchical_firewall_policy" {
  source = "../../modules/hierarchical_firewall_policy/"

  parent = local.common_folder_name
  name   = "common-firewall-rules"
  associations = [
    local.common_folder_name,
    local.network_folder_name,
    local.bootstrap_folder_name,
    local.development_folder_name,
    local.production_folder_name,
    local.nonproduction_folder_name,
  ]
  rules = {
    delegate-rfc1918-ingress = {
      description = "Delegate RFC1918 ingress"
      direction   = "INGRESS"
      action      = "goto_next"
      priority    = 500
      ranges = [
        "192.168.0.0/16",
        "10.0.0.0/8",
        "172.16.0.0/12"
      ]
      ports                   = { "all" = [] }
      target_service_accounts = null
      target_resources        = null
      logging                 = false
    }
    delegate-rfc1918-egress = {
      description = "Delegate RFC1918 egress"
      direction   = "EGRESS"
      action      = "goto_next"
      priority    = 510
      ranges = [
        "192.168.0.0/16",
        "10.0.0.0/8",
        "172.16.0.0/12"
      ]
      ports                   = { "all" = [] }
      target_service_accounts = null
      target_resources        = null
      logging                 = false
    }
    allow-iap-ssh-rdp = {
      description = "Always allow SSH and RDP from IAP"
      direction   = "INGRESS"
      action      = "allow"
      priority    = 5000
      ranges      = ["35.235.240.0/20"]
      ports = {
        tcp = ["22", "3389"]
      }
      target_service_accounts = null
      target_resources        = null
      logging                 = var.firewall_policies_enable_logging
    }
    allow-windows-activation = {
      description = "Always outgoing Windows KMS traffic (required to validate Windows licenses)"
      direction   = "EGRESS"
      action      = "allow"
      priority    = 5100
      ranges      = ["35.190.247.13/32"]
      ports = {
        tcp = ["1688"]
      }
      target_service_accounts = null
      target_resources        = null
      logging                 = var.firewall_policies_enable_logging
    }
    allow-google-hbs-and-hcs = {
      description = "Always allow connections from Google load balancer and health check ranges"
      direction   = "INGRESS"
      action      = "allow"
      priority    = 5200
      ranges = [
        "35.191.0.0/16",
        "130.211.0.0/22",
        "209.85.152.0/22",
        "209.85.204.0/22"
      ]
      ports = {
        tcp = ["80", "443"]
      }
      target_service_accounts = null
      target_resources        = null
      logging                 = var.firewall_policies_enable_logging
    }
  }
}
