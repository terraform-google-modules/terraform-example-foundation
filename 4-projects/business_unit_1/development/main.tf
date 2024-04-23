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

module "env" {
  source = "../../modules/base_env"

  env                 = "development"
  business_code       = "bu1"
  business_unit       = "business_unit_1"
  remote_state_bucket = var.remote_state_bucket
  location_kms        = coalesce(var.location_kms, local.default_region_kms)
  location_gcs        = coalesce(var.location_gcs, local.default_region_gcs)
  gcs_custom_placement_config = {
    data_locations = [
      upper(local.default_region),
      upper(local.default_region_2),
    ]
  }
  tfc_org_name                 = var.tfc_org_name
  peering_module_depends_on    = var.peering_module_depends_on
  peering_iap_fw_rules_enabled = true
  subnet_region                = coalesce(var.instance_region, local.default_region)
  subnet_ip_range              = "10.3.64.0/21"
}
