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
  jenkins_apis                = ["compute.googleapis.com", "sourcerepo.googleapis.com", "cloudkms.googleapis.com"]
  impersonation_enabled_count = var.sa_enable_impersonation ? 1 : 0
  activate_apis               = distinct(var.activate_apis)
  jenkins_gce_fw_tags         = ["ssh-jenkins-agent"]
}

resource "random_id" "suffix" {
  byte_length = 2
}

/******************************************
  CICD project
*******************************************/
module "cicd_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0" // TODO(caleonardo): use latest current versions so that we are up to date
  name                        = local.cicd_project_name
  random_project_id           = true
  disable_services_on_destroy = false
  folder_id                   = var.folder_id
  org_id                      = var.org_id
  billing_account             = var.billing_account
  activate_apis               = local.activate_apis
  labels                      = var.project_labels
}

resource "google_project_service" "jenkins_apis" {
  for_each           = toset(local.jenkins_apis)
  project            = module.cicd_project.project_id
  service            = each.value
  disable_on_destroy = false
}

/******************************************
  Jenkins Agent GCE instance
*******************************************/
resource "google_service_account" "jenkins_agent_gce_sa" {
  project      = module.cicd_project.project_id
  account_id   = "sa-${var.jenkins_sa_email}"
  display_name = "Jenkins Agent (GCE instance) custom Service Account"
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
      // TODO(caleonardo): This must not have an external IP. Only use for testing while developing a VPN resource
    }
  }

  // Adding ssh public keys to the GCE instance metadata, so the Jenkins Master can connect to this Agent
  metadata = {
    enable-oslogin = "false"
    ssh-keys       = var.jenkins_agent_gce_ssh_pub_key
  }

  // TODO(caleonardo): Setup the Java installation here for the Jenkins Agent
  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email = google_service_account.jenkins_agent_gce_sa.email
    scopes = [
      // TODO(caleonardo): These scopes will need to change.
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

resource "google_compute_firewall" "fw_allow_ssh_into_jenkins_agent" {
  project       = module.cicd_project.project_id
  name          = "fw-${google_compute_network.jenkins_agents.name}-1000-i-a-all-all-tcp-22"
  description   = "Allow the Jenkins Master (Client) to connect to the Jenkins Agents (Servers) using SSH."
  network       = google_compute_network.jenkins_agents.name
  source_ranges = var.jenkins_master_ip_addresses
  target_tags   = local.jenkins_gce_fw_tags
  priority      = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_network" "jenkins_agents" {
  project = module.cicd_project.project_id
  name    = "vpc-b-jenkinsagents"
}

// TODO(caleonardo): add an option to create a Jenkins Master in GCP, in case the user doesn't have one on-prem
// If you do not have a Jenkins implementation and don't want one, you should use the Cloud Build module instead of this Jenkins module

/******************************************
  VPN Connectivity on-prem <--> CICD project
*******************************************/

// TODO(Amanda / Daniel): add VPN for connectivity between Jenkins Master on prem with Jenkins Agent in GCP

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
  project            = module.cicd_project.project_id
  name               = format("%s-%s-%s-%s", var.storage_bucket_prefix, module.cicd_project.project_id, "jenkins-artifacts", random_id.suffix.hex)
  location           = var.default_region
  labels             = var.storage_bucket_labels
  bucket_policy_only = true
  versioning {
    enabled = true
  }
}

// TODO(Rohan): Evaluate if / how to migrate this to Secrets Manager
/******************************************
  KMS Keyring configuration -
  to protect any secrets in CICD project
*****************************************/

resource "google_kms_key_ring" "tf_keyring" {
  project  = module.cicd_project.project_id
  name     = "tf-keyring"
  location = var.default_region
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}

/******************************************
  KMS Key
 *****************************************/

resource "google_kms_crypto_key" "tf_key" {
  name     = "tf-key"
  key_ring = google_kms_key_ring.tf_keyring.self_link
}

/******************************************
  Permissions to decrypt.
 *****************************************/

resource "google_kms_crypto_key_iam_binding" "jenkins_crypto_key_decrypter" {
  crypto_key_id = google_kms_crypto_key.tf_key.self_link
  role          = "roles/cloudkms.cryptoKeyDecrypter"

  members = [
    "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}",
    "serviceAccount:${var.terraform_sa_email}"
  ]
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}

/******************************************
  Permissions for org admins to encrypt.
 *****************************************/

resource "google_kms_crypto_key_iam_binding" "jenkins_crypto_key_encrypter" {
  crypto_key_id = google_kms_crypto_key.tf_key.self_link
  role          = "roles/cloudkms.cryptoKeyEncrypter"

  members = [
    "group:${var.group_org_admins}",
  ]
}

/***********************************************
  Jenkins - IAM
 ***********************************************/

resource "google_storage_bucket_iam_member" "jenkins_artifacts_iam" {
  bucket = google_storage_bucket.gcs_jenkins_artifacts.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}

// Allow the Jenkins Agent (GCE Instance) custom Service Account to impersonate the Terraform Service Account
resource "google_service_account_iam_member" "jenkins_terraform_sa_impersonate_permissions" {
  count = local.impersonation_enabled_count

  service_account_id = var.terraform_sa_name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}

resource "google_organization_iam_member" "jenkins_serviceusage_consumer" {
  count = local.impersonation_enabled_count

  org_id = var.org_id
  role   = "roles/serviceusage.serviceUsageConsumer"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}

# Required to allow jenkins Service Account to access state with impersonation.
resource "google_storage_bucket_iam_member" "jenkins_state_iam" {
  count = local.impersonation_enabled_count

  bucket = var.terraform_state_bucket
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}
