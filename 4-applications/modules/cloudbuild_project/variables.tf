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

variable "impersonate_service_account" {
  description = "Service account email of the account to impersonate to run Terraform"
  type        = string
}

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associated this project with"
  type        = string
}

variable "default_region" {
  description = "Default region for subnet."
  type        = string
}

variable "project_prefix" {
  description = "The name of the GCP project"
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork the application infrastructure will use"
  type        = string
}

variable "application_name" {
  type        = string
  description = "Friendly application name to apply as a label."
}

variable "cost_centre" {
  description = "The cost centre that links to the application"
  type        = string
}

variable "admin_group" {
  description = "GSuite or Identity Group for GCP Application Administrators"
  type        = string
}