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
  network_name        = "vpc-b-cbpools"
  private_pool_name   = var.private_worker_pool.name != "" ? var.private_worker_pool.name : "private-pool-${random_string.suffix.result}"
  peered_network_id   = !var.private_worker_pool.enable_network_peering ? "" : var.private_worker_pool.peered_network_id != "" ? var.private_worker_pool.peered_network_id : module.peered_network[0].network_id
  peered_network_name = element(split("/", local.peered_network_id), index(split("/", local.peered_network_id), "networks") + 1, )
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "google_cloudbuild_worker_pool" "private_pool" {
  name     = local.private_pool_name
  project  = var.project_id
  location = var.private_worker_pool.region

  worker_config {
    disk_size_gb   = var.private_worker_pool.disk_size_gb
    machine_type   = var.private_worker_pool.machine_type
    no_external_ip = var.private_worker_pool.no_external_ip
  }

  dynamic "network_config" {
    for_each = var.private_worker_pool.enable_network_peering ? ["network_config"] : []
    content {
      peered_network = local.peered_network_id
    }
  }

  depends_on = [
    google_compute_global_address.worker_pool_range,
    google_service_networking_connection.worker_pool_conn,
  ]
}
