/**
 * Copyright 2020 Google LLC
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
  Monitoring - IAM
*****************************************/

resource "google_project_iam_member" "monitoring_prod_editor" {
  project = module.org_monitoring_prod.project_id
  role   = "roles/monitoring.editor"
  member = "group:${var.monitoring_workspace_users}"
}

resource "google_project_iam_member" "monitoring_nonprod_editor" {
  project = module.org_monitoring_nonprod.project_id
  role   = "roles/monitoring.editor"
  member = "group:${var.monitoring_workspace_users}"
}

/******************************************
  Audit Logs - IAM
*****************************************/

resource "google_project_iam_member" "audit_log_bq_user" {
  project = module.org_audit_logs.project_id
  role    = "roles/bigquery.user"
  member  = "group:${var.audit_data_users}"
}

resource "google_project_iam_member" "audit_log_bq_data_viewer" {
  project = module.org_audit_logs.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "group:${var.audit_data_users}"
}

/******************************************
  Billing BigQuery - IAM
*****************************************/

resource "google_project_iam_member" "billing_bq_user" {
  project = module.org_billing_logs.project_id
  role    = "roles/bigquery.user"
  member  = "group:${var.billing_data_users}"
}

resource "google_project_iam_member" "billing_bq_viewer" {
  project = module.org_billing_logs.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "group:${var.billing_data_users}"
}
