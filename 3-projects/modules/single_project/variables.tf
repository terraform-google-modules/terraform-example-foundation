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

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "folder_id" {
  description = "The folder id where project will be created"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associated this project with"
  type        = string
}

variable "impersonate_service_account" {
  description = "Service account email of the account to impersonate to run Terraform"
  type        = string
}

variable "project_prefix" {
  description = "The name of the GCP project"
  type        = string
}

variable "cost_centre" {
  description = "The cost centre that links to the application"
  type        = string
}

variable "application_name" {
  description = "The name of application where GCP resources relate"
  type        = string
}

variable "activate_apis" {
  description = "The api to activate for the GCP project"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "The environment the single project belongs to"
  type        = string
}

/******************************************
  Project subnet (Optional)
 *****************************************/
# variable "enable_networking" {
#   description = "The flag to create subnets in shared VPC"
#   type        = bool
#   default     = false
# }

# variable "subnet_ip_cidr_range" {
#   description = "The CIDR Range of the subnet to get allocated to the project"
#   type        = string
#   default     = ""
# }

# variable "subnet_secondary_ranges" {
#   description = "The secondary CIDR Ranges of the subnet to get allocated to the project"
#   type = list(object({
#     range_name    = string
#     ip_cidr_range = string
#   }))
#   default = []
# }

/******************************************
  Private DNS Management (Optional)
 *****************************************/
# variable "enable_private_dns" {
#   type        = bool
#   description = "The flag to create private dns zone in shared VPC"
#   default     = false
# }

# variable "domain" {
#   type        = string
#   description = "The top level domain name for the organization"
#   default     = ""
# }
