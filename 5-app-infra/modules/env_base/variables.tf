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

variable "environment" {
  description = "The environment the single project belongs to"
  type        = string
}

variable "business_unit" {
  description = "The business (ex. business_unit_1)."
  type        = string
  default     = "business_unit_1"
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "us-central1"
}

variable "num_instances" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = "f1-micro"
}

variable "disk_type" {
  description = "Boot disk type, can be either pd-ssd, local-ssd, pd-standard, or hyperdisk-balanced(Air Gapped)"
  type        = string
  default     = "pd-standard"
}

variable "source_image" {
  description = "Source disk image. if not provided defaults to the latest public Rocky Linux 9 optimized for GCP image."
  type        = string
  default     = ""
}

variable "hostname" {
  description = "Hostname of instances"
  type        = string
  default     = "example-app"
}

variable "project_suffix" {
  description = "The name of the GCP project. Max 16 characters with 3 character business unit code."
  type        = string
}

variable "remote_state_bucket" {
  description = "Backend bucket to load remote state information from previous steps."
  type        = string
}

variable "universe_domain" {
  description = "The universe domain to use for Google Cloud APIs. This defines the API endpoint boundary for your deployment. The default is 'googleapis.com' for the standard public Google Cloud. Modify this value if you are deploying to isolated environments like Google Cloud Dedicated (GCD)."
  type        = string
  default     = "googleapis.com"
}
