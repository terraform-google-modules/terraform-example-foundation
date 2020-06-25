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

output "subnets_private_access" {
  value       = module.main.subnets_private_access
  description = "Whether the subnets have access to Google API's without a public IP"
}

output "subnets_flow_logs" {
  value       = module.main.subnets_flow_logs
  description = "Whether the subnets have VPC flow logs enabled"
}

output "subnets_secondary_ranges" {
  value       = module.main.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}

output "allow_iap_ssh" {
  value       = google_compute_firewall.allow_iap_ssh
  description = "Firewall rule allow_iap_ssh created in the network"
}

output "allow_iap_rdp" {
  value       = google_compute_firewall.allow_iap_rdp
  description = "Firewall rule allow_iap_rdp created in the network"
}

output "allow_lb" {
  value       = google_compute_firewall.allow_lb
  description = "Firewall rule allow_lb created in the network"
}

output "default_policy" {
  value       = google_dns_policy.default_policy
  description = "DNS Policy created in the network"
}

output "dns_record_set_private_api" {
  value       = module.private_googleapis
  description = "DNS Record set for Private APIs"
}

output "dns_record_set_gcr_api" {
  value       = module.private_gcr
  description = "DNS Record set for GCR APIs"
}
