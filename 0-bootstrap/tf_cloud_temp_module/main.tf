terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.48.0"
    }
  }
}

provider "tfe" {
  token = var.tfe_token
}

locals {
    tfe_project_names = ["0-bootstrap", "1-org", "2-environments", "3-networks", "4-projects", "5-app-infra"]

    tfc_org_structure = {
    name = "TODO",
    projects = {
        "0-bootstrap" = {
            vcs_repo = "",
            workspaces = [
                {name="0-shared", vcs_branch="production", directory="/envs/shared"}
            ],
        },
        "1-org" = {
            vcs_repo = "",
            workspaces = [
                {name="1-shared", vcs_branch="production", directory="/envs/shared"}
            ],
        
        },
        "2-environments" = {
            vcs_repo = "",
            workspaces = [
                {name="2-production", vcs_branch="production", directory="/envs/production"},
                {name="2-non-production", vcs_branch="non-production", directory="/envs/non-production"},
                {name="2-development", vcs_branch="development", directory="/envs/development"},
            ],
        
        },
        "3-networks" = {
            vcs_repo = "",
            workspaces = [
                {name="3-production", vcs_branch="production", directory="/envs/production"},
                {name="3-non-production", vcs_branch="non-production", directory="/envs/non-production"},
                {name="3-development", vcs_branch="development", directory="/envs/development"},
                {name="3-shared", vcs_branch="production", directory="/envs/production"},
            ],
        
        },
        "4-projects" = {
            vcs_repo = "",
            workspaces = [
                {name="4-bu1-production", vcs_branch="production", directory="/business_unit_1/production"},
                {name="4-bu1-non-production", vcs_branch="non-production", directory="/business_unit_1/non-production"},
                {name="4-bu1-development", vcs_branch="development", directory="/business_unit_1/development"},
                {name="4-bu1-shared", vcs_branch="production", directory="/business_unit_1/production"},
                {name="4-bu2-production", vcs_branch="production", directory="/business_unit_2/production"},
                {name="4-bu2-non-production", vcs_branch="non-production", directory="/business_unit_2/non-production"},
                {name="4-bu2-development", vcs_branch="development", directory="/business_unit_2/development"},
                {name="4-bu2-shared", vcs_branch="production", directory="/business_unit_2/production"},
            ],
        
        },
        "5-app-infra" = {
            vcs_repo = "",
            workspaces = [
                {name="5-bu1-production", vcs_branch="production", directory="/business_unit_1/production"},
                {name="5-bu1-non-production", vcs_branch="non-production", directory="/business_unit_1/non-production"},
                {name="5-bu1-development", vcs_branch="development", directory="/business_unit_1/development"},
            ],
        
        },
    }
  }

    tfc_workspaces = flatten([
        for project, config in local.tfc_org_structure.projects:[
            for workspace in config.workspaces: {
                name = workspace.name,
                working_directory = workspace.directory,
                vcs_repo = {
                    identifier = config.vcs_repo,
                    branch = workspace.vcs_branch,
                }
                organization = local.tfc_org_structure.name,
            }
        ]
    ])
    

}

resource "tfe_organization" "foundation" {
  name  = local.tfc_org_structure.name
  email = "leonardo.romanini@ciandt.com"
}

resource "tfe_project" "project" {
  for_each = toset([for key, value in local.tfc_org_structure.projects : key])

  organization = tfe_organization.foundation.name
  name         = each.value
}

resource "tfe_workspace" "test" {
    for_each = {for k, v in local.tfc_workspaces : k => v}
  
    name     = each.value.name
    working_directory = each.value.working_directory
    vcs_repo {
        identifier = each.value.vcs_repo.identifier
        branch = each.value.vcs_repo.branch
        oauth_token_id = "TODO"
    }
    organization = each.value.organization
}

