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

locals {
  enable_transitivity = var.enable_hub_and_spoke && var.enable_hub_and_spoke_transitivity
  base_regional_aggregates = {
    (var.default_region1) = [
      "10.0.0.0/16",
      "100.64.0.0/16"
    ]
    (var.default_region2) = [
      "10.1.0.0/16",
      "100.65.0.0/16"
    ]
  }
  restricted_regional_aggregates = {
    (var.default_region1) = [
      "10.8.0.0/16",
      "100.72.0.0/16"
    ]
    (var.default_region2) = [
      "10.9.0.0/16",
      "100.73.0.0/16"
    ]
  }
}

/*
 * Base Network Transitivity
 */

module "base_transitivity" {
  count               = local.enable_transitivity ? 1 : 0
  source              = "../../modules/transitivity"
  project_id          = local.base_net_hub_project_id
  regions             = keys(local.base_subnet_primary_ranges)
  vpc_name            = module.base_shared_vpc[0].network_name
  gw_subnets          = { for region in keys(local.base_subnet_primary_ranges) : region => "sb-c-shared-base-hub-${region}" }
  regional_aggregates = local.base_regional_aggregates
  commands = [
    # Accept all ICMP (troubleshooting)
    "iptables -A INPUT -p icmp -j ACCEPT",
    # Accept SSH local traffic to the eth0 interface (health checking)
    "iptables -A INPUT -p tcp --dport 22 -d $(curl -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip) -j ACCEPT",
    # Drop everything else
    "iptables -A INPUT -j DROP",
    # Accept all return transit traffic for established flows
    "iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT",
    # Accept all transit traffic from internal ranges
    # Replace by actual multiple source/destination/proto/ports rules for fine-grained ACLs.
    "iptables -A FORWARD -s ${join(",", flatten(values(local.base_regional_aggregates)))} -d ${join(",", flatten(values(local.base_regional_aggregates)))} -j ACCEPT",
    # Drop everything else
    "iptables -A FORWARD -j DROP",
    # SNAT traffic not to the local eth0 interface
    "iptables -t nat -A POSTROUTING ! -d $(curl -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip) -j MASQUERADE",
  ]

  depends_on = [module.base_shared_vpc]
}

/*
 * Restricted Network Transitivity
 */

module "restricted_transitivity" {
  count               = local.enable_transitivity ? 1 : 0
  source              = "../../modules/transitivity"
  project_id          = local.restricted_net_hub_project_id
  regions             = keys(local.restricted_subnet_primary_ranges)
  vpc_name            = module.restricted_shared_vpc[0].network_name
  gw_subnets          = { for region in keys(local.restricted_subnet_primary_ranges) : region => "sb-c-shared-restricted-hub-${region}" }
  regional_aggregates = local.restricted_regional_aggregates
  commands = [
    # Accept all ICMP (troubleshooting)
    "iptables -A INPUT -p icmp -j ACCEPT",
    # Accept SSH local traffic to the eth0 interface (health checking)
    "iptables -A INPUT -p tcp --dport 22 -d $(curl -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip) -j ACCEPT",
    # Drop everything else
    "iptables -A INPUT -j DROP",
    # Accept all return transit traffic for established flows
    "iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT",
    # Accept all transit traffic from internal ranges
    # Replace by actual multiple source/destination/proto/ports rules for fine-grained ACLs.
    "iptables -A FORWARD -s ${join(",", flatten(values(local.restricted_regional_aggregates)))} -d ${join(",", flatten(values(local.restricted_regional_aggregates)))} -j ACCEPT",
    # Drop everything else
    "iptables -A FORWARD -j DROP",
    # SNAT traffic not to the local eth0 interface
    "iptables -t nat -A POSTROUTING ! -d $(curl -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip) -j MASQUERADE",
  ]

  depends_on = [module.restricted_shared_vpc]
}
