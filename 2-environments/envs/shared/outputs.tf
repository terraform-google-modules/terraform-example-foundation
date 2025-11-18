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

/*
output "env_folder" {
  description = "Environment folder created under parent."
  value       = var.is_environment_level_1 ? module.env[0].env_folder : null
}

output "env_secrets_project_id" {
  description = "Project for environment related secrets."
  value       = var.is_environment_level_1 ? module.env[0].env_secrets_project_id : null
}

output "env_kms_project_id" {
  description = "Project for environment Cloud Key Management Service (KMS)."
  value       = var.is_environment_level_1 ? module.env[0].env_kms_project_id : null
}

output "env_kms_project_number" {
  description = "Project Number for environment Cloud Key Management Service (KMS)."
  value       = var.is_environment_level_1 ? module.env[0].env_kms_project_number : null
}
*/

// TEST
/*
output "level_1_folders" {
  value = var.level_1_folders
}

output "level_2_folders" {
  value = var.level_2_folders
}
*/

output "is_environment_level_1" {
  value = var.is_environment_level_1
}

/*
output "folders_l1_env" {
  //value = module.l1_env
  value = flatten([for folder in module.l1_env : folder.folders_l1_env_result.folder.name])
}

output "folders_l1_not_env" {
  //value = module.l1_not_env
  value = flatten([for folder in module.l1_not_env : folder.folders_l1_not_env_result.name])
}
*/

output "level_1_folder_ids" {
  value = (var.is_environment_level_1 ?
   flatten([for folder in module.l1_env : folder.folders_l1_env_result.folder.name]) : 
   flatten([for folder in module.l1_not_env : folder.folders_l1_not_env_result.name]))
}

/*
output "tag_key" {
  value = data.google_tags_tag_key.environment
}

output "tag_dev" {
  value = data.google_tags_tag_value.environment_development
}

output "tag_nonprod" {
  value = data.google_tags_tag_value.environment_nonproduction
}

output "tag_prod" {
  value = data.google_tags_tag_value.environment_production
}
*/
