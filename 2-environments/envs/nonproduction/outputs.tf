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
  value       = module.env.env_folder
}

output "env_secrets_project_id" {
  description = "Project for environment related secrets."
  value       = module.env.env_secrets_project_id
}

output "env_kms_project_id" {
  description = "Project for environment Cloud Key Management Service (KMS)."
  value       = module.env.env_kms_project_id
}
