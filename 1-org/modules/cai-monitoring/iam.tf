/**
 * Copyright 2023 Google LLC
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
  cf_roles = [
    "roles/pubsub.publisher",
    "roles/eventarc.eventReceiver",
    "roles/run.invoker"
  ]
  services = {
    "cloudfunctions"   = "cloudfunctions.googleapis.com"
    "artifactregistry" = "artifactregistry.googleapis.com"
    "pubsub"           = "pubsub.googleapis.com"
  }
  identities = {
    "cloudfunctions"   = "serviceAccount:${google_project_service_identity.service_sa["cloudfunctions"].email}",
    "artifactregistry" = "serviceAccount:${google_project_service_identity.service_sa["artifactregistry"].email}",
    "pubsub"           = "serviceAccount:${google_project_service_identity.service_sa["pubsub"].email}",
    "storage"          = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
  }
}

// Service Accounts
resource "google_project_service_identity" "service_sa" {
  for_each = local.services
  provider = google-beta

  project = var.project_id
  service = each.value
}

data "google_storage_project_service_account" "gcs_sa" {
  project = var.project_id
}

// Cloud Function SA
resource "google_service_account" "cloudfunction" {
  account_id                   = "cai-monitoring"
  project                      = var.project_id
  create_ignore_already_exists = true
}

resource "google_organization_iam_member" "cloudfunction_findings_editor" {
  org_id = var.org_id
  role   = "roles/securitycenter.findingsEditor"
  member = "serviceAccount:${google_service_account.cloudfunction.email}"
}

resource "google_project_iam_member" "cloudfunction_iam" {
  for_each = toset(local.cf_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudfunction.email}"
}

// Time sleep
resource "time_sleep" "wait_kms_iam" {
  create_duration = "60s"
  depends_on = [
    google_organization_iam_member.cloudfunction_findings_editor,
    google_project_iam_member.cloudfunction_iam
  ]
}
