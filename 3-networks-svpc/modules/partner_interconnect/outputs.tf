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
  description = "Map of all Partner Interconnect attachment objects keyed by attachment identifier."
  value       = { for k, v in google_compute_interconnect_attachment.partner_attachment : k => v }
}

output "pairing_keys" {
  description = "Map of pairing keys for all Partner Interconnect attachments keyed by attachment identifier."
  value       = { for k, v in google_compute_interconnect_attachment.partner_attachment : k => v.pairing_key }
}

output "ncc_spoke_ids" {
  description = "Map of Network Connectivity Center spoke IDs keyed by region."
  value       = { for k, v in google_network_connectivity_spoke.partner_ic_spoke : k => v.id }
}
