/**
 * Copyright 2024 Google LLC
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

resource "google_service_account" "cai_monitoring_builder" {
  project                      = module.scc_notifications.project_id
  account_id                   = "cai-monitoring-builder"
  description                  = "Cloud Functions has an underlying dependency on Cloud Build and other services. This service account allows Cloud Build to provision the necessary resources for Cloud Functions."
  create_ignore_already_exists = true
}
