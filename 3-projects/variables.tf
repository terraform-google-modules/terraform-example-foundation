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

variable "terraform_service_account" {
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

variable "dev_folder" {
  description = "Optional - if using a folder for testing."
  type        = string
  default     = ""
}

/******************************************
  Folder Names
 *****************************************/

variable "prod_folder_name" {
  description = "Default Display Name for Production Folder."
  type        = string
  default     = "Production"
}

variable "nonprod_folder_name" {
  description = "Default Display Name for Non-Production Folder."
  type        = string
  default     = "Staging"
}

variable "qa_folder_name" {
  description = "Default Display Name for QA Folder."
  type        = string
  default     = "QA"
}

variable "dev_folder_name" {
  description = "Default Display Name for Development Folder."
  type        = string
  default     = "Development"
}

/******************************************
  Project Names
 *****************************************/

variable "prod_base_shared_vpc_project_name" {
  description = "Default Display Name for Production Base Shared VPC Project."
  type        = string
  default     = "p-base-shared-vpc"
}

variable "prod_rest_shared_vpc_project_name" {
  description = "Default Display Name for Production Restricted Shared VPC Project."
  type        = string
  default     = "p-rest-shared-vpc"
}

variable "prod_secrets_project_name" {
  description = "Default Display Name for Production Secrets Project."
  type        = string
  default     = "p-base-shared-vpc"
}

variable "nonprod_base_shared_vpc_project_name" {
  description = "Default Display Name for Non-Production Base Shared VPC Project."
  type        = string
  default     = "n-base-shared-vpc"
}
