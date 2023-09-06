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
  name_prefix = "firewall-tag-${var.environment_code}"
}

resource "google_compute_network_firewall_policy" "firewall_tag_policy" {
  name        = "${local.name_prefix}-policy"
  description = "Sample global network firewall policy"
  project     = var.project_id
}

resource "google_compute_network_firewall_policy_rule" "firewall_tag_policy_rule" {
  rule_name       = "${local.name_prefix}-policy-rule"
  description     = "This is a simple rule description"
  project         = var.project_id
  action          = "allow"   #TODO: To be defined
  direction       = "INGRESS" #TODO: To be defined
  disabled        = false
  enable_logging  = true
  firewall_policy = google_compute_network_firewall_policy.firewall_tag_policy.name
  priority        = 1000

  match {
    src_ip_ranges            = ["10.100.0.1/32"]              #TODO: To be defined
    src_fqdns                = ["google.com"]                 #TODO: To be defined
    src_region_codes         = ["US"]                         #TODO: To be defined
    src_threat_intelligences = ["iplist-known-malicious-ips"] #TODO: To be defined
    # src_address_groups = [google_network_security_address_group.basic_global_networksecurity_address_group.id]

    src_secure_tags {
      name = "tagValues/${google_tags_tag_value.firewall_tag_value.name}"
    }

    layer4_configs {
      ip_protocol = "all"
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
  description = "For keyname resources."
  parent      = "projects/${var.project_id}"
  purpose     = "GCE_FIREWALL"

  purpose_data = {
    network = "${var.project_id}/${var.network_name}"
  }
}

resource "google_tags_tag_value" "firewall_tag_value" {
  short_name  = "${local.name_prefix}-value"
  description = "For valuename resources."
  parent      = "tagKeys/${google_tags_tag_key.firewall_tag_key.name}"
}
