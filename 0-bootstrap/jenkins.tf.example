/**
 * Copyright 2022 Google LLC
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
  sa_names = { for k, v in google_service_account.terraform-env-sa : k => v.id }

  cicd_project_id = module.jenkins_bootstrap.cicd_project_id
}

module "jenkins_bootstrap" {
  source = "./modules/jenkins-agent"

  org_id                                   = var.org_id
  folder_id                                = google_folder.bootstrap.id
  billing_account                          = var.billing_account
  group_org_admins                         = local.group_org_admins
  default_region                           = var.default_region
  terraform_sa_names                       = local.sa_names
  terraform_state_bucket                   = module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation                  = true
  jenkins_controller_subnetwork_cidr_range = var.jenkins_controller_subnetwork_cidr_range
  jenkins_agent_gce_subnetwork_cidr_range  = var.jenkins_agent_gce_subnetwork_cidr_range
  jenkins_agent_gce_private_ip_address     = var.jenkins_agent_gce_private_ip_address
  nat_bgp_asn                              = var.nat_bgp_asn
  jenkins_agent_sa_email                   = var.jenkins_agent_sa_email
  jenkins_agent_gce_ssh_pub_key            = var.jenkins_agent_gce_ssh_pub_key
  vpn_shared_secret                        = var.vpn_shared_secret
  on_prem_vpn_public_ip_address            = var.on_prem_vpn_public_ip_address
  on_prem_vpn_public_ip_address2           = var.on_prem_vpn_public_ip_address2
  router_asn                               = var.router_asn
  bgp_peer_asn                             = var.bgp_peer_asn
  tunnel0_bgp_peer_address                 = var.tunnel0_bgp_peer_address
  tunnel0_bgp_session_range                = var.tunnel0_bgp_session_range
  tunnel1_bgp_peer_address                 = var.tunnel1_bgp_peer_address
  tunnel1_bgp_session_range                = var.tunnel1_bgp_session_range
}

resource "google_organization_iam_member" "org_jenkins_sa_browser" {
  count  = var.parent_folder == "" ? 1 : 0
  org_id = var.org_id
  role   = "roles/browser"
  member = "serviceAccount:${module.jenkins_bootstrap.jenkins_agent_sa_email}"
}

resource "google_folder_iam_member" "folder_jenkins_sa_browser" {
  count  = var.parent_folder != "" ? 1 : 0
  folder = var.parent_folder
  role   = "roles/browser"
  member = "serviceAccount:${module.jenkins_bootstrap.jenkins_agent_sa_email}"
}
