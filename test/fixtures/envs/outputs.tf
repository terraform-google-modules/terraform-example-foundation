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

output "monitoring_group" {
  description = "Monitoring workspace group."
  value       = var.group_email
}

output "dev_env_folder" {
  description = "Development environment folder created under parent."
  value       = module.development.env_folder
}

output "dev_monitoring_project_id" {
  description = "Development project for monitoring infra."
  value       = module.development.monitoring_project_id
}

output "dev_base_shared_vpc_project_id" {
  description = "Development project for base shared VPC."
  value       = module.development.base_shared_vpc_project_id
}

output "dev_restricted_shared_vpc_project_id" {
  description = "Development project for restricted shared VPC."
  value       = module.development.restricted_shared_vpc_project_id
}

output "dev_env_secrets_project_id" {
  description = "Development project for environment secrets."
  value       = module.development.env_secrets_project_id
}

output "nonprod_env_folder" {
  description = "Non-production environment folder created under parent."
  value       = module.non-production.env_folder
}

output "nonprod_monitoring_project_id" {
  description = "Non-production project for monitoring infra."
  value       = module.non-production.monitoring_project_id
}

output "nonprod_base_shared_vpc_project_id" {
  description = "Non-production project for base shared VPC."
  value       = module.non-production.base_shared_vpc_project_id
}

output "nonprod_restricted_shared_vpc_project_id" {
  description = "Non-production project for restricted shared VPC."
  value       = module.non-production.restricted_shared_vpc_project_id
}

output "nonprod_env_secrets_project_id" {
  description = "Non-production project for environment secrets."
  value       = module.non-production.env_secrets_project_id
}

output "prod_env_folder" {
  description = "Production environment folder created under parent."
  value       = module.production.env_folder
}

output "prod_monitoring_project_id" {
  description = "Production project for monitoring infra."
  value       = module.production.monitoring_project_id
}

output "prod_base_shared_vpc_project_id" {
  description = "Production project for base shared VPC."
  value       = module.production.base_shared_vpc_project_id
}

output "prod_restricted_shared_vpc_project_id" {
  description = "Production project for restricted shared VPC."
  value       = module.production.restricted_shared_vpc_project_id
}

output "prod_env_secrets_project_id" {
  description = "Production project for environment secrets."
  value       = module.production.env_secrets_project_id
}
