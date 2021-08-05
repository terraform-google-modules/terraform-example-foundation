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
  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
  org_admins_org_iam_permissions = var.org_policy_admin_role == true ? [
    "roles/orgpolicy.policyAdmin", "roles/resourcemanager.organizationAdmin", "roles/billing.user"
  ] : ["roles/resourcemanager.organizationAdmin", "roles/billing.user"]
}

resource "google_folder" "bootstrap" {
  display_name = "${var.folder_prefix}-bootstrap"
  parent       = local.parent
}

module "seed_bootstrap" {
  source                         = "terraform-google-modules/bootstrap/google"
  version                        = "~> 3.0"
  org_id                         = var.org_id
  folder_id                      = google_folder.bootstrap.id
  project_id                     = "${var.project_prefix}-b-seed"
  state_bucket_name              = "${var.bucket_prefix}-b-tfstate"
  billing_account                = var.billing_account
  group_org_admins               = var.group_org_admins
  group_billing_admins           = var.group_billing_admins
  default_region                 = var.default_region
  org_project_creators           = var.org_project_creators
  sa_enable_impersonation        = true
  parent_folder                  = var.parent_folder == "" ? "" : local.parent
  org_admins_org_iam_permissions = local.org_admins_org_iam_permissions
  project_prefix                 = var.project_prefix

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

  sa_org_iam_permissions = [
    "roles/accesscontextmanager.policyAdmin",
    "roles/billing.user",
    "roles/compute.networkAdmin",
    "roles/compute.xpnAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/logging.configWriter",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.folderAdmin",
    "roles/securitycenter.notificationConfigEditor",
    "roles/resourcemanager.organizationViewer"
  ]
}

resource "google_billing_account_iam_member" "tf_billing_admin" {
  billing_account_id = var.billing_account
  role               = "roles/billing.admin"
  member             = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
}

// Comment-out the cloudbuild_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
module "cloudbuild_bootstrap" {
  source                      = "terraform-google-modules/bootstrap/google//modules/cloudbuild"
  version                     = "~> 3.0"
  org_id                      = var.org_id
  folder_id                   = google_folder.bootstrap.id
  project_id                  = "${var.project_prefix}-b-cicd"
  billing_account             = var.billing_account
  group_org_admins            = var.group_org_admins
  default_region              = var.default_region
  terraform_sa_email          = module.seed_bootstrap.terraform_sa_email
  terraform_sa_name           = module.seed_bootstrap.terraform_sa_name
  terraform_state_bucket      = module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation     = true
  cloudbuild_plan_filename    = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename   = "cloudbuild-tf-apply.yaml"
  project_prefix              = var.project_prefix
  cloud_source_repos          = var.cloud_source_repos
  terraform_validator_release = "v0.4.0"
  terraform_version           = "0.13.7"
  terraform_version_sha256sum = "4a52886e019b4fdad2439da5ff43388bbcc6cce9784fde32c53dcd0e28ca9957"

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  project_labels = {
    environment       = "bootstrap"
    application_name  = "cloudbuild-bootstrap"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "b"
  }

  terraform_apply_branches = [
    "development",
    "non\\-production", //non-production needs a \ to ensure regex matches correct branches.
    "production"
  ]
}

// Standalone repo for Terraform-validator policies.
// This repo does not need to trigger builds in Cloud Build.
resource "google_sourcerepo_repository" "gcp_policies" {
  project = module.cloudbuild_bootstrap.cloudbuild_project_id
  name    = "gcp-policies"

  depends_on = [module.cloudbuild_bootstrap.csr_repos]
}

resource "google_project_iam_member" "project_source_reader" {
  project = module.cloudbuild_bootstrap.cloudbuild_project_id
  role    = "roles/source.reader"
  member  = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"

  depends_on = [module.cloudbuild_bootstrap.csr_repos]
}

data "google_project" "cloudbuild" {
  project_id = module.cloudbuild_bootstrap.cloudbuild_project_id

  depends_on = [module.cloudbuild_bootstrap.csr_repos]
}

resource "google_organization_iam_member" "org_cb_sa_browser" {
  count  = var.parent_folder == "" ? 1 : 0
  org_id = var.org_id
  role   = "roles/browser"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "folder_cb_sa_browser" {
  count  = var.parent_folder != "" ? 1 : 0
  folder = var.parent_folder
  role   = "roles/browser"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_organization_iam_member" "org_tf_compute_security_policy_admin" {
  count  = var.parent_folder == "" ? 1 : 0
  org_id = var.org_id
  role   = "roles/compute.orgSecurityPolicyAdmin"
  member = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
}

resource "google_folder_iam_member" "folder_tf_compute_security_policy_admin" {
  count  = var.parent_folder != "" ? 1 : 0
  folder = var.parent_folder
  role   = "roles/compute.orgSecurityPolicyAdmin"
  member = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
}

resource "google_organization_iam_member" "org_tf_compute_security_resource_admin" {
  count  = var.parent_folder == "" ? 1 : 0
  org_id = var.org_id
  role   = "roles/compute.orgSecurityResourceAdmin"
  member = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
}

resource "google_folder_iam_member" "folder_tf_compute_security_resource_admin" {
  count  = var.parent_folder != "" ? 1 : 0
  folder = var.parent_folder
  role   = "roles/compute.orgSecurityResourceAdmin"
  member = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
}

## Un-comment the jenkins_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
# module "jenkins_bootstrap" {
#  source                                  = "./modules/jenkins-agent"
#  org_id                                  = var.org_id
#  folder_id                               = google_folder.bootstrap.id
#  billing_account                         = var.billing_account
#  group_org_admins                        = var.group_org_admins
#  default_region                          = var.default_region
#  terraform_service_account               = module.seed_bootstrap.terraform_sa_email
#  terraform_sa_name                       = module.seed_bootstrap.terraform_sa_name
#  terraform_state_bucket                  = module.seed_bootstrap.gcs_bucket_tfstate
#  sa_enable_impersonation                 = true
#  jenkins_master_subnetwork_cidr_range    = var.jenkins_master_subnetwork_cidr_range
#  jenkins_agent_gce_subnetwork_cidr_range = var.jenkins_agent_gce_subnetwork_cidr_range
#  jenkins_agent_gce_private_ip_address    = var.jenkins_agent_gce_private_ip_address
#  nat_bgp_asn                             = var.nat_bgp_asn
#  jenkins_agent_sa_email                  = var.jenkins_agent_sa_email
#  jenkins_agent_gce_ssh_pub_key           = var.jenkins_agent_gce_ssh_pub_key
#  vpn_shared_secret                       = var.vpn_shared_secret
#  on_prem_vpn_public_ip_address           = var.on_prem_vpn_public_ip_address
#  on_prem_vpn_public_ip_address2          = var.on_prem_vpn_public_ip_address2
#  router_asn                              = var.router_asn
#  bgp_peer_asn                            = var.bgp_peer_asn
#  tunnel0_bgp_peer_address                = var.tunnel0_bgp_peer_address
#  tunnel0_bgp_session_range               = var.tunnel0_bgp_session_range
#  tunnel1_bgp_peer_address                = var.tunnel1_bgp_peer_address
#  tunnel1_bgp_session_range               = var.tunnel1_bgp_session_range
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
