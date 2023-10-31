/**
 * Copyright 2023 Google LLC
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
      "3-shared"         = { vcs_branch = "production", directory = "/envs/shared" },
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
  }

  tfc_workspaces_flat = flatten([
    for project, workspaces in local.tfc_workspaces : [
      for name, config in workspaces : {
        name              = name
        project           = project
        working_directory = config["directory"]
        branch            = config["vcs_branch"]
      }
    ]
    ]
  )

  tfc_workspace_map = { for v in local.tfc_workspaces_flat : v.name => v }

  sa_mapping = {
    for k, v in local.tfc_projects : k => {
      sa_name   = google_service_account.terraform-env-sa[k].name
      sa_email  = google_service_account.terraform-env-sa[k].email
      attribute = "*"
    }
  }
}


resource "tfe_project" "main" {
  for_each = local.tfc_projects

  organization = local.tfc_org_name
  name         = each.key
}

resource "tfe_workspace" "main" {
  for_each = local.tfc_workspace_map

  organization      = local.tfc_org_name
  name              = each.value.name
  working_directory = each.value.working_directory
  project_id        = tfe_project.main[each.value.project].id
  vcs_repo {
    identifier     = local.tfc_projects[each.value.project].vcs_repo
    branch         = each.value.branch
    oauth_token_id = var.vcs_oauth_token_id
  }
  global_remote_state = true
  terraform_version   = var.tfc_terraform_version
  agent_pool_id       = tfe_agent_pool.tfc_agent_pool.id
  execution_mode      = "agent"
}

data "tfe_workspace" "main" {
  for_each = local.tfc_workspace_map

  name         = each.value.name
  organization = local.tfc_org_name

  depends_on = [tfe_workspace.main]
}

resource "tfe_variable_set" "main" {
  name         = "Terraform Cloud Keys Varset"
  description  = "A resource that allows you to reuse the same variables across multiple workspaces"
  global       = false
  organization = local.tfc_org_name
}

resource "tfe_variable" "tfc_oauth_id_vcs" {
  key          = "vcs_oauth_token_id"
  value        = var.vcs_oauth_token_id
  category     = "terraform"
  description  = "The VCS Connection OAuth Connection Token ID"
  workspace_id = tfe_workspace.main["0-shared"].id
  sensitive    = true
}

resource "tfe_variable" "tfc_token" {
  key          = "tfc_token"
  value        = var.tfc_token
  category     = "terraform"
  description  = "The token used to authenticate with Terraform Cloud"
  workspace_id = tfe_workspace.main["0-shared"].id
  sensitive    = true
}

resource "tfe_variable" "tfc_terraform_version" {
  key          = "tfc_terraform_version"
  value        = var.tfc_terraform_version
  category     = "terraform"
  description  = "TF version desired for TFC workspaces"
  workspace_id = tfe_workspace.main["0-shared"].id
}

resource "tfe_variable" "tfc_organization_name" {
  key             = "tfc_org_name"
  value           = var.tfc_org_name
  category        = "terraform"
  description     = "Name of the TFC organization"
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_variable" "gcp_provider_auth" {
  key             = "TFC_GCP_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  description     = "If true TFC will attempt to use dynamic credentials to authenticate to GCP"
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_variable" "gcp_workload_provider_name" {
  key             = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value           = module.tfc-oidc.provider_name
  category        = "env"
  description     = "The canonical name of the workload identity provider."
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_variable" "service_account_email" {
  for_each = local.tfc_workspace_map

  key          = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value        = google_service_account.terraform-env-sa[each.value.project].email
  category     = "env"
  description  = "The service account email to use for the plan phase of a run."
  workspace_id = tfe_workspace.main[each.key].id
}

resource "tfe_workspace_variable_set" "main" {
  for_each = local.tfc_workspace_map

  variable_set_id = tfe_variable_set.main.id
  workspace_id    = tfe_workspace.main[each.key].id
}

resource "tfe_run_trigger" "networks_shared_production" {
  workspace_id  = tfe_workspace.main["3-production"].id
  sourceable_id = tfe_workspace.main["3-shared"].id
}

resource "tfe_run_trigger" "projects_bu1_shared_production" {
  workspace_id  = tfe_workspace.main["4-bu1-production"].id
  sourceable_id = tfe_workspace.main["4-bu1-shared"].id
}

resource "tfe_run_trigger" "projects_bu2_shared_production" {
  workspace_id  = tfe_workspace.main["4-bu2-production"].id
  sourceable_id = tfe_workspace.main["4-bu2-shared"].id
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
    "container.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "connectgateway.googleapis.com"
  ]
}

module "tfc-oidc" {
  source  = "GoogleCloudPlatform/tf-cloud-agents/google//modules/tfc-oidc"
  version = "0.1.0"

  project_id            = module.tfc_cicd.project_id
  pool_id               = "foundation-pool"
  provider_id           = "foundation-tfc-provider"
  sa_mapping            = local.sa_mapping
  tfc_organization_name = local.tfc_org_name
  attribute_condition   = "assertion.sub.startsWith(\"organization:${local.tfc_org_name}:\")"
}







data "google_client_config" "default" {
}

locals {
  tfc_agent_pool = "${var.tfc_agent_pool_name}-${random_string.suffix.result}"
  network_name   = "tfc-gke-simple-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Create a new agent pool in organization
resource "tfe_agent_pool" "tfc_agent_pool" {
  name         = local.tfc_agent_pool
  organization = local.tfc_org_name
}

# Create a new token for the agent pool
resource "tfe_agent_token" "tfc_agent_token" {
  agent_pool_id = tfe_agent_pool.tfc_agent_pool.id
  description   = var.tfc_agent_pool_token_description
}

# Create the infrastructure for the agent to run
module "tfc_agent_gke" {
  source = "./agents/custom-tfc-agent-gke"


  create_network         = true
  network_name           = local.network_name
  subnet_name            = local.network_name
  project_id             = module.tfc_cicd.project_id
  tfc_agent_token        = tfe_agent_token.tfc_agent_token.token
  create_service_account = false
  service_account_email  = google_service_account.terraform-env-sa["bootstrap"].email
  service_account_id  = google_service_account.terraform-env-sa["bootstrap"].id
}
