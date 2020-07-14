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
  base_prod_project_id   = data.google_projects.base_prod_project.projects[0].project_id
  base_prod_host_network = data.google_compute_network.base_prod_shared_vpc

  restricted_prod_project_id   = data.google_projects.restricted_prod_project.projects[0].project_id
  restricted_prod_host_network = data.google_compute_network.restricted_prod_shared_vpc

  base_nonprod_project_id   = data.google_projects.base_nonprod_project.projects[0].project_id
  base_nonprod_host_network = data.google_compute_network.base_nonprod_shared_vpc

  restricted_nonprod_project_id   = data.google_projects.restricted_nonprod_project.projects[0].project_id
  restricted_nonprod_host_network = data.google_compute_network.restricted_nonprod_shared_vpc

  base_dev_project_id   = data.google_projects.base_dev_project.projects[0].project_id
  base_dev_host_network = data.google_compute_network.base_dev_shared_vpc

  restricted_dev_project_id   = data.google_projects.restricted_dev_project.projects[0].project_id
  restricted_dev_host_network = data.google_compute_network.restricted_dev_shared_vpc
}

module "base_nonprod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-nonprod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.nonprod_folder_id

  shared_vpc         = local.base_nonprod_host_network.project
  shared_vpc_subnets = local.base_nonprod_host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_nonprod_project.subnetwork_self_link"

  labels = {
    environment      = "nonprod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "restricted_nonprod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-nonprod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.nonprod_folder_id

  shared_vpc         = local.restricted_nonprod_host_network.project
  shared_vpc_subnets = local.restricted_nonprod_host_network.subnetworks_self_links # Optional: To enable subnetting, to >

  labels = {
    environment      = "nonprod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "base_prod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-prod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.prod_folder_id

  shared_vpc         = local.base_prod_host_network.project
  shared_vpc_subnets = local.base_prod_host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_prod_project.subnetwork_self_link"

  labels = {
    environment      = "prod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "restricted_prod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-prod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.prod_folder_id

  shared_vpc         = local.restricted_prod_host_network.project
  shared_vpc_subnets = local.restricted_prod_host_network.subnetworks_self_links # Optional: To enable subnetting, to rep>

  labels = {
    environment      = "prod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "base_dev_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-dev"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.dev_folder_id

  shared_vpc         = local.base_dev_host_network.project
  shared_vpc_subnets = local.base_dev_host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_dev_project.subnetwork_self_link"

  labels = {
    environment      = "dev"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "restricted_dev_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-dev"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.dev_folder_id

  shared_vpc         = local.restricted_dev_host_network.project
  shared_vpc_subnets = local.restricted_dev_host_network.subnetworks_self_links # Optional: To enable subnetting, to repl>

  labels = {
    environment      = "dev"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

/******************************************
  Project subnets (Optional)
 *****************************************/
# module "base_networking_nonprod_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.base_nonprod_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking

#   application_name    = var.application_name
#   vpc_host_project_id = local.base_nonprod_host_network.project
#   vpc_self_link       = local.base_nonprod_host_network.self_link
#   ip_cidr_range       = var.base_nonprod_subnet_ip_cidr_range
#   secondary_ranges    = var.base_nonprod_subnet_secondary_ranges
# }

# module "restricted_networking_nonprod_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.restricted_nonprod_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking

#   application_name    = var.application_name
#   vpc_host_project_id = local.restricted_nonprod_host_network.project
#   vpc_self_link       = local.restricted_nonprod_host_network.self_link
#   ip_cidr_range       = var.restricted_nonprod_subnet_ip_cidr_range
#   secondary_ranges    = var.restricted_nonprod_subnet_secondary_ranges
# }

# module "base_networking_prod_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.base_prod_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking
#   application_name    = var.application_name
#   vpc_host_project_id = local.base_prod_host_network.project
#   vpc_self_link       = local.base_prod_host_network.self_link
#   ip_cidr_range       = var.base_prod_subnet_ip_cidr_range
#   secondary_ranges    = var.base_prod_subnet_secondary_ranges
# }

# module "restricted_networking_prod_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.restricted_prod_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking
#   application_name    = var.application_name
#   vpc_host_project_id = local.restricted_prod_host_network.project
#   vpc_self_link       = local.restricted_prod_host_network.self_link
#   ip_cidr_range       = var.restricted_prod_subnet_ip_cidr_range
#   secondary_ranges    = var.restricted_prod_subnet_secondary_ranges
# }

# module "base_networking_dev_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.base_dev_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking
#   application_name    = var.application_name
#   vpc_host_project_id = local.base_dev_host_network.project
#   vpc_self_link       = local.base_dev_host_network.self_link
#   ip_cidr_range       = var.base_dev_subnet_ip_cidr_range
#   secondary_ranges    = var.base_dev_subnet_secondary_ranges
# }

# module "restricted_networking_dev_project" {
#   source = "../../modules/project_subnet"

#   project_id          = module.restricted_dev_project.project_id
#   default_region      = var.default_region
#   enable_networking   = var.enable_networking
#   application_name    = var.application_name
#   vpc_host_project_id = local.restricted_dev_host_network.project
#   vpc_self_link       = local.restricted_dev_host_network.self_link
#   ip_cidr_range       = var.restricted_dev_subnet_ip_cidr_range
#   secondary_ranges    = var.restricted_dev_subnet_secondary_ranges
# }

/******************************************
  Private DNS Management (Optional)
 *****************************************/
# module "base_dns_nonprod" {
#   source = "../../modules/private_dns"

#   project_id            = module.base_nonprod_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "nonprod"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.base_nonprod_host_network.self_link
#   shared_vpc_project_id = local.base_nonprod_host_network.project
# }

# module "restricted_dns_nonprod" {
#   source = "../../modules/private_dns"

#   project_id            = module.restricted_nonprod_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "nonprod"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.restricted_nonprod_host_network.self_link
#   shared_vpc_project_id = local.restricted_nonprod_host_network.project
# }

# module "base_dns_prod" {
#   source = "../../modules/private_dns"

#   project_id            = module.base_prod_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "prod"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.base_prod_host_network.self_link
#   shared_vpc_project_id = local.base_prod_host_network.project
# }

# module "restricted_dns_prod" {
#   source = "../../modules/private_dns"

#   project_id            = module.restricted_prod_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "prod"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.restricted_prod_host_network.self_link
#   shared_vpc_project_id = local.restricted_prod_host_network.project
# }

# module "base_dns_dev" {
#   source = "../../modules/private_dns"

#   project_id            = module.base_dev_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "dev"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.base_dev_host_network.self_link
#   shared_vpc_project_id = local.base_dev_host_network.project
# }

# module "restricted_dns_dev" {
#   source = "../../modules/private_dns"

#   project_id            = module.restricted_dev_project.project_id
#   enable_private_dns    = var.enable_private_dns
#   environment           = "dev"
#   application_name      = var.application_name
#   top_level_domain      = var.domain
#   shared_vpc_self_link  = local.restricted_dev_host_network.self_link
#   shared_vpc_project_id = local.restricted_dev_host_network.project
# }
