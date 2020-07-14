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

module "test" {
  source                       = "../../../1-org"
  parent_folder                = var.parent_folder
  org_id                       = var.org_id
  billing_account              = var.billing_account
  terraform_service_account    = var.terraform_sa_email
  default_region               = "us-east4"
  dns_default_region1          = "us-east4"
  dns_default_region2          = "us-central1"
  billing_data_users           = var.group_email
  audit_data_users             = var.group_email
  scc_notification_name        = "test-scc-notification"
  domains_to_allow             = [var.domain_to_allow]
  domain                       = var.domain
  target_name_server_addresses = ["8.8.8.8", "8.8.8.4"]
}
