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

provider "google" {
  version = "~> 3.30"
}

provider "google-beta" {
  version = "~> 3.30"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

/*************************************************
  Bootstrap GCP Organization.
*************************************************/
locals {
  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
}

resource "google_folder" "bootstrap" {
  display_name = "fldr-bootstrap"
  parent       = local.parent
}

module "seed_bootstrap" {
  source                  = "terraform-google-modules/bootstrap/google"
  version                 = "~> 1.3"
  org_id                  = var.org_id
  folder_id               = google_folder.bootstrap.id
  billing_account         = var.billing_account
  group_org_admins        = var.group_org_admins
  group_billing_admins    = var.group_billing_admins
  default_region          = var.default_region
  org_project_creators    = var.org_project_creators
  sa_enable_impersonation = true
  parent_folder           = var.parent_folder == "" ? "" : local.parent
  skip_gcloud_download    = var.skip_gcloud_download
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
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
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
  source                    = "terraform-google-modules/bootstrap/google//modules/cloudbuild"
  version                   = "~> 1.3"
  org_id                    = var.org_id
  folder_id                 = google_folder.bootstrap.id
  billing_account           = var.billing_account
  group_org_admins          = var.group_org_admins
  default_region            = var.default_region
  terraform_sa_email        = module.seed_bootstrap.terraform_sa_email
  terraform_sa_name         = module.seed_bootstrap.terraform_sa_name
  terraform_state_bucket    = module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation   = true
  skip_gcloud_download      = var.skip_gcloud_download
  cloudbuild_plan_filename  = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-tf-apply.yaml"

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

  cloud_source_repos = [
    "gcp-bootstrap",
    "gcp-org",
    "gcp-environments",
    "gcp-networks",
    "gcp-projects"
  ]

  terraform_apply_branches = [
    "development",
    "non\\-production", //non-production needs a \ to ensure regex matches correct branches.
    "production"
  ]
}

## Un-comment the jenkins_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
# module "jenkins_bootstrap" {
#  source                                  = "./modules/jenkins-agent"
#  org_id                                  = var.org_id
#  folder_id                               = google_folder.bootstrap.id
#  billing_account                         = var.billing_account
#  group_org_admins                        = var.group_org_admins
#  default_region                          = var.default_region
#  terraform_sa_email                      = module.seed_bootstrap.terraform_sa_email
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
