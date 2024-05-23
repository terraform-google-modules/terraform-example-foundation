
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
  Project for Environment KMS
*****************************************/

module "env_kms" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 15.0"

  random_project_id           = true
  random_project_id_length    = 4
  default_service_account     = "deprivilege"
  name                        = "${local.project_prefix}-${var.environment_code}-kms"
  org_id                      = local.org_id
  billing_account             = local.billing_account
  folder_id                   = google_folder.env.id
  disable_services_on_destroy = false
  depends_on                  = [time_sleep.wait_60_seconds]
  activate_apis               = ["logging.googleapis.com", "cloudkms.googleapis.com", "billingbudgets.googleapis.com"]

  labels = {
    environment       = var.env
    application_name  = "env-kms"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "shared"
    env_code          = var.environment_code
    vpc               = "none"
  }
  budget_alert_pubsub_topic   = var.project_budget.kms_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.kms_alert_spent_percents
  budget_amount               = var.project_budget.kms_budget_amount
  budget_alert_spend_basis    = var.project_budget.kms_budget_alert_spend_basis
}
