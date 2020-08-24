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

module "vpn_agent_to_onprem" {
  source             = "terraform-google-modules/vpn/google"
  project_id         = module.cicd_project.project_id
  network            = google_compute_network.jenkins_agents.name
  region             = var.default_region
  gateway_name       = "vpn-from-onprem-to-cicd"
  tunnel_name_prefix = "vpn-from-onprem-to-cicd-tunnel-1"
  shared_secret      = var.vpn_shared_secret
  tunnel_count       = 1
  peer_ips           = [var.jenkins_master_vpn_public_ip_address] // the vpn-onprem-to-agent.gateway_ip
  remote_subnet      = var.jenkins_master_subnetwork_cidr_range
}
