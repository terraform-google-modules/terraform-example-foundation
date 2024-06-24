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

/*************************************************
  Bootstrap GCP Organization.
*************************************************/
locals {
  // The bootstrap module will enforce that only identities
  // in the list "org_project_creators" will have the Project Creator role,
  // so the granular service accounts for each step need to be added to the list.
  step_terraform_sa = [
    "serviceAccount:${google_service_account.terraform-env-sa["bootstrap"].email}",
    "serviceAccount:${google_service_account.terraform-env-sa["org"].email}",
    "serviceAccount:${google_service_account.terraform-env-sa["env"].email}",
    "serviceAccount:${google_service_account.terraform-env-sa["net"].email}",
    "serviceAccount:${google_service_account.terraform-env-sa["proj"].email}",
  ]
  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  org_admins_org_iam_permissions = var.org_policy_admin_role == true ? [
    "roles/orgpolicy.policyAdmin", "roles/resourcemanager.organizationAdmin", "roles/billing.user"
  ] : ["roles/resourcemanager.organizationAdmin", "roles/billing.user"]
}

resource "google_folder" "bootstrap" {
  display_name = "${var.folder_prefix}-bootstrap"
  parent       = local.parent
}

module "seed_bootstrap" {
  source  = "terraform-google-modules/bootstrap/google"
  version = "~> 8.0"

  org_id                         = var.org_id
  folder_id                      = google_folder.bootstrap.id
  project_id                     = "${var.project_prefix}-b-seed"
  state_bucket_name              = "${var.bucket_prefix}-${var.project_prefix}-b-seed-tfstate"
  force_destroy                  = var.bucket_force_destroy
  billing_account                = var.billing_account
  group_org_admins               = var.groups.required_groups.group_org_admins
  group_billing_admins           = var.groups.required_groups.group_billing_admins
  default_region                 = var.default_region
  org_project_creators           = local.step_terraform_sa
  sa_enable_impersonation        = true
  create_terraform_sa            = false
  parent_folder                  = var.parent_folder == "" ? "" : local.parent
  org_admins_org_iam_permissions = local.org_admins_org_iam_permissions
  project_prefix                 = var.project_prefix
  encrypt_gcs_bucket_tfstate     = true
  key_rotation_period            = "7776000s"
  kms_prevent_destroy            = !var.bucket_tfstate_kms_force_destroy

  project_labels = {
    environment       = "bootstrap"
    application_name  = "seed-bootstrap"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "shared"
    env_code          = "b"
    vpc               = "none"
  }

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "securitycenter.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "essentialcontacts.googleapis.com",
    "assuredworkloads.googleapis.com",
    "cloudasset.googleapis.com"
  ]

  sa_org_iam_permissions = []

  depends_on = [module.required_group]
}

