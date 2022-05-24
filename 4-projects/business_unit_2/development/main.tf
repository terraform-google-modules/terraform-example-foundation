/**
 * Copyright 2022 Google LLC
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
  source = "../../modules/base_env"

  env                              = "development"
  business_code                    = "bu2"
  business_unit                    = "business_unit_2"
  org_id                           = var.org_id
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.access_context_manager_policy_id
  parent_folder                    = var.parent_folder
  perimeter_name                   = var.perimeter_name
  peering_module_depends_on        = var.peering_module_depends_on
  project_prefix                   = var.project_prefix
  folder_prefix                    = var.folder_prefix
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  app_infra_pipeline_cloudbuild_sa = var.app_infra_pipeline_cloudbuild_sa
}
