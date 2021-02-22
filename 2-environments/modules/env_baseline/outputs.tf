/**
 * Copyright 2021 Google LLC
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

output "env_folder" {
  description = "Environment folder created under parent."
  value       = google_folder.env.name
}

output "monitoring_project_id" {
  description = "Project for monitoring infra."
  value       = module.monitoring_project.project_id
}

output "base_shared_vpc_project_id" {
  description = "Project for base shared VPC network."
  value       = module.base_shared_vpc_host_project.project_id
}

output "restricted_shared_vpc_project_id" {
  description = "Project for restricted shared VPC network."
  value       = module.restricted_shared_vpc_host_project.project_id
}

output "env_secrets_project_id" {
  description = "Project for environment secrets."
  value       = module.env_secrets.project_id
}
