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

output "network_name" {
  value       = module.main.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.main.network_self_link
  description = "The URI of the VPC being created"
}

output "subnets_names" {
  value       = module.main.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = module.main.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.main.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = module.main.subnets_regions
  description = "The region where the subnets will be created"
}

output "subnets_secondary_ranges" {
  value       = module.main.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}

output "region1_router1" {
  value       = try(module.region1_router1[0], null)
  description = "Router 1 for Region 1"
}

output "region1_router2" {
  value       = try(module.region1_router2[0], null)
  description = "Router 2 for Region 1"
}

output "region2_router1" {
  value       = try(module.region2_router1[0], null)
  description = "Router 1 for Region 2"
}

output "region2_router2" {
  value       = try(module.region2_router2[0], null)
  description = "Router 2 for Region 2"
}

output "access_level_name" {
  value       = local.access_level_name
  description = "Access context manager access level name "
}

output "service_perimeter_name" {
  value       = local.perimeter_name
  description = "Access context manager service perimeter name "
}
