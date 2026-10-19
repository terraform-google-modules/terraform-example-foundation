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

/******************************************
  Audit Logs - IAM
*****************************************/

locals {
  s_account_domain = local.universe_prefix != "" ? "${local.universe_prefix}-system.iam.gserviceaccount.com" : "iam.gserviceaccount.com"
  api_s_account = format(
    "service-org-%s@gcp-sa-cloudkms.%s",
    local.org_id,
    local.s_account_domain
  )

  # Formats data from the bootstrap state
  formatted_required_groups = {
    for k, v in local.required_groups : k => (
      startswith(v, "principalSet://") || startswith(v, "group:") ? v : "group:${v}"
    )
  }

  # Formats data from the gcp_groups variable, preserving nulls
  formatted_gcp_groups = {
    for k, v in var.gcp_groups : k => v == null ? null : (
      startswith(v, "principalSet://") || startswith(v, "group:") ? v : "group:${v}"
    )
  }
}

resource "google_project_iam_member" "audit_log_logging_viewer" {
  project = module.org_audit_logs.project_id
  role    = "roles/logging.viewer"
  member  = local.formatted_required_groups["audit_data_users"]
}

resource "google_project_iam_member" "audit_log_bq_user" {
  project = module.org_audit_logs.project_id
  role    = "roles/bigquery.user"
  member  = local.formatted_required_groups["audit_data_users"]
}

resource "google_project_iam_member" "audit_log_bq_data_viewer" {
  project = module.org_audit_logs.project_id
  role    = "roles/bigquery.dataViewer"
  member  = local.formatted_required_groups["audit_data_users"]
}

/******************************************
  Billing BigQuery - IAM
*****************************************/

resource "google_project_iam_member" "billing_bq_user" {
  project = module.org_billing_export.project_id
  role    = "roles/bigquery.user"
  member  = local.formatted_required_groups["billing_data_users"]
}

resource "google_project_iam_member" "billing_bq_viewer" {
  project = module.org_billing_export.project_id
  role    = "roles/bigquery.dataViewer"
  member  = local.formatted_required_groups["billing_data_users"]
}

/******************************************
  Billing Cloud Console - IAM
*****************************************/

resource "google_organization_iam_member" "billing_viewer" {
  org_id = local.org_id
  role   = "roles/billing.viewer"
  member = local.formatted_required_groups["billing_data_users"]
}

/******************************************
  Enable KMS Usage Tracking
*****************************************/

module "create_kms_organization_service_agent" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 4.0"
  upgrade = false

  create_cmd_triggers = {
    org_id = local.org_id
  }

  create_cmd_body = "beta services identity create --service cloudkms.googleapis.com --organization ${local.org_id}"
}

resource "google_organization_iam_member" "kms_usage_tracking" {
  count = var.enable_kms_key_usage_tracking ? 1 : 0

  depends_on = [
    module.create_kms_organization_service_agent,
  ]

  org_id = local.org_id
  role   = "roles/cloudkms.orgServiceAgent"
  member = "serviceAccount:${local.api_s_account}"
}

/******************************************
 Groups permissions
*****************************************/

resource "google_organization_iam_member" "security_reviewer" {
  count  = var.gcp_groups.security_reviewer != null && local.parent_folder == "" ? 1 : 0
  org_id = local.org_id
  role   = "roles/iam.securityReviewer"
  member = local.formatted_gcp_groups["security_reviewer"]
}

resource "google_folder_iam_member" "security_reviewer" {
  count  = var.gcp_groups.security_reviewer != null && local.parent_folder != "" ? 1 : 0
  folder = "folders/${local.parent_folder}"
  role   = "roles/iam.securityReviewer"
  member = local.formatted_gcp_groups["security_reviewer"]
}

resource "google_organization_iam_member" "network_viewer" {
  count  = var.gcp_groups.network_viewer != null && local.parent_folder == "" ? 1 : 0
  org_id = local.org_id
  role   = "roles/compute.networkViewer"
  member = local.formatted_gcp_groups["network_viewer"]
}

resource "google_folder_iam_member" "network_viewer" {
  count  = var.gcp_groups.network_viewer != null && local.parent_folder != "" ? 1 : 0
  folder = "folders/${local.parent_folder}"
  role   = "roles/compute.networkViewer"
  member = local.formatted_gcp_groups["network_viewer"]
}

resource "google_project_iam_member" "audit_log_viewer" {
  count   = var.gcp_groups.audit_viewer != null ? 1 : 0
  project = module.org_audit_logs.project_id
  role    = "roles/logging.viewer"
  member  = local.formatted_gcp_groups["audit_viewer"]
}

resource "google_project_iam_member" "audit_private_logviewer" {
  count   = var.gcp_groups.audit_viewer != null ? 1 : 0
  project = module.org_audit_logs.project_id
  role    = "roles/logging.privateLogViewer"
  member  = local.formatted_gcp_groups["audit_viewer"]
}

resource "google_project_iam_member" "audit_bq_data_viewer" {
  count   = var.gcp_groups.audit_viewer != null ? 1 : 0
  project = module.org_audit_logs.project_id
  role    = "roles/bigquery.dataViewer"
  member  = local.formatted_gcp_groups["audit_viewer"]
}

resource "google_organization_iam_member" "org_scc_admin" {
  count  = var.gcp_groups.scc_admin != null && local.parent_folder == "" ? 1 : 0
  org_id = local.org_id
  role   = "roles/securitycenter.adminEditor"
  member = local.formatted_gcp_groups["scc_admin"]
}

resource "google_project_iam_member" "project_scc_admin" {
  count   = var.gcp_groups.scc_admin != null && var.enable_scc_resources_in_terraform ? 1 : 0
  project = module.scc_notifications.project_id
  role    = "roles/securitycenter.adminEditor"
  member  = local.formatted_gcp_groups["scc_admin"]
}

resource "google_project_iam_member" "global_secrets_admin" {
  count   = var.gcp_groups.global_secrets_admin != null ? 1 : 0
  project = module.org_secrets.project_id
  role    = "roles/secretmanager.admin"
  member  = local.formatted_gcp_groups["global_secrets_admin"]
}

resource "google_project_iam_member" "kms_admin" {
  count   = var.gcp_groups.kms_admin != null ? 1 : 0
  project = module.common_kms.project_id
  role    = "roles/cloudkms.viewer"
  member  = local.formatted_gcp_groups["kms_admin"]
}

resource "google_organization_iam_member" "kms_protected_resources_viewer" {
  count  = var.gcp_groups.kms_admin != null && var.enable_kms_key_usage_tracking ? 1 : 0
  org_id = local.org_id
  role   = "roles/cloudkms.protectedResourcesViewer"
  member = local.formatted_gcp_groups["kms_admin"]
}

resource "google_project_iam_member" "cai_monitoring_builder" {
  project = module.scc_notifications.project_id
  for_each = toset(var.enable_scc_resources_in_terraform ?
    [
      "roles/logging.logWriter",
      "roles/storage.objectViewer",
      "roles/artifactregistry.writer",
  ] : [])
  role   = each.key
  member = "serviceAccount:${google_service_account.cai_monitoring_builder[0].email}"
}
