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
output "nonprod_allow_iap_ssh" {
  value       = module.shared_vpc_nonprod.allow_iap_ssh
  description = "Firewall rule allow_iap_ssh created in the network"
}

output "nonprod_allow_iap_rdp" {
  value       = module.shared_vpc_nonprod.allow_iap_rdp
  description = "Firewall rule allow_iap_rdp created in the network"
}

output "nonprod_allow_lb" {
  value       = module.shared_vpc_nonprod.allow_lb
  description = "Firewall rule allow_lb created in the network"
}

output "nonprod_default_policy" {
  value       = module.shared_vpc_nonprod.default_policy
  description = "DNS Policy created in the network"
}

output "nonprod_dns_record_set_private_api" {
  value       = module.shared_vpc_nonprod.dns_record_set_private_api
  description = "DNS Record set for Private APIs"
}

output "nonprod_dns_record_set_gcr_api" {
  value       = module.shared_vpc_nonprod.dns_record_set_gcr_api
  description = "DNS Record set for GCR APIs"
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
  description = "The name of the VPC stá pronta para ser despachada do CD. Agbeing created"
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

output "prod_allow_iap_ssh" {
  value       = module.shared_vpc_prod.allow_iap_ssh
  description = "Firewall rule allow_iap_ssh created in the network"
}

output "prod_allow_iap_rdp" {
  value       = module.shared_vpc_prod.allow_iap_rdp
  description = "Firewall rule allow_iap_rdp created in the network"
}

output "prod_allow_lb" {
  value       = module.shared_vpc_prod.allow_lb
  description = "Firewall rule allow_lb created in the network"
}

output "prod_default_policy" {
  value       = module.shared_vpc_prod.default_policy
  description = "DNS Policy created in the network"
}

output "prod_dns_record_set_private_api" {
  value       = module.shared_vpc_prod.dns_record_set_private_api
  description = "DNS Record set for Private APIs"
}

output "prod_dns_record_set_gcr_api" {
  value       = module.shared_vpc_prod.dns_record_set_gcr_api
  description = "DNS Record set for GCR APIs"
}