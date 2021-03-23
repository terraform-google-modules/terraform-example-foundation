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

output "dev_instances_self_links" {
  description = "List of self-links for compute instances"
  value       = module.app_infra_bu1_development.instances_self_links
}

output "dev_available_zones" {
  description = "List of available zones in region"
  value       = module.app_infra_bu1_development.available_zones
}

output "nonprod_instances_self_links" {
  description = "List of self-links for compute instances"
  value       = module.app_infra_bu1_nonproduction.instances_self_links
}

output "nonprod_available_zones" {
  description = "List of available zones in region"
  value       = module.app_infra_bu1_nonproduction.available_zones
}

output "prod_instances_self_links" {
  description = "List of self-links for compute instances"
  value       = module.app_infra_bu1_production.instances_self_links
}

output "prod_available_zones" {
  description = "List of available zones in region"
  value       = module.app_infra_bu1_production.available_zones
}
