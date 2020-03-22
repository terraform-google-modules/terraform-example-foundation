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

  shared_vpc         = local.nonprod_host_project_id
  shared_vpc_subnets = data.google_compute_network.nonprod_shared_vpc.subnetworks_self_links

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

  shared_vpc         = local.prod_host_project_id
  shared_vpc_subnets = data.google_compute_network.prod_shared_vpc.subnetworks_self_links

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
  vpc_host_project_id = data.google_projects.projects-nonprod.projects[0].project_id
  vpc_self_link       = data.google_compute_network.shared-vpc-nonprod.self_link
  ip_cidr_range       = var.subnet_allocation["nonprod"].primary_range
  application_name    = var.application_name
  secondary_ranges    = var.subnet_allocation["nonprod"].secondary_ranges
  enable_networking   = var.enable_networking
  project_id          = module.nonprod_project.project_id
}

module "networking_prod_project" {
  source              = "../../modules/project_subnet"
  vpc_host_project_id = data.google_projects.projects-prod.projects[0].project_id
  vpc_self_link       = data.google_compute_network.shared-vpc-prod.self_link
  ip_cidr_range       = var.subnet_allocation["prod"].primary_range
  application_name    = var.application_name
  secondary_ranges    = var.subnet_allocation["prod"].secondary_ranges
  enable_networking   = var.enable_networking
  project_id          = module.prod_project.project_id
}

