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

output "restricted_host_project_id" {
  value       = local.restricted_net_hub_project_id
  description = "The restricted host project ID"
}

output "base_host_project_id" {
  value       = local.base_net_hub_project_id
  description = "The base host project ID"
}

output "base_network_name" {
  value       = module.base_shared_vpc.network_name
  description = "The name of the VPC being created"
}

output "restricted_network_name" {
  value       = module.restricted_shared_vpc.network_name
  description = "The name of the VPC being created"
}

output "base_dns_policy" {
  value       = module.base_shared_vpc.base_dns_policy
  description = "The name of the DNS policy being created"
}

output "restricted_dns_policy" {
  value       = module.restricted_shared_vpc.restricted_dns_policy
  description = "The name of the DNS policy being created"
}
