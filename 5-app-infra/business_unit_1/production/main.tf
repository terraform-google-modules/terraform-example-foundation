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

locals {
  business_unit             = "business_unit_1"
  environment               = "production"
  enable_confidential_space = try(data.terraform_remote_state.projects_env.outputs.confidential_space_project, "") != ""

  machine_config = var.universe_domain == "googleapis.com" ? {
    machine_type = "f1-micro"
    disk_type    = "pd-standard"
    source_image = ""
    } : {
    machine_type = "c3-standard-4"
    disk_type    = "hyperdisk-balanced"
    source_image = "projects/eu0-system:debian-cloud/global/images/debian-12--tpc-20260413-2332"
  }
}

module "gce_instance" {
  source = "../../modules/env_base"

  environment         = local.environment
  business_unit       = local.business_unit
  project_suffix      = "sample-svpc"
  region              = coalesce(var.instance_region, local.default_region)
  remote_state_bucket = var.remote_state_bucket
  universe_domain     = var.universe_domain
  machine_type        = local.machine_config["machine_type"]
  disk_type           = local.machine_config["disk_type"]
  source_image        = local.machine_config["source_image"]

}

module "peering_gce_instance" {
  source = "../../modules/env_base"

  environment         = local.environment
  business_unit       = local.business_unit
  project_suffix      = "sample-peering"
  region              = coalesce(var.instance_region, local.default_region)
  remote_state_bucket = var.remote_state_bucket
  universe_domain     = var.universe_domain
  machine_type        = local.machine_config["machine_type"]
  disk_type           = local.machine_config["disk_type"]
  source_image        = local.machine_config["source_image"]
}

module "confidential_space" {
  source = "../../modules/confidential_space"
  count  = local.enable_confidential_space ? 1 : 0

  environment                              = local.environment
  confidential_image_digest                = var.confidential_image_digest
  business_unit                            = local.business_unit
  project_suffix                           = "conf-space"
  region                                   = coalesce(var.instance_region, local.default_region)
  remote_state_bucket                      = var.remote_state_bucket
  workload_pool_propagation_sleep_duration = var.workload_pool_propagation_sleep_duration
  universe_domain                          = var.universe_domain
}
