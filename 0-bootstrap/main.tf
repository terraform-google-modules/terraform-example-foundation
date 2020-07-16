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

provider "google" {
  version = "~> 3.30.0"
}

provider "google-beta" {
  version = "~> 3.30.0"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

/*************************************************
  Bootstrap GCP Organization.
*************************************************/
locals {
  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
}

resource "google_folder" "seed" {
  display_name = "seed"
  parent       = local.parent
}

module "seed_bootstrap" {
  source                  = "terraform-google-modules/bootstrap/google"
  version                 = "~> 1.2"
  org_id                  = var.org_id
  folder_id               = google_folder.seed.id
  billing_account         = var.billing_account
  group_org_admins        = var.group_org_admins
  group_billing_admins    = var.group_billing_admins
  default_region          = var.default_region
  org_project_creators    = var.org_project_creators
  sa_enable_impersonation = true
  parent_folder           = var.parent_folder == "" ? "" : local.parent
  skip_gcloud_download    = var.skip_gcloud_download

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "securitycenter.googleapis.com",
    "accesscontextmanager.googleapis.com"
  ]

  sa_org_iam_permissions = [
    "roles/accesscontextmanager.policyAdmin",
    "roles/billing.user",
    "roles/compute.networkAdmin",
    "roles/compute.xpnAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/logging.configWriter",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/securitycenter.notificationConfigEditor",
    "roles/resourcemanager.organizationViewer"
  ]
}

module "cloudbuild_bootstrap" {
  source                  = "terraform-google-modules/bootstrap/google//modules/cloudbuild"
  version                 = "~> 1.2"
  org_id                  = var.org_id
  folder_id               = google_folder.seed.id
  billing_account         = var.billing_account
  group_org_admins        = var.group_org_admins
  default_region          = var.default_region
  terraform_sa_email      = module.seed_bootstrap.terraform_sa_email
  terraform_sa_name       = module.seed_bootstrap.terraform_sa_name
  terraform_state_bucket  = module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation = true
  skip_gcloud_download    = var.skip_gcloud_download
  cloudbuild_plan_filename  = "build/cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "build/cloudbuild-tf-apply.yaml"

  cloud_source_repos = [
    "gcp-foundation"
  ]

  terraform_apply_branches = [
    "dev",
    "nonprod",
    "prod"
  ]
}
