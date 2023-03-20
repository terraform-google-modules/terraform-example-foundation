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
  env                               = "common"
  environment_code                  = "c"
  bgp_asn_number                    = var.enable_partner_interconnect ? "16550" : "64514"
  dns_bgp_asn_number                = var.enable_partner_interconnect ? "16550" : var.bgp_asn_dns
  default_region1                   = "us-west1"
  default_region2                   = "us-central1"
  dns_hub_project_id                = data.terraform_remote_state.org.outputs.dns_hub_project_id
  interconnect_project_id           = data.terraform_remote_state.org.outputs.interconnect_project_id
  interconnect_project_number       = data.terraform_remote_state.org.outputs.interconnect_project_number
  parent_folder                     = data.terraform_remote_state.bootstrap.outputs.common_config.parent_folder
  org_id                            = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  billing_account                   = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  default_region                    = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  project_prefix                    = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  folder_prefix                     = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  parent_id                         = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  bootstrap_folder_name             = data.terraform_remote_state.bootstrap.outputs.common_config.bootstrap_folder_name
  common_folder_name                = data.terraform_remote_state.org.outputs.common_folder_name
  development_folder_name           = data.terraform_remote_state.env_development.outputs.env_folder
  non_production_folder_name        = data.terraform_remote_state.env_non_production.outputs.env_folder
  production_folder_name            = data.terraform_remote_state.env_production.outputs.env_folder
  base_net_hub_project_id           = data.terraform_remote_state.org.outputs.base_net_hub_project_id
  restricted_net_hub_project_id     = data.terraform_remote_state.org.outputs.restricted_net_hub_project_id
  restricted_net_hub_project_number = data.terraform_remote_state.org.outputs.restricted_net_hub_project_number
  organization_service_account      = data.terraform_remote_state.bootstrap.outputs.organization_step_terraform_service_account_email
  networks_service_account          = data.terraform_remote_state.bootstrap.outputs.networks_step_terraform_service_account_email
  projects_service_account          = data.terraform_remote_state.bootstrap.outputs.projects_step_terraform_service_account_email

  dedicated_interconnect_egress_policy = var.enable_dedicated_interconnect ? [
    {
      "from" = {
        "identity_type" = ""
        "identities"    = ["serviceAccount:${local.networks_service_account}"]
      },
      "to" = {
        "resources" = ["projects/${local.interconnect_project_number}"]
        "operations" = {
          "compute.googleapis.com" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ] : []
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}

data "terraform_remote_state" "env_development" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/development"
  }
}

data "terraform_remote_state" "env_non_production" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/non-production"
  }
}

data "terraform_remote_state" "env_production" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/production"
  }
}
