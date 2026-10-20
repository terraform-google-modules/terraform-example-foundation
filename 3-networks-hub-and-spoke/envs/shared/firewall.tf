/**
 * Copyright 2026 Google LLC
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
  Allow HTTP (TCP Port 80) to Google APIs PSC
  Required for PKI / AIA / CRL certificate validation (RFC 5280)
  for Hub VPC.
 *****************************************/

resource "google_compute_network_firewall_policy_rule" "allow_google_apis_http" {
  count = local.private_service_connect_ip != null && local.private_service_connect_ip != "" ? 1 : 0

  project         = local.net_hub_project_id
  firewall_policy = module.shared_vpc.firewall_policy[0].name
  rule_name       = "fw-${local.environment_code}-svpc-1001-e-a-allow-google-apis-all-tcp-80"
  description     = "Allow Google APIs and PKI AIA / CRL certificate validation on TCP port 80."
  priority        = 1001
  direction       = "EGRESS"
  action          = "allow"
  enable_logging  = var.hub_firewall_enable_logging

  match {
    dest_ip_ranges = [local.private_service_connect_ip]
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80"]
    }
  }

  # Ensure module.shared_vpc completes all internal firewall rule creations
  # before mutating the policy to avoid GCP compute API concurrent operation lockouts (HTTP 409).
  depends_on = [
    module.shared_vpc
  ]
}
