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

data "google_projects" "network_projects" {
  filter = "parent.id:${split("/", var.folder_id)[1]} labels.application_name=${var.vpc_type}-shared-vpc-host labels.environment=${var.environment} lifecycleState=ACTIVE"
}

data "google_project" "network_project" {
  project_id = data.google_projects.network_projects.projects[0].project_id
}

data "google_projects" "environment_projects" {
  filter = "parent.id:${split("/", var.folder_id)[1]} name:*${var.project_suffix}* labels.application_name=${var.business_code}-sample-application labels.environment=${var.environment} lifecycleState=ACTIVE"
}

data "google_project" "env_project" {
  project_id = data.google_projects.environment_projects.projects[0].project_id
}

data "google_compute_network" "shared_vpc" {
  name    = "vpc-${local.environment_code}-shared-${var.vpc_type}"
  project = data.google_project.network_project.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  name    = "sb-${local.environment_code}-shared-${var.vpc_type}-${var.region}"
  region  = var.region
  project = data.google_project.network_project.project_id
}
