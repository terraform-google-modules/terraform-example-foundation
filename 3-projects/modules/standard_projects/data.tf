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
    for_each = toset(local.envs)
    filter = "labels.application_name=org-shared-vpc-${each.value}"
}

data "google_project" "projects" {
    for_each = data.google_projects.projects
    
    project_id = each.value.projects[0].project_id
}

data "google_compute_network" "shared-vpcs" {
    for_each = toset(local.envs)
  
    name    = "shared-vpc-${each.value}"
    project = local.host_project_env_map[each.value]
}

data "google_projects" "projects-monitoring" {
    for_each = toset(local.envs)

    filter = "labels.application_name=monitoring-${each.value}"
}

data "google_project" "projects-monitoring" {
    for_each = data.google_projects.projects-monitoring
    project_id = each.value.projects[0].project_id
}