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

resource "google_assured_workloads_workload" "workload" {
  count = var.assured_workload_configuration.enabled ? 1 : 0

  organization                 = local.org_id
  billing_account              = "billingAccounts/${local.billing_account}"
  provisioned_resources_parent = google_folder.env.id
  compliance_regime            = var.assured_workload_configuration.compliance_regime
  display_name                 = var.assured_workload_configuration.display_name
  location                     = var.assured_workload_configuration.location

  resource_settings {
    resource_type = var.assured_workload_configuration.resource_type
  }
}
