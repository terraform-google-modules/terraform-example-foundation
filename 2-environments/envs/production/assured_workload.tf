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

resource "google_folder" "assured_workload" {
  count = var.assured_workload_configuration != null && var.assured_workload_configuration.enabled ? 1 : 0

  display_name = "${var.folder_prefix}-assured-workload"
  parent       = module.env.env_folder
}

resource "google_assured_workloads_workload" "production" {
  provider = google-beta

  count = var.assured_workload_configuration != null && var.assured_workload_configuration.enabled ? 1 : 0

  billing_account              = "billingAccounts/${var.billing_account}"
  compliance_regime            = var.assured_workload_configuration.compliance_regime
  display_name                 = "Assured Workload Production"
  location                     = var.assured_workload_configuration.location
  organization                 = var.org_id
  provisioned_resources_parent = google_folder.assured_workload[0].name
}
