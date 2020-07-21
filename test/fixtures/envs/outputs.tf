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

output "dev_env_folder" {
  description = "Development environment folder created under parent."
  value       = module.dev.env_folder
}

output "dev_monitoring_role" {
  description = "Development monitoring workspace users added as member for monitoring editor."
  value       = module.dev.monitoring_editor_role
}

output "dev_monitoring_project_id" {
  description = "Development project for monitoring infra."
  value       = module.dev.monitoring_project_id
}

output "dev_base_shared_vpc_project_id" {
  description = "Development project for monitoring infra."
  value       = module.dev.base_shared_vpc_project_id
}

output "dev_restricted_shared_vpc_project_id" {
  description = "Development project for monitoring infra."
  value       = module.dev.restricted_shared_vpc_project_id
}

output "dev_env_secrets_project_id" {
  description = "Development project for monitoring infra."
  value       = module.dev.env_secrets_project_id
}

output "nonprod_env_folder" {
  description = "Non-production environment folder created under parent."
  value       = module.nonprod.env_folder
}

output "nonprod_monitoring_editor_role" {
  description = "Non-production monitoring workspace users added as member for monitoring editor."
  value       = module.nonprod.monitoring_editor_role
}

output "nonprod_monitoring_project_id" {
  description = "Non-production project for monitoring infra."
  value       = module.nonprod.monitoring_project_id
}

output "nonprod_base_shared_vpc_project_id" {
  description = "Non-production project for monitoring infra."
  value       = module.nonprod.base_shared_vpc_project_id
}

output "nonprod_restricted_shared_vpc_project_id" {
  description = "Non-production project for monitoring infra."
  value       = module.nonprod.restricted_shared_vpc_project_id
}

output "nonprod_env_secrets_project_id" {
  description = "Non-production project for monitoring infra."
  value       = module.nonprod.env_secrets_project_id
}

output "prod_env_folder" {
  description = "Production environment folder created under parent."
  value       = module.prod.env_folder
}

output "prod_monitoring_editor_role" {
  description = "Production monitoring workspace users added as member for monitoring editor."
  value       = module.prod.monitoring_editor_role
}

output "prod_monitoring_project_id" {
  description = "Production project for monitoring infra."
  value       = module.prod.monitoring_project_id
}

output "prod_base_shared_vpc_project_id" {
  description = "Production project for monitoring infra."
  value       = module.prod.base_shared_vpc_project_id
}

output "prod_restricted_shared_vpc_project_id" {
  description = "Production project for monitoring infra."
  value       = module.prod.restricted_shared_vpc_project_id
}

output "prod_env_secrets_project_id" {
  description = "Production project for monitoring infra."
  value       = module.prod.env_secrets_project_id
}
