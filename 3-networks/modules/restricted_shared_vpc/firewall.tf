/**
 * Copyright 2020 Google LLC
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
resource "google_compute_firewall" "deny_all_egress" {
  name           = "fw-${var.environment_code}-shared-restricted-65535-e-d-all-all-tcp-udp"
  network        = module.main.network_name
  project        = var.project_id
  direction      = "EGRESS"
  priority       = 65535
  enable_logging = var.firewall_enable_logging

  deny {
    protocol = "tcp"
  }

  deny {
    protocol = "udp"
  }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_restricted_api_egress" {
  name           = "fw-${var.environment_code}-shared-restricted-65534-e-a-allow-google-api-all-tcp-443"
  network        = module.main.network_name
  project        = var.project_id
  direction      = "EGRESS"
  priority       = 65534
  enable_logging = var.firewall_enable_logging

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = [local.restricted_googleapis_cidr]

  target_tags = ["allow-google-api"]
}

/******************************************
  Optional firewall rules
 *****************************************/

// Allow SSH via IAP when using the allow-iap-ssh tag for Linux workloads.
resource "google_compute_firewall" "allow_iap_ssh" {
  count          = var.optional_fw_rules_enabled ? 1 : 0
  name           = "fw-${var.environment_code}-shared-restricted-1000-i-a-all-allow-iap-ssh-tcp-22"
  network        = module.main.network_name
  project        = var.project_id
  enable_logging = var.firewall_enable_logging

  // Cloud IAP's TCP forwarding netblock
  source_ranges = data.google_netblock_ip_ranges.iap_forwarders.cidr_blocks_ipv4

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["allow-iap-ssh"]
}

// Allow RDP via IAP when using the allow-iap-rdp tag for Windows workloads.
resource "google_compute_firewall" "allow_iap_rdp" {
  count          = var.optional_fw_rules_enabled ? 1 : 0
  name           = "fw-${var.environment_code}-shared-restricted-1000-i-a-all-allow-iap-rdp-tcp-3389"
  network        = module.main.network_name
  project        = var.project_id
  enable_logging = var.firewall_enable_logging

  // Cloud IAP's TCP forwarding netblock
  source_ranges = data.google_netblock_ip_ranges.iap_forwarders.cidr_blocks_ipv4

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  target_tags = ["allow-iap-rdp"]
}

// Allow traffic for Internal & Global load balancing health check and load balancing IP ranges.
resource "google_compute_firewall" "allow_lb" {
  count          = var.optional_fw_rules_enabled ? 1 : 0
  name           = "fw-${var.environment_code}-shared-restricted-1000-i-a-all-allow-lb-tcp-80-8080-443"
  network        = module.main.network_name
  project        = var.project_id
  enable_logging = var.firewall_enable_logging

  source_ranges = concat(data.google_netblock_ip_ranges.health_checkers.cidr_blocks_ipv4, data.google_netblock_ip_ranges.legacy_health_checkers.cidr_blocks_ipv4)

  // Allow common app ports by default.
  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  target_tags = ["allow-lb"]
}

// Allow access to kms.windows.googlecloud.com for Windows license activation
resource "google_compute_firewall" "allow_windows_activation" {
  count          = var.windows_activation_enabled ? 1 : 0
  name           = "fw-${var.environment_code}-shared-restricted-0-e-a-allow-win-all-tcp-1688"
  network        = module.main.network_name
  project        = var.project_id
  direction      = "EGRESS"
  priority       = 0
  enable_logging = var.firewall_enable_logging

  allow {
    protocol = "tcp"
    ports    = ["1688"]
  }

  destination_ranges = ["35.190.247.13/32"]

  target_tags = ["allow-win"]
}
