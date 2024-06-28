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

module "cai_monitoring" {
  source = "../../modules/cai-monitoring"

  org_id                = local.org_id
  billing_account       = local.billing_account
  project_id            = module.scc_notifications.project_id
  location              = local.default_region
  build_service_account = "projects/${module.scc_notifications.project_id}/serviceAccounts/${google_service_account.cai_monitoring_builder.email}"
}
