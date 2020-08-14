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

output "base_shared_vpc_project" {
  description = "Project sample base project."
  value       = module.base_shared_vpc_project.project_id
}

output "floating_project" {
  description = "Project sample floating project."
  value       = module.floating_project.project_id
}

output "restricted_shared_vpc_project" {
  description = "Project sample restricted project id."
  value       = module.restricted_shared_vpc_project.project_id
}

output "restricted_shared_vpc_project_number" {
  description = "Project sample restricted project."
  value       = module.restricted_shared_vpc_project.project_number
}

output "vpc_service_control_attach_enabled" {
  description = "Enable or disable VPC Service Control Attach."
  value       = module.restricted_shared_vpc_project.vpc_service_control_attach_enabled
}

output "vpc_service_control_perimeter_name" {
  description = "VPC Service Control name."
  value       = var.perimeter_name
}

output "vpc_service_control_perimeter_services" {
  description = "VPC Service Control services."
  value       = module.restricted_shared_vpc_project.vpc_service_control_perimeter_services
}

output "access_context_manager_policy_id" {
  description = "Access Context Manager Policy ID."
  value       = var.access_context_manager_policy_id
}
