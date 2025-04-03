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
  enable_transitivity = var.enable_hub_and_spoke_transitivity

  regional_aggregates = {
    (local.default_region1) = [
      "10.8.0.0/16",
      "100.72.0.0/16"
    ]
    (local.default_region2) = [
      "10.9.0.0/16",
      "100.73.0.0/16"
    ]
  }
}

/*
 * Network Transitivity
 */

module "network_transitivity" {
  source = "../../modules/transitivity"
  count  = local.enable_transitivity ? 1 : 0

  project_id          = local.net_hub_project_id
  regions             = keys(local.subnet_primary_ranges)
  vpc_name            = module.shared_vpc.network_name
  gw_subnets          = { for region in keys(local.subnet_primary_ranges) : region => "sb-c-svpc-hub-${region}" }
  regional_aggregates = local.regional_aggregates
  firewall_policy     = module.shared_vpc.firewall_policy
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
    "iptables -A FORWARD -s ${join(",", flatten(values(local.regional_aggregates)))} -d ${join(",", flatten(values(local.regional_aggregates)))} -j ACCEPT",
    # Drop everything else
    "iptables -A FORWARD -j DROP",
    # SNAT traffic not to the local eth0 interface
    "iptables -t nat -A POSTROUTING ! -d $(curl -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip) -j MASQUERADE",
  ]

  depends_on = [module.shared_vpc]
}
