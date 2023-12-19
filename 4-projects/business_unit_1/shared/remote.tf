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
  org_id                             = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  parent_folder                      = data.terraform_remote_state.bootstrap.outputs.common_config.parent_folder
  parent                             = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  billing_account                    = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  common_folder_name                 = data.terraform_remote_state.org.outputs.common_folder_name
  default_region                     = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  project_prefix                     = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  folder_prefix                      = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  projects_remote_bucket_tfstate     = data.terraform_remote_state.bootstrap.outputs.projects_gcs_bucket_tfstate
  cloud_build_private_worker_pool_id = try(data.terraform_remote_state.bootstrap.outputs.cloud_build_private_worker_pool_id, "")
  cloud_builder_artifact_repo        = try(data.terraform_remote_state.bootstrap.outputs.cloud_builder_artifact_repo, "")
  enable_cloudbuild_deploy           = local.cloud_builder_artifact_repo != ""
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}
