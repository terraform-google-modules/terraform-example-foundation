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
  terraform_version = "1.5.7"
  // The version of the terraform docker image to be used in the workspace builds
  docker_tag_version_terraform = "v1"

  cicd_project_id = module.tf_source.cloudbuild_project_id

  state_bucket_kms_key = "projects/${module.seed_bootstrap.seed_project_id}/locations/${var.default_region}/keyRings/${var.project_prefix}-keyring/cryptoKeys/${var.project_prefix}-key"

  bucket_self_link_prefix             = "https://www.googleapis.com/storage/v1/b/"
  default_state_bucket_self_link      = "${local.bucket_self_link_prefix}${module.seed_bootstrap.gcs_bucket_tfstate}"
  gcp_projects_state_bucket_self_link = module.gcp_projects_state_bucket.bucket.self_link

  cb_config = {
    "bootstrap" = {
      source       = "gcp-bootstrap",
      state_bucket = local.default_state_bucket_self_link,
    },
    "org" = {
      source       = "gcp-org",
      state_bucket = local.default_state_bucket_self_link,
    },
    "env" = {
      source       = "gcp-environments",
      state_bucket = local.default_state_bucket_self_link,
    },
    "net" = {
      source       = "gcp-networks",
      state_bucket = local.default_state_bucket_self_link,
    },
    "proj" = {
      source       = "gcp-projects",
      state_bucket = local.gcp_projects_state_bucket_self_link,
    },
  }

  cloud_source_repos = [for v in local.cb_config : v.source]
  cloudbuilder_repo  = "tf-cloudbuilder"
  base_cloud_source_repos = [
    "gcp-policies",
    "gcp-bootstrap",
    local.cloudbuilder_repo,
  ]
  gar_repository           = split("/", module.tf_cloud_builder.artifact_repo)[length(split("/", module.tf_cloud_builder.artifact_repo)) - 1]
  cloud_builder_trigger_id = element(split("/", module.tf_cloud_builder.cloudbuild_trigger_id), index(split("/", module.tf_cloud_builder.cloudbuild_trigger_id), "triggers") + 1, )

  # If user is not bringing its own repositories, will create CSR
  create_cloud_source_repos = var.cloudbuildv2_repository_config.repo_type == "CSR" ? distinct(concat(local.base_cloud_source_repos, local.cloud_source_repos)) : []
  # Used for backwards compatibility on conditional permission assignment
  cloud_source_repos_granular_sa = var.cloudbuildv2_repository_config.repo_type == "CSR" ? local.granular_sa : {}
  create_cloudbuildv2_connection = var.cloudbuildv2_repository_config.repo_type != "CSR"
  # If user is bringing its own repositories, will create cloudbuildv2_repos
  cloudbuildv2_repos   = var.cloudbuildv2_repository_config.repo_type != "CSR" ? var.cloudbuildv2_repository_config.repositories : {}
  is_github_connection = var.cloudbuildv2_repository_config.repo_type == "GITHUBv2"
  is_gitlab_connection = var.cloudbuildv2_repository_config.repo_type == "GITLABv2"
  bootstrap_csr_repo_id = length(local.create_cloud_source_repos) == 0 ? "" : (
    contains(keys(module.tf_source.csr_repos), local.cloudbuilder_repo) ? split("/", module.tf_source.csr_repos[local.cloudbuilder_repo].id)[3] : ""
  )
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

module "gcp_projects_state_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 6.0"

  name          = "${var.bucket_prefix}-${module.seed_bootstrap.seed_project_id}-gcp-projects-tfstate"
  project_id    = module.seed_bootstrap.seed_project_id
  location      = var.default_region
  force_destroy = var.bucket_force_destroy

  encryption = {
    default_kms_key_name = local.state_bucket_kms_key
  }

  depends_on = [module.seed_bootstrap.gcs_bucket_tfstate]
}

module "tf_source" {
  source  = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_source"
  version = "~> 8.0"

