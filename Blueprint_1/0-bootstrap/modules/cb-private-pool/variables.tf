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

variable "project_id" {
  description = "ID of the project where the private pool will be created"
  type        = string
}

variable "private_worker_pool" {
  description = <<EOT
  name: Name of the worker pool. A name with a random suffix is generated if not set.
  region: The private worker pool region. See https://cloud.google.com/build/docs/locations for available locations.
  disk_size_gb: Size of the disk attached to the worker, in GB.
  machine_type: Machine type of a worker.
  no_external_ip: If true, workers are created without any public address, which prevents network egress to public IPs.
  enable_network_peering: Set to true to enable configuration of networking peering for the private worker pool.
  create_peered_network: If true a network will be created to stablish the network peering.
  peered_network_id: The ID of the existing network to configure peering for the private worker pool if create_peered_network false. The project containing the network must have Service Networking API (`servicenetworking.googleapis.com`) enabled.
  peered_network_subnet_ip: The IP range to be used for the subnet that a will created in the peered network if create_peered_network true.
  peering_address: The IP address or beginning of the peering address range. This can be supplied as an input to reserve a specific address or omitted to allow GCP to choose a valid one.
  peering_prefix_length: The prefix length of the IP peering range. If not present, it means the address field is a single IP address.
  EOT
  type = object({
    name                     = optional(string, "")
    region                   = optional(string, "us-central1")
    disk_size_gb             = optional(number, 100)
    machine_type             = optional(string, "e2-medium")
    no_external_ip           = optional(bool, false)
    enable_network_peering   = optional(bool, false)
    create_peered_network    = optional(bool, false)
    peered_network_id        = optional(string, "")
    peered_network_subnet_ip = optional(string, "")
    peering_address          = optional(string, null)
    peering_prefix_length    = optional(number, 24)
  })
  default = {}

  validation {
    condition = (
      !var.private_worker_pool.enable_network_peering ||
      (var.private_worker_pool.enable_network_peering && var.private_worker_pool.create_peered_network && var.private_worker_pool.peered_network_subnet_ip != "") ||
      (var.private_worker_pool.enable_network_peering && !var.private_worker_pool.create_peered_network && var.private_worker_pool.peered_network_id != "")
    )
    error_message = "If network peering is enable, the peered network must be create by the module using the provided peered network subnet ip or a valid network ID is required"

  }
}

variable "vpn_configuration" {
  description = <<EOT
  enable_vpn: set to true to create VPN connection to on prem. If true, the following values must be valid.
  on_prem_public_ip_address0: The first public IP address for on prem VPN connection.
  on_prem_public_ip_address1: The second public IP address for on prem VPN connection.
  router_asn: Border Gateway Protocol (BGP) Autonomous System Number (ASN) for cloud routes.
  bgp_peer_asn: Border Gateway Protocol (BGP) Autonomous System Number (ASN) for peer cloud routes.
  shared_secret: The shared secret used in the VPN.
  psk_secret_project_id: The ID of the project that contains the secret from secret manager that holds the VPN pre-shared key.
  psk_secret_name: The name of the secret to retrieve from secret manager that holds the VPN pre-shared key.
  tunnel0_bgp_peer_address: BGP peer address for tunnel 0.
  tunnel0_bgp_session_range: BGP session range for tunnel 0.
  tunnel1_bgp_peer_address: BGP peer address for tunnel 1.
  tunnel1_bgp_session_range: BGP session range for tunnel 1.
  EOT
  type = object({
    enable_vpn                 = optional(bool, false)
    on_prem_public_ip_address0 = optional(string, "")
    on_prem_public_ip_address1 = optional(string, "")
    router_asn                 = optional(number, 64515)
    bgp_peer_asn               = optional(number, 64513)
    psk_secret_project_id      = optional(string, "")
    psk_secret_name            = optional(string, "")
    tunnel0_bgp_peer_address   = optional(string, "")
    tunnel0_bgp_session_range  = optional(string, "")
    tunnel1_bgp_peer_address   = optional(string, "")
    tunnel1_bgp_session_range  = optional(string, "")
  })
  default = {}

  validation {
    condition = !var.vpn_configuration.enable_vpn || (
      var.vpn_configuration.enable_vpn &&
      var.vpn_configuration.on_prem_public_ip_address0 != "" &&
      var.vpn_configuration.on_prem_public_ip_address1 != "" &&
      var.vpn_configuration.psk_secret_project_id != "" &&
      var.vpn_configuration.psk_secret_name != "" &&
      var.vpn_configuration.tunnel0_bgp_peer_address != "" &&
      var.vpn_configuration.tunnel0_bgp_session_range != "" &&
      var.vpn_configuration.tunnel1_bgp_peer_address != "" &&
      var.vpn_configuration.tunnel1_bgp_session_range != "" &&
      var.vpn_configuration.router_asn != null &&
      var.vpn_configuration.bgp_peer_asn != null
    )
    error_message = "If VPN configuration is enabled, all values are required."
  }
}

variable "vpc_flow_logs" {
  description = <<EOT
  aggregation_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN.
  flow_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].
  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, CUSTOM_METADATA.
  metadata_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM_METADATA.
  filter_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field.
EOT
  type = object({
    aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_sampling        = optional(string, "0.5")
    metadata             = optional(string, "INCLUDE_ALL_METADATA")
    metadata_fields      = optional(list(string), [])
    filter_expr          = optional(string, "true")
  })
  default = {}
}
