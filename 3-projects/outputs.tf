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
