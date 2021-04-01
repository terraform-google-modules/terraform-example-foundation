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

variable "org_id" {
  description = "The organization id for projects"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associated with projects "
  type        = string
}

variable "policy_id" {
  type        = string
  description = "The ID of the access context manager policy the perimeter lies in. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
}

variable "parent_folder" {
  description = "Folder for testing."
  type        = string
  default     = ""
}

variable "dev_restricted_service_perimeter_name" {
  description = "development access context manager service perimeter name"
  type        = string
}

variable "nonprod_restricted_service_perimeter_name" {
  description = "non-production access context manager service perimeter name"
  type        = string
}

variable "prod_restricted_service_perimeter_name" {
  description = "production access context manager service perimeter name"
  type        = string
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
}

variable "enable_hub_and_spoke" {
  description = "Enable Hub-and-Spoke architecture."
  type        = bool
  default     = false
}
