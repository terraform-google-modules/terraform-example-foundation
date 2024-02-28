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

// These values are retrieved from the saved terraform state of the execution
// of step 0-bootstrap using the terraform_remote_state data source.
// These values can be overridden here if needed.
// Some values, like org_id, parent_folder, and parent, must be consistent in all steps.
locals {
  org_id                                        = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  parent_folder                                 = data.terraform_remote_state.bootstrap.outputs.common_config.parent_folder
  parent                                        = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  billing_account                               = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  default_region                                = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  project_prefix                                = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  folder_prefix                                 = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  networks_step_terraform_service_account_email = data.terraform_remote_state.bootstrap.outputs.networks_step_terraform_service_account_email
  org_step_terraform_service_account_email      = data.terraform_remote_state.bootstrap.outputs.organization_step_terraform_service_account_email
  bootstrap_folder_name                         = data.terraform_remote_state.bootstrap.outputs.common_config.bootstrap_folder_name
  cloud_build_private_worker_pool_id            = try(data.terraform_remote_state.bootstrap.outputs.cloud_build_private_worker_pool_id, "")
  required_groups                               = data.terraform_remote_state.bootstrap.outputs.required_groups
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}
