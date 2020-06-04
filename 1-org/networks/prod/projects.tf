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
  Initializing variables
*****************************************/

variable "billing_account" {}
variable "default_region" {}
variable "folder_id" {}
variable "org_id" {}
variable "terraform_service_account" {}

/******************************************
  Projects for Shared VPCs
*****************************************/

module "org_shared_vpc_prod" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  name                        = "org-shared-vpc-prod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.folder_id
  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com"
  ]

  labels = {
    environment      = "prod"
    application_name = "org-shared-vpc-prod"
  }
}
