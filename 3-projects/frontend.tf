
module "frontend_subnet_allocation" {
    source = "./modules/subnet_allocation"
    
    project_index = index(local.app_network_indexes, "frontend")
    application_name = "awesome_app"

    cidr_vms = var.cidr_vms
    cidr_gke_pods = var.cidr_gke_pods
    cidr_gke_services = var.cidr_gke_services
    cidr_gke_masters = var.cidr_gke_masters
    subnet_size = var.subnet_size
}


output "result" {
    value = module.frontend_subnet_allocation.subnet_cidr
}

module "folders" {
    source = "./modules/folder_environments"

    parent_folder_id    = "folders/974267969478"
    folder_display_name = "frendcloud"
}



module "awesome_app" {
    source = "./modules/standard_projects"

    org_id = var.organization_id
    billing_account = var.billing_account
    impersonate_service_account = var.terraform_service_account

    project_folder_map = module.folders.folder_map
    
    project_prefix = "app"
    cost_centre = "retail"
    application_name = "awesome_app"

    # enable_network = true
    # subnet_allocation = module.frontend_subnet_allocation.subnet_allocation
    
    # enable_dns = true
    # enable_cloud_build = true
    # enable_network = true
}

module "awesome_app_single" {
    source = "./modules/single_project"

    org_id = var.organization_id
    billing_account = var.billing_account
    impersonate_service_account = var.terraform_service_account

    project_folder_map = module.folders.folder_map
    
    project_prefix = "app"
    cost_centre = "retail"
    application_name = "awesome_shared"

    # enable_dns = true
    # enable_cloud_build = true
    # enable_network = true
}