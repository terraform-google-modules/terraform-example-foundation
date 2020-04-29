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
 
 output "project_id" {
  value       = module.project.project_id
  description = "The project where application-related infrastructure will reside."
}

output "network_project_id" {
  value       = local.host_network.project
  description = "The network project where hosts the shared vpc used by the project created."
}

output "network_name" {
  value       = local.host_network.name
  description = "The name of Shared VPC used by the project created."
}

output "environment" {
  value       = var.environment
  description = "The environment the single project belongs to"
}
