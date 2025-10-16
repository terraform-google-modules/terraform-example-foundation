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

output "floating_project" {
  description = "Project sample floating project."
  value       = module.floating_project.project_id
}

output "floating_project_number" {
  description = "Project number sample floating project."
  value       = module.floating_project.project_number
}

output "peering_project" {
  description = "Project sample peering project id."
  value       = module.peering_project.project_id
}

output "peering_project_number" {
  description = "Project sample peering project number."
  value       = module.peering_project.project_number
}

output "peering_network" {
  description = "Peer network peering resource."
  value       = module.peering.peer_network_peering
}

output "shared_vpc_project" {
  description = "Project sample restricted project id."
  value       = module.shared_vpc_project.project_id
}

output "shared_vpc_project_number" {
  description = "Project sample shared vpc project."
  value       = module.shared_vpc_project.project_number
}

output "subnets_self_links" {
  value       = local.subnets_self_links
  description = "The self-links of subnets."
}

output "vpc_service_control_perimeter_name" {
  description = "VPC Service Control name."
  value       = local.perimeter_name
}

output "access_context_manager_policy_id" {
  description = "Access Context Manager Policy ID."
  value       = local.access_context_manager_policy_id
}

output "restricted_enabled_apis" {
  description = "Activated APIs."
  value       = module.shared_vpc_project.enabled_apis
}

output "peering_complete" {
  description = "Output to be used as a module dependency."
  value       = module.peering.complete
}

output "keyring" {
  description = "The name of the keyring."
  value       = module.kms.keyring
}

output "keys" {
  description = "List of created key names."
  value       = keys(module.kms.keys)
}

output "bucket" {
  description = "The created storage bucket."
  value       = module.gcs_buckets.bucket
}

output "peering_subnetwork_self_link" {
  description = "The subnetwork self link of the peering network."
  value       = var.peering_iap_fw_rules_enabled ? module.peering_network.subnets_self_links[0] : ""
}

output "iap_firewall_tags" {
  description = "The security tags created for IAP (SSH and RDP) firewall rules and to be used on the VM created on step 5-app-infra on the peering network project."
  value = var.peering_iap_fw_rules_enabled ? {
    "tagKeys/${google_tags_tag_key.firewall_tag_key_ssh[0].name}" = "tagValues/${google_tags_tag_value.firewall_tag_value_ssh[0].name}"
    "tagKeys/${google_tags_tag_key.firewall_tag_key_rdp[0].name}" = "tagValues/${google_tags_tag_value.firewall_tag_value_rdp[0].name}"
  } : {}
}

output "confidential_space_project" {
  description = "Confidential Space project id."
  value       = module.confidential_space_project.project_id
}

output "confidential_space_project_number" {
  description = "Confidential Space project number."
  value       = module.confidential_space_project.project_number
}

output "confidential_space_workload_sa" {
  description = "Workload Service Account for confidential space"
  value       = google_service_account.workload_sa.email
}

