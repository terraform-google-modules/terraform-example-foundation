/**
 * Copyright 2019 Google LLC
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

output "jenkins_project_id" {
  description = "Project where Jenkins Agents and terraform builder container image will reside."
  value       = module.jenkins_project.project_id
}

output "jenkins_sa_email" {
  description = "Email for privileged custom service account for Jenkins Agent GCE instance."
  value       = google_service_account.jenkins_agent_gce_sa.email
}

output "jenkins_sa_name" {
  description = "Fully qualified name for privileged custom service account for Jenkins Agent GCE instance."
  value       = google_service_account.jenkins_agent_gce_sa.name
}

output "gcs_bucket_jenkins_artifacts" {
  description = "Bucket used to store Jenkins artifacts in Jenkins project."
  value       = google_storage_bucket.jenkins_artifacts.name
}

// TODO(caleonardo): Configure this repo on-prem
//output "csr_repos" {
//  description = "List of Cloud Source Repos created by the module, linked to Cloud Build triggers."
//  value       = google_sourcerepo_repository.gcp_repo
//}

output "kms_keyring" {
  description = "KMS Keyring created by the module."
  value       = google_kms_key_ring.tf_keyring
}

output "kms_crypto_key" {
  description = "KMS key created by the module."
  value       = google_kms_crypto_key.tf_key
}