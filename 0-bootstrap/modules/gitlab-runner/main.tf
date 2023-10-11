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
  cicd_project_id = "../gitlab-oidc.project_id"
  network_name    = var.create_network ? google_compute_network.gl_network[0].self_link : var.network_name
  subnet_name     = var.create_network ? google_compute_subnetwork.gl_subnetwork[0].self_link : var.subnet_name
  service_account = var.service_account == "" ? google_service_account.runner_service_account[0].email : var.service_account
}

/*****************************************
  Optional Runner Networking
 *****************************************/
resource "google_compute_network" "gl_network" {
  count = var.create_network ? 1 : 0

  name                    = var.network_name
  project                 = local.cicd_project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gl_subnetwork" {
  count = var.create_subnetwork ? 1 : 0

  project       = local.cicd_project_id
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip
  region        = var.region
  network       = local.network_name
  #network       = google_compute_network.gl_network[0].name
}

# module "peered_network" {
#   source  = "terraform-google-modules/network/google"
#   version = "~> 5.2"

#   count   = var.private_worker_pool.create_peered_network ? 1 : 0

#   project_id                             = var.project_id
#   network_name                           = local.network_name
#   delete_default_internet_gateway_routes = "true"

#   subnets = [
#     {
#       subnet_name           = "sb-b-cbpools-${var.private_worker_pool.region}"
#       subnet_ip             = var.private_worker_pool.peered_network_subnet_ip
#       subnet_region         = var.private_worker_pool.region
#       subnet_private_access = "true"
#       subnet_flow_logs      = "true"
#       description           = "Peered subnet for Cloud Build private pool"
#     }
#   ]

# }

resource "google_compute_router" "default" {
  count = var.create_network ? 1 : 0

  name    = "${var.network_name}-router"
  network = google_compute_network.gl_network[0].self_link
  region  = var.region
  project = local.cicd_project_id
}

// Nat is being used here since internet access is required for the Runner Network. Other internet access can be setup instead of NAT resource (e.g: Secure Web Proxy)
resource "google_compute_router_nat" "nat" {
  count = var.create_network ? 1 : 0

  project                            = local.cicd_project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.default[0].name
  region                             = google_compute_router.default[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_dns_policy" "default_policy" {
  project = local.cicd_project_id
  #name                      = "dp-${local.vpc_name}-default-policy"
  name                      = "dp-${local.network_name}-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = true

  networks {
    #network_url = module.network.network_self_link
    network_url = local.network_name
  }
}

/*****************************************
  IAM Bindings GCE SVC
 *****************************************/

resource "google_service_account" "runner_service_account" {
  count = var.service_account == "" ? 1 : 0

  project      = local.cicd_project_id
  account_id   = "runner-service-account"
  display_name = "GitLab Runner GCE Service Account"
}

/*****************************************
  Runner Secrets
 *****************************************/
resource "google_secret_manager_secret" "gl-secret" {
  provider = google-beta

  project   = local.cicd_project_id
  secret_id = "gl-token"

  labels = {
    label = "gl-token"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}
resource "google_secret_manager_secret_version" "gl-secret-version" {
  provider = google-beta

  secret = google_secret_manager_secret.gl-secret.id
  secret_data = jsonencode({
    "REPO_NAME"    = var.repo_name
    "REPO_OWNER"   = var.repo_owner
    "GITLAB_TOKEN" = var.gitlab_token
    "LABELS"       = join(",", var.gl_runner_labels)
  })
}

resource "google_secret_manager_secret_iam_member" "gl-secret-member" {
  provider = google-beta

  project   = local.cicd_project_id
  secret_id = google_secret_manager_secret.gl-secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.service_account}"
}

/*****************************************
  Runner GCE Instance Template
 *****************************************/

module "mig_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 7.0"

  project_id         = local.cicd_project_id
  machine_type       = var.machine_type
  network_ip         = var.network_ip
  network            = local.network_name
  subnetwork         = local.subnet_name
  region             = var.region
  subnetwork_project = local.cicd_project_id
  service_account = {
    email = local.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  disk_size_gb         = 100
  disk_type            = "pd-ssd"
  auto_delete          = true
  name_prefix          = "gl-runner"
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project
  startup_script       = file("${abspath(path.module)}/startup_script.sh")
  source_image         = var.source_image
  metadata = merge({
    "secret-id" = google_secret_manager_secret_version.gl-secret-version.name
  }, var.custom_metadata)
  tags = [
    "gl-runner-vm"
  ]
}
/*****************************************
  Runner MIG
 *****************************************/
module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 7.0"

  project_id         = local.cicd_project_id
  subnetwork_project = local.cicd_project_id
  hostname           = var.instance_name
  region             = var.region
  instance_template  = module.mig_template.self_link

  /* autoscaler */
  autoscaling_enabled = true
  min_replicas        = var.min_replicas
  max_replicas        = var.max_replicas
  cooldown_period     = var.cooldown_period
}

