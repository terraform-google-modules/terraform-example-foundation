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
  name    = "top-scc-notification"
  project = module.scc_notifications.project_id
}

resource "google_pubsub_subscription" "scc_notification_subscription" {
  name    = "sub-scc-notification"
  topic   = google_pubsub_topic.scc_notification_topic.name
  project = module.scc_notifications.project_id
}

module "scc_notification" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 1.1.0"

  additional_components = var.skip_gcloud_download ? [] : ["alpha"]

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<-EOF
    alpha scc notifications create ${var.scc_notification_name} --organization ${var.org_id} \
    --description "SCC Notification for all active findings" \
    --pubsub-topic projects/${module.scc_notifications.project_id}/topics/${google_pubsub_topic.scc_notification_topic.name} \
    --filter "${var.scc_notification_filter}" \
    --project "${module.scc_notifications.project_id}" \
    --impersonate-service-account=${var.terraform_service_account}
EOF

  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = <<-EOF
  alpha scc notifications delete organizations/${var.org_id}/notificationConfigs/${var.scc_notification_name} \
  --impersonate-service-account ${var.terraform_service_account} \
  --project "${module.scc_notifications.project_id}" \
  --quiet
  EOF
  skip_download          = var.skip_gcloud_download
}
