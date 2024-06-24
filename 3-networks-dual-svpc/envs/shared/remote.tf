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
  env                       = "common"
  environment_code          = "c"
  dns_bgp_asn_number        = var.enable_partner_interconnect ? "16550" : var.bgp_asn_dns
  default_region1           = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  default_region2           = data.terraform_remote_state.bootstrap.outputs.common_config.default_region_2
  folder_prefix             = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  dns_hub_project_id        = data.terraform_remote_state.org.outputs.dns_hub_project_id
  interconnect_project_id   = data.terraform_remote_state.org.outputs.interconnect_project_id
  parent_id                 = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  bootstrap_folder_name     = data.terraform_remote_state.bootstrap.outputs.common_config.bootstrap_folder_name
  common_folder_name        = data.terraform_remote_state.org.outputs.common_folder_name
  network_folder_name       = data.terraform_remote_state.org.outputs.network_folder_name
  development_folder_name   = data.terraform_remote_state.env_development.outputs.env_folder
  nonproduction_folder_name = data.terraform_remote_state.env_nonproduction.outputs.env_folder
  production_folder_name    = data.terraform_remote_state.env_production.outputs.env_folder
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

data "terraform_remote_state" "env_development" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/development"
  }
}

data "terraform_remote_state" "env_nonproduction" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/nonproduction"
  }
}

data "terraform_remote_state" "env_production" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/production"
  }
}
