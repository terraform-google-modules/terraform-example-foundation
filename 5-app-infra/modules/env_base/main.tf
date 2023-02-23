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
  env_project_id        = local.env_project_ids[var.project_suffix]
  subnetwork_self_links = data.terraform_remote_state.projects_env.outputs.base_subnets_self_links
  subnetwork_self_link  = [for subnet in local.subnetwork_self_links : subnet if length(regexall("regions/${var.region}/subnetworks", subnet)) > 0][0]
}


data "terraform_remote_state" "projects_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/${var.environment}"
  }
}

resource "google_service_account" "compute_engine_service_account" {
  project      = local.env_project_id
  account_id   = "sa-example-app"
  display_name = "Example app service Account"
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 8.0"

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
  version = "~> 8.0"

  region            = var.region
  subnetwork        = local.subnetwork_self_link
  num_instances     = var.num_instances
  hostname          = var.hostname
  instance_template = module.instance_template.self_link
}
