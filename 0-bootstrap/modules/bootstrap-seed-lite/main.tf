locals {
  parent_is_folder = var.parent_folder != ""
  parent_id        = local.parent_is_folder ? split("/", var.parent_folder)[1] : var.org_id
  project_creators = distinct(concat(var.bootstrap_admin_members, var.org_project_creators))
  admin_role_members = flatten([
    for member in var.bootstrap_admin_members : [
      for role in var.org_admins_org_iam_permissions : {
        key    = "${member}/${role}"
        member = member
        role   = role
      }
    ]
  ])
}

module "seed_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0"

  name                        = var.project_id
  random_project_id           = false
  disable_services_on_destroy = false
  folder_id                   = var.folder_id
  org_id                      = var.org_id
  billing_account             = var.billing_account
  activate_apis               = distinct(concat(var.activate_apis, var.encrypt_gcs_bucket_tfstate ? ["cloudkms.googleapis.com"] : []))
  create_project_sa           = false
  labels                      = var.project_labels
  lien                        = true
  deletion_policy             = var.project_deletion_policy
  auto_create_network         = false
}

resource "google_organization_iam_binding" "billing_creator" {
  count = length(var.billing_admin_members) > 0 ? 1 : 0

  org_id  = var.org_id
  role    = "roles/billing.creator"
  members = var.billing_admin_members
}

resource "google_organization_iam_binding" "project_creator" {
  count = local.parent_is_folder ? 0 : 1

  org_id  = local.parent_id
  role    = "roles/resourcemanager.projectCreator"
  members = local.project_creators
}

resource "google_folder_iam_binding" "project_creator" {
  count = local.parent_is_folder ? 1 : 0

  folder  = local.parent_id
  role    = "roles/resourcemanager.projectCreator"
  members = local.project_creators
}

resource "google_organization_iam_member" "bootstrap_admins" {
  for_each = { for item in local.admin_role_members : item.key => item }

  org_id = var.org_id
  role   = each.value.role
  member = each.value.member
}

resource "google_organization_iam_member" "billing_admins" {
  for_each = toset(var.billing_admin_members)

  org_id = var.org_id
  role   = "roles/billing.admin"
  member = each.value
}

data "google_storage_project_service_account" "gcs_account" {
  project = module.seed_project.project_id
}

module "kms" {
  count   = var.encrypt_gcs_bucket_tfstate ? 1 : 0
  source  = "terraform-google-modules/kms/google"
  version = "~> 4.0"

  project_id           = module.seed_project.project_id
  location             = var.default_region
  keyring              = "${var.project_prefix}-keyring"
  keys                 = ["${var.project_prefix}-key"]
  key_rotation_period  = var.key_rotation_period
  key_protection_level = "SOFTWARE"
  set_decrypters_for   = ["${var.project_prefix}-key"]
  set_encrypters_for   = ["${var.project_prefix}-key"]
  decrypters = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
  encrypters = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
  prevent_destroy = var.kms_prevent_destroy
}

resource "google_storage_bucket" "org_terraform_state" {
  project                     = module.seed_project.project_id
  name                        = var.state_bucket_name
  location                    = var.default_region
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  dynamic "encryption" {
    for_each = var.encrypt_gcs_bucket_tfstate ? [1] : []
    content {
      default_kms_key_name = module.kms[0].keys["${var.project_prefix}-key"]
    }
  }
}
