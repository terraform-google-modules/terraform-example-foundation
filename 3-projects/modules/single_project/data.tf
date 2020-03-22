/**
 * Copyright 2020 Google LLC
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
  filter = "labels.application_name=org-shared-vpc-${var.environment}"
}

data "google_compute_network" "shared_vpc" {
  name    = "shared-vpc-${var.environment}"
  project = local.network_project_id
}

data "google_projects" "projects-monitoring" {
  filter = "labels.application_name=monitoring-${var.environment}"
}