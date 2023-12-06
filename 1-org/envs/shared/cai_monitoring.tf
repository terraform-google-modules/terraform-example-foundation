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

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.1"

  project_id      = module.scc_notifications.project_id
  keyring         = "krg-cai-monitoring"
  location        = local.default_region
  keys            = ["key-cai-monitoring"]
  prevent_destroy = !var.cai_monitoring_kms_force_destroy
}

module "cai_monitoring" {
  source = "../../modules/cai-monitoring"

  org_id               = local.org_id
  billing_account      = local.billing_account
  project_id           = module.scc_notifications.project_id
  location             = local.default_region
  enable_cmek          = true
  encryption_key       = module.kms.keys["key-cai-monitoring"]
  impersonate_sa_email = local.org_step_terraform_service_account_email
}
