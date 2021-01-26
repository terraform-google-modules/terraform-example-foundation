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

locals {
  enable_transitivity = var.enable_hub_and_spoke && var.enable_hub_and_spoke_transitivity
  # The topology below is a local summarization of the data spread over:
  #   * env/shared/net-hubs.tf
  #   * env/development/main.tf
  #   * env/non-production/main.tf and
  #   * env/production/main.tf
  # It is not (yet) a single source of truth.
  network_topology = {
    "shared" = {
      "base" = {
        "vpc-c-shared-base-hub" = {
          (var.default_region1) = {
            name             = "sb-c-shared-base-hub-${var.default_region1}"
            primary_range    = "172.16.1.0/24"
            secondary_ranges = []
          }
          (var.default_region2) = {
            name             = "sb-c-shared-base-hub-${var.default_region2}"
            primary_range    = "172.16.2.0/24"
            secondary_ranges = []
          }

        }
      }
      "restricted" = {
        "vpc-c-shared-restricted-hub" = {
          (var.default_region1) = {
            name             = "sb-c-shared-restricted-hub-${var.default_region1}"
            primary_range    = "172.16.3.0/24"
            secondary_ranges = []
          }
          (var.default_region2) = {
            name             = "sb-c-shared-restricted-hub-${var.default_region2}"
            primary_range    = "172.16.4.0/24"
            secondary_ranges = []
          }

        }
      }
    }
    "development" = {
      "base" = {
        "vpc-d-shared-base-spoke" = {
          (var.default_region1) = {
            name          = "sb-d-shared-base-${var.default_region1}"
            primary_range = "10.0.128.0/21"
            secondary_ranges = [
              {
                ip_cidr_range = "192.168.16.0/21"
                range_name    = "rn-d-shared-base-${var.default_region1}-gke-pod"
              },
              {
                ip_cidr_range = "192.168.24.0/21"
                range_name    = "rn-d-shared-base-${var.default_region1}-gke-svc"
              }
            ]
          }
          (var.default_region2) = {
            name             = "sb-d-shared-base-${var.default_region2}"
            primary_range    = "10.0.136.0/21"
            secondary_ranges = []
          }

        }
      }
      "restricted" = {
        "vpc-d-shared-restricted-spoke" = {
          (var.default_region1) = {
            name          = "sb-d-shared-restricted-${var.default_region1}"
            primary_range = "10.0.160.0/21"
            secondary_ranges = [
              {
                ip_cidr_range = "192.168.0.0/21"
                range_name    = "rn-d-shared-restricted-${var.default_region1}-gke-pod"
              },
              {
                ip_cidr_range = "192.168.8.0/21"
                range_name    = "rn-d-shared-restricted-${var.default_region1}-gke-svc"
              }

            ]
          }
          (var.default_region2) = {
            name             = "sb-d-shared-restricted-${var.default_region2}"
            primary_range    = "10.0.168.0/21"
            secondary_ranges = []
          }
        }
      }
    }
    "non-production" = {
      "base" = {
        "vpc-n-shared-base-spoke" = {
          (var.default_region1) = {
            name          = "sb-n-shared-base-${var.default_region1}"
            primary_range = "10.0.64.0/21"
            secondary_ranges = [
              {
                ip_cidr_range = "192.168.48.0/21"
                range_name    = "rn-n-shared-base-${var.default_region1}-gke-pod"
              },
              {
                ip_cidr_range = "192.168.56.0/21"
                range_name    = "rn-n-shared-base-${var.default_region1}-gke-svc"
              }
            ]
          }
          (var.default_region2) = {
            name             = "sb-n-shared-base-${var.default_region2}"
            primary_range    = "10.0.72.0/21"
            secondary_ranges = []
          }

        }
      }
      "restricted" = {
        "vpc-n-shared-restricted-spoke" = {
          (var.default_region1) = {
            name          = "sb-n-shared-restricted-${var.default_region1}"
            primary_range = "10.0.96.0/21"
            secondary_ranges = [
              {
                ip_cidr_range = "192.168.32.0/21"
                range_name    = "rn-n-shared-restricted-${var.default_region1}-gke-pod"
              },
              {
                ip_cidr_range = "192.168.40.0/21"
                range_name    = "rn-n-shared-restricted-${var.default_region1}-gke-svc"
              }

            ]
          }
          (var.default_region2) = {
            name             = "sb-n-shared-restricted-${var.default_region2}"
            primary_range    = "10.0.104.0/21"
            secondary_ranges = []
          }
        }
      }
    }
    "production" = {
      "base" = {
        "vpc-p-shared-base-spoke" = {
          (var.default_region1) = {
            name          = "sb-p-shared-base-${var.default_region1}"
            primary_range = "10.0.0.0/21"
            secondary_ranges = [
              {
                ip_cidr_range = "192.168.80.0/21"
                range_name    = "rn-p-shared-base-${var.default_region1}-gke-pod"
              },
              {
                ip_cidr_range = "192.168.88.0/21"
                range_name    = "rn-p-shared-base-${var.default_region1}-gke-svc"
              }
            ]
          }
          (var.default_region2) = {
            name             = "sb-p-shared-base-${var.default_region2}"
            primary_range    = "10.0.8.0/21"
            secondary_ranges = []
          }

        }
      }
      "restricted" = {
        "vpc-p-shared-restricted-spoke" = {
          (var.default_region1) = {
            name          = "sb-p-shared-restricted-${var.default_region1}"
            primary_range = "10.0.32.0/21"
            secondary_ranges = [
              {
                ip_cidr_range = "192.168.64.0/21"
                range_name    = "rn-p-shared-restricted-${var.default_region1}-gke-pod"
              },
              {
                ip_cidr_range = "192.168.72.0/21"
                range_name    = "rn-p-shared-restricted-${var.default_region1}-gke-svc"
              }

            ]
          }
          (var.default_region2) = {
            name             = "sb-p-shared-restricted-${var.default_region2}"
            primary_range    = "10.0.40.0/21"
            secondary_ranges = []
          }
        }
      }
    }
  }
  regional_aggregates = {
    (var.default_region1) = [

    ]
    (var.default_region2) = [

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
  regions             = keys(local.network_topology["shared"]["base"]["vpc-c-shared-base-hub"])
  vpc_name            = module.base_shared_vpc[0].network_name
  gw_subnets          = { for region, subnet in local.network_topology["shared"]["base"]["vpc-c-shared-base-hub"] : region => subnet.name }
  regional_aggregates = local.regional_aggregates
}