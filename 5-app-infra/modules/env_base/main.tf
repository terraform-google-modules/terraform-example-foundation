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
  env_project_ids = {
    "sample-base"     = data.terraform_remote_state.projects_env.outputs.base_shared_vpc_project,
    "sample-floating" = data.terraform_remote_state.projects_env.outputs.floating_project,
    "sample-peering"  = data.terraform_remote_state.projects_env.outputs.peering_project,
    "sample-restrict" = data.terraform_remote_state.projects_env.outputs.restricted_shared_vpc_project,
  }
  env_project_subnets = {
    "sample-base"     = local.base_subnetwork_self_link,
    "sample-floating" = local.base_subnetwork_self_link,
    "sample-peering"  = data.terraform_remote_state.projects_env.outputs.peering_subnetwork_self_link,
    "sample-restrict" = local.base_subnetwork_self_link,
  }
  env_project_resource_manager_tags = {
    "sample-base"     = null,
    "sample-floating" = null,
    "sample-peering"  = data.terraform_remote_state.projects_env.outputs.iap_firewall_tags,
    "sample-restrict" = null,
  }

  subnetwork_self_links     = data.terraform_remote_state.projects_env.outputs.base_subnets_self_links
  base_subnetwork_self_link = [for subnet in local.subnetwork_self_links : subnet if length(regexall("regions/${var.region}/subnetworks", subnet)) > 0][0]

  env_project_id        = local.env_project_ids[var.project_suffix]
  subnetwork_self_link  = local.env_project_subnets[var.project_suffix]
  resource_manager_tags = local.env_project_resource_manager_tags[var.project_suffix]
}


data "terraform_remote_state" "projects_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/${var.environment}"
  }
}

resource "google_service_account" "compute_engine_service_account" {
  project                      = local.env_project_id
  account_id                   = "sa-example-app"
  display_name                 = "Example app service Account"
  create_ignore_already_exists = true
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 11.0"

  machine_type = var.machine_type
  region       = var.region
  project_id   = local.env_project_id
  subnetwork   = local.subnetwork_self_link

  metadata = {
    block-project-ssh-keys = "true"
  }

  service_account = {
    email  = google_service_account.compute_engine_service_account.email
    scopes = ["compute-rw"]
  }
}

module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 11.0"

  region                = var.region
  subnetwork            = local.subnetwork_self_link
  num_instances         = var.num_instances
  hostname              = var.hostname
  instance_template     = module.instance_template.self_link
  resource_manager_tags = local.resource_manager_tags
}
