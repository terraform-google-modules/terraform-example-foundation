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
  value       = module.app_infra_cloudbuild_project.project_id
}

output "enable_cloudbuild_deploy" {
  description = "Enable infra deployment using Cloud Build."
  value       = true
}

# Legacy outputs maintained for backward compatibility
output "cloudbuild_project_id" {
  description = "APP Infra cloudbuild project id."
  value       = module.app_infra_cloudbuild_project.project_id
}

output "cloudbuild_project_number" {
  description = "APP Infra cloudbuild project number."
  value       = module.app_infra_cloudbuild_project.project_number
}

output "repos" {
  description = "CSRs to store source code."
  value       = toset([for repo in google_sourcerepo_repository.app_infra_repo : repo.name])
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts."
  value       = { for k, ws in module.tf_workspace : k => split("/", ws.artifacts_bucket)[length(split("/", ws.artifacts_bucket)) - 1] }
}

output "log_buckets" {
  description = "GCS Buckets to store Cloud Build logs."
  value       = local.log_buckets
}

output "plan_triggers_id" {
  description = "CB plan triggers."
  value       = [for ws in module.tf_workspace : ws.cloudbuild_plan_trigger_id]
}

output "apply_triggers_id" {
  description = "CB apply triggers."
  value       = [for ws in module.tf_workspace : ws.cloudbuild_apply_trigger_id]
}

output "artifact_registry_repository_id" {
  description = "Artifact Registry ID."
  value       = local.gar_project_id
}

output "bootstrap_cloudbuild_project_id" {
  description = "Cloudbuild project ID."
  value       = module.app_infra_cloudbuild_project.project_id
}

output "image_name" {
  description = "Image path used by confidential space instance."
  value       = local.confidential_space_image_tag
}
