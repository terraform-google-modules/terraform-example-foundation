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

/* ----------------------------------------
    Specific to cloudbuild_module
   ---------------------------------------- */
output "cloudbuild_project_id" {
  description = "Project where Cloud Build configuration and terraform container image will reside."
  value       = module.tf_source.cloudbuild_project_id
}

output "cloudbuild_project_number" {
  description = "Project number of the Cloud Build project"
  value       = data.google_project.cloudbuild_project.number
}

output "gcs_bucket_cloudbuild_artifacts" {
  description = "Bucket used to store Cloud Build artifacts in cicd project."
  value       = { for key, value in module.tf_workspace : key => replace(value.artifacts_bucket, local.bucket_self_link_prefix, "") }
}

output "gcs_bucket_cloudbuild_logs" {
  description = "Bucket used to store Cloud Build logs in cicd project."
  value       = { for key, value in module.tf_workspace : key => replace(value.logs_bucket, local.bucket_self_link_prefix, "") }
}

output "cloud_builder_artifact_repo" {
  description = "Artifact Registry (AR) Repository created to store TF Cloud Builder images."
  value       = "projects/${module.tf_source.cloudbuild_project_id}/locations/${var.default_region}/repositories/${module.tf_cloud_builder.artifact_repo}"
}

output "csr_repos" {
  description = "List of Cloud Source Repos created by the module, linked to Cloud Build triggers."
  value = { for k, v in module.tf_source.csr_repos : k => {
    "id"      = v.id,
    "name"    = v.name,
    "project" = v.project,
    "url"     = v.url,
    }
  }
}

output "cloud_build_private_worker_pool_id" {
  description = "ID of the Cloud Build private worker pool."
  value       = module.tf_private_pool.private_worker_pool_id
}

output "cloud_build_worker_range_id" {
  description = "The Cloud Build private worker IP range ID."
  value       = module.tf_private_pool.worker_range_id
}

output "cloud_build_worker_peered_ip_range" {
  description = "The IP range of the peered service network."
  value       = module.tf_private_pool.worker_peered_ip_range
}

output "cloud_build_peered_network_id" {
  description = "The ID of the Cloud Build peered network."
  value       = module.tf_private_pool.peered_network_id
}
