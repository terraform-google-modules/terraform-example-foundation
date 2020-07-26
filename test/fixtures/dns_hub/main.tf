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

module "dns_hub" {
  source                       = "../../../3-networks/envs/shared"
  dns_default_region1          = "us-central1"
  dns_default_region2          = "us-west1"
  domain                       = var.domain
  target_name_server_addresses = ["8.8.8.8", "8.8.8.4"]
  terraform_service_account    = var.terraform_sa_email
  parent_folder                = var.parent_folder
  org_id                       = var.org_id
}
