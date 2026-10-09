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

# Universal Outputs
output "default_region" {
  description = "Default region to create resources where applicable."
  value       = module.app_infra_pipeline.default_region
}

output "terraform_service_accounts" {
  description = "APP Infra Pipeline Terraform Accounts."
  value       = module.app_infra_pipeline.terraform_service_accounts
}

output "state_buckets" {
  description = "GCS Buckets to store TF state."
  value       = module.app_infra_pipeline.state_buckets
}

output "cicd_project_id" {
  description = "APP Infra CI/CD Project ID (CB, GitHub, or GitLab project; empty for local)."
  value       = module.app_infra_pipeline.cicd_project_id
}

output "enable_cloudbuild_deploy" {
  description = "Enable infra deployment using Cloud Build."
  value       = module.app_infra_pipeline.enable_cloudbuild_deploy
}

output "cloudbuild_project_id" {
  description = "APP Infra cloudbuild project id."
  value       = module.app_infra_pipeline.cloudbuild_project_id
}

output "cloudbuild_project_number" {
  description = "APP Infra cloudbuild project number."
  value       = module.app_infra_pipeline.cloudbuild_project_number
}

output "repos" {
  description = "CSRs to store source code."
  value       = module.app_infra_pipeline.repos
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts."
  value       = module.app_infra_pipeline.artifact_buckets
}

output "log_buckets" {
  description = "GCS Buckets to store Cloud Build logs."
  value       = module.app_infra_pipeline.log_buckets
}

output "plan_triggers_id" {
  description = "CB plan triggers."
  value       = module.app_infra_pipeline.plan_triggers_id
}

output "apply_triggers_id" {
  description = "CB apply triggers."
  value       = module.app_infra_pipeline.apply_triggers_id
}

output "artifact_registry_repository_id" {
  description = "Artifact Registry ID."
  value       = module.app_infra_pipeline.artifact_registry_repository_id
}

output "bootstrap_cloudbuild_project_id" {
  description = "Cloudbuild project ID."
  value       = module.app_infra_pipeline.bootstrap_cloudbuild_project_id
}

output "image_name" {
  description = "Image path used by confidential space instance."
  value       = module.app_infra_pipeline.image_name
}
