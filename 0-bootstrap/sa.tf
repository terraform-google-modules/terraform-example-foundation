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
    "bootstrap" = "Foundation Bootstrap SA. Managed by Terraform.",
    "org"       = "Foundation Organization SA. Managed by Terraform.",
    "env"       = "Foundation Environment SA. Managed by Terraform.",
    "net"       = "Foundation Network SA. Managed by Terraform.",
    "proj"      = "Foundation Projects SA. Managed by Terraform.",
  }

  common_roles = [
    "roles/browser", // Required for gcloud beta terraform vet to be able to read the ancestry of folders
  ]

  granular_sa_org_level_roles = {
    "bootstrap" = distinct(concat([
      "roles/resourcemanager.organizationAdmin",
      "roles/accesscontextmanager.policyAdmin",
      "roles/serviceusage.serviceUsageConsumer",
    ], local.common_roles)),
    "org" = distinct(concat([
      "roles/orgpolicy.policyAdmin",
      "roles/logging.configWriter",
      "roles/resourcemanager.organizationAdmin",
      "roles/securitycenter.notificationConfigEditor",
      "roles/resourcemanager.organizationViewer",
      "roles/accesscontextmanager.policyAdmin",
      "roles/essentialcontacts.admin",
      "roles/resourcemanager.tagAdmin",
      "roles/resourcemanager.tagUser",
      "roles/cloudasset.owner",
      "roles/securitycenter.sourcesEditor",
    ], local.common_roles)),
    "env" = distinct(concat([
      "roles/resourcemanager.tagUser",
      "roles/assuredworkloads.admin",
    ], local.common_roles)),
    "net" = distinct(concat([
      "roles/accesscontextmanager.policyAdmin",
      "roles/compute.xpnAdmin",
    ], local.common_roles)),
    "proj" = distinct(concat([
      "roles/accesscontextmanager.policyAdmin",
      "roles/resourcemanager.organizationAdmin",
      "roles/serviceusage.serviceUsageConsumer",
      "roles/cloudkms.admin",
    ], local.common_roles)),
  }

  granular_sa_parent_level_roles = {
    "bootstrap" = [
      "roles/resourcemanager.folderAdmin",
    ],
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
      "roles/resourcemanager.folderAdmin",
      "roles/artifactregistry.admin",
      "roles/compute.networkAdmin",
      "roles/compute.xpnAdmin",
    ],
  }

  // Roles required to manage resources in the Seed project
  granular_sa_seed_project = {
    "bootstrap" = [
      "roles/storage.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectDeleter",
      "roles/cloudkms.admin",
    ],
    "org" = [
      "roles/storage.objectAdmin",
    ],
    "env" = [
      "roles/storage.objectAdmin"
    ],
    "net" = [
      "roles/storage.objectAdmin",
    ],
    "proj" = [
      "roles/storage.objectAdmin",
    ],
  }

  // Roles required to manage resources in the CI/CD project
  granular_sa_cicd_project = {
    "bootstrap" = [
      "roles/storage.admin",
      "roles/compute.networkAdmin",
      "roles/cloudbuild.builds.editor",
      "roles/cloudbuild.workerPoolOwner",
      "roles/artifactregistry.admin",
      "roles/source.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/workflows.admin",
      "roles/cloudscheduler.admin",
      "roles/resourcemanager.projectDeleter",
      "roles/dns.admin",
      "roles/iam.workloadIdentityPoolAdmin",
    ],
  }

  bootstrap_projects = {
    "seed" = module.seed_bootstrap.seed_project_id,
    "cicd" = local.cicd_project_id,
  }
}

resource "google_service_account" "terraform-env-sa" {
  for_each = local.granular_sa

  project                      = module.seed_bootstrap.seed_project_id
  account_id                   = "sa-terraform-${each.key}"
  display_name                 = each.value
  create_ignore_already_exists = true
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

module "seed_project_iam_member" {
  source   = "./modules/parent-iam-member"
  for_each = local.granular_sa_seed_project

  member      = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"
  parent_type = "project"
  parent_id   = module.seed_bootstrap.seed_project_id
  roles       = each.value
}

module "cicd_project_iam_member" {
  source   = "./modules/parent-iam-member"
  for_each = local.granular_sa_cicd_project

  member      = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"
  parent_type = "project"
  parent_id   = local.cicd_project_id
  roles       = each.value
}

// When the bootstrap projects are created, the Compute Engine
// default service account is disabled but it still has the Editor
// role associated with the service account. This default SA is the
// only member with the editor role.
// This module will remove all editors from both projects.
module "bootstrap_projects_remove_editor" {
  source   = "./modules/parent-iam-remove-role"
  for_each = local.bootstrap_projects

  parent_type = "project"
  parent_id   = each.value
  roles       = ["roles/editor"]

  depends_on = [
    module.seed_project_iam_member,
    module.cicd_project_iam_member
  ]
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

resource "google_billing_account_iam_member" "billing_account_sink" {
  billing_account_id = var.billing_account
  role               = "roles/logging.configWriter"
  member             = "serviceAccount:${google_service_account.terraform-env-sa["org"].email}"
}

