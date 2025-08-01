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
  default_tee_image_reference = "${local.default_region}-docker.pkg.dev/${local.cloudbuild_project_id}/${local.artifact_registry_repository}/confidential_space_image:latest"
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

  cloudbuild_project_id             = data.terraform_remote_state.projects_env.outputs.bootstrap_cloudbuild_project_id
  default_region                    = data.terraform_remote_state.projects_env.outputs.default_region
  env_project_id                    = local.env_project_ids[var.project_suffix]
  subnetwork_self_link              = local.env_project_subnets[var.project_suffix]
  subnetwork_project                = element(split("/", local.subnetwork_self_link), index(split("/", local.subnetwork_self_link), "projects") + 1, )
  resource_manager_tags             = local.env_project_resource_manager_tags[var.project_suffix]
  artifact_registry_repository      = "tf-runners"
  app_infra_cloudbuild_project      = data.terraform_remote_state.projects_env.outputs.confidential_space_project
  confidential_space_project_number = data.terraform_remote_state.projects_env.outputs.confidential_space_project_number
  confidential_space_project_id     = data.terraform_remote_state.projects_env.outputs.confidential_space_project
  cloudbuild_service_account        = data.terraform_remote_state.projects_env.outputs.cloudbuild_sa
  confidential_space_workload_sa    = data.terraform_remote_state.projects_env.outputs.confidential_space_workload_sa
}

data "terraform_remote_state" "projects_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/${var.environment}"
  }
}

resource "google_project_iam_member" "workload_identity_admin" {
  project = local.app_infra_cloudbuild_project
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${local.confidential_space_workload_sa}"
}

resource "google_iam_workload_identity_pool" "confidential_space_pool" {
  workload_identity_pool_id = "confidential-space-pool"
  disabled                  = false
  project                   = local.env_project_id
}

resource "google_iam_workload_identity_pool_provider" "attestation_verifier" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.confidential_space_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "attestation-verifier"
  display_name                       = "attestation-verifier"
  description                        = "OIDC provider for confidential computing attestation"
  project                            = local.env_project_id

  oidc {
    issuer_uri        = "https://confidentialcomputing.googleapis.com/"
    allowed_audiences = ["https://sts.googleapis.com"]
  }

  attribute_mapping = {
    "google.subject"         = "\"gcpcs::\" + assertion.submods.container.image_digest + \"::\" + assertion.submods.gce.project_number + \"::\" + assertion.submods.gce.instance_id"
    "attribute.image_digest" = "assertion.submods.container.image_digest"
  }

  attribute_condition = <<EOT
assertion.submods.container.image_digest == "${var.image_digest}" &&
"${local.confidential_space_workload_sa}" in assertion.google_service_accounts &&
assertion.swname == "CONFIDENTIAL_SPACE" &&
"STABLE" in assertion.submods.confidential_space.support_attributes
EOT

}

resource "google_service_account_iam_member" "impersonate_workload_sa" {
  service_account_id = "projects/${local.env_project_id}/serviceAccounts/${local.confidential_space_workload_sa}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.cloudbuild_service_account}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
  project    = local.cloudbuild_project_id
  repository = local.artifact_registry_repository
  location   = local.default_region
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${local.confidential_space_workload_sa}"
}

module "confidential_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 13.0"

  region     = var.region
  project_id = local.env_project_id
  subnetwork = local.subnetwork_self_link

  source_image_project       = var.source_image_project
  source_image               = var.source_image_family
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
    tee-image-reference = local.default_tee_image_reference
  }

  service_account = {
    email  = local.confidential_space_workload_sa
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

resource "google_project_iam_member" "workload_sa_user" {
  project = local.env_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = var.confidential_space_workload_operator
}

resource "google_project_iam_member" "workload_sa_confidential_user" {
  project = local.env_project_id
  role    = "roles/confidentialcomputing.workloadUser"
  member  = "serviceAccount:${local.confidential_space_workload_sa}"
}

resource "google_project_iam_member" "workload_sa_logging_writer" {
  project = local.env_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.confidential_space_workload_sa}"
}

module "kms_confidential_space" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 4.0"

  project_id          = local.env_project_id
  keyring             = var.confidential_space_keyring_name
  location            = var.confidential_space_location_kms
  keys                = [var.confidential_space_key_name]
  key_rotation_period = var.key_rotation_period
  encrypters          = ["serviceAccount:${local.confidential_space_workload_sa}"]
  set_encrypters_for  = [var.confidential_space_key_name]
  decrypters          = ["serviceAccount:${local.confidential_space_workload_sa}"]
  set_decrypters_for  = [var.confidential_space_key_name]
  prevent_destroy     = "false"
}

// Using resource since the KMS module doesn't support condition attribute
resource "google_kms_crypto_key_iam_member" "key_decrypter" {
  crypto_key_id = module.kms_confidential_space.keys[var.confidential_space_key_name]
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${local.confidential_space_workload_sa}"

  condition {
    expression  = "request.auth.claims.google.container.image_digest == '${var.image_digest}'"
    title       = "RequireAttestedImage"
    description = "OnlyAllowTrustedImage"
  }
}

resource "google_kms_crypto_key_iam_member" "gcs_encrypter_ecrypter" {
  crypto_key_id = module.kms_confidential_space.keys[var.confidential_space_key_name]
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${local.confidential_space_project_number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "encrypter_binding" {
  crypto_key_id = module.kms_confidential_space.keys[var.confidential_space_key_name]
  role          = "roles/cloudkms.cryptoKeyEncrypter"
  member        = "serviceAccount:${local.confidential_space_workload_sa}"
}


resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = "projects/${local.env_project_id}/serviceAccounts/${local.confidential_space_workload_sa}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${local.confidential_space_project_number}/locations/global/workloadIdentityPools/confidential-space-pool/*"
}

 resource "random_string" "bucket_name" {
   length  = 5
   upper   = false
   numeric = true
   lower   = true
   special = false
 }

module "gcs_buckets" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 9.0"

  project_id         = local.confidential_space_project_id
  location           = var.location_gcs
  name               = "${var.gcs_bucket_prefix}-${local.confidential_space_project_id}-cmek-encrypted-${random_string.bucket_name.result}"
  bucket_policy_only = true
}

resource "google_project_iam_member" "workload_gcs_admin_sa" {
  project = local.confidential_space_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${local.confidential_space_workload_sa}"
}

resource "google_storage_bucket_iam_member" "results_bucket_object_admin" {
  bucket = module.gcs_buckets.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.confidential_space_workload_sa}"
}

resource "google_storage_bucket_iam_member" "object_viewer" {
  bucket = module.gcs_buckets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.confidential_space_workload_sa}"
}
