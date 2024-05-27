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


provider "github" {
  owner = var.gh_repos.owner
  token = var.gh_token
}

locals {
  cicd_project_id = module.gh_cicd.project_id

  gh_config = {
    "bootstrap" = var.gh_repos.bootstrap,
    "org"       = var.gh_repos.organization,
    "env"       = var.gh_repos.environments,
    "net"       = var.gh_repos.networks,
    "proj"      = var.gh_repos.projects,
  }

  sa_mapping = {
    for k, v in local.gh_config : k => {
      sa_name   = google_service_account.terraform-env-sa[k].name
      attribute = "attribute.repository/${var.gh_repos.owner}/${v}"
    }
  }

  common_secrets = {
    "PROJECT_ID" : module.gh_cicd.project_id,
    "WIF_PROVIDER_NAME" : module.gh_oidc.provider_name,
    "TF_BACKEND" : module.seed_bootstrap.gcs_bucket_tfstate,
    "TF_VAR_gh_token" : var.gh_token,
  }

  secrets_list = flatten([
    for k, v in local.gh_config : [
      for secret, plaintext in local.common_secrets : {
        config          = k
        secret_name     = secret
        plaintext_value = plaintext
        repository      = v
      }
    ]
  ])

  sa_secrets = [for k, v in local.gh_config : {
    config          = k
    secret_name     = "SERVICE_ACCOUNT_EMAIL"
    plaintext_value = google_service_account.terraform-env-sa[k].email
    repository      = v
    }
  ]

  gh_secrets = { for v in concat(local.sa_secrets, local.secrets_list) : "${v.config}.${v.secret_name}" => v }

}

module "gh_cicd" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 15.0"

  name              = "${var.project_prefix}-b-cicd-wif-gh"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = google_folder.bootstrap.id
  billing_account   = var.billing_account
  activate_apis = [
    "compute.googleapis.com",
    "admin.googleapis.com",
    "iam.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
  ]
}

module "gh_oidc" {
  source  = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version = "~> 3.1"

  project_id  = module.gh_cicd.project_id
  pool_id     = "foundation-pool"
  provider_id = "foundation-gh-provider"
  sa_mapping  = local.sa_mapping
}

resource "github_actions_secret" "secrets" {
  for_each = local.gh_secrets

  repository      = each.value.repository
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value
}

resource "google_service_account_iam_member" "self_impersonate" {
  for_each = local.granular_sa

  service_account_id = google_service_account.terraform-env-sa[each.key].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.terraform-env-sa[each.key].email}"
}
