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
  filter = "parent.id:${split("/", data.google_active_folder.env.name)[1]} labels.application_name=base-shared-vpc-host labels.environment=production lifecycleState=ACTIVE"
}

data "google_compute_network" "shared_vpc" {
  name    = "vpc-p-shared-base"
  project = data.google_projects.projects.projects[0].project_id
}

module "peering_project" {
  source                      = "../../modules/single_project"
  impersonate_service_account = var.terraform_service_account
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = data.google_active_folder.env.name
  skip_gcloud_download        = var.skip_gcloud_download
  environment                 = "production"

  # Metadata
  project_prefix    = "sample-peering"
  application_name  = "bu2-sample-peering"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu2"
}

module "peering_network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 2.0"
  project_id                             = module.peering_project.project_id
  network_name                           = "vpc-p-peering-base"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "true"
  subnets                                = []
}

module "peering" {
  source = "terraform-google-modules/network/google//modules/network-peering"
  prefix        = "bu2-p"
  local_network = module.peering_network.network_self_link
  peer_network  = data.google_compute_network.shared_vpc.self_link
}
