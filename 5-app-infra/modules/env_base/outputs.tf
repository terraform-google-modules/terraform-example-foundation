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

output "instances_self_links" {
  description = "List of self-links for compute instances"
  value       = module.compute_instance.instances_self_links
}

output "instances_details" {
  description = "List of details for compute instances"
  value       = module.compute_instance.instances_details
}

output "available_zones" {
  description = "List of available zones in region"
  value       = module.compute_instance.available_zones
}

output "project_id" {
  description = "Project where compute instance was created"
  value       = data.google_project.env_project.project_id
}

output "region" {
  description = "Region where compute instance was created"
  value       = var.region
}
