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
  ec  = substr(var.folder_name,0,1)
  env = substr(var.env_tag_value,12,13)

  assured_workload_configuration = var.is_environment_level_1 && local.ec == "p" ? {
    enabled           = var.assured_workload_enabled
    location          = var.assured_workload_region
    display_name      = "FEDRAMP-MODERATE"
    compliance_regime = "FEDRAMP_MODERATE"
    resource_type     = "CONSUMER_FOLDER"
  } : {}
}

module "env" {
  source = "../../modules/env_baseline"

  folder_name                = var.folder_name
  env                        = local.env
  environment_code           = local.ec
  remote_state_bucket        = var.remote_state_bucket
  tfc_org_name               = var.tfc_org_name
  project_deletion_policy    = var.project_deletion_policy
  folder_deletion_protection = var.folder_deletion_protection

  assured_workload_configuration = local.assured_workload_configuration
}

resource "google_folder" "l2" {
  count = "${length(var.level_2_folders)}"
    display_name        = "${var.folder_prefix}-${var.folder_abbreviated_name}-${lookup(var.level_2_folders[count.index],"folder_name")}"
    parent              = module.env.folder.id
    deletion_protection = var.folder_deletion_protection

    depends_on = [module.env]
}
