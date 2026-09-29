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

output "interconnect_attachments" {
  description = "Map of all partner interconnect attachment objects keyed by attachment name."
  value       = { for k, v in module.partner_interconnect_attachments : k => v.attachment }
}

output "customer_router_ip_addresses" {
  description = "Map of IPv4 addresses + prefix lengths to configure on customer router subinterfaces."
  value       = { for k, v in module.partner_interconnect_attachments : k => v.customer_router_ip_address }
}

output "partner_pairing_keys" {
  description = "Pairing keys generated for Partner Interconnect provisioning."
  value       = { for k, v in module.partner_interconnect_attachments : k => v.attachment.pairing_key }
}

output "partner_asns" {
  description = "Map of partner ASNs assigned to each Partner Interconnect attachment."
  value       = { for k, v in module.partner_interconnect_attachments : k => v.attachment.partner_asn }
}
