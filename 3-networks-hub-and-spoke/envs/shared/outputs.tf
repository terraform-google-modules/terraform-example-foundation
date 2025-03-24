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

output "shared_vpc_host_project_id" {
  value       = local.net_hub_project_id
  description = "The host project ID"
}

output "network_name" {
  value       = module.shared_vpc.network_name
  description = "The name of the Shared VPC being created"
}

output "dns_policy" {
  value       = module.shared_vpc.dns_policy
  description = "The name of the DNS policy being created"
}
