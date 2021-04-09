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

output "tf_runner_artifact_repo" {
  description = "GAR Repo created to store runner images"
  value       = google_artifact_registry_repository.tf-image-repo.name
}

output "default_region" {
  description = "Default region to create resources where applicable."
  value       = var.default_region
}

output "gar_name" {
  description = "GAR Repo name created to store runner images"
  value       = local.gar_name
}

output "cloudbuild_sa" {
  description = "Cloud Build service account"
  value       = "${data.google_project.cloudbuild_project.number}@cloudbuild.gserviceaccount.com"
}

output "repos" {
  description = "CSRs to store source code"
  value       = local.created_csrs
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts"
  value       = values(local.artifact_buckets)
}

output "state_buckets" {
  description = "GCS Buckets to store TF state"
  value       = values(local.state_buckets)
}

output "plan_triggers" {
  description = "CB plan triggers"
  value       = [for trigger in google_cloudbuild_trigger.non_main_trigger : trigger.name]
}

output "apply_triggers" {
  description = "CB apply triggers"
  value       = [for trigger in google_cloudbuild_trigger.main_trigger : trigger.name]
}
