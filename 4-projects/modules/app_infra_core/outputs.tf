/**
 * Copyright 2026 Google LLC
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

output "default_region" {
  description = "Default region where resources were created."
  value       = var.default_region
}

output "terraform_service_accounts" {
  description = "App Infra Pipeline Terraform Service Accounts emails mapped by repo."
  value       = { for k, sa in google_service_account.app_infra_sa : k => sa.email }
}

output "terraform_service_accounts_names" {
  description = "App Infra Pipeline Terraform Service Accounts names mapped by repo."
  value       = { for k, sa in google_service_account.app_infra_sa : k => sa.name }
}

output "terraform_service_accounts_ids" {
  description = "App Infra Pipeline Terraform Service Accounts resource IDs mapped by repo."
  value       = { for k, sa in google_service_account.app_infra_sa : k => sa.id }
}

output "state_buckets" {
  description = "GCS State Buckets mapped by repo."
  value       = { for k, b in google_storage_bucket.state_buckets : k => b.name }
}

output "state_bucket_self_links" {
  description = "GCS State Buckets self links mapped by repo."
  value       = { for k, b in google_storage_bucket.state_buckets : k => b.self_link }
}

output "artifact_registry_repositories" {
  description = "Artifact Registry repositories mapped by repo."
  value       = { for k, r in google_artifact_registry_repository.tf_runners : k => r.repository_id }
}

output "artifact_registry_name" {
  description = "Primary Artifact Registry repository name."
  value       = length(var.app_infra_repos) > 0 ? google_artifact_registry_repository.tf_runners[tolist(var.app_infra_repos)[0]].repository_id : ""
}
