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

/*
 * Hub & Spoke Peering Transitivity with Gateway VMs
 */

module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 3.0"
  project_id = var.project_id
  names      = ["transitivity-gw"]
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
  ]
}

module "templates" {
  source         = "terraform-google-modules/vm/google//modules/instance_template"
  version        = "6.0.0"
  for_each       = toset(var.regions)
  can_ip_forward = true
  disk_size_gb   = 10
  name_prefix    = "transitivity-gw-${each.key}"
  network        = var.vpc_name
  project_id     = var.project_id
  region         = each.key
  service_account = {
    email  = module.service_account.emails["transitivity-gw"]
    scopes = ["cloud-platform"]
  }
  metadata = {
    user-data = templatefile("${path.module}/assets/gw.yaml", { commands = var.commands })
  }
  source_image       = "cos-stable-85-13310-1041-161"
  subnetwork         = var.gw_subnets[each.key]
  subnetwork_project = var.project_id
}

module "migs" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "6.0.0"
  for_each          = toset(var.regions)
  project_id        = var.project_id
  region            = each.key
  target_size       = 3
  hostname          = "transitivity-gw"
  instance_template = module.templates[each.key].self_link
  update_policy = [
    {
      max_surge_fixed              = 4
      max_surge_percent            = null
      instance_redistribution_type = "NONE"
      max_unavailable_fixed        = 4
      max_unavailable_percent      = null
      min_ready_sec                = 180
      minimal_action               = "RESTART"
      type                         = "OPPORTUNISTIC"
    }
  ]
}

module "ilbs" {
  source                  = "GoogleCloudPlatform/lb-internal/google"
  version                 = "~> 2.4.0"
  for_each                = toset(var.regions)
  region                  = each.key
  name                    = each.key
  ports                   = null
  all_ports               = true
  global_access           = true
  network                 = var.vpc_name
  subnetwork              = var.gw_subnets[each.key]
  source_ip_ranges        = flatten(values(var.regional_aggregates))
  target_service_accounts = [module.service_account.emails["transitivity-gw"]]
  source_tags             = null
  target_tags             = null
  create_backend_firewall = false
  backends = [
    { group = module.migs[each.key].instance_group, description = "" },
  ]

  health_check = {
    type                = "tcp"
    check_interval_sec  = 5
    healthy_threshold   = 4
    timeout_sec         = 1
    unhealthy_threshold = 5
    response            = null
    proxy_header        = "NONE"
    port                = 22
    port_name           = null
    request             = null
    request_path        = null
    host                = null
    enable_log          = var.health_check_enable_log
  }
  project = var.project_id
}

locals {
  routes = flatten([for region, ranges in var.regional_aggregates : [for range in ranges : { region = region, range = range }]])
}

resource "google_compute_route" "routes" {
  for_each = {
    for route in local.routes : replace("ilb-${route.region}-${route.range}", "/[./]/", "-") => route
  }
  project      = var.project_id
  network      = var.vpc_name
  name         = each.key
  description  = "Transitivity route for ${each.value.range} in ${each.value.region}"
  dest_range   = each.value.range
  next_hop_ilb = module.ilbs[each.value.region].forwarding_rule
}

resource "google_compute_firewall" "allow_transtivity_ingress" {
  name      = "fw-allow-transitivity-ingress"
  network   = var.vpc_name
  project   = var.project_id
  direction = "INGRESS"
  priority  = 1000

  dynamic "log_config" {
    for_each = var.firewall_enable_logging == true ? [{
      metadata = "INCLUDE_ALL_METADATA"
    }] : []

    content {
      metadata = log_config.value.metadata
    }
  }

  allow {
    protocol = "all"
  }

  source_ranges           = flatten(values(var.regional_aggregates))
  target_service_accounts = [module.service_account.emails["transitivity-gw"]]
}

resource "google_compute_firewall" "allow_transitivity_egress" {
  name      = "fw-allow-transitivity-egress"
  network   = var.vpc_name
  project   = var.project_id
  direction = "EGRESS"
  priority  = 1000

  dynamic "log_config" {
    for_each = var.firewall_enable_logging == true ? [{
      metadata = "INCLUDE_ALL_METADATA"
    }] : []

    content {
      metadata = log_config.value.metadata
    }
  }

  allow {
    protocol = "all"
  }

  destination_ranges      = flatten(values(var.regional_aggregates))
  target_service_accounts = [module.service_account.emails["transitivity-gw"]]
}
