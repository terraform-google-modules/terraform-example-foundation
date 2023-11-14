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

locals {
  env_code = substr(var.env, 0, 1)
}

data "google_netblock_ip_ranges" "legacy_health_checkers" {
  range_type = "legacy-health-checkers"
}

data "google_netblock_ip_ranges" "health_checkers" {
  range_type = "health-checkers"
}

data "google_netblock_ip_ranges" "iap_forwarders" {
  range_type = "iap-forwarders"
}

module "peering_project" {
  source = "../single_project"

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.env_folder_name
  environment     = var.env
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix

  // Enabling Cloud Build Deploy to use Service Accounts during the build and give permissions to the SA.
  // The permissions will be the ones necessary for the deployment of the step 5-app-infra
  enable_cloudbuild_deploy = local.enable_cloudbuild_deploy

  // A map of Service Accounts to use on the infra pipeline (Cloud Build)
  // Where the key is the repository name ("${var.business_code}-example-app")
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  // Map for the roles where the key is the repository name ("${var.business_code}-example-app")
  // and the value is the list of roles that this SA need to deploy step 5-app-infra
  sa_roles = {
    "${var.business_code}-example-app" = [
      "roles/compute.instanceAdmin.v1",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
      "roles/resourcemanager.tagUser",
    ]
  }

  activate_apis = [
    "dns.googleapis.com"
  ]

  # Metadata
  project_suffix    = "sample-peering"
  application_name  = "${var.business_code}-sample-peering"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

module "peering_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id                             = module.peering_project.project_id
  network_name                           = "vpc-${local.env_code}-peering-base"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "true"

  subnets = [
    {
      subnet_name           = "sb-${local.env_code}-${var.business_code}-peered-${var.subnet_region}"
      subnet_ip             = var.subnet_ip_range
      subnet_region         = var.subnet_region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Peered subnetwork on region ${var.subnet_region}."
    }
  ]
}

resource "google_dns_policy" "default_policy" {
  project                   = module.peering_project.project_id
  name                      = "dp-${local.env_code}-peering-base-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = true
  networks {
    network_url = module.peering_network.network_self_link
  }
}

module "peering" {
  source  = "terraform-google-modules/network/google//modules/network-peering"
  version = "~> 7.0"

  prefix            = "${var.business_code}-${local.env_code}"
  local_network     = module.peering_network.network_self_link
  peer_network      = local.base_network_self_link
  module_depends_on = var.peering_module_depends_on
}

/******************************************
  Mandatory firewall rules
 *****************************************/

resource "google_compute_firewall" "deny_all_egress" {
  name      = "fw-${local.env_code}-peering-base-65530-e-d-all-all-tcp-udp"
  network   = module.peering_network.network_name
  project   = module.peering_project.project_id
  direction = "EGRESS"
  priority  = 65530

  dynamic "log_config" {
    for_each = var.firewall_enable_logging == true ? [{
      metadata = "INCLUDE_ALL_METADATA"
    }] : []

    content {
      metadata = log_config.value.metadata
    }
  }

  deny {
    protocol = "tcp"
  }

  deny {
    protocol = "udp"
  }

  destination_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "allow_private_api_egress" {
  name      = "fw-${local.env_code}-peering-base-65430-e-a-allow-google-apis-all-tcp-443"
  network   = module.peering_network.network_name
  project   = module.peering_project.project_id
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

  destination_ranges = ["199.36.153.8/30"]

  target_tags = ["allow-google-apis"]
}


/******************************************
  Optional firewall rules
 *****************************************/

// Allow access to kms.windows.googlecloud.com for Windows license activation
resource "google_compute_firewall" "allow_windows_activation" {
  count     = var.windows_activation_enabled ? 1 : 0
  name      = "fw-${local.env_code}-peering-base-0-e-a-allow-win-activation-all-tcp-1688"
  network   = module.peering_network.network_name
  project   = module.peering_project.project_id
  direction = "EGRESS"
  priority  = 0

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
    ports    = ["1688"]
  }

  destination_ranges = ["35.190.247.13/32"]

  target_tags = ["allow-win-activation"]
}

