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
  value       = var.default_region
}

output "terraform_service_accounts" {
  description = "App Infra Pipeline Terraform SA mapped to source repos as keys"
  value       = local.workspace_sa_email
}

output "gar_name" {
  description = "Artifact Registry (AR) repository name created to store runner images"
  value       = local.gar_name
}

output "repos" {
  description = "CSRs to store source code"
  value       = local.created_csrs
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts"
  value       = local.artifact_buckets
}

output "state_buckets" {
  description = "GCS Buckets to store TF state"
  value       = local.state_buckets
}

output "log_buckets" {
  description = "GCS Buckets to store Cloud Build logs"
  value       = local.log_buckets
}

output "plan_triggers_id" {
  description = "CB plan triggers"
  value       = local.plan_triggers_id
}

output "apply_triggers_id" {
  description = "CB apply triggers"
  value       = local.apply_triggers_id
}
