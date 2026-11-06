/**
 * Copyright 2025 Google LLC
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
  iam_roles = [
    "roles/iam.serviceAccountUser",
    "roles/confidentialcomputing.workloadUser",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/storage.admin",
    "roles/logging.logWriter",
  ]
  ar_project_id = local.cicd_project_id != "" ? local.cicd_project_id : try(data.terraform_remote_state.business_unit_shared.outputs.artifact_registry_repository_id, "")
}

resource "google_service_account" "workload_sa" {
  count = var.enable_confidential_space ? 1 : 0

  account_id   = "confidential-space-workload-sa"
  display_name = "Workload Service Account for confidential space"
  project      = module.confidential_space_project[0].project_id
}

resource "google_project_iam_member" "workload_sa_roles" {
  for_each = toset(var.enable_confidential_space ? local.iam_roles : [])

  project = module.confidential_space_project[0].project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workload_sa[0].email}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
  count = var.enable_confidential_space && local.ar_project_id != "" ? 1 : 0

  project    = local.ar_project_id
  repository = "tf-runners"
  location   = local.default_region
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.workload_sa[0].email}"
}

module "confidential_space_project" {
  source = "../single_project"
  count  = var.enable_confidential_space ? 1 : 0

  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.env_business_unit.name
  environment              = var.env
  project_budget           = var.project_budget
  project_prefix           = local.project_prefix
  universe_prefix          = local.universe_prefix
  billing_budget_available = local.available_universe_services.billing_budget
  project_deletion_policy  = var.project_deletion_policy

  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  sa_roles = {
    "${var.business_code}-example-app" = [
      "roles/compute.instanceAdmin.v1",
      "roles/iam.serviceAccountUser",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.workloadIdentityPoolAdmin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/cloudkms.admin",
      "roles/storage.admin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/resourcemanager.tagUser",
    ]
  }

  activate_apis = [
    "accesscontextmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "compute.googleapis.com",
    "confidentialcomputing.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "dns.googleapis.com",
    "networkconnectivity.googleapis.com"
  ]
  vpc_service_control_attach_enabled = local.enforce_vpcsc ? "true" : "false"
  vpc_service_control_attach_dry_run = !local.enforce_vpcsc ? "true" : "false"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"

  # Metadata
  project_suffix    = "conf-space"
  application_name  = "${var.business_code}-sample-instance"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

module "confidential_space_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.2"
  count   = var.enable_confidential_space ? 1 : 0

  project_id                             = module.confidential_space_project[0].project_id
  network_name                           = "vpc-${local.env_code}-${var.business_code}-conf-space"
  shared_vpc_host                        = false
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name           = "sb-${local.env_code}-${var.business_code}-conf-space-${local.default_region}"
      subnet_ip             = var.confidential_space_subnet_ip_range
      subnet_region         = local.default_region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Dedicated subnetwork for Confidential Space workloads in ${local.default_region}."
    }
  ]
}

module "confidential_space_psc" {
  source  = "terraform-google-modules/network/google//modules/private-service-connect"
  version = "~> 18.2"
  count   = var.enable_confidential_space ? 1 : 0

  project_id                 = module.confidential_space_project[0].project_id
  dns_code                   = "dz-${local.env_code}-conf-space"
  network_self_link          = module.confidential_space_network[0].network_self_link
  private_service_connect_ip = var.confidential_space_private_service_connect_ip
  forwarding_rule_target     = local.enforce_vpcsc ? "vpc-sc" : "all-apis"
}

resource "google_dns_managed_zone" "pkg_dev" {
  count = var.enable_confidential_space ? 1 : 0

  project     = module.confidential_space_project[0].project_id
  name        = "pkg-dev-${local.env_code}-conf-space"
  dns_name    = "pkg.dev."
  description = "Private DNS zone for Artifact Registry (pkg.dev) routing to Private Service Connect"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.confidential_space_network[0].network_self_link
    }
  }
}

resource "google_dns_record_set" "pkg_dev_cname" {
  count = var.enable_confidential_space ? 1 : 0

  project      = module.confidential_space_project[0].project_id
  managed_zone = google_dns_managed_zone.pkg_dev[0].name
  name         = "*.pkg.dev."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["pkg.dev."]
}

resource "google_dns_record_set" "pkg_dev_a" {
  count = var.enable_confidential_space ? 1 : 0

  project      = module.confidential_space_project[0].project_id
  managed_zone = google_dns_managed_zone.pkg_dev[0].name
  name         = "pkg.dev."
  type         = "A"
  ttl          = 300
  rrdatas      = [var.confidential_space_private_service_connect_ip]
}

resource "google_dns_policy" "confidential_space_dns_policy" {
  count = var.enable_confidential_space ? 1 : 0

  project                   = module.confidential_space_project[0].project_id
  name                      = "dp-${local.env_code}-conf-space-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = true

  networks {
    network_url = module.confidential_space_network[0].network_self_link
  }
}

resource "google_tags_tag_key" "firewall_tag_key_conf_space" {
  count = var.enable_confidential_space ? 1 : 0

  short_name = "confidential-space"
  parent     = "projects/${module.confidential_space_project[0].project_id}"
  purpose    = "GCE_FIREWALL"

  purpose_data = {
    network = "${module.confidential_space_project[0].project_id}/${module.confidential_space_network[0].network_name}"
  }
}

resource "google_tags_tag_value" "firewall_tag_value_conf_space" {
  count = var.enable_confidential_space ? 1 : 0

  short_name = "workload"
  parent     = "tagKeys/${google_tags_tag_key.firewall_tag_key_conf_space[0].name}"
}

module "confidential_space_firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/network-firewall-policy"
  version = "~> 18.0"
  count   = var.enable_confidential_space ? 1 : 0

  project_id  = module.confidential_space_project[0].project_id
  policy_name = "fp-${local.env_code}-conf-space-firewalls"
  description = "Firewall rules for Confidential Space Network: ${module.confidential_space_network[0].network_name}."

  rules = [
    {
      priority       = "65530"
      direction      = "EGRESS"
      action         = "deny"
      rule_name      = "fw-${local.env_code}-conf-space-65530-e-d-all-all-tcp-udp"
      description    = "Lower priority rule to deny all egress traffic."
      enable_logging = var.firewall_enable_logging
      match = {
        dest_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = [
          {
            ip_protocol = "tcp"
          },
          {
            ip_protocol = "udp"
          },
        ]
      }
    },
    {
      priority       = "1000"
      direction      = "EGRESS"
      action         = "allow"
      rule_name      = "fw-${local.env_code}-conf-space-1000-e-a-allow-google-apis-all-tcp-443"
      description    = "Allow Google APIs on TCP port 443 via Private Service Connect."
      enable_logging = var.firewall_enable_logging
      match = {
        dest_ip_ranges = [var.confidential_space_private_service_connect_ip]
        layer4_configs = [
          {
            ip_protocol = "tcp"
            ports       = ["443"]
          },
        ]
      }
    },
    {
      priority           = "1001"
      direction          = "EGRESS"
      action             = "allow"
      rule_name          = "fw-${local.env_code}-conf-space-1001-e-a-allow-google-apis-all-tcp-80"
      description        = "Allow Google APIs and PKI AIA/CRL certificate validation on TCP port 80 via Private Service Connect."
      enable_logging     = var.firewall_enable_logging
      target_secure_tags = ["tagValues/${google_tags_tag_value.firewall_tag_value_conf_space[0].name}"]
      match = {
        dest_ip_ranges = [var.confidential_space_private_service_connect_ip]
        layer4_configs = [
          {
            ip_protocol = "tcp"
            ports       = ["80"]
          },
        ]
      }
    },
  ]

  depends_on = [
    google_tags_tag_value.firewall_tag_value_conf_space
  ]
}

resource "google_compute_network_firewall_policy_association" "confidential_space_vpc_association" {
  count = var.enable_confidential_space ? 1 : 0

  name              = "${module.confidential_space_firewall_rules[0].fw_policy[0].name}-${module.confidential_space_network[0].network_name}"
  attachment_target = module.confidential_space_network[0].network_id
  firewall_policy   = module.confidential_space_firewall_rules[0].fw_policy[0].id
  project           = module.confidential_space_project[0].project_id

  depends_on = [
    module.confidential_space_firewall_rules,
    module.confidential_space_network
  ]
}

resource "google_network_connectivity_spoke" "confidential_space_spoke" {
  count = var.enable_confidential_space && var.confidential_space_enable_ncc_spoke ? 1 : 0

  project     = module.confidential_space_project[0].project_id
  name        = "spk-${local.env_code}-conf-space"
  location    = "global"
  description = "NCC Spoke for Confidential Space standalone VPC"
  hub         = local.ncc_hub_uri
  group       = local.ncc_spoke_group

  linked_vpc_network {
    uri                   = module.confidential_space_network[0].network_id
    include_export_ranges = [var.confidential_space_private_service_connect_ip]
  }
}