// Allow traffic for Internal & Global load balancing health check and load balancing IP ranges.
resource "google_compute_firewall" "allow_lb" {
  count   = var.optional_fw_rules_enabled ? 1 : 0
  name    = "fw-${local.env_code}-peering-base-1000-i-a-all-allow-lb-tcp-80-8080-443"
  network = module.peering_network.network_name
  project = module.peering_project.project_id

  dynamic "log_config" {
    for_each = var.firewall_enable_logging == true ? [{
      metadata = "INCLUDE_ALL_METADATA"
    }] : []

    content {
      metadata = log_config.value.metadata
    }
  }

  source_ranges = concat(data.google_netblock_ip_ranges.health_checkers.cidr_blocks_ipv4, data.google_netblock_ip_ranges.legacy_health_checkers.cidr_blocks_ipv4)

  // Allow common app ports by default.
  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  target_tags = ["allow-lb"]
}

// Allow SSH and RDP via IAP when using the Firewall Secure Tags.
module "allow_iap_ssh_rdp" {
  source  = "terraform-google-modules/network/google//modules/network-firewall-policy"
  version = "~> 8.0"

  project_id  = module.peering_project.project_id
  policy_name = "fp-${local.env_code}-allow-iap-policy"

  rules = [
    {
      // Allow SSH via IAP when using the ssh-iap-access/allow resource manager tag for Linux workloads.
      rule_name          = "fw-${local.env_code}-peering-base-1000-i-a-all-allow-iap-ssh-tcp-22"
      action             = "allow"
      direction          = "INGRESS"
      priority           = "1000"
      enable_logging     = true
      target_secure_tags = ["tagValues/${google_tags_tag_value.firewall_tag_value_ssh[0].name}"]
      match = {
        src_ip_ranges = data.google_netblock_ip_ranges.iap_forwarders.cidr_blocks_ipv4
        layer4_configs = [
          {
            ip_protocol = "tcp"
            ports       = ["22"]
          },
        ]
      }
    },
    {
      // Allow RDP via IAP when using the rdp-iap-access/allow resource manager tag for Windows workloads.
      rule_name          = "fw-${local.env_code}-peering-base-1001-i-a-all-allow-iap-rdp-tcp-3389"
      action             = "allow"
      direction          = "INGRESS"
      priority           = "1001"
      enable_logging     = true
      target_secure_tags = ["tagValues/${google_tags_tag_value.firewall_tag_value_rdp[0].name}"]
      match = {
        src_ip_ranges = data.google_netblock_ip_ranges.iap_forwarders.cidr_blocks_ipv4
        layer4_configs = [
          {
            ip_protocol = "tcp"
            ports       = ["3389"]
          },
        ]
      }
    }
  ]

  depends_on = [
    google_tags_tag_value.firewall_tag_value_ssh,
    google_tags_tag_value.firewall_tag_value_rdp
  ]
}

resource "google_compute_network_firewall_policy_association" "vpc_associations" {
  name              = "fpa-${local.env_code}-allow-iap-ssh-rdp"
  attachment_target = module.peering_network.network_id
  firewall_policy   = module.allow_iap_ssh_rdp.fw_policy[0].id
  project           = module.peering_project.project_id

  depends_on = [
    module.allow_iap_ssh_rdp,
    module.peering_network
  ]
}

resource "google_tags_tag_key" "firewall_tag_key_ssh" {
  count = var.peering_iap_fw_rules_enabled ? 1 : 0

  short_name = "ssh-iap-access"
  parent     = "projects/${module.peering_project.project_id}"
  purpose    = "GCE_FIREWALL"

  purpose_data = {
    network = "${module.peering_project.project_id}/${module.peering_network.network_name}"
  }
}

resource "google_tags_tag_value" "firewall_tag_value_ssh" {
  count = var.peering_iap_fw_rules_enabled ? 1 : 0

  short_name = "allow"
  parent     = "tagKeys/${google_tags_tag_key.firewall_tag_key_ssh[0].name}"
}

resource "google_tags_tag_key" "firewall_tag_key_rdp" {
  count = var.peering_iap_fw_rules_enabled ? 1 : 0

  short_name = "rdp-iap-access"
  parent     = "projects/${module.peering_project.project_id}"
  purpose    = "GCE_FIREWALL"

  purpose_data = {
    network = "${module.peering_project.project_id}/${module.peering_network.network_name}"
  }
}

resource "google_tags_tag_value" "firewall_tag_value_rdp" {
  count = var.peering_iap_fw_rules_enabled ? 1 : 0

  short_name = "allow"
  parent     = "tagKeys/${google_tags_tag_key.firewall_tag_key_rdp[0].name}"
}
