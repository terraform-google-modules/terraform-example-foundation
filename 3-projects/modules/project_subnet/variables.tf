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

variable "vpc_host_project_id" {
  description = "VPC Host project ID."
  type        = string
}

variable "vpc_self_link" {
  description = "Self link for VPC to create the subnet in."
  type        = string
}

variable "ip_cidr_range" {
  description = "CIDR Block to use for the subnet."
  type        = string
}

variable "application_name" {
  description = "Name for subnets"
  type        = string
}

variable "enable_vpc_flow_logs" {
  description = "Flag to enable VPC flow logs with default configuration."
  type        = bool
  default     = false
}

variable "enable_private_access" {
  description = "Flag to enable Google Private access in the subnet."
  type        = bool
  default     = true
}

variable "default_region" {
  description = "Default region for resources."
  type        = string
}

variable "secondary_ranges" {
  description = "Secondary ranges that will be used in some of the subnets"
  type = list(object({
    range_name    = string,
    ip_cidr_range = string
  }))
  default = []
}

variable "enable_networking" {
  description = "The Flag to toggle the creation of subnets"
  type        = bool
  default     = false
}

variable "project_id" {
  type        = string
  description = "Project Id"
}
