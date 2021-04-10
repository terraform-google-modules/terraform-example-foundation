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
  environment_code = element(split("", var.environment), 0)
}

resource "google_service_account" "compute_engine_service_account" {
  project      = data.google_project.env_project.project_id
  account_id   = "sa-example-app"
  display_name = "Example app service Account"
}

module "instance_template" {
  source       = "terraform-google-modules/vm/google//modules/instance_template"
  version      = "6.2.0"
  machine_type = var.machine_type
  region       = var.region
  project_id   = data.google_project.env_project.project_id
  subnetwork   = data.google_compute_subnetwork.subnetwork.self_link
  service_account = {
    email  = google_service_account.compute_engine_service_account.email
    scopes = ["compute-rw"]
  }
}

module "compute_instance" {
  source            = "terraform-google-modules/vm/google//modules/compute_instance"
  version           = "6.2.0"
  region            = var.region
  subnetwork        = data.google_compute_subnetwork.subnetwork.self_link
  num_instances     = var.num_instances
  hostname          = var.hostname
  instance_template = module.instance_template.self_link
}
