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
  peered_ip_range = var.private_worker_pool.enable_network_peering ? "${google_compute_global_address.worker_pool_range[0].address}/${google_compute_global_address.worker_pool_range[0].prefix_length}" : ""

  nat_proxy_vm_ip_range = "10.1.1.0/24"

  single_project_network = {
    subnet_name           = "eab-develop-us-central1"
    subnet_ip             = "10.1.20.0/24"
    subnet_region         = "us-central1"
    subnet_private_access = true
  }
  single_project_secondary = {
    "eab-develop-us-central1" = [
      {
        range_name    = "eab-develop-us-central1-secondary-01"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "eab-develop-us-central1-secondary-02"
        ip_cidr_range = "192.168.64.0/18"
      },
  ] }
}

module "peered_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"
  count   = var.private_worker_pool.create_peered_network ? 1 : 0

  project_id                             = var.project_id
  network_name                           = local.network_name
  delete_default_internet_gateway_routes = "true"

  subnets = [
    {
      subnet_name                      = "sb-b-cbpools-${var.private_worker_pool.region}"
      subnet_ip                        = var.private_worker_pool.peered_network_subnet_ip
      subnet_region                    = var.private_worker_pool.region
      subnet_private_access            = "true"
      subnet_flow_logs                 = "true"
      subnet_flow_logs_interval        = var.vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.vpc_flow_logs.filter_expr
      description                      = "Peered subnet for Cloud Build private pool"
    }
  ]

}

resource "google_dns_policy" "default_policy" {
  count = var.private_worker_pool.create_peered_network ? 1 : 0

  project                   = var.project_id
  name                      = "dp-b-cbpools-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = true
  networks {
    network_url = module.peered_network[0].network_self_link
  }
}

resource "google_compute_global_address" "worker_pool_range" {
  count = var.private_worker_pool.enable_network_peering ? 1 : 0

  name          = "ga-b-cbpools-worker-pool-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.private_worker_pool.peering_address
  prefix_length = var.private_worker_pool.peering_prefix_length
  network       = local.peered_network_id
}

resource "google_service_networking_connection" "worker_pool_conn" {
  count = var.private_worker_pool.enable_network_peering ? 1 : 0

  network                 = local.peered_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.worker_pool_range[0].name]
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  count = var.private_worker_pool.enable_network_peering ? 1 : 0

  project = var.project_id
  peering = google_service_networking_connection.worker_pool_conn[0].peering
  network = local.peered_network_name

  import_custom_routes = true
  export_custom_routes = true
}

module "firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/firewall-rules"
  version = "~> 10.0"
  count   = var.private_worker_pool.enable_network_peering ? 1 : 0

  project_id   = var.project_id
  network_name = local.peered_network_id

  rules = [
    {
      name                    = "fw-b-cbpools-100-i-a-all-all-all-service-networking"
      description             = "Allow ingress from the IPs configured for service networking"
      direction               = "INGRESS"
      priority                = 100
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null

      ranges = [local.peered_ip_range]

      allow = [{
        protocol = "all"
        ports    = null
      }]

      deny = []

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-pool-to-nat"
      description             = "Allow all from worker pool to NAT gateway"
      direction               = "INGRESS"
      priority                = 1000
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["nat-gateway"]
      target_service_accounts = null

      ranges = ["${google_compute_global_address.worker_pool_range[0].address}/${google_compute_global_address.worker_pool_range[0].prefix_length}"]

      allow = [{
        protocol = "all"
        ports    = null
      }]

      deny = []

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-icmp"
      description             = "Allow ICMP from anywhere"
      direction               = "INGRESS"
      priority                = 65534
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null

      ranges = ["0.0.0.0/1"]

      allow = [{
        protocol = "icmp"
        ports    = null
      }]

      deny = []

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-ssh-ingress"
      description             = "Allow SSH from anywhere (0.0.0.0/1)"
      direction               = "INGRESS"
      priority                = 1000
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null

      ranges = ["0.0.0.0/1"]

      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]

      deny = []

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}

resource "google_compute_address" "cloud_build_nat" {
  project      = var.project_id
  address_type = "EXTERNAL"
  name         = "cloud-build-nat"
  network_tier = "PREMIUM"
  region       = "us-central1"
}

resource "google_compute_instance" "vm-proxy" {
  project      = var.project_id
  name         = "cloud-build-nat-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["direct-gateway-access", "nat-gateway"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network            = local.peered_network_name
    subnetwork         = "sb-b-cbpools-${var.private_worker_pool.region}"
    subnetwork_project = var.project_id

  }

  can_ip_forward = true

  // This script configures the VM to do IP Forwarding
  metadata_startup_script = "sysctl -w net.ipv4.ip_forward=1 && iptables -t nat -A POSTROUTING -o $(ip addr show scope global | head -1 | awk -F: '{print $2}') -j MASQUERADE"

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [resource.google_compute_router_nat.cb-nat]
}

#  This route will route packets to the NAT VM
resource "google_compute_route" "through-nat" {
  name              = "through-nat-range1"
  project           = var.project_id
  dest_range        = "0.0.0.0/1"
  network           = local.peered_network_name
  next_hop_instance = google_compute_instance.vm-proxy.id
  priority          = 10
}

resource "google_compute_route" "through-nat2" {
  name              = "through-nat-range2"
  project           = var.project_id
  dest_range        = "128.0.0.0/1"
  network           = local.peered_network_name
  next_hop_instance = google_compute_instance.vm-proxy.id
  priority          = 10
}

# This route allow the NAT VM to reach the internet with it's external IP address

resource "google_compute_route" "direct-to-gateway" {
  name             = "direct-to-gateway-range1"
  project          = var.project_id
  dest_range       = "0.0.0.0/1"
  network          = local.peered_network_name
  next_hop_gateway = "default-internet-gateway"
  tags             = ["direct-gateway-access"]
  priority         = 5
}

resource "google_compute_route" "direct-to-gateway2" {
  name             = "direct-to-gateway-range2"
  project          = var.project_id
  dest_range       = "128.0.0.0/1"
  network          = local.peered_network_name
  next_hop_gateway = "default-internet-gateway"
  tags             = ["direct-gateway-access"]
  priority         = 5
}

# Cloud Router
resource "google_compute_router" "cb-router" {
  name    = "cb-cloud-router"
  network = local.peered_network_name
  region  = "us-central1"
  project = var.project_id
}

# Cloud NAT
resource "google_compute_router_nat" "cb-nat" {
  project                            = var.project_id
  name                               = "cb-cloud-nat"
  router                             = google_compute_router.cb-router.name
  region                             = google_compute_router.cb-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}
