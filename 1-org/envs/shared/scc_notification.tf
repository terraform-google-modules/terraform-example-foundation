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
  SCC Notification
*****************************************/

resource "google_pubsub_topic" "scc_notification_topic" {
  count   = var.enable_scc_resources_in_terraform ? 1 : 0
  name    = "top-scc-notification"
  project = module.scc_notifications.project_id
}

resource "google_pubsub_subscription" "scc_notification_subscription" {
  count   = var.enable_scc_resources_in_terraform ? 1 : 0
  name    = "sub-scc-notification"
  topic   = google_pubsub_topic.scc_notification_topic[0].name
  project = module.scc_notifications.project_id
}

resource "google_scc_notification_config" "scc_notification_config" {
  count        = var.enable_scc_resources_in_terraform ? 1 : 0
  config_id    = var.scc_notification_name
  organization = local.org_id
  description  = "SCC Notification for all active findings"
  pubsub_topic = google_pubsub_topic.scc_notification_topic[0].id

  streaming_config {
    filter = var.scc_notification_filter
  }
}
