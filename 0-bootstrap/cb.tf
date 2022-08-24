
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
  // terraform version image configuration
  terraform_version = "1.0.0"
  // The version of the terraform docker image to be used in the workspace builds
  docker_tag_version_terraform = "v1"

  cb_source = {
    "org"  = "gcp-org",
    "env"  = "gcp-environments",
    "net"  = "gcp-networks",
    "proj" = "gcp-projects",
  }
  cloud_source_repos = values(local.cb_source)
  cloudbuilder_repo  = "tf-cloudbuilder"
  base_cloud_source_repos = [
    "gcp-policies",
    "gcp-bootstrap",
    local.cloudbuilder_repo,
  ]
  gar_repository = split("/", module.tf_cloud_builder.artifact_repo)[length(split("/", module.tf_cloud_builder.artifact_repo)) - 1]
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "tf_source" {
  source  = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_source"
  version = "~> 6.2"

  org_id                = var.org_id
  folder_id             = google_folder.bootstrap.id
  project_id            = "${var.project_prefix}-b-cicd-${random_string.suffix.result}"
  billing_account       = var.billing_account
  group_org_admins      = local.group_org_admins
  buckets_force_destroy = var.bucket_force_destroy

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "sourcerepo.googleapis.com",
    "workflows.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "billingbudgets.googleapis.com",
  ]

  cloud_source_repos = distinct(concat(local.base_cloud_source_repos, local.cloud_source_repos))

  project_labels = {
    environment       = "bootstrap"
    application_name  = "cloudbuild-bootstrap"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "b"
  }

  # Remove after github.com/terraform-google-modules/terraform-google-bootstrap/issues/160
  depends_on = [module.seed_bootstrap]
}

module "tf_cloud_builder" {
  source  = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_builder"
  version = "~> 6.2"

  project_id                   = module.tf_source.cloudbuild_project_id
  dockerfile_repo_uri          = module.tf_source.csr_repos[local.cloudbuilder_repo].url
  gar_repo_location            = var.default_region
  workflow_region              = var.default_region
  terraform_version            = local.terraform_version
  cb_logs_bucket_force_destroy = var.bucket_force_destroy
}

module "bootstrap_csr_repo" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.1.0"
  upgrade = false

  create_cmd_entrypoint = "${path.module}/scripts/push-to-repo.sh"
  create_cmd_body       = "${module.tf_source.cloudbuild_project_id} ${split("/", module.tf_source.csr_repos[local.cloudbuilder_repo].id)[3]} ${path.module}/Dockerfile"
}

resource "time_sleep" "cloud_builder" {
  create_duration = "30s"

  depends_on = [
    module.tf_cloud_builder,
    module.bootstrap_csr_repo,
  ]
}

module "build_terraform_image" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.1.0"
  upgrade = false

  create_cmd_triggers = {
    "terraform_version" = local.terraform_version
  }

  create_cmd_body = "beta builds triggers run ${split("/", module.tf_cloud_builder.cloudbuild_trigger_id)[3]} --branch main --project ${module.tf_source.cloudbuild_project_id}"

  module_depends_on = [
    time_sleep.cloud_builder,
  ]
}

module "tf_workspace" {
  source   = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_workspace"
  version  = "~> 6.2"
  for_each = local.granular_sa

  project_id                = module.tf_source.cloudbuild_project_id
  location                  = var.default_region
  state_bucket_self_link    = "${local.bucket_self_link_prefix}${module.seed_bootstrap.gcs_bucket_tfstate}"
  cloudbuild_plan_filename  = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-tf-apply.yaml"
  tf_repo_uri               = module.tf_source.csr_repos[local.cb_source[each.key]].url
  cloudbuild_sa             = google_service_account.terraform-env-sa[each.key].id
  create_cloudbuild_sa      = false
  diff_sa_project           = true
  create_state_bucket       = false
  buckets_force_destroy     = var.bucket_force_destroy

  substitutions = {
    "_ORG_ID"                       = var.org_id
    "_BILLING_ID"                   = var.billing_account
    "_DEFAULT_REGION"               = var.default_region
    "_GAR_REPOSITORY"               = local.gar_repository
    "_DOCKER_TAG_VERSION_TERRAFORM" = local.docker_tag_version_terraform
  }

  tf_apply_branches = ["development", "non\\-production", "production"]

  depends_on = [
    module.tf_source,
    module.tf_cloud_builder,
  ]

}
