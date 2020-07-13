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
  prod_project_id   = data.google_projects.prod_project.projects[0].project_id
  prod_host_network = data.google_compute_network.prod_shared_vpc

  nonprod_project_id   = data.google_projects.nonprod_project.projects[0].project_id
  nonprod_host_network = data.google_compute_network.nonprod_shared_vpc

  dev_project_id   = data.google_projects.dev_project.projects[0].project_id
  dev_host_network = data.google_compute_network.dev_shared_vpc
}

module "nonprod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-nonprod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.nonprod_folder_id

  shared_vpc         = local.nonprod_host_network.project
  shared_vpc_subnets = local.nonprod_host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_nonprod_project.subnetwork_self_link"

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
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-prod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.prod_folder_id

  shared_vpc         = local.prod_host_network.project
  shared_vpc_subnets = local.prod_host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_prod_project.subnetwork_self_link"

  labels = {
    environment      = "prod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "dev_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-dev"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.dev_folder_id

  shared_vpc         = local.dev_host_network.project
  shared_vpc_subnets = local.dev_host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_dev_project.subnetwork_self_link"

  labels = {
    environment      = "dev"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

/******************************************
  Project subnets (Optional)
 *****************************************/
# module "networking_nonprod_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.nonprod_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking

#   application_name    = var.application_name
#   vpc_host_project_id = local.nonprod_host_network.project
#   vpc_self_link       = local.nonprod_host_network.self_link
#   ip_cidr_range       = var.nonprod_subnet_ip_cidr_range
#   secondary_ranges    = var.nonprod_subnet_secondary_ranges
# }

# module "networking_prod_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.prod_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking
#   application_name    = var.application_name
#   vpc_host_project_id = local.prod_host_network.project
#   vpc_self_link       = local.prod_host_network.self_link
#   ip_cidr_range       = var.prod_subnet_ip_cidr_range
#   secondary_ranges    = var.prod_subnet_secondary_ranges
# }

# module "networking_dev_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.dev_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking
#   application_name    = var.application_name
#   vpc_host_project_id = local.dev_host_network.project
#   vpc_self_link       = local.dev_host_network.self_link
#   ip_cidr_range       = var.dev_subnet_ip_cidr_range
#   secondary_ranges    = var.dev_subnet_secondary_ranges
# }

/******************************************
  Private DNS Management (Optional)
 *****************************************/
# module "dns_nonprod" {
#   source = "../../modules/private_dns"

#   project_id            = module.nonprod_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "nonprod"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.nonprod_host_network.self_link
#   shared_vpc_project_id = local.nonprod_host_network.project
# }

# module "dns_prod" {
#   source = "../../modules/private_dns"

#   project_id            = module.prod_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "prod"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.prod_host_network.self_link
#   shared_vpc_project_id = local.prod_host_network.project
# }

# module "dns_dev" {
#   source = "../../modules/private_dns"

#   project_id            = module.dev_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "dev"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.dev_host_network.self_link
#   shared_vpc_project_id = local.dev_host_network.project
# }
