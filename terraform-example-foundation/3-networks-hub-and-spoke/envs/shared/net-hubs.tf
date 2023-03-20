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
  /*
   * Base network ranges
   */
  base_subnet_primary_ranges = {
    (local.default_region1) = "10.0.0.0/24"
    (local.default_region2) = "10.1.0.0/24"
  }
  /*
   * Restricted network ranges
   */
  restricted_subnet_primary_ranges = {
    (local.default_region1) = "10.8.0.0/24"
    (local.default_region2) = "10.9.0.0/24"
  }


  supported_restricted_service = [
    "accessapproval.googleapis.com",
    "adsdatahub.googleapis.com",
    "aiplatform.googleapis.com",
    "alloydb.googleapis.com",
    "alpha-documentai.googleapis.com",
    "analyticshub.googleapis.com",
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "artifactregistry.googleapis.com",
    "assuredworkloads.googleapis.com",
    "automl.googleapis.com",
    "baremetalsolution.googleapis.com",
    "batch.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigtable.googleapis.com",
    "binaryauthorization.googleapis.com",
    "cloud.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddebugger.googleapis.com",
    "clouddeploy.googleapis.com",
    "clouderrorreporting.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudprofiler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudsearch.googleapis.com",
    "cloudtrace.googleapis.com",
    "composer.googleapis.com",
    "compute.googleapis.com",
    "connectgateway.googleapis.com",
    "contactcenterinsights.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerfilesystem.googleapis.com",
    "containerregistry.googleapis.com",
    "containerthreatdetection.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "datafusion.googleapis.com",
    "datamigration.googleapis.com",
    "dataplex.googleapis.com",
    "dataproc.googleapis.com",
    "datastream.googleapis.com",
    "dialogflow.googleapis.com",
    "dlp.googleapis.com",
    "dns.googleapis.com",
    "documentai.googleapis.com",
    "domains.googleapis.com",
    "eventarc.googleapis.com",
    "file.googleapis.com",
    "firebaseappcheck.googleapis.com",
    "firebaserules.googleapis.com",
    "firestore.googleapis.com",
    "gameservices.googleapis.com",
    "gkebackup.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "healthcare.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "iaptunnel.googleapis.com",
    "ids.googleapis.com",
    "integrations.googleapis.com",
    "kmsinventory.googleapis.com",
    "krmapihosting.googleapis.com",
    "language.googleapis.com",
    "lifesciences.googleapis.com",
    "logging.googleapis.com",
    "managedidentities.googleapis.com",
    "memcache.googleapis.com",
    "meshca.googleapis.com",
    "meshconfig.googleapis.com",
    "metastore.googleapis.com",
    "ml.googleapis.com",
    "monitoring.googleapis.com",
    "networkconnectivity.googleapis.com",
    "networkmanagement.googleapis.com",
    "networksecurity.googleapis.com",
    "networkservices.googleapis.com",
    "notebooks.googleapis.com",
    "opsconfigmonitoring.googleapis.com",
    "orgpolicy.googleapis.com",
    "osconfig.googleapis.com",
    "oslogin.googleapis.com",
    "privateca.googleapis.com",
    "pubsub.googleapis.com",
    "pubsublite.googleapis.com",
    "recaptchaenterprise.googleapis.com",
    "recommender.googleapis.com",
    "redis.googleapis.com",
    "retail.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicedirectory.googleapis.com",
    "spanner.googleapis.com",
    "speakerid.googleapis.com",
    "speech.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "storagetransfer.googleapis.com",
    "sts.googleapis.com",
    "texttospeech.googleapis.com",
    "timeseriesinsights.googleapis.com",
    "tpu.googleapis.com",
    "trafficdirector.googleapis.com",
    "transcoder.googleapis.com",
    "translate.googleapis.com",
    "videointelligence.googleapis.com",
    "vision.googleapis.com",
    "visionai.googleapis.com",
    "vmmigration.googleapis.com",
    "vpcaccess.googleapis.com",
    "webrisk.googleapis.com",
    "workflows.googleapis.com",
    "workstations.googleapis.com",
  ]

  restricted_services = length(var.custom_restricted_services) != 0 ? var.custom_restricted_services : local.supported_restricted_service
}

