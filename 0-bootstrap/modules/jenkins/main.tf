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
  jenkins_project_id       = format("%s-%s", var.project_prefix, "jenkins")
  jenkins_apis             = ["cloudkms.googleapis.com"]
  impersonation_enabled_count = var.sa_enable_impersonation == true ? 1 : 0
  activate_apis               = distinct(var.activate_apis)
  jenkins_gce_fw_tags         = ["jenkins-ssh-agent"]
}

resource "random_id" "suffix" {
  byte_length = 2
}

data "google_organization" "org" {
  organization = var.org_id
}


/******************************************
  Jenkins project
*******************************************/

module "jenkins_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  name                        = local.jenkins_project_id
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
  project            = module.jenkins_project.project_id
  service            = each.value
  disable_on_destroy = false
}

/******************************************
  Jenkins GCE instance
*******************************************/
resource "google_service_account" "jenkins_agent_gce_sa" {
  project      = module.jenkins_project.project_id
  account_id   = "jenkins-agent-gce-sa"
  display_name = "CFT Jenkins Agent GCE custom Service Account"
}

resource "google_compute_instance" "jenkins_agent_gce_instance" {
  name         = "jenkins_agent_01"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = local.jenkins_gce_fw_tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  // TODO(caleonardo): Add the ssh public keys to the metadata
  metadata = {
    enable-oslogin = "false"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email = google_service_account.jenkins_agent_gce_sa.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

/******************************************
  Jenkins GCE Firewall rules
*******************************************/

resource "google_compute_firewall" "allow_ssh_to_jenkins_agent_fw" {
  name    = "allow-ssh-to-jenkins-agent"
  network = google_compute_network.default.name

  //  allow {
  //    protocol = "icmp"
  //  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = local.jenkins_gce_fw_tags
}

resource "google_compute_network" "default" {
  name = "test-network"
}

/******************************************
  Jenkins IAM for admins
*******************************************/

resource "google_project_iam_member" "org_admins_jenkins_admin" {
  project = module.jenkins_project.project_id
  role    = "roles/compute.admin"
  member  = "group:${var.group_org_admins}"
}

resource "google_project_iam_member" "org_admins_jenkins_viewer" {
  project = module.jenkins_project.project_id
  role    = "roles/viewer"
  member  = "group:${var.group_org_admins}"
}

/******************************************
  Jenkins Artifact bucket
*******************************************/

resource "google_storage_bucket" "jenkins_artifacts" {
  project            = module.jenkins_project.project_id
  name               = format("%s-%s-%s", var.project_prefix, "jenkins-artifacts", random_id.suffix.hex)
  location           = var.default_region
  labels             = var.storage_bucket_labels
  bucket_policy_only = true
  versioning {
    enabled = true
  }
}

/******************************************
  KMS Keyring
 *****************************************/

resource "google_kms_key_ring" "tf_keyring" {
  project  = module.jenkins_project.project_id
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

resource "google_kms_crypto_key_iam_binding" "cloud_build_crypto_key_encrypter" {
  crypto_key_id = google_kms_crypto_key.tf_key.self_link
  role          = "roles/cloudkms.cryptoKeyEncrypter"

  members = [
    "group:${var.group_org_admins}",
  ]
}

/******************************************
  Create Cloud Source Repos
*******************************************/

resource "google_sourcerepo_repository" "gcp_repo" {
  for_each = toset(var.cloud_source_repos)
  project  = module.jenkins_project.project_id
  name     = each.value
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}

// ****************************************************************************
// TODO(caleonardo): Configure this repo on-prem
///******************************************
//  Cloud Source Repo IAM
//*******************************************/
//
//resource "google_project_iam_member" "org_admins_source_repo_admin" {
//  project = module.jenkins_project.project_id
//  role    = "roles/source.admin"
//  member  = "group:${var.group_org_admins}"
//}

// TODO(caleonardo): Configure these triggers in Jenkins - use jcac.yaml
///***********************************************
// Cloud Build - Master branch triggers
// ***********************************************/
//
//resource "google_cloudbuild_trigger" "master_trigger" {
//  for_each    = toset(var.cloud_source_repos)
//  project     = module.jenkins_project.project_id
//  description = "${each.value} - terraform apply on push to master."
//
//  trigger_template {
//    branch_name = "master"
//    repo_name   = each.value
//  }
//
//  substitutions = {
//    _ORG_ID               = var.org_id
//    _BILLING_ID           = var.billing_account
//    _DEFAULT_REGION       = var.default_region
//    _TF_SA_EMAIL          = var.terraform_sa_email
//    _STATE_BUCKET_NAME    = var.terraform_state_bucket
//    _ARTIFACT_BUCKET_NAME = google_storage_bucket.jenkins_artifacts.name
//    _SEED_PROJECT_ID      = module.jenkins_project.project_id
//  }
//
//  filename = "cloudbuild-tf-apply.yaml"
//  depends_on = [
//    google_sourcerepo_repository.gcp_repo,
//  ]
//}
//
///***********************************************
// Cloud Build - Non Master branch triggers
// ***********************************************/
//
//resource "google_cloudbuild_trigger" "non_master_trigger" {
//  for_each    = toset(var.cloud_source_repos)
//  project     = module.jenkins_project.project_id
//  description = "${each.value} - terraform plan on all branches except master."
//
//  trigger_template {
//    branch_name = "[^master]"
//    repo_name   = each.value
//  }
//
//  substitutions = {
//    _ORG_ID               = var.org_id
//    _BILLING_ID           = var.billing_account
//    _DEFAULT_REGION       = var.default_region
//    _TF_SA_EMAIL          = var.terraform_sa_email
//    _STATE_BUCKET_NAME    = var.terraform_state_bucket
//    _ARTIFACT_BUCKET_NAME = google_storage_bucket.jenkins_artifacts.name
//    _SEED_PROJECT_ID      = module.jenkins_project.project_id
//  }
//
//  filename = "cloudbuild-tf-plan.yaml"
//  depends_on = [
//    google_sourcerepo_repository.gcp_repo,
//  ]
//}

// TODO(caleonardo): Configure this Terraform builder in Jenkins - use jcac.yaml
///***********************************************
// Cloud Build - Terraform builder
// ***********************************************/
//
//resource "null_resource" "cloudbuild_terraform_builder" {
//  triggers = {
//    project_id_cloudbuild_project = module.jenkins_project.project_id
//    terraform_version_sha256sum   = var.terraform_version_sha256sum
//    terraform_version             = var.terraform_version
//  }
//
//  provisioner "local-exec" {
//    command = <<EOT
//      gcloud builds submit ${path.module}/cloudbuild_builder/ \
//      --project ${module.jenkins_project.project_id} \
//      --config=${path.module}/cloudbuild_builder/cloudbuild.yaml \
//      --substitutions=_TERRAFORM_VERSION=${var.terraform_version},_TERRAFORM_VERSION_SHA256SUM=${var.terraform_version_sha256sum}
//  EOT
//  }
//  depends_on = [
//    google_project_service.jenkins_apis,
//  ]
//}
// ****************************************************************************

/***********************************************
  Jenkins - IAM
 ***********************************************/

resource "google_storage_bucket_iam_member" "jenkins_artifacts_iam" {
  bucket = google_storage_bucket.jenkins_artifacts.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}

/* TODO(caleonardo): better use google_service_account.jenkins_agent_gce_sa.email
           directly, without impersonation.*/
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

# Required to allow jenkins to access state with impersonation.
resource "google_storage_bucket_iam_member" "jenkins_state_iam" {
  count = local.impersonation_enabled_count

  bucket = var.terraform_state_bucket
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_agent_gce_sa.email}"
  depends_on = [
    google_project_service.jenkins_apis,
  ]
}