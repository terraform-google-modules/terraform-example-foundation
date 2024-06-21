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

output "base_shared_vpc_project" {
  description = "Project sample base project."
  value       = module.env.base_shared_vpc_project
}

output "base_shared_vpc_project_sa" {
  description = "Project sample base project SA."
  value       = module.env.base_shared_vpc_project_sa
}

output "base_subnets_self_links" {
  value       = module.env.base_subnets_self_links
  description = "The self-links of subnets from base environment."
}

output "floating_project" {
  description = "Project sample floating project."
  value       = module.env.floating_project
}

output "peering_project" {
  description = "Project sample peering project id."
  value       = module.env.peering_project
}

output "peering_network" {
  description = "Peer network peering resource."
  value       = module.env.peering_network
}

output "restricted_shared_vpc_project" {
  description = "Project sample restricted project id."
  value       = module.env.restricted_shared_vpc_project
}

output "restricted_shared_vpc_project_number" {
  description = "Project sample restricted project."
  value       = module.env.restricted_shared_vpc_project_number
}

output "restricted_subnets_self_links" {
  value       = module.env.restricted_subnets_self_links
  description = "The self-links of subnets from restricted environment."
}

output "vpc_service_control_perimeter_name" {
  description = "VPC Service Control name."
  value       = module.env.vpc_service_control_perimeter_name
}

output "restricted_enabled_apis" {
  description = "Activated APIs."
  value       = module.env.restricted_enabled_apis
}

output "access_context_manager_policy_id" {
  description = "Access Context Manager Policy ID."
  value       = module.env.access_context_manager_policy_id
}

output "peering_complete" {
  description = "Output to be used as a module dependency."
  value       = module.env.peering_complete
}

output "keyring" {
  description = "The name of the keyring."
  value       = module.env.keyring
}

output "keys" {
  description = "List of created key names."
  value       = module.env.keys
}

output "bucket" {
  description = "The created storage bucket."
  value       = module.env.bucket
}

output "peering_subnetwork_self_link" {
  description = "The subnetwork self link of the peering network."
  value       = module.env.peering_subnetwork_self_link
}

output "iap_firewall_tags" {
  description = "The security tags created for IAP (SSH and RDP) firewall rules and to be used on the VM created on step 5-app-infra on the peering network project."
  value       = module.env.iap_firewall_tags
}

output "default_region" {
  description = "The default region for the project."
  value       = local.default_region
}
