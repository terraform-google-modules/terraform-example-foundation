/*
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

module "instance_templates" {
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
  instance_template = module.instance_templates[each.key].self_link
  stateful_disks = [
    {
      device_name = "persistent-disk-0"
      delete_rule = "ON_PERMANENT_INSTANCE_DELETION"
    }
  ]
  update_policy = [
    {
      max_surge_fixed              = 3
      max_surge_percent            = null
      instance_redistribution_type = "NONE"
      max_unavailable_fixed        = 3
      max_unavailable_percent      = null
      min_ready_sec                = 180
      minimal_action               = "RESTART"
      type                         = "OPPORTUNISTIC"
    }
  ]
}

module "firewall" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc-firewall?ref=v4.3.0"
  project_id = var.project_id
  network    = var.vpc_name
  # we do not use tag based firewall rules
  ssh_source_ranges   = []
  http_source_ranges  = []
  https_source_ranges = []
  # we use custom rules instead
  custom_rules = {
    allow-ssh-hcs = {
      description = "Allow SSH to transitivity gateways"
      direction   = "INGRESS"
      action      = "allow"
      sources     = []
      ranges = [
        # IAP range, only needed for troubleshooting
        "35.235.240.0/20",
        # Health checkers range
        "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"
      ]
      targets              = [module.service_account.emails["transitivity-gw"]]
      use_service_accounts = true
      rules                = [{ protocol = "tcp", ports = [22] }]
      extra_attributes     = {}
    }
  }
}

module "ilb_addresses" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-address?ref=v4.3.0"
  project_id = var.project_id
  for_each   = toset(var.regions)
  internal_addresses = {
    "transitivity-gw" = {
      region     = each.key,
      subnetwork = var.gw_subnets[each.key]
    }
  }
}

module "ilbs" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules//net-ilb?ref=v4.3.0"
  for_each   = toset(var.regions)
  project_id = var.project_id
  region     = each.key
  name       = "ilb-${each.key}"
  network    = var.vpc_name
  subnetwork = var.gw_subnets[each.key]
  address    = module.ilb_addresses[each.key].internal_addresses["transitivity-gw"].address
  ports      = null
  backend_config = {
    session_affinity                = "CLIENT_IP"
    timeout_sec                     = null
    connection_draining_timeout_sec = null
  }
  backends = [{
    failover       = false
    group          = module.migs[each.key].instance_group
    balancing_mode = "CONNECTION"
    }
  ]
  health_check_config = {
    type = "tcp", check = { port = 22 }, config = {}, logging = true
  }
}
