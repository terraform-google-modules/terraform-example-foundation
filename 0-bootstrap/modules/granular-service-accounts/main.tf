/**
 * Copyright 2022 Google LLC
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
  granular_sa = {
    "org"  = "CFT Organization Step Terraform Account",
    "env"  = "CFT Environment Step Terraform Account",
    "net"  = "CFT Network Step Terraform Account",
    "proj" = "CFT Projects Step Terraform Account",
  }

  granular_sa_org_level_roles = {
    "org" = [
      "roles/orgpolicy.policyAdmin",
      "roles/logging.configWriter",
      "roles/resourcemanager.organizationAdmin",
      "roles/securitycenter.notificationConfigEditor",
      "roles/resourcemanager.organizationViewer",
      "roles/accesscontextmanager.policyAdmin",
    ],
    "net" = [
      "roles/accesscontextmanager.policyAdmin",
      "roles/compute.xpnAdmin",
    ],
    "proj" = [
      "roles/accesscontextmanager.policyAdmin",
      "roles/serviceusage.serviceUsageConsumer"
    ],
  }

  granular_sa_parent_level_roles = {
    "org" = [
      "roles/resourcemanager.folderAdmin",
    ],
    "env" = [
      "roles/resourcemanager.folderAdmin"
    ],
    "net" = [
      "roles/resourcemanager.folderViewer",
      "roles/dns.admin",
      "roles/compute.networkAdmin",
      "roles/compute.securityAdmin",
      "roles/compute.orgSecurityPolicyAdmin",
      "roles/compute.orgSecurityResourceAdmin",
      "roles/iam.serviceAccountAdmin",
    ],
    "proj" = [
      "roles/resourcemanager.folderViewer",
      "roles/resourcemanager.folderIamAdmin",
      "roles/compute.networkAdmin",
      "roles/compute.xpnAdmin",
    ],
  }
}

resource "google_service_account" "terraform-env-sa" {
  for_each = local.granular_sa

  project      = var.seed_project_id
  account_id   = "terraform-${each.key}-sa"
  display_name = each.value
}


resource "google_organization_iam_member" "org" {
  for_each = toset(local.granular_sa_org_level_roles["org"])

  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["org"].email}"
}

resource "google_organization_iam_member" "net" {
  for_each = toset(local.granular_sa_org_level_roles["net"])

  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["net"].email}"
}

resource "google_organization_iam_member" "proj" {
  for_each = toset(local.granular_sa_org_level_roles["proj"])

  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["proj"].email}"
}

resource "google_billing_account_iam_member" "tf_billing_user" {
  for_each = local.granular_sa

  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"

  depends_on = [
    google_service_account.terraform-env-sa
  ]
}

resource "google_billing_account_iam_member" "billing_admin_user" {
  for_each = local.granular_sa

  billing_account_id = var.billing_account
  role               = "roles/billing.admin"
  member             = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"

  depends_on = [
    google_billing_account_iam_member.tf_billing_user
  ]
}

resource "google_service_account_iam_member" "cloudbuild_terraform_sa_impersonate_permissions" {
  for_each = local.granular_sa

  service_account_id = google_service_account.terraform-env-sa[each.key].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.cloud_build_sa}"

  depends_on = [
    google_service_account.terraform-env-sa
  ]
}

resource "google_organization_iam_member" "org_parent_org_step" {
  for_each = toset(var.parent_folder == "" ? local.granular_sa_parent_level_roles["org"] : [])

  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["org"].email}"
}

resource "google_folder_iam_member" "folder_parent_org_step" {
  for_each = toset(var.parent_folder != "" ? local.granular_sa_parent_level_roles["org"] : [])

  folder = var.parent_folder
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["org"].email}"
}

resource "google_organization_iam_member" "org_parent_env_step" {
  for_each = toset(var.parent_folder == "" ? local.granular_sa_parent_level_roles["env"] : [])

  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["env"].email}"
}

resource "google_folder_iam_member" "folder_parent_env_step" {
  for_each = toset(var.parent_folder != "" ? local.granular_sa_parent_level_roles["env"] : [])

  folder = var.parent_folder
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["env"].email}"
}

resource "google_organization_iam_member" "org_parent_net_step" {
  for_each = toset(var.parent_folder == "" ? local.granular_sa_parent_level_roles["net"] : [])

  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["net"].email}"
}

resource "google_folder_iam_member" "folder_parent_net_step" {
  for_each = toset(var.parent_folder != "" ? local.granular_sa_parent_level_roles["net"] : [])

  folder = var.parent_folder
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["net"].email}"
}

resource "google_organization_iam_member" "org_parent_proj_step" {
  for_each = toset(var.parent_folder == "" ? local.granular_sa_parent_level_roles["proj"] : [])

  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["proj"].email}"
}

resource "google_folder_iam_member" "folder_parent_proj_step" {
  for_each = toset(var.parent_folder != "" ? local.granular_sa_parent_level_roles["proj"] : [])

  folder = var.parent_folder
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform-env-sa["proj"].email}"
}
