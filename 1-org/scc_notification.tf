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
  SCC Notification
*****************************************/

locals {
  description = "SCC Notification for all findings '${var.scc_notification_filter}'"
}


resource "google_pubsub_topic" "scc_notification_topic" {
  name = "top-scc-notification"
}

resource "google_pubsub_subscription" "scc_notification_subscription" {
  name  = "sub-scc-notification"
  topic = google_pubsub_topic.scc_notification_topic.name

  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}


module "scc_notification" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 1.1.0"

  platform = "linux"

  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "alpha scc notifications create ${var.scc_notification_name} --organization \"${var.org_id}\" --description \"${local.description}\" --pubsub-topic ${google_pubsub_topic.scc_notification_topic.name} --filter \"${var.scc_notification_filter}\""
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "alpha scc notifications delete organizations/${var.org_id}/notificationConfigs/${var.scc_notification_name} --quiet"
  skip_download          = "true"
}
