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
  parent          = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  folder_prefix   = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  tags            = data.terraform_remote_state.org.outputs.tags
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

module "l1_env" {
  source = "../../modules/folders_l1_env"

  count = var.is_environment_level_1 ? "${length(var.level_1_folders)}" : "0"

    folder_name             = "${lookup(var.level_1_folders[count.index],"folder_name")}"
    folder_abbreviated_name = "${lookup(var.level_1_folders[count.index],"folder_abbreviated_name")}"
    folder_prefix           = local.folder_prefix

    tfc_org_name    = var.tfc_org_name
    level_2_folders = var.level_2_folders

    project_deletion_policy    = var.project_deletion_policy
    folder_deletion_protection = var.folder_deletion_protection

    remote_state_bucket    = var.remote_state_bucket
    env_tag_value          = "${lookup(var.level_1_folders[count.index],"env_tag_value")}"
    is_environment_level_1 = var.is_environment_level_1
    assured_workload_enabled = var.assured_workload_enabled
    assured_workload_region = var.assured_workload_region
}

module "l1_not_env" {
  source = "../../modules/folders_l1_not_env"

  count = var.is_environment_level_1 ? "0" : "${length(var.level_1_folders)}"

    folder_name             = "${lookup(var.level_1_folders[count.index],"folder_name")}"
    folder_abbreviated_name = "${lookup(var.level_1_folders[count.index],"folder_abbreviated_name")}"
    folder_prefix           = local.folder_prefix

    tfc_org_name    = var.tfc_org_name
    level_2_folders = var.level_2_folders

    project_deletion_policy    = var.project_deletion_policy
    folder_deletion_protection = var.folder_deletion_protection

    parent = local.parent
    tags   = local.tags
}

