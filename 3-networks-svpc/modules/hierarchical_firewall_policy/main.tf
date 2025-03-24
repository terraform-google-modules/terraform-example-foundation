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
  policy_id = google_compute_firewall_policy.policy.id
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "google_compute_firewall_policy" "policy" {
  short_name = "${var.name}-${random_string.suffix.result}"
  parent     = var.parent
}

resource "google_compute_firewall_policy_rule" "rule" {
  for_each = var.rules

  firewall_policy         = google_compute_firewall_policy.policy.id
  action                  = each.value.action
  direction               = each.value.direction
  priority                = each.value.priority
  target_resources        = each.value.target_resources
  target_service_accounts = each.value.target_service_accounts
  enable_logging          = each.value.logging
  # preview                 = each.value.preview
  match {
    # description = each.value.description

    src_ip_ranges  = each.value.direction == "INGRESS" ? each.value.ranges : null
    dest_ip_ranges = each.value.direction == "EGRESS" ? each.value.ranges : null
    dynamic "layer4_configs" {
      for_each = each.value.ports
      iterator = port
      content {
        ip_protocol = port.key
        ports       = port.value
      }
    }
  }
}

resource "google_compute_firewall_policy_association" "association" {
  for_each = toset(var.associations)

  name              = replace("${local.policy_id}-${each.value}", "/", "-")
  firewall_policy   = google_compute_firewall_policy.policy.id
  attachment_target = each.value
}
