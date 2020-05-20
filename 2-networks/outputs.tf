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

/******************************************
 Nonprod Outputs
*****************************************/

output "nonprod_host_project_id" {
  value       = local.nonprod_host_project_id
  description = "The host project ID for nonprod"
}

output "nonprod_network_name" {
  value       = module.shared_vpc_nonprod.network_name
  description = "The name of the VPC being created"
}

output "nonprod_network_self_link" {
  value       = module.shared_vpc_nonprod.network_self_link
  description = "The URI of the VPC being created"
}

output "nonprod_subnets_names" {
  value       = module.shared_vpc_nonprod.subnets_names
  description = "The names of the subnets being created"
}

output "nonprod_subnets_ips" {
  value       = module.shared_vpc_nonprod.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "nonprod_subnets_self_links" {
  value       = module.shared_vpc_nonprod.subnets_self_links
  description = "The self-links of subnets being created"
}

output "nonprod_subnets_secondary_ranges" {
  value       = module.shared_vpc_nonprod.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}

/******************************************
 Prod Outputs
*****************************************/

output "prod_host_project_id" {
  value       = local.prod_host_project_id
  description = "The host project ID for prod"
}

output "prod_network_name" {
  value       = module.shared_vpc_prod.network_name
  description = "The name of the VPC being created"
}

output "prod_network_self_link" {
  value       = module.shared_vpc_prod.network_self_link
  description = "The URI of the VPC being created"
}

output "prod_subnets_names" {
  value       = module.shared_vpc_prod.subnets_names
  description = "The names of the subnets being created"
}

output "prod_subnets_ips" {
  value       = module.shared_vpc_prod.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "prod_subnets_self_links" {
  value       = module.shared_vpc_prod.subnets_self_links
  description = "The self-links of subnets being created"
}

output "prod_subnets_secondary_ranges" {
  value       = module.shared_vpc_prod.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}
