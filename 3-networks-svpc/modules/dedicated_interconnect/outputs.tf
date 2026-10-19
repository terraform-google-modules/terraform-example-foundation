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

output "interconnect_attachments" {
  description = "Map of all Dedicated Interconnect attachment objects keyed by attachment identifier."
  value       = { for k, v in module.interconnect_attachments : k => v.attachment }
}

output "customer_router_ip_addresses" {
  description = "Map of customer router IP addresses for all attachments keyed by attachment identifier."
  value       = { for k, v in module.interconnect_attachments : k => v.customer_router_ip_address }
}

output "google_cloud_router_ip_addresses" {
  description = "Map of Google Cloud Router BGP IP addresses for all attachments keyed by attachment identifier."
  value       = { for k, v in module.interconnect_attachments : k => v.attachment.cloud_router_ip_address }
}

output "ncc_spoke_ids" {
  description = "Map of Network Connectivity Center spoke IDs keyed by region."
  value       = { for k, v in google_network_connectivity_spoke.interconnect_spoke : k => v.id }
}
