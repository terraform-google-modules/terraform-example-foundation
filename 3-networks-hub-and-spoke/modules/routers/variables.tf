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

variable "project_id" {
  type        = string
  description = "project ID to create the routers."
}

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with VPC that will use the Routers."
}

variable "region1" {
  type        = string
  description = "First subnet region."
}

variable "region2" {
  type        = string
  description = "Second subnet region."
}

variable "bgp_asn_subnet" {
  type        = number
  description = "BGP ASN for Subnets cloud routers."
}

variable "advertised_ip_ranges" {
  type = list(object({
    range       = string
    description = optional(string)
  }))
  description = "User-specified list of individual IP ranges to advertise."
  default     = []
}
