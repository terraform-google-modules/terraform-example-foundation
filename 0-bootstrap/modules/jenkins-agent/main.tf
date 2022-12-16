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

locals {
  cicd_project_name           = format("%s-%s", var.project_prefix, "b-cicd")
  impersonation_enabled_count = var.sa_enable_impersonation ? 1 : 0
  activate_apis               = distinct(concat(var.activate_apis, ["billingbudgets.googleapis.com"]))
  jenkins_gce_fw_tags         = ["ssh-jenkins-agent"]
}

resource "random_id" "suffix" {
  byte_length = 2
}

/******************************************
  CICD project
*******************************************/
module "cicd_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name                        = local.cicd_project_name
  random_project_id           = true
  random_project_id_length    = 4
  disable_services_on_destroy = false
  folder_id                   = var.folder_id
  org_id                      = var.org_id
  billing_account             = var.billing_account
  activate_apis               = local.activate_apis
  labels                      = var.project_labels
}

/******************************************
  Jenkins Agent GCE instance
*******************************************/
resource "google_service_account" "jenkins_agent_gce_sa" {
  project      = module.cicd_project.project_id
  account_id   = format("%s-%s", var.service_account_prefix, var.jenkins_agent_sa_email)
  display_name = "Jenkins Agent (GCE instance) custom Service Account"
}

data "template_file" "jenkins_agent_gce_startup_script" {
  // Add Cloud NAT for the Agent to reach internet and download updates and necessary binaries
  // not needed  if user has a golden image with all necessary packages.
  template = file("${path.module}/files/jenkins_gce_startup_script.sh")
  vars = {
    tpl_TERRAFORM_DIR               = "/usr/local/bin/"
    tpl_TERRAFORM_VERSION           = var.terraform_version
    tpl_TERRAFORM_VERSION_SHA256SUM = var.terraform_version_sha256sum
    tpl_SSH_PUB_KEY                 = var.jenkins_agent_gce_ssh_pub_key
  }
}

