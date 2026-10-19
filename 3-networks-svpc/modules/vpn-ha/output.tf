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

output "vpn_gateways" {
  description = "Map of all HA VPN gateway module instances."
  value       = { for k, v in module.vpn_ha : k => v }
}

output "vpn_tunnel_self_links" {
  description = "Map of VPN tunnel self links grouped by gateway key."
  value       = { for k, v in module.vpn_ha : k => v.tunnel_self_links }
}

output "ncc_vpn_spoke_ids" {
  description = "Map of Network Connectivity Center VPN spoke IDs keyed by region."
  value       = { for k, v in google_network_connectivity_spoke.vpn_spoke : k => v.id }
}
