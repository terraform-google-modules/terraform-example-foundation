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

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform"
  type        = string
}

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
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  default     = "f1-micro"
}

variable "hostname" {
  description = "Hostname of instances"
  default     = "example-app"
}

variable "service_account" {
  default = null
  type = object({
    email  = string,
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
}

variable "business_code" {
  description = "The code that describes which business unit owns the project"
  type        = string
  default     = "abcd"
}

variable "project_suffix" {
  description = "The name of the GCP project. Max 16 characters with 3 character business unit code. Valid options are `sample-base` or `sample-restrict`."
  type        = string
}

variable "backend_bucket" {
  description = "Backend bucket to load remote state information from previous steps."
  type        = string
}
