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

variable "project_id" {
  description = "Project ID for project where applications resources reside.."
  type        = string
}

variable "vpc_self_link" {
  description = "Self link for VPC to create the subnet in."
  type        = string
}

variable "application_name" {
  description = "Name for subnets"
  type        = string
}

variable "default_region" {
  description = "Default region for resources."
  type        = string
  default     = "australia-southeast1"
}

variable "firewall_rules" {
  description = "List of project specific firewall rules, that will be scoped to supplied service accounts. Service accounts will be created."
  type = list(object({
    rule_name               = string
    allow_protocol          = string
    allow_ports             = list(string)
    source_service_accounts = list(string)
    target_service_accounts = list(string)
  }))
}

variable "enable_networking" {
  description = "Flag to toggle the creation of subnets & firewall rules"
  type        = bool
  default     = true
}