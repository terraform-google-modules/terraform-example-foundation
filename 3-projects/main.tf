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

    # enable_dns = true
    # enable_cloud_build = true
    # enable_network = true
}