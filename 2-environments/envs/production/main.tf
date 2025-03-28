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

module "env" {
  source = "../../modules/env_baseline"

  env                 = "production"
  environment_code    = "p"
  remote_state_bucket = var.remote_state_bucket
  tfc_org_name        = var.tfc_org_name

  project_deletion_policy    = var.project_deletion_policy
  folder_deletion_protection = var.folder_deletion_protection

  assured_workload_configuration = {
    enabled           = false
    location          = "us-central1"
    display_name      = "FEDRAMP-MODERATE"
    compliance_regime = "FEDRAMP_MODERATE"
    resource_type     = "CONSUMER_FOLDER"
  }
}
