/**
 * Copyright 2019 Google LLC
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
  cicd_project_name           = format("%s-%s", var.project_prefix, "cicd")
  impersonation_enabled_count = var.sa_enable_impersonation == true ? 1 : 0
  activate_apis               = distinct(var.activate_apis)
  jenkins_gce_fw_tags         = ["ssh-jenkins-agent"]
}

/******************************************
  CICD project
*******************************************/
module "cicd_project" {
  source                      = "terraform-google-modules/project-factory/google"
  // TODO(caleonardo): use latest current versions so that we are up to date
  version                     = "~> 7.0"
  name                        = local.cicd_project_name
  random_project_id           = true
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
  account_id   = var.jenkins_sa_email
  display_name = "CFT Jenkins Agent GCE custom Service Account"
}

resource "google_compute_instance" "jenkins_agent_gce_instance" {
  project      = module.cicd_project.project_id
  name         = var.jenkins_agent_gce_name
  machine_type = var.jenkins_agent_gce_machine_type
  zone         = "${var.default_region}-a"

  tags = local.jenkins_gce_fw_tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.jenkins_agents.self_link

    access_config {
      // Ephemeral IP
      // TODO(caleonardo): This must not have an external IP at all - Only use for testing while developing
    }
  }

  // Adding ssh public keys to the metadata, so the Jenkins Master can connect
  metadata = {
    enable-oslogin = "false"
    ssh-keys       = "${var.jenkins_agent_gce_ssh_user}:${file(var.jenkins_agent_gce_ssh_pub_key_file)}"
  }

  // TODO(caleonardo): Setup the Java installation here for the Jenkins Agent
  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email = google_service_account.jenkins_agent_gce_sa.email
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/userinfo.email",
    ]
  }

  // allow stopping the GCE instance to update some of its values
  allow_stopping_for_update = true
}

/******************************************
  Jenkins Agent GCE Firewall rules
*******************************************/

resource "google_compute_firewall" "allow_ssh_to_jenkins_agent_fw" {
  project       = module.cicd_project.project_id
  name          = "allow-ssh-to-jenkins-agents"
  description   = "Allow the Jenkins Master (Client) to connect to the Jenkins Agents (Servers) using SSH."
  network       = google_compute_network.jenkins_agents.name

  source_ranges = var.jenkins_master_ip_addresses
  target_tags   = local.jenkins_gce_fw_tags

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_network" "jenkins_agents" {
  project = module.cicd_project.project_id
  name    = "jenkins-agents-network"
}

// TODO(caleonardo): add an option to create a Jenkins Master in GCP, in case the user doesn't have one on-prem