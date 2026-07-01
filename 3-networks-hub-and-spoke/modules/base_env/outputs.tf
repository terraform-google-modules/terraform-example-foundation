/**
 * Copyright 2022 Google LLC
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

output "target_name_server_addresses" {
  value       = var.target_name_server_addresses
  description = "List of IPv4 address of target name servers for the forwarding zone configuration"
}

output "shared_vpc_host_project_id" {
  value       = local.shared_vpc_project_id
  description = "The host project ID"
}

output "network_name" {
  value       = module.shared_vpc.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.shared_vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "subnets_names" {
  value       = module.shared_vpc.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = module.shared_vpc.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.shared_vpc.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_secondary_ranges" {
  value       = module.shared_vpc.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}
