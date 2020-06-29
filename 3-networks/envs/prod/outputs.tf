/**
 * Copyright 2020 Google LLC
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

/*********************
 Restricted Outputs
*********************/

output "restricted_host_project_id" {
  value       = local.restricted_project_id
  description = "The restricted host project ID"
}

output "restricted_network_name" {
  value       = module.restricted_shared_vpc.network_name
  description = "The name of the VPC being created"
}

output "restricted_network_self_link" {
  value       = module.restricted_shared_vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "restricted_subnets_names" {
  value       = module.restricted_shared_vpc.subnets_names
  description = "The names of the subnets being created"
}

output "restricted_subnets_ips" {
  value       = module.restricted_shared_vpc.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "restricted_subnets_self_links" {
  value       = module.restricted_shared_vpc.subnets_self_links
  description = "The self-links of subnets being created"
}

output "restricted_subnets_secondary_ranges" {
  value       = module.restricted_shared_vpc.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}

output "restricted_allow_iap_ssh" {
  value       = module.restricted_shared_vpc.allow_iap_ssh
  description = "Firewall rule allow_iap_ssh created in the network"
}

output "restricted_allow_iap_rdp" {
  value       = module.restricted_shared_vpc.allow_iap_rdp
  description = "Firewall rule allow_iap_rdp created in the network"
}

output "restricted_allow_lb" {
  value       = module.restricted_shared_vpc.allow_lb
  description = "Firewall rule allow_lb created in the network"
}

output "restricted_default_policy" {
  value       = module.restricted_shared_vpc.default_policy
  description = "DNS Policy created in the network"
}

output "restricted_dns_record_set_restricted_api" {
  value       = module.restricted_shared_vpc.dns_record_set_restricted_api
  description = "DNS Record set for Restricted APIs"
}

output "restricted_dns_record_set_gcr_api" {
  value       = module.restricted_shared_vpc.dns_record_set_gcr_api
  description = "DNS Record set for GCR APIs"
}

output "restricted_region1_router1" {
  value       = module.restricted_shared_vpc.region1_router1
  description = "Router 1 for Region 1"
}

output "restricted_region1_router2" {
  value       = module.restricted_shared_vpc.region1_router2
  description = "Router 1 for Region 2"
}

output "restricted_region2_router1" {
  value       = module.restricted_shared_vpc.region2_router1
  description = "Router 2 for Region 1"
}

output "restricted_region2_router2" {
  value       = module.restricted_shared_vpc.region2_router2
  description = "Router 2 for Region 2"
}
