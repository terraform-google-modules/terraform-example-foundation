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

output "access_context_manager_policy_id" {
  description = "The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
  value       = var.policy_id
}

output "enable_hub_and_spoke" {
  description = "Hub and Spoke enabled."
  value       = var.enable_hub_and_spoke
}

/******************************************
 Development Outputs
*****************************************/

output "dev_restricted_access_level_name" {
  description = "development access context manager access level name"
  value       = module.development.restricted_access_level_name
}

output "dev_restricted_service_perimeter_name" {
  description = "development access context manager service perimeter name"
  value       = module.development.restricted_service_perimeter_name
}

output "dev_restricted_host_project_id" {
  description = "The development restricted host project ID"
  value       = module.development.restricted_host_project_id
}

output "dev_base_host_project_id" {
  description = "The development base host project ID"
  value       = module.development.base_host_project_id
}

/******************************************
 Non-production Outputs
*****************************************/

output "nonprod_restricted_access_level_name" {
  description = "non-production access context manager access level name"
  value       = module.non-production.restricted_access_level_name
}

output "nonprod_restricted_service_perimeter_name" {
  description = "non-production access context manager service perimeter name"
  value       = module.non-production.restricted_service_perimeter_name
}


output "nonprod_restricted_host_project_id" {
  description = "The non-production restricted host project ID"
  value       = module.non-production.restricted_host_project_id
}

output "nonprod_base_host_project_id" {
  description = "The non-production base host project ID"
  value       = module.non-production.base_host_project_id
}

/******************************************
 Production Outputs
*****************************************/

output "prod_restricted_access_level_name" {
  description = "production access context manager access level name"
  value       = module.production.restricted_access_level_name
}

output "prod_restricted_service_perimeter_name" {
  description = "production access context manager service perimeter name"
  value       = module.production.restricted_service_perimeter_name
}

output "prod_restricted_host_project_id" {
  description = "The production restricted host project ID"
  value       = module.production.restricted_host_project_id
}

output "prod_base_host_project_id" {
  description = "The production base host project ID"
  value       = module.production.base_host_project_id
}
