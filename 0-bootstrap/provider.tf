/**
 * Copyright 2023 Google LLC
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

provider "google-beta" {
  user_project_override = true
  billing_project       = var.groups.billing_project
}

# If you are using Terraform Cloud Agents, un-comment this block after the first apply according README instructions
# provider "kubernetes" {
#   host = "https://connectgateway.googleapis.com/v1/projects/${module.tfc_cicd.project_number}/locations/global/gkeMemberships/${module.tfc_agent_gke[0].hub_cluster_membership_id}"

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "gke-gcloud-auth-plugin"
#   }
# }
