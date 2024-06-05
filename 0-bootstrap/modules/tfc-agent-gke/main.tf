/**
 * Copyright 2023 Google LLC
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
  service_account_email   = var.create_service_account ? google_service_account.tfc_agent_service_account[0].email : var.service_account_email
  service_account_id      = var.create_service_account ? google_service_account.tfc_agent_service_account[0].id : var.service_account_id
  tfc_agent_name          = "${var.tfc_agent_name_prefix}-${random_string.suffix.result}"
  vpc_name                = "b-tfc-runner"
  private_googleapis_cidr = module.private_service_connect.private_service_connect_ip
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

/*****************************************
  Network
 *****************************************/

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id                             = var.project_id
  network_name                           = var.network_name
  delete_default_internet_gateway_routes = true

  routes = [
    {
      name              = "rt-${local.vpc_name}-1000-egress-internet-default"
      description       = "Tag based route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "tfc-runner-vm"
      next_hop_internet = "true"
      priority          = "1000"
    }
  ]

  subnets = [
    {
      description           = "Subnet for Terraform Cloud Runner"
      subnet_name           = var.subnet_name
      subnet_ip             = var.subnet_ip
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
  ]

  secondary_ranges = {
    (var.subnet_name) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = var.ip_range_pods_cidr
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = var.ip_range_services_cider
      }
    ]
  }

}

/*****************************************
  IAM Bindings GKE
 *****************************************/

resource "google_service_account" "tfc_agent_service_account" {
  count = var.create_service_account ? 1 : 0

  project                      = var.project_id
  account_id                   = "tfc-agent-gke"
  display_name                 = "Terraform Cloud agent GKE Service Account"
  create_ignore_already_exists = true
}

/*****************************************
  TFC agent GKE
 *****************************************/

module "tfc_agent_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster/"
  version = "~> 31.0"

  project_id         = var.project_id
  region             = var.region
  regional           = true
  zones              = var.zones
  network            = module.network.network_name
  name               = local.tfc_agent_name
  subnetwork         = module.network.subnets_names[0]
  service_account    = local.service_account_email
  network_project_id = var.network_project_id != "" ? var.network_project_id : var.project_id
  ip_range_pods      = var.ip_range_pods_name
  ip_range_services  = var.ip_range_services_name

  enable_vertical_pod_autoscaling = true
  enable_private_endpoint         = true
  enable_private_nodes            = true
  master_ipv4_cidr_block          = "172.16.0.0/28"

  master_authorized_networks = [
    {
      cidr_block   = "10.60.0.0/17"
      display_name = "VPC"
    },
  ]

  network_tags = ["tfc-runner-vm"]

  depends_on = [module.network]

}

/*****************************************
  K8S resources for configuring TFC agent
 *****************************************/

data "google_client_config" "default" {
}

resource "kubernetes_secret" "tfc_agent_secrets" {
  metadata {
    name = var.tfc_agent_k8s_secrets
  }
  data = {
    tfc_agent_address     = var.tfc_agent_address
    tfc_agent_token       = var.tfc_agent_token
    tfc_agent_single      = var.tfc_agent_single
    tfc_agent_auto_update = var.tfc_agent_auto_update
    tfc_agent_name        = local.tfc_agent_name
  }
}

