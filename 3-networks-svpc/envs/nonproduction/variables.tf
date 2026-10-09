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

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "universe_domain" {
  description = "The universe domain to use for Google Cloud APIs. This defines the API endpoint boundary for your deployment. The default is 'googleapis.com' for the standard public Google Cloud. Modify this value if you are deploying to isolated environments like Google Cloud Dedicated (GCD)."
  type        = string
  default     = "googleapis.com"

  validation {
    condition     = var.universe_domain != null && length(trimspace(coalesce(var.universe_domain, ""))) > 0
    error_message = "The universe_domain variable cannot be null or an empty string."
  }
}

variable "pkg_dev_domain" {
  description = "Domain for Artifact Registry. Change if using a custom universe_domain."
  type        = string
  default     = "pkg.dev"

  validation {
    condition     = var.pkg_dev_domain != null && length(trimspace(coalesce(var.pkg_dev_domain, ""))) > 0
    error_message = "The pkg_dev_domain variable cannot be null or an empty string."
  }
}

variable "enable_gcr_dns" {
  description = "Enable DNS zone creation for legacy gcr.io. Set to false for GCD environments where Container Registry is not available."
  type        = bool
  default     = true
}

variable "domain" {
  type        = string
  description = "The DNS name of peering managed zone, for instance 'example.com.'. Must end with a period."
}

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
  default     = ""
}
