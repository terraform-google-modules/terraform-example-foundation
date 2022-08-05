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
  parent_folder             = data.terraform_remote_state.bootstrap.outputs.common_config.parent_folder
  org_id                    = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  billing_account           = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  default_region            = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  project_prefix            = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  folder_prefix             = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  parent                    = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  terraform_service_account = var.terraform_service_account
}
