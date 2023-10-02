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


provider "tfe" {
  token = var.tfc_token
}


locals {

  cicd_project_id = module.tfc_cicd.project_id

  tfc_org_name = var.tfc_org_name

    tfc_config = {
    "bootstrap" = var.vcs_repos.bootstrap,
    "org"       = var.vcs_repos.organization,
    "env"       = var.vcs_repos.environments,
    "net"       = var.vcs_repos.networks,
    "proj"      = var.vcs_repos.projects,
  }

  tfc_projects = {
    "bootstrap" = {
      vcs_repo = var.vcs_repos.bootstrap,
    },
    "org" = {
      vcs_repo = var.vcs_repos.organization,
    },
    "env" = {
      vcs_repo = var.vcs_repos.environments,
    },
    "net" = {
      vcs_repo = var.vcs_repos.networks,
    },
    "proj" = {
      vcs_repo = var.vcs_repos.projects,
    },
    # TODO: Move this to step 4
    "app-infra" = {
      vcs_repo = var.vcs_repos.app-infra,
    },
  }

  tfc_workspaces = {
    "bootstrap" = {
      "0-shared" = { vcs_branch = "production", directory = "/envs/shared" }
    },
    "org" = {
      "1-shared" = { vcs_branch = "production", directory = "/envs/shared" }
    },
    "env" = {
      "2-production"     = { vcs_branch = "production", directory = "/envs/production" },
      "2-non-production" = { vcs_branch = "non-production", directory = "/envs/non-production" },
      "2-development"    = { vcs_branch = "development", directory = "/envs/development" },
    },
    "net" = {
      "3-production"     = { vcs_branch = "production", directory = "/envs/production" },
      "3-non-production" = { vcs_branch = "non-production", directory = "/envs/non-production" },
      "3-development"    = { vcs_branch = "development", directory = "/envs/development" },
      "3-shared"         = { vcs_branch = "production", directory = "/envs/production" },
    },
    "proj" = {
      "4-bu1-production"     = { vcs_branch = "production", directory = "/business_unit_1/production" },
      "4-bu1-non-production" = { vcs_branch = "non-production", directory = "/business_unit_1/non-production" },
      "4-bu1-development"    = { vcs_branch = "development", directory = "/business_unit_1/development" },
      "4-bu1-shared"         = { vcs_branch = "production", directory = "/business_unit_1/production" },
      "4-bu2-production"     = { vcs_branch = "production", directory = "/business_unit_2/production" },
      "4-bu2-non-production" = { vcs_branch = "non-production", directory = "/business_unit_2/non-production" },
      "4-bu2-development"    = { vcs_branch = "development", directory = "/business_unit_2/development" },
      "4-bu2-shared"         = { vcs_branch = "production", directory = "/business_unit_2/production" },

    },
    # TODO: Move this to step 4
    # "app-infra" = {
    #   "5-bu1-production"     = { vcs_branch = "production", directory = "/business_unit_1/production" },
    #   "5-bu1-non-production" = { vcs_branch = "non-production", directory = "/business_unit_1/non-production" },
    #   "5-bu1-development"    = { vcs_branch = "development", directory = "/business_unit_1/development" },
    # },
  }

  tfc_workspaces_flat = flatten([
      for project, workspaces in local.tfc_workspaces : [
        for name, config in workspaces : {
          name = name
          project   = project
          working_directory = config["directory"]
          branch = config["vcs_branch"]
        }
      ]
    ]
  )

  sa_mapping = {
    for k, v in local.tfc_config : k => {
      sa_name   = google_service_account.terraform-env-sa[k].name
      sa_email = var.vcs_repos.owner
      attribute = "attribute.repository/${var.vcs_repos.owner}/${v}"
    }
  }

  # commom_secrets = {
  #   "PROJECT_ID" : module.gh_cicd.project_id,
  #   "WIF_PROVIDER_NAME" : module.gh_oidc.provider_name,
  #   "TF_BACKEND" : module.seed_bootstrap.gcs_bucket_tfstate,
  #   "TF_VAR_gh_token": var.gh_token,
  # }

  # secrets_list = flatten([
  #   for k, v in local.gh_config : [
  #     for secret, plaintext in local.commom_secrets : {
  #       config          = k
  #       secret_name     = secret
  #       plaintext_value = plaintext
  #       repository      = v
  #     }
  #   ]
  # ])

  # sa_secrets = [for k, v in local.gh_config : {
  #   config          = k
  #   secret_name     = "SERVICE_ACCOUNT_EMAIL"
  #   plaintext_value = google_service_account.terraform-env-sa[k].email
  #   repository      = v
  #   }
  # ]

  # gh_secrets = { for v in concat(local.sa_secrets, local.secrets_list) : "${v.config}.${v.secret_name}" => v }
}


resource "tfe_project" "project" {
  for_each = local.tfc_projects

  organization = local.tfc_org_name
  name         = each.key
}

data "tfe_project" "project_lookup" {
  for_each = local.tfc_projects

  organization = local.tfc_org_name
  name         = each.key

  depends_on = [tfe_project.project]
}

resource "tfe_workspace" "test" {
  for_each = {for k, v in local.tfc_workspaces_flat: k => v}

  organization      = local.tfc_org_name
  name              = each.value.name
  working_directory = each.value.working_directory
  project_id        = data.tfe_project.project_lookup[each.value.project].id
  vcs_repo {
    identifier     = local.tfc_projects[each.value.project].vcs_repo
    branch         = each.value.branch
    oauth_token_id = "ot-8GzsPyXGK5GPjnuC" # TODO: Make a var here
  }
}

module "tfc_cicd" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 12.0"

  name              = "${var.project_prefix}-b-cicd-wif-tfc"
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

module "tfc-oidc" {
  source  = "GoogleCloudPlatform/tf-cloud-agents/google//modules/tfc-oidc"
  version = "0.1.0"
  project_id  = module.tfc_cicd.project_id
  pool_id     = "foundation-pool"
  provider_id = "foundation-tfc-provider"
  sa_mapping  = local.sa_mapping
  tfc_organization_name = var.tfc_org_name
  tfc_workspace_name = "bootstrap"
}

# module "tfc_oidc" {
#   source      = "terraform-google-modules/terraform-cloud-agents/google//modules/tfc-oidc"
#   project_id  = module.gh_cicd.project_id
#   pool_id     = "foundation-pool"
#   provider_id = "foundation-tfc-provider"
#   sa_mapping  = local.sa_mapping
#   tfc_organization_name = var.tfc_organization_name
#   tfc_workspace_name = "bootstrap"
# }

# resource "github_actions_secret" "secrets" {
#   for_each = local.gh_secrets

#   repository      = each.value.repository
#   secret_name     = each.value.secret_name
#   plaintext_value = each.value.plaintext_value
# }