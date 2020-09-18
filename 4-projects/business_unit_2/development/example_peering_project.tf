/**
 * Copyright 2020 Google LLC
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

 data "google_projects" "projects" {
  count  = var.vpc_type == "" ? 0 : 1
  filter = "parent.id:${split("/", var.folder_id)[1]} labels.application_name=${var.vpc_type}-shared-vpc-host labels.environment=${var.environment} lifecycleState=ACTIVE"
}

data "google_compute_network" "shared_vpc" {
  count   = var.vpc_type == "" ? 0 : 1
  name    = "vpc-${local.env_code}-shared-${var.vpc_type}"
  project = data.google_projects.projects[0].projects[0].project_id
}


locals {
  vpc_name                = "d-peering-base"
  network_name            = "vpc-${local.vpc_name}"
}

module "peering_project" {
  source                      = "../../modules/single_project"
  impersonate_service_account = var.terraform_service_account
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = data.google_active_folder.env.name
  skip_gcloud_download        = var.skip_gcloud_download
  environment                 = "development"

  # Metadata
  project_prefix    = "sample-peering"
  application_name  = "bu1-sample-peering"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu1"
}

module "peering_network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 2.0"
  project_id                             = module.peering_project.project_id
  network_name                           = local.network_name
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "true"
}

module "peering" {
  source = "terraform-google-modules/network/google//modules/network-peering"

  prefix        = "bu1-d"
  local_network = module.peering_network.network_self_link
  peer_network  = data.google_compute_network.shared_vpc[0].network_self_link
}
