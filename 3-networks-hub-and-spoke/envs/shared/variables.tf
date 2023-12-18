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

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "perimeter_additional_members" {
  description = "The list of additional members to be added to the perimeter access level members list. To be able to see the resources protected by the VPC Service Controls in the restricted perimeter, add your user in this list. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`."
  type        = list(string)
}

variable "access_context_manager_policy_id" {
  type        = number
  description = "The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
}

variable "dns_enable_logging" {
  type        = bool
  description = "Toggle DNS logging for VPC DNS."
  default     = true
}

variable "dns_vpc_flow_logs" {
  description = <<EOT
  enable_logging: set to true to enable VPC flow logging for the subnetworks.
  aggregation_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN.
  flow_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].
  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, CUSTOM_METADATA.
  metadata_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM_METADATA.
  filter_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field.
EOT
  type = object({
    enable_logging       = optional(string, "true")
    aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_sampling        = optional(string, "0.5")
    metadata             = optional(string, "INCLUDE_ALL_METADATA")
    metadata_fields      = optional(list(string), [])
    filter_expr          = optional(string, "true")
  })
  default = {}
}

variable "domain" {
  type        = string
  description = "The DNS name of forwarding managed zone, for instance 'example.com'. Must end with a period."
}

variable "bgp_asn_dns" {
  type        = number
  description = "BGP Autonomous System Number (ASN)."
  default     = 64667
}

variable "target_name_server_addresses" {
  description = "List of IPv4 address of target name servers for the forwarding zone configuration. See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones for details on target name servers in the context of Cloud DNS forwarding zones."
  type        = list(map(any))
}

variable "base_hub_windows_activation_enabled" {
  type        = bool
  description = "Enable Windows license activation for Windows workloads in Base Hub"
  default     = false
}

variable "restricted_hub_windows_activation_enabled" {
  type        = bool
  description = "Enable Windows license activation for Windows workloads in Restricted Hub."
  default     = false
}

variable "base_hub_dns_enable_inbound_forwarding" {
  type        = bool
  description = "Toggle inbound query forwarding for Base Hub VPC DNS."
  default     = true
}

variable "restricted_hub_dns_enable_inbound_forwarding" {
  type        = bool
  description = "Toggle inbound query forwarding for Restricted Hub VPC DNS."
  default     = true
}

variable "base_hub_dns_enable_logging" {
  type        = bool
  description = "Toggle DNS logging for Base Hub VPC DNS."
  default     = true
}

variable "restricted_hub_dns_enable_logging" {
  type        = bool
  description = "Toggle DNS logging for Restricted Hub VPC DNS."
  default     = true
}

variable "base_hub_firewall_enable_logging" {
  type        = bool
  description = "Toggle firewall logging for VPC Firewalls in Base Hub VPC."
  default     = true
}

variable "restricted_hub_firewall_enable_logging" {
  type        = bool
  description = "Toggle firewall logging for VPC Firewalls in Restricted Hub VPC."
  default     = true
}

variable "base_hub_nat_enabled" {
  type        = bool
  description = "Toggle creation of NAT cloud router in Base Hub."
  default     = false
}

variable "restricted_hub_nat_enabled" {
  type        = bool
  description = "Toggle creation of NAT cloud router in Restricted Hub."
  default     = false
}

variable "base_hub_nat_bgp_asn" {
  type        = number
  description = "BGP ASN for first NAT cloud routes in Base Hub."
  default     = 64514
}

variable "restricted_hub_nat_bgp_asn" {
  type        = number
  description = "BGP ASN for first NAT cloud routes in Restricted Hub."
  default     = 64514
}

variable "base_hub_nat_num_addresses_region1" {
  type        = number
  description = "Number of external IPs to reserve for first Cloud NAT in Base Hub."
  default     = 2
}

variable "restricted_hub_nat_num_addresses_region1" {
  type        = number
  description = "Number of external IPs to reserve for first Cloud NAT in Restricted Hub."
  default     = 2
}

variable "base_hub_nat_num_addresses_region2" {
  type        = number
  description = "Number of external IPs to reserve for second Cloud NAT in Base Hub."
  default     = 2
}

variable "restricted_hub_nat_num_addresses_region2" {
  type        = number
  description = "Number of external IPs to reserve for second Cloud NAT in Restricted Hub."
  default     = 2
}

variable "base_vpc_flow_logs" {
  description = <<EOT
  enable_logging: set to true to enable VPC flow logging for the subnetworks.
  aggregation_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN.
  flow_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].
  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, CUSTOM_METADATA.
  metadata_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM_METADATA.
  filter_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field.
EOT
  type = object({
    enable_logging       = optional(string, "true")
    aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_sampling        = optional(string, "0.5")
    metadata             = optional(string, "INCLUDE_ALL_METADATA")
    metadata_fields      = optional(list(string), [])
    filter_expr          = optional(string, "true")
  })
  default = {}
}

variable "restricted_vpc_flow_logs" {
  description = <<EOT
  enable_logging: set to true to enable VPC flow logging for the subnetworks.
  aggregation_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN.
  flow_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].
  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, CUSTOM_METADATA.
  metadata_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM_METADATA.
  filter_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field.
EOT
  type = object({
    enable_logging       = optional(string, "true")
    aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_sampling        = optional(string, "0.5")
    metadata             = optional(string, "INCLUDE_ALL_METADATA")
    metadata_fields      = optional(list(string), [])
    filter_expr          = optional(string, "true")
  })
  default = {}
}

variable "firewall_policies_enable_logging" {
  type        = bool
  description = "Toggle hierarchical firewall logging."
  default     = true
}

variable "enable_dedicated_interconnect" {
  description = "Enable Dedicated Interconnect in the environment."
  type        = bool
  default     = false
}

variable "enable_partner_interconnect" {
  description = "Enable Partner Interconnect in the environment."
  type        = bool
  default     = false
}

variable "preactivate_partner_interconnect" {
  description = "Preactivate Partner Interconnect VLAN attachment in the environment."
  type        = bool
  default     = false
}

variable "enable_hub_and_spoke_transitivity" {
  description = "Enable transitivity via gateway VMs on Hub-and-Spoke architecture."
  type        = bool
  default     = false
}

variable "custom_restricted_services" {
  description = "List of custom services to be protected by the VPC-SC perimeter. If empty, all supported services (https://cloud.google.com/vpc-service-controls/docs/supported-products) will be protected."
  type        = list(string)
  default     = []
}

variable "egress_policies" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference), each list object has a `from` and `to` value that describes egress_from and egress_to.\n\nExample: `[{ from={ identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "ingress_policies" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
  default     = ""
}
