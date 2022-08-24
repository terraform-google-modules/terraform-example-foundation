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

/*************************************************
  Bootstrap GCP Organization.
*************************************************/
locals {
  // The bootstrap module will enforce that only identities
  // in the list "org_project_creators" will have the Project Creator role,
  // so the granular service accounts for each step need to be added to the list.
  step_terraform_sa = [
    "serviceAccount:${google_service_account.terraform-env-sa["org"].email}",
    "serviceAccount:${google_service_account.terraform-env-sa["env"].email}",
    "serviceAccount:${google_service_account.terraform-env-sa["net"].email}",
    "serviceAccount:${google_service_account.terraform-env-sa["proj"].email}",
  ]
  org_project_creators = distinct(concat(var.org_project_creators, local.step_terraform_sa))
  parent               = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  org_admins_org_iam_permissions = var.org_policy_admin_role == true ? [
    "roles/orgpolicy.policyAdmin", "roles/resourcemanager.organizationAdmin", "roles/billing.user"
  ] : ["roles/resourcemanager.organizationAdmin", "roles/billing.user"]
  bucket_self_link_prefix = "https://www.googleapis.com/storage/v1/b/"
  group_org_admins        = var.groups.create_groups ? var.groups.required_groups.group_org_admins : var.group_org_admins
  group_billing_admins    = var.groups.create_groups ? var.groups.required_groups.group_billing_admins : var.group_billing_admins
}

resource "google_folder" "bootstrap" {
  display_name = "${var.folder_prefix}-bootstrap"
  parent       = local.parent
}

module "seed_bootstrap" {
  source                         = "terraform-google-modules/bootstrap/google"
  version                        = "~> 6.2"
  org_id                         = var.org_id
  folder_id                      = google_folder.bootstrap.id
  project_id                     = "${var.project_prefix}-b-seed"
  state_bucket_name              = "${var.bucket_prefix}-b-tfstate"
  force_destroy                  = var.bucket_force_destroy
  billing_account                = var.billing_account
  group_org_admins               = local.group_org_admins
  group_billing_admins           = local.group_billing_admins
  default_region                 = var.default_region
  org_project_creators           = local.org_project_creators
  sa_enable_impersonation        = true
  parent_folder                  = var.parent_folder == "" ? "" : local.parent
  org_admins_org_iam_permissions = local.org_admins_org_iam_permissions
  project_prefix                 = var.project_prefix

  # Remove after github.com/terraform-google-modules/terraform-google-bootstrap/issues/160
  depends_on = [google_folder.bootstrap, module.required_group, module.optional_group]

  project_labels = {
    environment       = "bootstrap"
    application_name  = "seed-bootstrap"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "b"
  }

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "securitycenter.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  sa_org_iam_permissions = []
}

## Un-comment the jenkins_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
# module "jenkins_bootstrap" {
#  source                                   = "./modules/jenkins-agent"
#  org_id                                   = var.org_id
#  folder_id                                = google_folder.bootstrap.id
#  billing_account                          = var.billing_account
#  group_org_admins                         = local.group_org_admins
#  default_region                           = var.default_region
#  terraform_service_account                = module.seed_bootstrap.terraform_sa_email
#  terraform_sa_name                        = module.seed_bootstrap.terraform_sa_name
#  terraform_state_bucket                   = module.seed_bootstrap.gcs_bucket_tfstate
#  sa_enable_impersonation                  = true
#  jenkins_controller_subnetwork_cidr_range = var.jenkins_controller_subnetwork_cidr_range
#  jenkins_agent_gce_subnetwork_cidr_range  = var.jenkins_agent_gce_subnetwork_cidr_range
#  jenkins_agent_gce_private_ip_address     = var.jenkins_agent_gce_private_ip_address
#  nat_bgp_asn                              = var.nat_bgp_asn
#  jenkins_agent_sa_email                   = var.jenkins_agent_sa_email
#  jenkins_agent_gce_ssh_pub_key            = var.jenkins_agent_gce_ssh_pub_key
#  vpn_shared_secret                        = var.vpn_shared_secret
#  on_prem_vpn_public_ip_address            = var.on_prem_vpn_public_ip_address
#  on_prem_vpn_public_ip_address2           = var.on_prem_vpn_public_ip_address2
#  router_asn                               = var.router_asn
#  bgp_peer_asn                             = var.bgp_peer_asn
#  tunnel0_bgp_peer_address                 = var.tunnel0_bgp_peer_address
#  tunnel0_bgp_session_range                = var.tunnel0_bgp_session_range
#  tunnel1_bgp_peer_address                 = var.tunnel1_bgp_peer_address
#  tunnel1_bgp_session_range                = var.tunnel1_bgp_session_range
# }

# resource "google_organization_iam_member" "org_jenkins_sa_browser" {
#   count  = var.parent_folder == "" ? 1 : 0
#   org_id = var.org_id
#   role   = "roles/browser"
#   member = "serviceAccount:${module.jenkins_bootstrap.jenkins_agent_sa_email}"
# }

# resource "google_folder_iam_member" "folder_jenkins_sa_browser" {
#   count  = var.parent_folder != "" ? 1 : 0
#   folder = var.parent_folder
#   role   = "roles/browser"
#   member = "serviceAccount:${module.jenkins_bootstrap.jenkins_agent_sa_email}"
# }
