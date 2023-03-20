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
  value       = module.base_shared_gce_instance.instances_self_links
}

output "instances_names" {
  description = "List of names for compute instances"
  value       = [for u in module.base_shared_gce_instance.instances_details : u.name]
}

output "instances_zones" {
  description = "List of zone for compute instances"
  value       = [for u in module.base_shared_gce_instance.instances_details : u.zone]
}

output "instances_details" {
  description = "List of details for compute instances"
  value       = module.base_shared_gce_instance.instances_details
  sensitive   = true
}

output "available_zones" {
  description = "List of available zones in region"
  value       = module.base_shared_gce_instance.available_zones
}

output "project_id" {
  description = "Project where compute instance was created"
  value       = module.base_shared_gce_instance.project_id
}

output "region" {
  description = "Region where compute instance was created"
  value       = module.base_shared_gce_instance.region
}
