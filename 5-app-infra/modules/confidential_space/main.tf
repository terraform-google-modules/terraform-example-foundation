/**
 * Copyright 2025 Google LLC
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
  default_tee_image_reference = "${var.artifact_registry_location}-docker.pkg.dev/${local.env_project_id}/${google_artifact_registry_repository.ar_confidential_space.repository_id}/workload-confidential-space:latest"
  source_image_project        = "ubuntu-os-cloud"
  source_image_family         = "ubuntu-2204-lts"

  env_project_ids = {
    "conf-space" = data.terraform_remote_state.projects_env.outputs.confidential_space_project,
  }
  env_project_subnets = {
    "conf-space" = local.svpc_subnetwork_self_link,
  }
  env_project_resource_manager_tags = {
    "conf-space" = null,
  }

  subnetwork_self_links     = data.terraform_remote_state.projects_env.outputs.subnets_self_links
  svpc_subnetwork_self_link = [for subnet in local.subnetwork_self_links : subnet if length(regexall("regions/${var.region}/subnetworks", subnet)) > 0][0]

  env_project_id        = local.env_project_ids[var.project_suffix]
  subnetwork_self_link  = local.env_project_subnets[var.project_suffix]
  subnetwork_project    = element(split("/", local.subnetwork_self_link), index(split("/", local.subnetwork_self_link), "projects") + 1, )
  resource_manager_tags = local.env_project_resource_manager_tags[var.project_suffix]
}


data "terraform_remote_state" "projects_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/${var.environment}"
  }
}

resource "google_service_account" "confidential_compute_engine_service_account" {
  project                      = local.env_project_id
  account_id                   = "sa-confidential-space"
  display_name                 = "Confidential Space example service Account"
  create_ignore_already_exists = true
}


module "confidential_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 13.0"

  region     = var.region
  project_id = local.env_project_id
  subnetwork = local.subnetwork_self_link

  source_image_project       = var.source_image_project != "" ? var.source_image_project : local.source_image_project
  source_image               = var.source_image_family != "" ? var.source_image_family : local.source_image_family
  machine_type               = var.confidential_machine_type
  min_cpu_platform           = var.cpu_platform
  enable_confidential_vm     = true
  confidential_instance_type = var.confidential_instance_type

  shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    tee-image-reference = var.docker_image_reference != "" ? var.docker_image_reference : local.default_tee_image_reference
  }

  service_account = {
    email  = google_service_account.confidential_compute_engine_service_account.email
    scopes = ["cloud-platform"]
  }

}

module "confidential_compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 13.0"

  region                = var.region
  subnetwork_project    = local.subnetwork_project
  subnetwork            = local.subnetwork_self_link
  num_instances         = var.num_instances
  hostname              = var.confidential_hostname
  instance_template     = module.confidential_instance_template.self_link
  resource_manager_tags = local.resource_manager_tags
}

resource "google_service_account" "workload_sa" {
  account_id   = "confidential-space-workload-sa"
  display_name = "Workload Service Account for confidential space"
  project      = local.env_project_id
}

resource "google_project_iam_member" "workload_sa_user" {
  project = local.env_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = var.confidential_space_workload_operator
}

resource "google_project_iam_member" "workload_sa_confidential_user" {
  project = local.env_project_id
  role    = "roles/confidentialcomputing.workloadUser"
  member  = "serviceAccount:${google_service_account.workload_sa.email}"
}

resource "google_project_iam_member" "workload_sa_logging_writer" {
  project = local.env_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.workload_sa.email}"
}

resource "google_artifact_registry_repository" "ar_confidential_space" {
  repository_id = "ar-confidential-space"
  format        = "DOCKER"
  location      = var.artifact_registry_location
  project       = local.env_project_id
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
  repository = google_artifact_registry_repository.ar_confidential_space.id
  location   = google_artifact_registry_repository.ar_confidential_space.location
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.workload_sa.email}"
}


module "kms_confidential_space" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 4.0"

  project_id          = local.env_project_id
  keyring             = var.confidential_space_keyring_name
  location            = var.confidential_space_location_kms
  keys                = [var.confidential_space_key_name]
  key_rotation_period = var.key_rotation_period
  encrypters          = ["serviceAccount:${google_service_account.workload_sa.email}"]
  set_encrypters_for  = [var.confidential_space_key_name]
  decrypters          = ["serviceAccount:${google_service_account.workload_sa.email}"]
  set_decrypters_for  = [var.confidential_space_key_name]
  prevent_destroy     = "false"
}

// Using resource since the KMS module doesn't support condition attribute
resource "google_kms_crypto_key_iam_member" "key_decrypter" {
  crypto_key_id = module.kms_confidential_space.keys[0]
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${google_service_account.workload_sa.email}"

  condition {
    expression  = "request.auth.claims.google.container.image_digest == '${var.image_digest}'"
    title       = "RequireAttestedImage"
    description = "OnlyAllowTrustedImage"
  }
}

