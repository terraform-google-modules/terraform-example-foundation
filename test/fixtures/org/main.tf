/**
 * Copyright 2021 Google LLC
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

resource "random_id" "suffix" {
  byte_length = 4
}


module "test" {
  source                                      = "../../../1-org/envs/shared"
  parent_folder                               = var.parent_folder
  org_id                                      = var.org_id
  billing_account                             = var.billing_account
  terraform_service_account                   = var.terraform_service_account
  default_region                              = "us-east4"
  billing_data_users                          = var.group_email
  audit_data_users                            = var.group_email
  scc_notification_name                       = "test-scc-notif-${random_id.suffix.hex}"
  domains_to_allow                            = [var.domain_to_allow]
  create_access_context_manager_access_policy = false
  audit_logs_table_delete_contents_on_destroy = true
  log_export_storage_force_destroy            = true
  enable_os_login_policy                      = true
  project_prefix                              = var.project_prefix
  enable_hub_and_spoke                        = var.enable_hub_and_spoke
}
