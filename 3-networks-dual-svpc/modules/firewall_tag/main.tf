/**
 * Copyright 2023 Google LLC
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
  name_prefix = "fw-${var.environment_code}-tag"
}

resource "google_compute_network_firewall_policy" "firewall_tag_policy" {
  name        = "${local.name_prefix}-policy"
  description = "Sample global network firewall policy"
  project     = var.project_id
}

resource "google_compute_network_firewall_policy_rule" "allow_all_ingress" {
  rule_name       = "${local.name_prefix}-allow-all-ingress"
  description     = "This rule enables all ingress."
  project         = var.project_id
  action          = "allow"
  direction       = "INGRESS"
  disabled        = false
  enable_logging  = true
  firewall_policy = google_compute_network_firewall_policy.firewall_tag_policy.name
  priority        = 1000

  match {
    src_ip_ranges = ["0.0.0.0/0"]

    dynamic "src_secure_tags" {
      for_each = google_tags_tag_value.firewall_tag_value
      content {
        name = "tagValues/${src_secure_tags.value.name}"
      }
    }

    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "allow_all_egress" {
  rule_name       = "${local.name_prefix}-allow-all-egress"
  description     = "This rule enables all egress."
  project         = var.project_id
  action          = "allow"
  direction       = "EGRESS"
  disabled        = false
  enable_logging  = true
  firewall_policy = google_compute_network_firewall_policy.firewall_tag_policy.name
  priority        = 1000

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "all"

      dynamic "target_secure_tags" {
        for_each = google_tags_tag_value.firewall_tag_value
        content {
          name = "tagValues/${target_secure_tags.value.name}"
        }
      }
    }
  }
}

resource "google_compute_network_firewall_policy_association" "firewall_tag_policy_association" {
  name              = "${local.name_prefix}-association"
  project           = var.project_id
  attachment_target = var.network_id
  firewall_policy   = google_compute_network_firewall_policy.firewall_tag_policy.name
}

resource "google_tags_tag_key" "firewall_tag_key" {
  short_name  = "${local.name_prefix}-key"
  description = "Secure firewall tag key for environment ${var.environment_code}."
  parent      = "projects/${var.project_id}"
  purpose     = "GCE_FIREWALL"

  purpose_data = {
    network = "${var.project_id}/${var.network_name}"
  }
}

resource "google_tags_tag_value" "firewall_tag_value" {
  for_each = toset(var.business_unit)

  short_name  = "${local.name_prefix}-${each.value}"
  description = "Secure firewall tag value for BU ${each.value} and environment ${var.environment_code}."
  parent      = "tagKeys/${google_tags_tag_key.firewall_tag_key.name}"
}
