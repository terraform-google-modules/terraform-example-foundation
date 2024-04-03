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
  # TODO: Update reference to module version when service_directory_registrations
  # is officially released. Only 1 commit has been made to the private service connect
  # submodule since v9.0.0. This commit adds var.service_directory_region which is required
  # to use the default region from  data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  # https://github.com/terraform-google-modules/terraform-google-network/commits/d4855d6b82b7963e22ed0f05aa31900915cfb954/modules/private-service-connect

  # Example update:
  # source  = "terraform-google-modules/network/google//modules/private-service-connect?ref=d4855d6b82b7963e22ed0f05aa31900915cfb954"
  # version = "~> 9.1"
  source = "github.com/terraform-google-modules/terraform-google-network//modules/private-service-connect?ref=d4855d6b82b7963e22ed0f05aa31900915cfb954"


  project_id                 = var.project_id
  dns_code                   = "dz-${var.environment_code}-shared-restricted"
  network_self_link          = module.main.network_self_link
  private_service_connect_ip = var.private_service_connect_ip
  forwarding_rule_target     = "vpc-sc"
  service_directory_region   = var.default_region1
}