  org_id                = var.org_id
  folder_id             = google_folder.bootstrap.id
  project_id            = "${var.project_prefix}-b-cicd-${random_string.suffix.result}"
  location              = var.default_region
  billing_account       = var.billing_account
  group_org_admins      = var.groups.required_groups.group_org_admins
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
    "dns.googleapis.com",
    "secretmanager.googleapis.com"
  ]

  cloud_source_repos = local.create_cloud_source_repos

  project_labels = {
    environment       = "bootstrap"
    application_name  = "cloudbuild-bootstrap"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "shared"
    env_code          = "b"
    vpc               = "none"
  }

  # Remove after github.com/terraform-google-modules/terraform-google-bootstrap/issues/160
  depends_on = [module.seed_bootstrap]
}

module "tf_private_pool" {
  source = "./modules/cb-private-pool"

  project_id = module.tf_source.cloudbuild_project_id

  private_worker_pool = {
    region                   = var.default_region,
    enable_network_peering   = true,
    create_peered_network    = true,
    peered_network_subnet_ip = "10.3.0.0/24"
    peering_address          = "192.168.0.0"
    peering_prefix_length    = 24
  }

  vpn_configuration = {
    enable_vpn = false
  }
}

module "tf_cloud_builder" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-bootstrap.git//modules/tf_cloudbuild_builder?ref=f79bbc53f0593882e552ee0e1ca4019a4db88ac7"

  project_id                   = module.tf_source.cloudbuild_project_id
  dockerfile_repo_uri          = local.create_cloud_source_repos == [] ? module.tf_source.csr_repos[local.cloudbuilder_repo].url : module.cloudbuild_repositories[0].cloud_build_repositories_2nd_gen_repositories["tf_cloud_builder"].id
  use_cloudbuildv2_repository  = local.cloudbuildv2_repos != {} ? true : false
  dockerfile_repo_type         = local.is_github_connection ? "GITHUB" : (local.is_gitlab_connection ? "UNKNOWN" : "CLOUD_SOURCE_REPOSITORIES")
  gar_repo_location            = var.default_region
  workflow_region              = var.default_region
  terraform_version            = local.terraform_version
  build_timeout                = "1200s"
  cb_logs_bucket_force_destroy = var.bucket_force_destroy
  trigger_location             = var.default_region
  enable_worker_pool           = true
  worker_pool_id               = module.tf_private_pool.private_worker_pool_id
  bucket_name                  = "${var.bucket_prefix}-${module.tf_source.cloudbuild_project_id}-tf-cloudbuilder-build-logs"
}

module "bootstrap_csr_repo" {
  source = "terraform-google-modules/gcloud/google"
  # only run bootstrap_csr_repo if CSR were created
  count   = length(local.create_cloud_source_repos) == 0 ? 0 : 1
  version = "~> 3.1"
  upgrade = false

  create_cmd_entrypoint = "${path.module}/scripts/push-to-repo.sh"
  create_cmd_body       = "${module.tf_source.cloudbuild_project_id} ${local.bootstrap_csr_repo_id} ${path.module}/Dockerfile"
}

module "bootstrap_github_repo" {
  source = "terraform-google-modules/gcloud/google"
  # only run bootstrap_github_repo if user is using github
  count   = local.is_github_connection ? 1 : 0
  version = "~> 3.1"
  upgrade = false

  create_cmd_entrypoint = "${path.module}/scripts/github-bootstrap-builder-repo.sh"
  create_cmd_body       = "${var.cloudbuildv2_repository_config.github_pat} ${var.cloudbuildv2_repository_config.repositories.tf_cloud_builder.repository_url} ${path.module}/Dockerfile"
}

module "bootstrap_gitlab_repo" {
  source  = "terraform-google-modules/gcloud/google"
  count   = local.is_gitlab_connection ? 1 : 0
  version = "~> 3.1"
  upgrade = false

  create_cmd_entrypoint = "${path.module}/scripts/gitlab-bootstrap-builder-repo.sh"
  create_cmd_body       = "${var.cloudbuildv2_repository_config.gitlab_authorizer_credential} ${var.cloudbuildv2_repository_config.repositories.tf_cloud_builder.repository_url} ${path.module}/Dockerfile"
}

resource "time_sleep" "cloud_builder" {
  create_duration = "30s"

  depends_on = [
    module.tf_cloud_builder,
    module.bootstrap_csr_repo,
    module.bootstrap_github_repo
  ]
}

