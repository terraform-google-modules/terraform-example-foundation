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

  parent_type = var.parent_folder == "" ? "organization" : "folder"
  parent_id   = var.parent_folder == "" ? var.org_id : var.parent_folder

  granular_sa = {
    "org"  = "Foundation Organization SA. Managed by Terraform.",
    "env"  = "Foundation Environment SA. Managed by Terraform.",
    "net"  = "Foundation Network SA. Managed by Terraform.",
    "proj" = "Foundation Projects SA. Managed by Terraform.",
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
      "roles/compute.networkAdmin",
      "roles/compute.securityAdmin",
      "roles/compute.orgSecurityPolicyAdmin",
      "roles/compute.orgSecurityResourceAdmin",
      "roles/dns.admin",
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

  project      = module.seed_bootstrap.seed_project_id
  account_id   = "terraform-${each.key}-sa"
  display_name = each.value
}

module "org_iam_member" {
  source   = "./modules/parent-iam-member"
  for_each = local.granular_sa_org_level_roles

  member      = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"
  parent_type = "organization"
  parent_id   = var.org_id
  roles       = each.value
}

module "parent_iam_member" {
  source   = "./modules/parent-iam-member"
  for_each = local.granular_sa_parent_level_roles

  member      = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"
  parent_type = local.parent_type
  parent_id   = local.parent_id
  roles       = each.value
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
  member             = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_service_account.terraform-env-sa
  ]
}
