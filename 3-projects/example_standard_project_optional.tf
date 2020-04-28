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

# module "example_standard_projects_optional" {
#   source = "./modules/standard_projects"

#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   impersonate_service_account = var.terraform_service_account

#   nonprod_folder_id = module.example_team_folders.nonprod_folder_id
#   prod_folder_id    = module.example_team_folders.prod_folder_id

#   # Metadata
#   project_prefix   = "standard-optional"
#   cost_centre      = "cost-centre-1"
#   application_name = "sample-standard-app-optional"

#   # Network Setting (Optional)
#   enable_networking            = true
#   nonprod_subnet_ip_cidr_range = "10.64.0.0/16"
#   nonprod_subnet_secondary_ranges = [{
#     range_name    = "nonprod-gke-pod",
#     ip_cidr_range = "10.65.0.0/16"
#     }, {
#     range_name    = "nonprod-gke-svc",
#     ip_cidr_range = "10.66.0.0/16"
#   }]
#   prod_subnet_ip_cidr_range = "10.6.0.0/16"
#   prod_subnet_secondary_ranges = [{
#     range_name    = "prod-gke-pod",
#     ip_cidr_range = "10.7.0.0/16"
#     }, {
#     range_name    = "prod-gke-svc",
#     ip_cidr_range = "10.8.0.0/16"
#   }]

#   # DNS Setting (Optional)
#   enable_private_dns = true
#   domain             = var.domain
# }
