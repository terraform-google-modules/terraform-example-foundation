/**
 * Copyright 2022 Google LLC
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
  vpc_type        = var.forwarding_rule_target == "vpc-sc" ? "restricted" : "base"
  googleapis_url  = var.forwarding_rule_target == "vpc-sc" ? "restricted.googleapis.com." : "private.googleapis.com."
  recordsets_name = split(".", local.googleapis_url)[0]
}

resource "google_compute_global_address" "private_service_connect" {
  provider     = google-beta
  project      = var.project_id
  name         = "global-psconnect-ip"
  address_type = "INTERNAL"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = var.network_id
  address      = var.private_service_connect_ip
}

resource "google_compute_global_forwarding_rule" "forwarding_rule_private_service_connect" {
  provider              = google-beta
  project               = var.project_id
  name                  = "globalrule"
  target                = var.forwarding_rule_target
  network               = var.network_id
  ip_address            = google_compute_global_address.private_service_connect.id
  load_balancing_scheme = ""
}