/******************************************
  Base Network VPC
*****************************************/

module "base_shared_vpc" {
  source = "../../modules/base_shared_vpc"

  project_id                    = local.base_net_hub_project_id
  dns_hub_project_id            = local.dns_hub_project_id
  environment_code              = local.environment_code
  private_service_connect_ip    = "10.2.0.5"
  bgp_asn_subnet                = local.bgp_asn_number
  default_region1               = local.default_region1
  default_region2               = local.default_region2
  domain                        = var.domain
  dns_enable_inbound_forwarding = var.base_hub_dns_enable_inbound_forwarding
  dns_enable_logging            = var.base_hub_dns_enable_logging
  firewall_enable_logging       = var.base_hub_firewall_enable_logging
  nat_enabled                   = var.base_hub_nat_enabled
  nat_bgp_asn                   = var.base_hub_nat_bgp_asn
  nat_num_addresses_region1     = var.base_hub_nat_num_addresses_region1
  nat_num_addresses_region2     = var.base_hub_nat_num_addresses_region2
  windows_activation_enabled    = var.base_hub_windows_activation_enabled
  mode                          = "hub"

  subnets = [
    {
      subnet_name           = "sb-c-shared-base-hub-${local.default_region1}"
      subnet_ip             = local.base_subnet_primary_ranges[local.default_region1]
      subnet_region         = local.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Base network hub subnet for ${local.default_region1}"
    },
    {
      subnet_name           = "sb-c-shared-base-hub-${local.default_region2}"
      subnet_ip             = local.base_subnet_primary_ranges[local.default_region2]
      subnet_region         = local.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Base network hub subnet for ${local.default_region2}"
    }
  ]
  secondary_ranges = {}

  depends_on = [module.dns_hub_vpc]
}

/******************************************
  Restricted Network VPC
*****************************************/

module "restricted_shared_vpc" {
  source = "../../modules/restricted_shared_vpc"

  project_id                       = local.restricted_net_hub_project_id
  project_number                   = local.restricted_net_hub_project_number
  dns_hub_project_id               = local.dns_hub_project_id
  environment_code                 = local.environment_code
  private_service_connect_ip       = "10.10.0.5"
  access_context_manager_policy_id = var.access_context_manager_policy_id
  restricted_services              = local.restricted_services
  members = distinct(concat([
    "serviceAccount:${local.networks_service_account}",
    "serviceAccount:${local.projects_service_account}",
    "serviceAccount:${local.organization_service_account}",
  ], var.perimeter_additional_members))
  bgp_asn_subnet                = local.bgp_asn_number
  default_region1               = local.default_region1
  default_region2               = local.default_region2
  domain                        = var.domain
  dns_enable_inbound_forwarding = var.restricted_hub_dns_enable_inbound_forwarding
  dns_enable_logging            = var.restricted_hub_dns_enable_logging
  firewall_enable_logging       = var.restricted_hub_firewall_enable_logging
  nat_enabled                   = var.restricted_hub_nat_enabled
  nat_bgp_asn                   = var.restricted_hub_nat_bgp_asn
  nat_num_addresses_region1     = var.restricted_hub_nat_num_addresses_region1
  nat_num_addresses_region2     = var.restricted_hub_nat_num_addresses_region2
  windows_activation_enabled    = var.restricted_hub_windows_activation_enabled
  mode                          = "hub"

  subnets = [
    {
      subnet_name           = "sb-c-shared-restricted-hub-${local.default_region1}"
      subnet_ip             = local.restricted_subnet_primary_ranges[local.default_region1]
      subnet_region         = local.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Restricted network hub subnet for ${local.default_region1}"
    },
    {
      subnet_name           = "sb-c-shared-restricted-hub-${local.default_region2}"
      subnet_ip             = local.restricted_subnet_primary_ranges[local.default_region2]
      subnet_region         = local.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = var.subnetworks_enable_logging
      description           = "Restricted network hub subnet for ${local.default_region2}"
    }
  ]
  secondary_ranges = {}

  egress_policies = distinct(concat(
    local.dedicated_interconnect_egress_policy,
    var.egress_policies
  ))

  ingress_policies = var.ingress_policies

  depends_on = [module.dns_hub_vpc]
}
