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

variable "target_name_server_addresses" {
  description = "List of IPv4 address of target name servers for the forwarding zone configuration. See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones for details on target name servers in the context of Cloud DNS forwarding zones."
  type        = list(map(any))
  default     = []
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "env" {
  description = "The environment to prepare (ex. development)"
  type        = string
}

variable "environment_code" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization (ex. d)."
}

variable "default_region1" {
  type        = string
  description = "First subnet region. The shared vpc modules only configures two regions."
}

variable "default_region2" {
  type        = string
  description = "Second subnet region. The shared vpc modules only configures two regions."
}

variable "domain" {
  type        = string
  description = "The DNS name of peering managed zone, for instance 'example.com.'. Must end with a period."
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

variable "private_service_cidr" {
  type        = string
  description = "CIDR range for private service networking. Used for Cloud SQL and other managed services in the Shared Vpc."
}

variable "subnet_primary_ranges" {
  type        = map(string)
  description = "The base subnet primary IPTs ranges to the Shared Vpc."
}

variable "subnet_proxy_ranges" {
  type        = map(string)
  description = "The base proxy-only subnet primary IPTs ranges to the Shared Vpc."
}

variable "subnet_secondary_ranges" {
  type        = map(list(map(string)))
  description = "The base subnet secondary IPTs ranges to the Shared Vpc"
}

variable "private_service_connect_ip" {
  type        = string
  description = "The base subnet internal IP to be used as the private service connect endpoint in the Shared VPC"
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

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
}

