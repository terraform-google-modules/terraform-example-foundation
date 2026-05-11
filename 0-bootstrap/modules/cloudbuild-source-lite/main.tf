locals {
  admin_roles = flatten([
    for member in var.admin_members : [
      for role in concat(
        ["roles/cloudbuild.builds.editor", "roles/viewer"],
        length(var.cloud_source_repos) > 0 ? ["roles/source.admin"] : []
        ) : {
        key    = "${member}/${role}"
        member = member
        role   = role
      }
    ]
  ])
}

module "cloudbuild_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0"

  name                        = var.project_id
  random_project_id           = false
  disable_services_on_destroy = false
  folder_id                   = var.folder_id
  org_id                      = var.org_id
  billing_account             = var.billing_account
  activate_apis               = distinct(concat(var.activate_apis, ["cloudbuild.googleapis.com", "storage-api.googleapis.com", "iam.googleapis.com", "cloudresourcemanager.googleapis.com", "cloudbilling.googleapis.com"]))
  labels                      = var.project_labels
  deletion_policy             = var.project_deletion_policy
  auto_create_network         = false
}

module "cloudbuild_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 12.0"

  name          = "${module.cloudbuild_project.project_id}_cloudbuild"
  project_id    = module.cloudbuild_project.project_id
  location      = var.location
  force_destroy = var.buckets_force_destroy
}

resource "google_sourcerepo_repository" "gcp_repo" {
  for_each = toset(var.cloud_source_repos)

  project = module.cloudbuild_project.project_id
  name    = each.value
}

resource "google_project_iam_member" "admins" {
  for_each = { for item in local.admin_roles : item.key => item }

  project = module.cloudbuild_project.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_storage_bucket_iam_member" "cloudbuild_iam" {
  bucket = module.cloudbuild_bucket.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.cloudbuild_project.project_number}@cloudbuild.gserviceaccount.com"
}
