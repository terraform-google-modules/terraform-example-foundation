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

locals {
  envs = ["nonprod", "prod"]
  host_project_env_map = {for project in data.google_project.projects : project.labels.environment => project.project_id }
  env_project_map = {for env, project in local.host_project_env_map : project => env }
  network_env_map = {for network in data.google_compute_network.shared-vpcs : local.env_project_map[network.project] => network}
  monitor_project_env_map = {for project in data.google_project.projects-monitoring : project.labels.environment => project.project_id }
}

module "nonprod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  default_service_account     = "depriviledge"
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-nonprod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.project_folder_map["nonprod"]

  shared_vpc         = local.host_project_env_map["nonprod"]
  shared_vpc_subnets = local.network_env_map["nonprod"].subnetworks_self_links

  labels = {
    environment      = "nonprod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "prod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  default_service_account     = "depriviledge"
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-prod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.project_folder_map["prod"]

  shared_vpc         = local.host_project_env_map["prod"]
  shared_vpc_subnets = local.network_env_map["prod"].subnetworks_self_links

  labels = {
    environment      = "prod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

/******************************************
  Project subnets
 *****************************************/
module "networking_nonprod_project" {
  source              = "../../modules/project_subnet"
  vpc_host_project_id = local.host_project_env_map["nonprod"]
  vpc_self_link       = local.network_env_map["nonprod"].self_link
  ip_cidr_range       = var.subnet_allocation["nonprod"].primary_range
  application_name    = var.application_name
  secondary_ranges    = var.subnet_allocation["nonprod"].secondary_ranges
  enable_networking   = var.enable_networking
  project_id          = module.nonprod_project.project_id
}

module "networking_prod_project" {
  source              = "../../modules/project_subnet"
  vpc_host_project_id = local.host_project_env_map["prod"]
  vpc_self_link       = local.network_env_map["prod"].self_link
  ip_cidr_range       = var.subnet_allocation["prod"].primary_range
  application_name    = var.application_name
  secondary_ranges    = var.subnet_allocation["prod"].secondary_ranges
  enable_networking   = var.enable_networking
  project_id          = module.prod_project.project_id
}

/******************************************
  monitoring groups
 *****************************************/
resource "google_monitoring_group" "monitoring_nonprod" {
  display_name = "${var.application_name} - nonprod"
  filter       = "resource.metadata.cloud_account=\"${module.nonprod_project.project_id}\""
  project      = local.monitor_project_env_map["nonprod"].project_id
}

resource "google_monitoring_group" "monitoring_prod" {
  display_name = "${var.application_name} - prod"
  filter       = "resource.metadata.cloud_account=\"${module.prod_project.project_id}\""
  project      = local.monitor_project_env_map["prod"].project_id
}

/******************************************
  Private DNS Management
 *****************************************/
module "dns_nonprod" {
  source                = "../../modules/private_dns"
  enable_networking     = var.enable_networking
  project_id            = module.nonprod_project.project_id
  application_name      = var.application_name
  environment           = "nonprod"
  shared_vpc_self_link  = local.network_env_map["nonprod"].self_link
  shared_vpc_project_id = local.host_project_env_map["nonprod"]
  domain = var.domain
}

module "dns_prod" {
  source                = "../../modules/private_dns"
  enable_networking     = var.enable_networking
  project_id            = module.prod_project.project_id
  application_name      = var.application_name
  environment           = "prod"
  shared_vpc_self_link  = local.network_env_map["prod"].self_link
  shared_vpc_project_id = local.host_project_env_map["prod"]
  domain = var.domain
}