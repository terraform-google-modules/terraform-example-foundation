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

data "google_projects" "projects" {
  count  = var.vpc_type == "" ? 0 : 1
  filter = "parent.id:${split("/", var.folder_id)[1]} labels.application_name=${var.vpc_type}-shared-vpc-host labels.environment=${var.environment} lifecycleState=ACTIVE"
}

data "google_compute_network" "shared_vpc" {
  count   = var.vpc_type == "" ? 0 : 1
  name    = "vpc-${local.env_code}-shared-${var.vpc_type}${local.shared_vpc_mode}"
  project = data.google_projects.projects[0].projects[0].project_id
}
