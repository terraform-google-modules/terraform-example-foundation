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

locals {
  # Build map of firewall rules including full service account e-mail.
  firewall_rules_map = {
    for x in var.firewall_rules :
    "${var.application_name}-${x.rule_name}" => {
      rule_name      = x.rule_name
      allow_protocol = x.allow_protocol
      allow_ports    = x.allow_ports
      source_service_accounts = toset(flatten([
        for source_acc in x.source_service_accounts : [
          "${source_acc}@${var.project_id}.iam.gserviceaccount.com"
        ]
      ]))
      target_service_accounts = toset(flatten([
        for target_acc in x.target_service_accounts : [
          "${target_acc}@${var.project_id}.iam.gserviceaccount.com"
        ]
      ]))
    }
  }
  # Build a unique list of source service accounts.
  source_service_accounts = flatten([
    for rule in var.firewall_rules : [
      for source_acc in rule.source_service_accounts : [
        source_acc
      ]
    ]
  ])
  # Build a unique list of target service accounts.
  target_service_accounts = flatten([
    for rule in var.firewall_rules : [
      for target_acc in rule.target_service_accounts : [
        target_acc
      ]
    ]
  ])
  all_service_accounts = toset(concat(local.source_service_accounts, local.target_service_accounts))

  # Toggle creation according to flag.
  firewall_rules   = var.enable_networking == true ? local.firewall_rules_map : {}
  service_accounts = var.enable_networking == true ? local.all_service_accounts : []
}

/******************************************
  Firewall rule creation.
 *****************************************/

resource "google_compute_firewall" "project_firewall_rules" {
  for_each = local.firewall_rules
  project  = var.vpc_host_project_id
  name     = "${var.application_name}-${each.value.rule_name}"
  network  = var.vpc_self_link

  allow {
    protocol = each.value.allow_protocol
    ports    = each.value.allow_ports
  }

  source_service_accounts = each.value.source_service_accounts
  target_service_accounts = each.value.target_service_accounts

  # Make sure service accounts have been created first.
  depends_on = [
    google_service_account.service_accounts
  ]
}

/******************************************
  Service account creation
 *****************************************/

resource "google_service_account" "service_accounts" {
  for_each     = local.service_accounts
  project      = var.project_id
  account_id   = each.value
  display_name = each.value
}