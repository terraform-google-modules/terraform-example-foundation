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

output "default_region" {
  description = "Default region to create resources where applicable."
  value       = try(module.infra_pipelines[0].default_region, "")
}

output "cloudbuild_project_id" {
  description = "APP Infra cloudbuild project id."
  value       = try(module.app_infra_cloudbuild_project[0].project_id, "")
}

output "cloudbuild_project_number" {
  description = "APP Infra cloudbuild project number."
  value       = module.app_infra_cloudbuild_project[0].project_number
}

output "terraform_service_accounts" {
  description = "APP Infra Pipeline Terraform Accounts."
  value       = try(module.infra_pipelines[0].terraform_service_accounts, {})
}

output "repos" {
  description = "CSRs to store source code"
  value       = try(module.infra_pipelines[0].repos, toset([]))
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts"
  value       = try(module.infra_pipelines[0].artifact_buckets, {})
}

output "state_buckets" {
  description = "GCS Buckets to store TF state"
  value       = try(module.infra_pipelines[0].state_buckets, {})
}

output "log_buckets" {
  description = "GCS Buckets to store Cloud Build logs"
  value       = try(module.infra_pipelines[0].log_buckets, {})
}

output "plan_triggers_id" {
  description = "CB plan triggers"
  value       = try(module.infra_pipelines[0].plan_triggers_id, [])
}

output "apply_triggers_id" {
  description = "CB apply triggers"
  value       = try(module.infra_pipelines[0].apply_triggers_id, [])
}

output "enable_cloudbuild_deploy" {
  description = "Enable infra deployment using Cloud Build."
  value       = local.enable_cloudbuild_deploy
}

output "artifact_registry_repository_id" {
  description = "Artifact Registry ID."
  value       = module.infra_pipelines[0].artifact_registry_repository_id
}

output "bootstrap_cloudbuild_project_id" {
  description = "Cloudbuild project ID."
  value       = local.cloudbuild_project_id
}

output "image_name" {
  description = "Image path used by confidential space instance."
  value       = local.confidential_space_image_tag
}
