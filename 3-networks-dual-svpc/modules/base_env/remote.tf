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

locals {
  restricted_project_id        = data.terraform_remote_state.org.outputs.shared_vpc_projects[var.env].restricted_shared_vpc_project_id
  restricted_project_number    = data.terraform_remote_state.org.outputs.shared_vpc_projects[var.env].restricted_shared_vpc_project_number
  base_project_id              = data.terraform_remote_state.org.outputs.shared_vpc_projects[var.env].base_shared_vpc_project_id
  interconnect_project_number  = data.terraform_remote_state.org.outputs.interconnect_project_number
  dns_hub_project_id           = data.terraform_remote_state.org.outputs.dns_hub_project_id
  organization_service_account = data.terraform_remote_state.bootstrap.outputs.organization_step_terraform_service_account_email
  networks_service_account     = data.terraform_remote_state.bootstrap.outputs.networks_step_terraform_service_account_email
  projects_service_account     = data.terraform_remote_state.bootstrap.outputs.projects_step_terraform_service_account_email
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
