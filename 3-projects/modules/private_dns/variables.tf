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
  Private DNS Management (Optional)
 *****************************************/
variable "project_id" {
  description = "Project ID for VPC."
  type        = string
}

variable "application_name" {
  description = "Friendly application name to apply as a label."
  type        = string
}

variable "environment" {
  description = "Environment to look up VPC and host project."
  type        = string
}

variable "top_level_domain" {
  description = "The top level domain name for the organization"
  type        = string
}

variable "shared_vpc_self_link" {
  description = "Self link of Shared VPC Network."
  type        = string
}

variable "shared_vpc_project_id" {
  description = "Project ID for Shared VPC."
  type        = string
}

variable "enable_private_dns" {
  description = "Flag to toggle the creation of dns zones"
  type        = bool
  default     = true
}
