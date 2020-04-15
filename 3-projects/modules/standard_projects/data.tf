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

data "google_projects" "prod-project" {
  filter = "labels.application_name:org-shared-vpc-prod"
}

data "google_project" "prod-project" {
  project_id = data.google_projects.prod-project.projects[0].project_id
}

data "google_compute_network" "prod-shared-vpc" {
  name    = "shared-vpc-prod"
  project = data.google_project.prod-project.project_id
}

data "google_projects" "nonprod-project" {
  filter = "labels.application_name:org-shared-vpc-nonprod"
}

data "google_project" "nonprod-project" {
  project_id = data.google_projects.nonprod-project.projects[0].project_id
}

data "google_compute_network" "nonprod-shared-vpc" {
  name    = "shared-vpc-nonprod"
  project = data.google_project.nonprod-project.project_id
}