resource "google_compute_instance" "jenkins_agent_gce_instance" {
  project      = module.cicd_project.project_id
  name         = var.jenkins_agent_gce_name
  machine_type = var.jenkins_agent_gce_machine_type
  zone         = "${var.default_region}-a"

  tags = local.jenkins_gce_fw_tags

  boot_disk {
    initialize_params {
      // It is better if user has a golden image with all necessary packages.
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    // Internal and static IP configuration
    subnetwork = google_compute_subnetwork.jenkins_agents_subnet.self_link
    network_ip = google_compute_address.jenkins_agent_gce_static_ip.address
  }

  // Adding ssh public keys to the GCE instance metadata, so the Jenkins Controller can connect to this Agent
  metadata = {
    enable-oslogin = "false"
    ssh-keys       = var.jenkins_agent_gce_ssh_pub_key
  }

  metadata_startup_script = data.template_file.jenkins_agent_gce_startup_script.rendered

  service_account {
    email = google_service_account.jenkins_agent_gce_sa.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  // allow stopping the GCE instance to update some of its values
  allow_stopping_for_update = true
}

/******************************************
  Jenkins Agent GCE Network and Firewall rules
*******************************************/

resource "google_compute_firewall" "fw_allow_ssh_into_jenkins_agent" {
  project       = module.cicd_project.project_id
  name          = "fw-${google_compute_network.jenkins_agents.name}-1000-i-a-all-all-tcp-22"
  description   = "Allow the Jenkins Controller (Client) to connect to the Jenkins Agents (Servers) using SSH."
  network       = google_compute_network.jenkins_agents.name
  source_ranges = var.jenkins_controller_subnetwork_cidr_range
  target_tags   = local.jenkins_gce_fw_tags
  priority      = 1000

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_network" "jenkins_agents" {
  project = module.cicd_project.project_id
  name    = "vpc-b-jenkinsagents"
}

resource "google_compute_subnetwork" "jenkins_agents_subnet" {
  project       = module.cicd_project.project_id
  name          = "sb-b-jenkinsagents-${var.default_region}"
  ip_cidr_range = var.jenkins_agent_gce_subnetwork_cidr_range
  region        = var.default_region
  network       = google_compute_network.jenkins_agents.self_link

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
    filter_expr          = true
  }
}

resource "google_dns_policy" "default_policy" {
  project                   = module.cicd_project.project_id
  name                      = "dp-b-jenkinsagents-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = true
  networks {
    network_url = google_compute_network.jenkins_agents.self_link
  }
}

resource "google_compute_address" "jenkins_agent_gce_static_ip" {
  // This internal IP address needs to be accessible via the VPN tunnel
  project      = module.cicd_project.project_id
  name         = "jenkins-agent-gce-static-ip"
  subnetwork   = google_compute_subnetwork.jenkins_agents_subnet.self_link
  address_type = "INTERNAL"
  address      = var.jenkins_agent_gce_private_ip_address
  region       = var.default_region
  purpose      = "GCE_ENDPOINT"
  description  = "The static Internal IP address of the Jenkins Agent"
}

/******************************************
  NAT Cloud Router & NAT config
 *****************************************/

resource "google_compute_router" "nat_router_region1" {
  name    = "cr-${google_compute_network.jenkins_agents.name}-${var.default_region}-nat-router"
  project = module.cicd_project.project_id
  region  = var.default_region
  network = google_compute_network.jenkins_agents.self_link

  bgp {
    asn = var.nat_bgp_asn
  }
}

resource "google_compute_address" "nat_external_addresses1" {
  name    = "cn-${google_compute_network.jenkins_agents.name}-${var.default_region}"
  project = module.cicd_project.project_id
  region  = var.default_region
}

resource "google_compute_router_nat" "nat_external_addresses_region1" {
  project                            = module.cicd_project.project_id
  name                               = "rn-${google_compute_network.jenkins_agents.name}-${var.default_region}-egress"
  router                             = google_compute_router.nat_router_region1.name
  region                             = var.default_region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_external_addresses1.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}

/******************************************
  VPN Connectivity Controller on-prem <--> CICD project
*******************************************/

// Please add VPN connectivity manually: see README > Requirements

/******************************************
  Jenkins IAM for admins
*******************************************/

resource "google_project_iam_member" "org_admins_jenkins_admin" {
  project = module.cicd_project.project_id
  role    = "roles/compute.admin"
  member  = "group:${var.group_org_admins}"
}

resource "google_project_iam_member" "org_admins_jenkins_viewer" {
  project = module.cicd_project.project_id
  role    = "roles/viewer"
  member  = "group:${var.group_org_admins}"
}

/******************************************
  Jenkins Artifact bucket
*******************************************/

resource "google_storage_bucket" "gcs_jenkins_artifacts" {
  project                     = module.cicd_project.project_id
  name                        = format("%s-%s-%s-%s", var.storage_bucket_prefix, module.cicd_project.project_id, "jenkins-artifacts", random_id.suffix.hex)
  location                    = var.default_region
  labels                      = var.storage_bucket_labels
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

/***********************************************
  Jenkins - IAM
 ***********************************************/

// Allow the Jenkins Agent (GCE Instance) custom Service Account to store artifacts in GCS
// The pipeline must use gsutil to store artifacts in the GCS bucket
resource "google_storage_bucket_iam_member" "jenkins_artifacts_iam" {
  bucket = google_storage_bucket.gcs_jenkins_artifacts.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
}

// Allow the Jenkins Agent (GCE Instance) custom Service Account to impersonate the Terraform Service Account
resource "google_service_account_iam_member" "jenkins_terraform_sa_impersonate_permissions" {
  for_each = var.sa_enable_impersonation ? var.terraform_sa_names : {}

  service_account_id = each.value
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
}

resource "google_organization_iam_member" "jenkins_serviceusage_consumer" {
  count = local.impersonation_enabled_count

  org_id = var.org_id
  role   = "roles/serviceusage.serviceUsageConsumer"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
}

# Required to allow jenkins Service Account to access state with impersonation.
resource "google_storage_bucket_iam_member" "jenkins_state_iam" {
  count = local.impersonation_enabled_count

  bucket = var.terraform_state_bucket
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
}
