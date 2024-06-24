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

output "env_folder" {
  description = "Environment folder created under parent."
  value       = google_folder.env.name
}

output "env_secrets_project_id" {
  description = "Project for environment secrets."
  value       = module.env_secrets.project_id
}

output "env_kms_project_id" {
  description = "Project for environment Cloud Key Management Service (KMS)."
  value       = module.env_kms.project_id
}


output "assured_workload_id" {
  description = "Assured Workload ID."
  value       = var.assured_workload_configuration.enabled ? google_assured_workloads_workload.workload[0].id : ""
}

output "assured_workload_resources" {
  description = "Resources associated with the Assured Workload."
  value       = var.assured_workload_configuration.enabled ? google_assured_workloads_workload.workload[0].resources : []
}
