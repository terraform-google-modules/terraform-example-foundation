/**
 * Copyright 2021-2022 Google LLC
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

locals {
  //project IDs must start with a letter.
  //Max length for project_prefix is 3, basde in the projects create in the foundation
  project_prefix = "${random_string.one_letter.result}${random_string.two_alphanumeric.result}"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "one_letter" {
  length  = 1
  numeric = false
  special = false
  upper   = false
}

resource "random_string" "two_alphanumeric" {
  length  = 2
  special = false
  upper   = false
}

resource "google_folder" "test_folder" {
  display_name = "test_foundation_folder_${random_string.suffix.result}"
  parent       = "folders/${var.folder_id}"
}

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 15.0"

  name                     = "ci-foundation-${random_string.suffix.result}"
  random_project_id        = true
  random_project_id_length = 4
  org_id                   = var.org_id
  folder_id                = var.folder_id
  billing_account          = var.billing_account

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudkms.googleapis.com",
    "bigquery.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "securitycenter.googleapis.com",
    "servicenetworking.googleapis.com",
    "billingbudgets.googleapis.com",
    "essentialcontacts.googleapis.com",
  ]
}
