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
  environment               = "development"
  terraform_service_account = var.terraform_service_account
  project_service_account   = "project-service-account@${data.terraform_remote_state.projects_env.outputs.base_shared_vpc_project}.iam.gserviceaccount.com"
}

module "base_shared_gce_instance" {
  source = "../../modules/env_base"

  environment               = local.environment
  business_code             = "bu1"
  business_unit             = local.business_unit
  project_suffix            = "sample-base"
  region                    = var.instance_region
  num_instances             = 1
  machine_type              = "f1-micro"
  backend_bucket            = var.backend_bucket
  terraform_service_account = local.terraform_service_account
}
