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


module "private_service_connect" {
  source  = "terraform-google-modules/network/google//modules/private-service-connect"
  version = "~> 9.1"

  project_id                 = var.project_id
  dns_code                   = "dz-${var.environment_code}-shared-restricted"
  network_self_link          = module.main.network_self_link
  private_service_connect_ip = var.private_service_connect_ip
  forwarding_rule_target     = "vpc-sc"
  service_directory_region   = var.default_region1
}
