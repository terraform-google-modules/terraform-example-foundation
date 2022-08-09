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

variable "env" {
  description = "The environment to prepare (ex. development)"
  type        = string
}

variable "environment_code" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization (ex. d)."
}

variable "org_id" {
  type        = string
  description = "Organization ID"
}

variable "access_context_manager_policy_id" {
  type        = number
  description = "The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
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

variable "parent_folder" {
  description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step."
  type        = string
  default     = ""
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "enable_partner_interconnect" {
  description = "Enable Partner Interconnect in the environment."
  type        = bool
  default     = false
}

variable "enable_hub_and_spoke_transitivity" {
  description = "Enable transitivity via gateway VMs on Hub-and-Spoke architecture."
  type        = bool
  default     = false
}

variable "base_private_service_cidr" {
  type        = string
  description = "CIDR range for private service networking. Used for Cloud SQL and other managed services in the Base Shared Vpc."
}

variable "base_subnet_primary_ranges" {
  type        = map(string)
  description = "The base subnet primary IPTs ranges to the Base Shared Vpc."
}

variable "base_subnet_secondary_ranges" {
  type        = map(list(map(string)))
  description = "The base subnet secondary IPTs ranges to the Base Shared Vpc."
}

variable "restricted_private_service_cidr" {
  type        = string
  description = "CIDR range for private service networking. Used for Cloud SQL and other managed services in the Restricted Shared Vpc."
}

variable "restricted_subnet_primary_ranges" {
  type        = map(string)
  description = "The base subnet primary IPTs ranges to the Restricted Shared Vpc."
}

variable "restricted_subnet_secondary_ranges" {
  type        = map(list(map(string)))
  description = "The base subnet secondary IPTs ranges to the Restricted Shared Vpc"
}

variable "members" {
  type        = list(string)
  description = "An allowed list of members (users, service accounts)to be include in the VPC-SC perimeter. The signed-in identity originating the request must be a part of one of the provided members. If not specified, a request may come from any user (logged in/not logged in, etc.). Formats: user:{emailid}, serviceAccount:{emailid}"
}
