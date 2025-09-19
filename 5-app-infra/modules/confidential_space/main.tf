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

  cloudbuild_project_id             = data.terraform_remote_state.business_unit_shared.outputs.bootstrap_cloudbuild_project_id
  default_region                    = data.terraform_remote_state.projects_env.outputs.default_region
  env_project_id                    = local.env_project_ids[var.project_suffix]
  subnetwork_self_link              = local.env_project_subnets[var.project_suffix]
  subnetwork_project                = element(split("/", local.subnetwork_self_link), index(split("/", local.subnetwork_self_link), "projects") + 1, )
  resource_manager_tags             = local.env_project_resource_manager_tags[var.project_suffix]
  artifact_registry_repository      = "tf-runners"
  confidential_space_project_id     = data.terraform_remote_state.projects_env.outputs.confidential_space_project
  confidential_space_project_number = data.terraform_remote_state.projects_env.outputs.confidential_space_project_number
  confidential_space_workload_sa    = data.terraform_remote_state.projects_env.outputs.confidential_space_workload_sa
}

data "terraform_remote_state" "projects_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/${var.environment}"
  }
}

data "terraform_remote_state" "business_unit_shared" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/shared"
  }
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
assertion.submods.container.image_digest == "${var.confidential_image_digest}" &&
"${local.confidential_space_workload_sa}" in assertion.google_service_accounts &&
assertion.swname == "CONFIDENTIAL_SPACE" &&
"STABLE" in assertion.submods.confidential_space.support_attributes
EOT

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

resource "time_sleep" "wait_workload_pool_propagation" {
  create_duration = "60s"

  depends_on = [
    google_iam_workload_identity_pool.confidential_space_pool
  ]
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = "projects/${local.env_project_id}/serviceAccounts/${local.confidential_space_workload_sa}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${local.confidential_space_project_number}/locations/global/workloadIdentityPools/confidential-space-pool/*"

  depends_on = [
    time_sleep.wait_workload_pool_propagation
  ]
}

