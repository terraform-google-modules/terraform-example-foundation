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
  env_project_ids = {
    "sample-floating" = data.terraform_remote_state.projects_env.outputs.floating_project,
    "sample-peering"  = data.terraform_remote_state.projects_env.outputs.peering_project,
    "sample-svpc"     = data.terraform_remote_state.projects_env.outputs.shared_vpc_project,
    "conf-space"     = data.terraform_remote_state.projects_env.outputs.confidential_space_project,//added
  }
  env_project_subnets = {
    "sample-floating" = local.svpc_subnetwork_self_link,
    "sample-peering"  = data.terraform_remote_state.projects_env.outputs.peering_subnetwork_self_link,
    "sample-svpc"     = local.svpc_subnetwork_self_link,
    "conf-space"     = local.svpc_subnetwork_self_link, //added
  }
  env_project_resource_manager_tags = {
    "sample-floating" = null,
    "sample-peering"  = data.terraform_remote_state.projects_env.outputs.iap_firewall_tags,
    "sample-svpc"     = null,
    "conf-space"     = null,//added
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

resource "google_service_account" "compute_engine_service_account" {
  project                      = local.env_project_id
  account_id                   = "sa-example-app"
  display_name                 = "Example app service Account"
  create_ignore_already_exists = true
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 13.0"

  machine_type = var.machine_type
  region       = var.region
  project_id   = local.env_project_id
  subnetwork   = local.subnetwork_self_link

  metadata = {
    block-project-ssh-keys = "true"
  }

  service_account = {
    email  = google_service_account.compute_engine_service_account.email
    scopes = ["compute-rw"]
  }
}

module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 13.0"

  region                = var.region
  subnetwork            = local.subnetwork_self_link
  subnetwork_project    = local.subnetwork_project
  num_instances         = var.num_instances
  hostname              = var.hostname
  instance_template     = module.instance_template.self_link
  resource_manager_tags = local.resource_manager_tags
}



///confidential space
////
module "confidential_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 13.0"

  region     = var.region
  project_id = local.env_project_id
  subnetwork = local.subnetwork_self_link

  #name_prefix                = "confidential-space-template"
  source_image_project       = "confidential-space-images"
  source_image               = "confidential-space"
  machine_type               = "n2d-standard-2"
  min_cpu_platform           = "AMD Milan"
  enable_confidential_vm     = true
  confidential_instance_type = "SEV"

  shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    tee-image-reference = "us-central1-docker.pkg.dev/prj-p-bu1-sample-peering-cue4/prj-p-bu1-sample-repo/prj-p-bu1-repo:latest"

  }

  service_account = {
    email  = google_service_account.compute_engine_service_account.email
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
  hostname              = "confidential-instance"
  instance_template     = module.confidential_instance_template.self_link
  resource_manager_tags = local.resource_manager_tags
}

resource "google_service_account" "workload_sa" {
  account_id   = "confidential-space-workload-sa"
  display_name = "Workload Service Account for confidential space"
  project      = local.env_project_id
}

resource "google_project_service" "enabled_services" {
  project = local.env_project_id

  service = [
    "cloudkms.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "compute.googleapis.com",
    "confidentialcomputing.googleapis.com"
  ]
}

resource "google_project_iam_member" "workload_sa_user" {
  project = local.env_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "user:${data.google_client_config.default.account_id}"
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
  repository_id   = "ar-confidential-space"
  format          = "DOCKER"
  location        = "us"
  project         = local.env_project_id
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
  repository = google_artifact_registry_repository.ar_confidential_space.id
  location   = google_artifact_registry_repository.ar_confidential_space.location
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.workload_sa.email}"
}

resource "google_kms_key_ring" "workload_keyring" {
  name     = "workload-key-ring"
  location = "global"
  project  = local.env_project_id
}

resource "google_kms_crypto_key" "workload_key" {
  name     = "workload-key"
  key_ring = google_kms_key_ring.workload_keyring.id
  purpose  = "ENCRYPT_DECRYPT"
}

resource "google_kms_crypto_key_iam_member" "key_decrypter" {
  crypto_key_id = google_kms_crypto_key.workload_key.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${google_service_account.workload_sa.email}"

  condition {
    expression  = "request.auth.claims.google.container.image_digest == 'sha256:HASH-GERADO-PELO-DIGEST'"
    title       = "RequireAttestedImage"
    description = "OnlyAllowTrustedImage"
  }
}

