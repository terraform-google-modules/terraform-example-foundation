terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.48.0"
    }
  }
}

provider "tfe" {
  token = var.tfc_token
}

locals {
  tfc_org_name = var.tfc_org_name

  tfc_projects = {
    "bootstrap" = {
      vcs_repo = var.vcs_repos.bootstrap,
    },
    "org" = {
      vcs_repo = var.vcs_repos.organization,
    },
    "envs" = {
      vcs_repo = var.vcs_repos.environments,
    },
    "networks" = {
      vcs_repo = var.vcs_repos.networks,
    },
    "projects" = {
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
    "envs" = {
      "2-production"     = { vcs_branch = "production", directory = "/envs/production" },
      "2-non-production" = { vcs_branch = "non-production", directory = "/envs/non-production" },
      "2-development"    = { vcs_branch = "development", directory = "/envs/development" },
    },
    "networks" = {
      "3-production"     = { vcs_branch = "production", directory = "/envs/production" },
      "3-non-production" = { vcs_branch = "non-production", directory = "/envs/non-production" },
      "3-development"    = { vcs_branch = "development", directory = "/envs/development" },
      "3-shared"         = { vcs_branch = "production", directory = "/envs/production" },
    },
    "projects" = {
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
    "app-infra" = {
      "5-bu1-production"     = { vcs_branch = "production", directory = "/business_unit_1/production" },
      "5-bu1-non-production" = { vcs_branch = "non-production", directory = "/business_unit_1/non-production" },
      "5-bu1-development"    = { vcs_branch = "development", directory = "/business_unit_1/development" },
    },
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
      ])

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
    oauth_token_id = "ot-8GzsPyXGK5GPjnuC"
  }
}

# TBD - Do we need OAUTH creation via Terraform?
# It wil require manual steps anyway if we don't use github/gitlab providers
# in order to grant the proper access
# resource "tfe_oauth_client" "oauth" {
#   organization     = local.tfc_org_structure.name
#   api_url          = var.vcs_api_url
#   http_url         = var.vcs_http_url
#   oauth_token      = var.vcs_oauth_token
#   service_provider = var.vcs_service_provider
# }
