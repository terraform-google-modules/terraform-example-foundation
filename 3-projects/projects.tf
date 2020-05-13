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
  Projects for Production
*****************************************/

module "base_shared_vpc" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = var.prod_base_shared_vpc_project_name
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.prod.id
  activate_apis               = ["logging.googleapis.com", "compute.googleapis.com"]

  labels = {
    environment      = "prod"
    application_name = "base-shared-vpc"
  }
  skip_gcloud_download = true
}

module "restricted_shared_vpc" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = var.prod_rest_shared_vpc_project_name
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.prod.id
  activate_apis               = ["logging.googleapis.com", "compute.googleapis.com"]

  labels = {
    environment      = "prod"
    application_name = "rest-shared-vpc"
  }
  skip_gcloud_download = true
}

module "prod_secrets_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  name                        = var.prod_secrets_project_name
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.prod.id
  activate_apis               = ["logging.googleapis.com", "secretmanager.googleapis.com"]

  labels = {
    environment      = "prod"
    application_name = "secrets"
  }
  skip_gcloud_download = true
}
