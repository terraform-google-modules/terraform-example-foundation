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
