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
  value       = module.infra_pipelines.default_region
}

output "tf_runner_artifact_repo" {
  description = "GAR Repo created to store runner images"
  value       = module.infra_pipelines.tf_runner_artifact_repo
}

output "cloudbuild_project_id" {
  value = module.app_infra_cloudbuild_project.project_id
}

output "cloudbuild_sa" {
  description = "Cloud Build service account"
  value       = module.infra_pipelines.cloudbuild_sa
}

output "repos" {
  description = "CSRs to store source code"
  value       = module.infra_pipelines.repos
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts"
  value       = module.infra_pipelines.artifact_buckets
}

output "state_buckets" {
  description = "GCS Buckets to store TF state"
  value       = module.infra_pipelines.state_buckets
}

output "plan_triggers" {
  description = "CB plan triggers"
  value       = module.infra_pipelines.plan_triggers
}

output "apply_triggers" {
  description = "CB apply triggers"
  value       = module.infra_pipelines.apply_triggers
}
