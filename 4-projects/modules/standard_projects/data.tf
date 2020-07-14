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

data "google_projects" "base_prod_project" {
  filter = "labels.application_name:base-shared-vpc-host-prod"
}

data "google_compute_network" "base_prod_shared_vpc" {
  name    = "p-shared-base"
  project = local.base_prod_project_id
}

data "google_projects" "restricted_prod_project" {
  filter = "labels.application_name:restricted-shared-vpc-host-prod"
}

data "google_compute_network" "restricted_prod_shared_vpc" {
  name    = "p-shared-restricted"
  project = local.restricted_prod_project_id
}

data "google_projects" "base_nonprod_project" {
  filter = "labels.application_name:base-shared-vpc-host-nonprod"
}

data "google_compute_network" "base_nonprod_shared_vpc" {
  name    = "n-shared-base"
  project = local.base_nonprod_project_id
}

data "google_projects" "restricted_nonprod_project {
  filter = "labels.application_name:restricted-shared-vpc-host-nonprod"
}

data "google_compute_network" "restricted_nonprod_shared_vpc" {
  name    = "n-shared-restricted"
  project = local.restricted_nonprod_project_id
}

data "google_projects" "base_dev_project" {
  filter = "labels.application_name:base-shared-vpc-host-dev"
}

data "google_compute_network" "base_dev_shared_vpc" {
  name    = "d-shared-base"
  project = local.base_dev_project_id
}

data "google_projects" "restricted_dev_project" {
  filter = "labels.application_name:restricted-shared-vpc-host-dev"
}

data "google_compute_network" "restricted_dev_shared_vpc" {
  name    = "d-shared-restricted"
  project = local.restricted_dev_project_id
}
