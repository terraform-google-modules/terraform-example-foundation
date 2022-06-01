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
  source                     = "../private_service_connect"
  project_id                 = var.project_id
  network_id                 = module.main.network_self_link
  environment_code           = var.environment_code
  network_self_link          = module.main.network_self_link
  private_service_connect_ip = "10.3.0.5"
  forwarding_rule_target     = "all-apis"
}
