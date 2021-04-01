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

output "org_id" {
  description = "Google Organization ID"
  value       = var.org_id
}

output "seed_project_id" {
  description = "Project where service accounts and core APIs will be enabled."
  value       = module.bootstrap.seed_project_id
}

output "terraform_service_account" {
  description = "Email for privileged service account for Terraform."
  value       = module.bootstrap.terraform_service_account
}

output "gcs_bucket_tfstate" {
  description = "Bucket used for storing terraform state for foundations pipelines in seed project."
  value       = module.bootstrap.gcs_bucket_tfstate
}

output "cloudbuild_project_id" {
  description = "Project where CloudBuild configuration and terraform container image will reside."
  value       = module.bootstrap.cloudbuild_project_id
}

output "gcs_bucket_cloudbuild_artifacts" {
  description = "Bucket used to store Cloud/Build artefacts in CloudBuild project."
  value       = module.bootstrap.gcs_bucket_cloudbuild_artifacts
}
