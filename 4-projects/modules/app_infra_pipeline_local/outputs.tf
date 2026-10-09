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
  description = "Default region to create resources where applicable."
  value       = var.default_region
}

output "terraform_service_accounts" {
  description = "APP Infra Pipeline Terraform Accounts."
  value       = module.core.terraform_service_accounts
}

output "state_buckets" {
  description = "GCS Buckets to store TF state."
  value       = module.core.state_buckets
}

output "cicd_project_id" {
  description = "APP Infra CI/CD Project ID (CB, GitHub, or GitLab project; empty for local)."
  value       = ""
}

output "enable_cloudbuild_deploy" {
  description = "Enable infra deployment using Cloud Build."
  value       = false
}

output "cloudbuild_project_id" {
  description = "APP Infra cloudbuild project id."
  value       = ""
}

output "cloudbuild_project_number" {
  description = "APP Infra cloudbuild project number."
  value       = ""
}

output "repos" {
  description = "CSRs to store source code."
  value       = toset([])
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts."
  value       = {}
}

output "log_buckets" {
  description = "GCS Buckets to store Cloud Build logs."
  value       = {}
}

output "plan_triggers_id" {
  description = "CB plan triggers."
  value       = []
}

output "apply_triggers_id" {
  description = "CB apply triggers."
  value       = []
}

output "artifact_registry_repository_id" {
  description = "Artifact Registry ID."
  value       = module.app_infra_project.project_id
}

output "bootstrap_cloudbuild_project_id" {
  description = "Cloudbuild project ID."
  value       = ""
}

output "image_name" {
  description = "Image path used by confidential space instance."
  value       = ""
}
