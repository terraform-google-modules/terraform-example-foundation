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
  projects_ids = {
    org_audit_logs         = module.org_audit_logs.project_id,
    org_billing_logs       = module.org_billing_logs.project_id
    org_secrets            = module.org_secrets.project_id,
    interconnect           = module.interconnect.project_id,
    scc_notifications      = module.scc_notifications.project_id,
    dns_hub                = module.dns_hub.project_id,
    base_network_hub       = module.base_network_hub.project_id,
    restricted_network_hub = module.restricted_network_hub.project_id
  }

  parent_resource_id   = var.parent_folder != "" ? var.parent_folder : var.org_id
  parent_resource_type = length(projects_ids) > 0 ? "project" : (var.parent_folder != "" ? "folder" : "organization")
}

module "centralized_logging" {
  source                         = "../../modules/centralized-logging"
  projects_ids                   = local.projects_ids
  logging_destination_project_id = module.org_audit_logs.project_id
  kms_project_id                 = module.org_audit_logs.project_id
  bucket_name                    = "bkt-logging-${module.org_audit_logs.project_id}"
  bigquery_name                  = "bq-logging-${module.org_audit_logs.project_id}"
  pubsub_name                    = "ps-logging-${module.org_audit_logs.project_id}"
  logging_location               = var.default_region
  delete_contents_on_destroy     = var.delete_contents_on_destroy
  //  key_rotation_period_seconds    = local.key_rotation_period_seconds

  depends_on = [
    module.org_audit_logs,
    module.org_billing_logs,
    module.org_secrets,
    module.interconnect,
    module.scc_notifications,
    module.dns_hub,
    module.base_network_hub,
    module.restricted_network_hub
  ]
}

/******************************************
  Billing logs (Export configured manually)
*****************************************/

resource "google_bigquery_dataset" "billing_dataset" {
  dataset_id    = "billing_data"
  project       = module.org_billing_logs.project_id
  friendly_name = "GCP Billing Data"
  location      = var.default_region
}
