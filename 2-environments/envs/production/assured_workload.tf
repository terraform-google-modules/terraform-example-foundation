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
  assured_workloads_folder = "${var.folder_prefix}-assured-workloads"
  enable_assured_workload  = lookup(var.assured_workload_configuration, "enabled", false)
  assured_workload_project = "${var.project_prefix}-p-aw-regional"
}

resource "google_folder" "assured_workloads" {
  display_name = local.assured_workloads_folder
  parent       = module.env.env_folder
}

resource "google_assured_workloads_workload" "workload" {
  count = local.enable_assured_workload ? 1 : 0

  billing_account              = "billingAccounts/${var.billing_account}"
  compliance_regime            = var.assured_workload_configuration.compliance_regime
  display_name                 = "${var.folder_prefix}-workload"
  location                     = var.assured_workload_configuration.location
  organization                 = var.org_id
  provisioned_resources_parent = google_folder.assured_workloads.name

  resource_settings {
    resource_id   = local.assured_workload_project
    resource_type = "CONSUMER_PROJECT"
  }
}
