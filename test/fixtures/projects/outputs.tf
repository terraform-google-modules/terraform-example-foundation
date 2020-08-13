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

output "dev_bu1_project_base" {
  description = "Project sample base project."
  value       = module.projects_bu1_dev.base_shared_vpc_project
}

output "dev_bu1_project_floating" {
  description = "Project sample floating project."
  value       = module.projects_bu1_dev.example_floating_project
}

output "dev_bu1_project_restricted" {
  description = "Project sample restricted project."
  value       = module.projects_bu1_dev.restricted_shared_vpc_project
}

output "dev_bu2_project_base" {
  description = "Project sample base project."
  value       = module.projects_bu2_dev.base_shared_vpc_project
}

output "dev_bu2_project_floating" {
  description = "Project sample floating project."
  value       = module.projects_bu2_dev.example_floating_project
}

output "dev_bu2_project_restricted" {
  description = "Project sample restricted project."
  value       = module.projects_bu2_dev.restricted_shared_vpc_project
}

output "nonprod_bu1_project_base" {
  description = "Project sample base project."
  value       = module.projects_bu1_nonprod.base_shared_vpc_project
}

output "nonprod_bu1_project_floating" {
  description = "Project sample floating project."
  value       = module.projects_bu1_nonprod.example_floating_project
}

output "nonprod_bu1_project_restricted" {
  description = "Project sample restricted project."
  value       = module.projects_bu1_nonprod.restricted_shared_vpc_project
}

output "nonprod_bu2_project_base" {
  description = "Project sample base project."
  value       = module.projects_bu2_nonprod.base_shared_vpc_project
}

output "nonprod_bu2_project_floating" {
  description = "Project sample floating project."
  value       = module.projects_bu2_nonprod.example_floating_project
}

output "nonprod_bu2_project_restricted" {
  description = "Project sample restricted project."
  value       = module.projects_bu2_nonprod.restricted_shared_vpc_project
}

output "prod_bu1_project_base" {
  description = "Project sample base project."
  value       = module.projects_bu1_prod.base_shared_vpc_project
}

output "prod_bu1_project_floating" {
  description = "Project sample floating project."
  value       = module.projects_bu1_prod.example_floating_project
}

output "prod_bu1_project_restricted" {
  description = "Project sample restricted project."
  value       = module.projects_bu1_prod.restricted_shared_vpc_project
}

output "prod_bu2_project_base" {
  description = "Project sample base project."
  value       = module.projects_bu2_prod.base_shared_vpc_project
}

output "prod_bu2_project_floating" {
  description = "Project sample floating project."
  value       = module.projects_bu2_prod.example_floating_project
}

output "prod_bu2_project_restricted" {
  description = "Project sample restricted project."
  value       = module.projects_bu2_prod.restricted_shared_vpc_project
}
