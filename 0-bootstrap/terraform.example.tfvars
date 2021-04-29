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

org_id = "000000000000"

billing_account = "000000-000000-000000"

group_org_admins = "gcp-organization-admins@example.com"

group_billing_admins = "gcp-billing-admins@example.com"

default_region = "us-central1"

// Optional - for an organization with existing projects or for development/validation.
// Uncomment this variable to place all the example foundation resources under
// the provided folder instead of the root organization.
// The variable value is the numeric folder ID
// The folder must already exist.
//parent_folder = "01234567890"

/* ----------------------------------------
    Specific to jenkins_bootstrap module
   ---------------------------------------- */
// Un-comment the jenkins_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
//jenkins_agent_gce_subnetwork_cidr_range = "172.16.1.0/24"
//
//jenkins_agent_gce_private_ip_address = "172.16.1.6"
//
//jenkins_agent_gce_ssh_pub_key = "ssh-rsa [KEY_VALUE] [USERNAME]"
//
//jenkins_agent_sa_email = "jenkins-agent-gce" # service_account_prefix will be added
//
//jenkins_master_subnetwork_cidr_range = ["10.1.0.6/32"]
//
//nat_bgp_asn = "64514"
//
//vpn_shared_secret = "shared_secret"
//
//on_prem_vpn_public_ip_address = ""
//
//on_prem_vpn_public_ip_address2 = ""
//
//router_asn = "64515"
//
//bgp_peer_asn = "64513"
//
//tunnel0_bgp_peer_address = "169.254.1.1"
//
//tunnel0_bgp_session_range = "169.254.1.2/30"
//
//tunnel1_bgp_peer_address = "169.254.2.1"
//
//tunnel1_bgp_session_range = "169.254.2.2/30"
