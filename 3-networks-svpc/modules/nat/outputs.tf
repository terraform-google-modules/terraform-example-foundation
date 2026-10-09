/**
 * Copyright 2026 Google LLC
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

output "nat_ip_address_list" {
  description = "A flat list of all external IP addresses reserved for NAT. Very useful for third-party firewall allowlisting."
  value       = [for addr in google_compute_address.nat_external_addresses : addr.address]
}

output "nat_ip_addresses_map" {
  description = "A map of NAT external IP addresses with their keys, useful if you need to know which IP belongs to which region/index."
  value = {
    for k, v in google_compute_address.nat_external_addresses : k => v.address
  }
}

output "cloud_router_names" {
  description = "Map of Cloud Router names created, keyed by region."
  # The module exposes a 'router' output containing the created resource
  value = {
    for k, v in module.cloud_router : k => v.router.name
  }
}

output "cloud_router_ids" {
  description = "Map of Cloud Router IDs created, keyed by region."
  value = {
    for k, v in module.cloud_router : k => v.router.id
  }
}
