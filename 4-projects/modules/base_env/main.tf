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

locals {
  terraform_service_account        = var.terraform_service_account
  parent_folder                    = data.terraform_remote_state.bootstrap.outputs.common_config.parent_folder
  org_id                           = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  billing_account                  = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  default_region                   = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  project_prefix                   = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  folder_prefix                    = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  parent                           = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  perimeter_name                   = data.terraform_remote_state.network_env.outputs.restricted_service_perimeter_name
  base_network_self_link           = data.terraform_remote_state.network_env.outputs.base_network_self_link
  base_subnets_self_links          = data.terraform_remote_state.network_env.outputs.base_subnets_self_links
  base_host_project_id             = data.terraform_remote_state.network_env.outputs.base_host_project_id
  restricted_host_project_id       = data.terraform_remote_state.network_env.outputs.restricted_host_project_id
  restricted_subnets_self_links    = data.terraform_remote_state.network_env.outputs.restricted_subnets_self_links
  access_context_manager_policy_id = data.terraform_remote_state.network_env.outputs.access_context_manager_policy_id
  env_folder_name                  = data.terraform_remote_state.environments_env.outputs.env_folder
  app_infra_pipeline_cloudbuild_sa = data.terraform_remote_state.business_unit_shared.outputs.cloudbuild_sa
}
