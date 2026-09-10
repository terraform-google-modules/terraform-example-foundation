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

module "ncc_project" {
  source = "../single_project"

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = google_folder.env_business_unit.name
  environment     = var.env
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix

  project_deletion_policy = var.project_deletion_policy

  vpc_service_control_attach_enabled = local.enforce_vpcsc ? "true" : "false"
  vpc_service_control_attach_dry_run = !local.enforce_vpcsc ? "true" : "false"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"


  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "networkconnectivity.googleapis.com"
  ]

  # Metadata
  project_suffix    = "sample-ncc"
  application_name  = "${var.business_code}-sample-application"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

module "sample_ncc_vpc" {
  source  = "terraform-google-modules/network/google//modules/foundation/network"
  version = "~> 18.2"

  project_id      = module.ncc_project.project_id
  vpc_name        = "sample-spoke"
  shared_vpc_host = false

  resource_code              = var.business_code
  private_service_connect_ip = var.ncc_private_service_connect_ip

  ncc_hub_config = {
    create_hub  = false
    uri         = local.ncc_hub_uri
    spoke_group = local.ncc_spoke_group
  }

  subnets = var.ncc_spoke_subnets
}
