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

locals {
  cloudbuild_bucket_name = "${var.cloudbuild_project_id}_cloudbuild"
  workspace_sa_email     = { for k, v in module.tf_workspace.cloudbuild_sa : k => element(split("/", v), length(split("/", v)) - 1) }
  gar_region             = split("-docker.pkg.dev", var.cloud_builder_artifact_repo)[0]
  gar_project_id         = split("/", var.cloud_builder_artifact_repo)[length(split("/", var.cloud_builder_artifact_repo)) - 2]
  gar_name               = split("/", var.cloud_builder_artifact_repo)[length(split("/", var.cloud_builder_artifact_repo)) - 1]
  created_csrs           = toset([for repo in google_sourcerepo_repository.app_infra_repo : repo.name])
}

# Create CSRs
resource "google_sourcerepo_repository" "app_infra_repo" {
  for_each = toset(var.app_infra_repos)

  project = var.cloudbuild_project_id
  name    = each.value
}

resource "google_sourcerepo_repository" "gcp_policies" {
  project = var.cloudbuild_project_id
  name    = "gcp-policies"
}

resource "google_storage_bucket" "cloudbuild_bucket" {
  project  = var.cloudbuild_project_id
  name     = local.cloudbuild_bucket_name
  location = var.default_region

  uniform_bucket_level_access = true
  force_destroy               = true
  versioning {
    enabled = true
  }
}

//=========================

module "tf_workspace" {
  source   = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_workspace"
  version  = "~> 6.2"
  for_each = toset(var.app_infra_repos)

  project_id                = var.cloudbuild_project_id
  location                  = var.default_region
  cloudbuild_plan_filename  = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-tf-apply.yaml"
  tf_repo_uri               = google_sourcerepo_repository.app_infra_repo[each.key].url
  diff_sa_project           = true
  buckets_force_destroy     = true

  substitutions = {
    "_BILLING_ID"                   = var.billing_account
    "_GAR_REGION"                   = local.gar_region
    "_GAR_PROJECT_ID"               = local.gar_project_id
    "_GAR_REPOSITORY"               = local.gar_name
    "_DOCKER_TAG_VERSION_TERRAFORM" = var.terraform_docker_tag_version
  }

  tf_apply_branches = ["development", "non\\-production", "production"]

  depends_on = [
    google_sourcerepo_repository.app_infra_repo,
  ]

}

/***********************************************
  Cloud Build - IAM
 ***********************************************/

resource "google_artifact_registry_repository_iam_member" "terraform-image-iam" {
  provider = google-beta
  for_each = toset(var.app_infra_repos)

  project    = local.gar_project_id
  location   = local.gar_region
  repository = local.gar_name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${local.workspace_sa_email[each.key]}"
}

resource "google_folder_iam_member" "browser_cloud_build" {
  for_each = toset(var.folders_to_grant_browser_role)

  folder = each.value
  role   = "roles/browser"
  member = "serviceAccount:${local.workspace_sa_email[each.key]}"
}
