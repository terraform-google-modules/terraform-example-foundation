output "example_single_project" {
  description = "The information related to the example single project."
  value = {
    "${module.example_single_project.environment}" : {
      project_id         = module.example_single_project.project_id
      network_project_id = module.example_single_project.network_project_id
      network_name       = module.example_single_project.network_name
    }
  }
}

output "example_standard_projects" {
  description = "The information related to the example single project."
  value = {
    nonprod : {
      project_id         = module.example_standard_projects.nonprod_project_id
      network_project_id = module.example_standard_projects.nonprod_network_project_id
      network_name       = module.example_standard_projects.nonprod_network_name
    }
    prod : {
      project_id         = module.example_standard_projects.prod_project_id
      network_project_id = module.example_standard_projects.prod_network_project_id
      network_name       = module.example_standard_projects.prod_network_name
    }
  }
}

/******************************************
  Project subnets & Private DNS Management (Optional)
 *****************************************/
# output "example_single_project_optional" {
#   value = {
#     "${module.example_single_project.environment}" : {
#       project_id         = module.example_single_project_optional.project_id
#       network_project_id = module.example_single_project_optional.network_project_id
#       network_name       = module.example_single_project_optional.network_name
#     }
#   }
# }

# output "example_standard_projects_optional" {
#   value = {
#     nonprod : {
#       project_id         = module.example_standard_projects_optional.nonprod_project_id
#       network_project_id = module.example_standard_projects_optional.nonprod_network_project_id
#       network_name       = module.example_standard_projects_optional.nonprod_network_name
#     }
#     prod : {
#       project_id         = module.example_standard_projects_optional.prod_project_id
#       network_project_id = module.example_standard_projects_optional.prod_network_project_id
#       network_name       = module.example_standard_projects_optional.prod_network_name
#     }
#   }
# }
