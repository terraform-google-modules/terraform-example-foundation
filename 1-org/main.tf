/**
 * Copyright 2020 Google LLC
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
  parent               = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  parent_resource_id   = var.parent_folder != "" ? var.parent_folder : var.org_id
  parent_resource_type = var.parent_folder != "" ? "folder" : "organization"
  policy_folder_id     = var.parent_folder != "" ? var.parent_folder : null
  policy_for           = var.parent_folder != "" ? "folder" : "organization"
  policy_org_id        = var.parent_folder != "" ? null : var.org_id
}

module "folders_shared" {
  source = "./folders/shared"

  parent = local.parent
}

module "logging_shared" {
  source = "./logging/shared"

  access_table_expiration_ms       = var.access_table_expiration_ms
  audit_data_users                 = var.audit_data_users
  billing_account                  = var.billing_account
  billing_data_users               = var.billing_data_users
  data_access_table_expiration_ms  = var.data_access_table_expiration_ms
  default_region                   = var.default_region
  folder_id                        = module.folders_shared.logs_folder_id
  org_id                           = var.org_id
  parent_resource_id               = local.parent_resource_id
  parent_resource_type             = local.parent_resource_type
  system_event_table_expiration_ms = var.system_event_table_expiration_ms
  terraform_service_account        = var.terraform_service_account
}


module "monitoring_dev" {
  source = "./monitoring/nonprod"

  billing_account            = var.billing_account
  default_region             = var.default_region
  folder_id                  = module.folders_shared.monitoring_folder_id
  monitoring_workspace_users = var.monitoring_workspace_users
  org_id                     = var.org_id
  terraform_service_account  = var.terraform_service_account
}


module "monitoring_prod" {
  source = "./monitoring/prod"

  billing_account            = var.billing_account
  default_region             = var.default_region
  folder_id                  = module.folders_shared.monitoring_folder_id
  monitoring_workspace_users = var.monitoring_workspace_users
  org_id                     = var.org_id
  terraform_service_account  = var.terraform_service_account
}

module "networks_dev" {
  source = "./networking/nonprod"

  billing_account = var.billing_account
  default_region  = var.default_region
  folder_id       = module.folders_shared.networking_folder_id
  //TODO networking_admins  = var.networking_admins
  org_id                    = var.org_id
  terraform_service_account = var.terraform_service_account
}

module "networks_prod" {
  source = "./networking/prod"

  billing_account = var.billing_account
  default_region  = var.default_region
  folder_id       = module.folders_shared.networking_folder_id
  //TODO networking_admins  = var.networking_admins
  org_id                    = var.org_id
  terraform_service_account = var.terraform_service_account
}


module "org_iam_shared" {
  source = "./org-iam/shared"
}

module "org_policies_shared" {
  source = "./org-policies/shared"

  domains_to_allow = var.domains_to_allow
  folder_id        = local.policy_folder_id
  organization_id  = local.policy_org_id
  policy_for       = local.policy_for
}

module "secrets_shared" {
  source = "./secrets/shared"
}
