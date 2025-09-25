/**
 * Copyright 2025 Google LLC
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

output "instances_self_links" {
  description = "List of self-links for compute instances"
  value       = module.confidential_compute_instance.instances_self_links
}

output "instances_details" {
  description = "List of details for compute instances"
  value       = module.confidential_compute_instance.instances_details
}

output "available_zones" {
  description = "List of available zones in region"
  value       = module.confidential_compute_instance.available_zones
}

output "project_id" {
  description = "Project where compute instance was created"
  value       = local.env_project_id
}

output "confidential_space_project_id" {
  description = "Project where confidential compute instance was created"
  value       = local.confidential_space_project_id
}

output "confidential_space_project_number" {
  description = "Project number from confidential compute instance"
  value       = local.confidential_space_project_number
}

output "confidential_image_digest" {
  description = "SHA256 digest of the Docker image."
  value       = var.confidential_image_digest
}

output "workload_pool_provider_id" {
  description = "Workload pool provider used by confidential space."
  value       = google_iam_workload_identity_pool_provider.attestation_verifier.workload_identity_pool_provider_id
}

output "workload_identity_pool_id" {
  description = "Workload identity pool ID."
  value       = google_iam_workload_identity_pool.confidential_space_pool.workload_identity_pool_id

}

