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
  restricted_project_id             = data.tfe_outputs.environments_env.nonsensitive_values.restricted_shared_vpc_project_id
  restricted_project_number         = data.tfe_outputs.environments_env.nonsensitive_values.restricted_shared_vpc_project_number
  base_project_id                   = data.tfe_outputs.environments_env.nonsensitive_values.base_shared_vpc_project_id
  dns_hub_project_id                = data.tfe_outputs.org.nonsensitive_values.dns_hub_project_id
  base_net_hub_project_id           = data.tfe_outputs.org.nonsensitive_values.base_net_hub_project_id
  restricted_net_hub_project_id     = data.tfe_outputs.org.nonsensitive_values.restricted_net_hub_project_id
  restricted_net_hub_project_number = data.tfe_outputs.org.nonsensitive_values.restricted_net_hub_project_number
  networks_service_account          = data.tfe_outputs.bootstrap.nonsensitive_values.networks_step_terraform_service_account_email
  projects_service_account          = data.tfe_outputs.bootstrap.nonsensitive_values.projects_step_terraform_service_account_email
}

data "tfe_outputs" "bootstrap" {
  organization = var.tfc_org_name
  workspace = "0-shared"
}

data "tfe_outputs" "org" {
  organization = var.tfc_org_name
  workspace = "1-shared"
}

data "tfe_outputs" "environments_env" {
  organization = var.tfc_org_name
  workspace = "2-${var.env}"
}