# Deploy the agent
resource "kubernetes_deployment" "tfc_agent_deployment" {
  metadata {
    name = "${local.tfc_agent_name}-deployment"
    annotations = { "autopilot.gke.io/resource-adjustment" = jsonencode(
      {
        input = {
          containers = [
            {
              name = local.tfc_agent_name
              requests = {
                cpu               = var.tfc_agent_cpu_request
                memory            = var.tfc_agent_memory_request
                ephemeral-storage = var.tfc_agent_ephemeral_storage
              }
            },
          ]
        }
        modified = true
        output = {
          containers = [
            {
              limits = {
                cpu               = var.tfc_agent_cpu_request
                ephemeral-storage = var.tfc_agent_ephemeral_storage
                memory            = var.tfc_agent_memory_request
              }
              name = local.tfc_agent_name
              requests = {
                cpu               = var.tfc_agent_cpu_request
                ephemeral-storage = var.tfc_agent_ephemeral_storage
                memory            = var.tfc_agent_memory_request
              }
            },
          ]
        }
      }
      )
      "autopilot.gke.io/warden-version" = "2.7.41"
    }
  }

  spec {
    selector {
      match_labels = {
        app = local.tfc_agent_name
      }
    }

    replicas = var.tfc_agent_min_replicas

    template {
      metadata {
        labels = {
          app = local.tfc_agent_name
        }
      }

      spec {
        container {
          name  = local.tfc_agent_name
          image = var.tfc_agent_image

          env {
            name = "TFC_ADDRESS"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_address"
              }
            }
          }

          env {
            name = "TFC_AGENT_TOKEN"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_token"
              }
            }
          }

          env {
            name = "TFC_AGENT_NAME"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_name"
              }
            }
          }

          env {
            name = "TFC_AGENT_SINGLE"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_single"
              }
            }
          }

          env {
            name = "TFC_AGENT_AUTO_UPDATE"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_auto_update"
              }
            }
          }

          # https://developer.hashicorp.com/terraform/cloud-docs/agents/requirements
          resources {
            requests = {
              memory            = var.tfc_agent_memory_request
              cpu               = var.tfc_agent_cpu_request
              ephemeral-storage = var.tfc_agent_ephemeral_storage
            }
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }

        }

        security_context {
          run_as_non_root     = false
          supplemental_groups = []

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }

      }
    }
  }
}

resource "google_compute_router" "nat" {
  count = var.nat_enabled ? 1 : 0

  name    = "cr-${local.vpc_name}-${var.region}-nat-router"
  project = var.project_id
  region  = var.region
  network = module.network.network_self_link

  bgp {
    asn = var.nat_bgp_asn
  }
}

resource "google_compute_address" "nat_external_addresses" {
  count = var.nat_enabled ? var.nat_num_addresses : 0

  project = var.project_id
  name    = "ca-${local.vpc_name}-${var.region}-${count.index}"
  region  = var.region
}

resource "google_compute_router_nat" "egress" {
  count = var.nat_enabled ? 1 : 0

  name                               = "rn-${local.vpc_name}-${var.region}-egress"
  project                            = var.project_id
  router                             = google_compute_router.nat[0].name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_external_addresses.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}

resource "google_compute_firewall" "allow_private_api_egress" {
  name      = "fw-${local.vpc_name}-65430-e-a-allow-google-apis-all-tcp-443"
  network   = module.network.network_name
  project   = var.project_id
  direction = "EGRESS"
  priority  = 65430

  dynamic "log_config" {
    for_each = var.firewall_enable_logging == true ? [{
      metadata = "INCLUDE_ALL_METADATA"
    }] : []

    content {
      metadata = log_config.value.metadata
    }
  }

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = [local.private_googleapis_cidr]

  target_tags = ["tfc-runner-vm"]
}

module "private_service_connect" {
  source  = "terraform-google-modules/network/google//modules/private-service-connect"
  version = "~> 9.1"

  project_id                 = var.project_id
  dns_code                   = "dz-${local.vpc_name}"
  network_self_link          = module.network.network_self_link
  private_service_connect_ip = var.private_service_connect_ip
  forwarding_rule_target     = "all-apis"
}

resource "google_dns_policy" "default_policy" {
  project                   = var.project_id
  name                      = "dp-${local.vpc_name}-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = true

  networks {
    network_url = module.network.network_self_link
  }
}

module "hub" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/fleet-membership"
  version = "~> 31.0"

  project_id   = var.project_id
  location     = var.region
  cluster_name = module.tfc_agent_cluster.name
}

resource "google_project_service_identity" "container_engine_sa" {
  provider = google-beta

  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_service_account_iam_member" "container_engine_sa_impersonate_permissions" {
  service_account_id = local.service_account_id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_project_service_identity.container_engine_sa.email}"
}