module "build_terraform_image" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.1"
  upgrade = false

  create_cmd_triggers = {
    "terraform_version" = local.terraform_version
  }

  create_cmd_body = "beta builds triggers run  ${local.cloud_builder_trigger_id} --branch main --region ${var.default_region} --project ${module.tf_source.cloudbuild_project_id}"

  module_depends_on = [
    time_sleep.cloud_builder,
  ]
}

module "cloudbuild_repositories" {
  count  = local.cloudbuildv2_repos != {} ? 1 : 0
  source = "git::https://github.com/terraform-google-modules/terraform-google-bootstrap.git//modules/cloudbuild_repo_connection?ref=f79bbc53f0593882e552ee0e1ca4019a4db88ac7"

  project_id = module.tf_source.cloudbuild_project_id

  credential_config = {
    credential_type                   = var.cloudbuildv2_repository_config.repo_type
    gitlab_authorizer_credential      = var.cloudbuildv2_repository_config.gitlab_authorizer_credential
    gitlab_read_authorizer_credential = var.cloudbuildv2_repository_config.gitlab_read_authorizer_credential
    github_pat                        = var.cloudbuildv2_repository_config.github_pat
    github_app_id                     = var.cloudbuildv2_repository_config.github_app_id
  }
  cloud_build_repositories = var.cloudbuildv2_repository_config.repositories
}

module "tf_workspace" {
  source   = "git::https://github.com/terraform-google-modules/terraform-google-bootstrap.git//modules/tf_cloudbuild_workspace?ref=f79bbc53f0593882e552ee0e1ca4019a4db88ac7"
  for_each = local.granular_sa

  project_id                = module.tf_source.cloudbuild_project_id
  location                  = var.default_region
  trigger_location          = var.default_region
  enable_worker_pool        = true
  worker_pool_id            = module.tf_private_pool.private_worker_pool_id
  state_bucket_self_link    = local.cb_config[each.key].state_bucket
  log_bucket_name           = "${var.bucket_prefix}-${module.tf_source.cloudbuild_project_id}-${local.cb_config[each.key].source}-build-logs"
  artifacts_bucket_name     = "${var.bucket_prefix}-${module.tf_source.cloudbuild_project_id}-${local.cb_config[each.key].source}-build-artifacts"
  cloudbuild_plan_filename  = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-tf-apply.yaml"
  tf_repo_uri               = local.cloudbuildv2_repos != {} ? module.cloudbuild_repositories[0].cloud_build_repositories_2nd_gen_repositories[each.key].id : module.tf_source.csr_repos[local.cb_config[each.key].source].url

  tf_repo_type          = local.cloudbuildv2_repos != {} ? "CLOUDBUILD_V2_REPOSITORY" : "CLOUD_SOURCE_REPOSITORIES"
  cloudbuild_sa         = google_service_account.terraform-env-sa[each.key].id
  create_cloudbuild_sa  = false
  diff_sa_project       = true
  create_state_bucket   = false
  buckets_force_destroy = var.bucket_force_destroy

  substitutions = {
    "_ORG_ID"                       = var.org_id
    "_BILLING_ID"                   = var.billing_account
    "_GAR_REGION"                   = var.default_region
    "_GAR_PROJECT_ID"               = module.tf_source.cloudbuild_project_id
    "_GAR_REPOSITORY"               = local.gar_repository
    "_DOCKER_TAG_VERSION_TERRAFORM" = local.docker_tag_version_terraform
  }

  tf_apply_branches = ["development", "nonproduction", "production"]

  depends_on = [
    module.tf_source,
    module.tf_cloud_builder,
  ]

}

resource "google_artifact_registry_repository_iam_member" "terraform_sa_artifact_registry_reader" {
  for_each = local.granular_sa

  project    = module.tf_source.cloudbuild_project_id
  location   = var.default_region
  repository = local.gar_repository
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"
}

resource "google_sourcerepo_repository_iam_member" "member" {
  for_each = local.cloud_source_repos_granular_sa

  project    = module.tf_source.cloudbuild_project_id
  repository = module.tf_source.csr_repos["gcp-policies"].name
  role       = "roles/viewer"
  member     = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"
}
