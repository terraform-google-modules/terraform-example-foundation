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
  Default DNS Policy
 *****************************************/

resource "google_dns_policy" "default_policy" {
  provider                  = google-beta
  project                   = var.project_id
  name                      = "default-policy"
  enable_inbound_forwarding = var.dns_enable_inbound_forwarding
  enable_logging            = var.dns_enable_logging
  networks {
    network_url = module.main.network_self_link
  }
}

/******************************************
  Private Google APIs DNS Zone & records.
 *****************************************/

resource "google_dns_managed_zone" "private_googleapis" {
  provider    = google-beta
  project     = var.project_id
  name        = "private-googleapis"
  dns_name    = "googleapis.com."
  description = "Private DNS zone to configure private.googleapis.com"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = module.main.network_self_link
    }
  }
}

resource "google_dns_record_set" "googleapis_cname" {
  provider     = google-beta
  project      = var.project_id
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.private_googleapis.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["private.googleapis.com."]
}

resource "google_dns_record_set" "private_googleapis_a" {
  provider     = google-beta
  project      = var.project_id
  name         = "private.googleapis.com."
  managed_zone = google_dns_managed_zone.private_googleapis.name
  type         = "A"
  ttl          = 300

  rrdatas = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

/******************************************
  Private GCR DNS Zone & records.
 *****************************************/

resource "google_dns_managed_zone" "private_gcr" {
  provider    = google-beta
  project     = var.project_id
  name        = "private-gcr"
  dns_name    = "gcr.io."
  description = "Private DNS zone to configure gcr.io"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = module.main.network_self_link
    }
  }
}

resource "google_dns_record_set" "gcr_cname" {
  provider     = google-beta
  project      = var.project_id
  name         = "*.gcr.io."
  managed_zone = google_dns_managed_zone.private_gcr.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["gcr.io."]
}

resource "google_dns_record_set" "private_gcr_a" {
  provider     = google-beta
  project      = var.project_id
  name         = "gcr.io."
  managed_zone = google_dns_managed_zone.private_gcr.name
  type         = "A"
  ttl          = 300

  rrdatas = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}
