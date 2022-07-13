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

variable "project_id" {
  type        = string
  description = "VPC Project ID"
}

variable "regions" {
  type        = set(string)
  description = "Regions to deploy the transitivity appliances"
  default     = null
}

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with shared VPC that will use the Interconnect."
}

variable "gw_subnets" {
  description = "Subnets in {REGION => SUBNET} format."
  type        = map(string)
}

variable "regional_aggregates" {
  description = "Aggregate ranges for each region in {REGION => [AGGREGATE_CIDR,] } format."
  type        = map(list(string))
}

variable "commands" {
  description = "Commands for the transitivity gateway to run on every boot."
  type        = list(string)
  default     = []
}

variable "firewall_enable_logging" {
  type        = bool
  description = "Toggle firewall logging for VPC Firewalls."
  default     = true
}

variable "health_check_enable_log" {
  type        = bool
  description = "Toggle logging for health checks."
  default     = false
}
