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
  dedicated_interconnect_egress_policy = var.enable_dedicated_interconnect ? [
    {
      "from" = {
        "identity_type" = ""
        "identities"    = ["serviceAccount:${local.networks_service_account}"]
      },
      "to" = {
        "resources" = ["projects/${local.interconnect_project_number}"]
        "operations" = {
          "compute.googleapis.com" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ] : []

  bgp_asn_number = var.enable_partner_interconnect ? "16550" : "64514"

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

  restricted_services         = length(var.custom_restricted_services) != 0 ? var.custom_restricted_services : local.supported_restricted_service
  restricted_services_dry_run = length(var.custom_restricted_services_dry_run) != 0 ? var.custom_restricted_services : local.supported_restricted_service
}

/******************************************
 Restricted shared VPC
*****************************************/
module "restricted_shared_vpc" {
  source = "../restricted_shared_vpc"

  project_id                       = local.restricted_project_id
  dns_hub_project_id               = local.dns_hub_project_id
  project_number                   = local.restricted_project_number
  environment_code                 = var.environment_code
  access_context_manager_policy_id = var.access_context_manager_policy_id
  restricted_services              = local.restricted_services
  restricted_services_dry_run      = local.restricted_services_dry_run
  members = distinct(concat([
    "serviceAccount:${local.networks_service_account}",
    "serviceAccount:${local.projects_service_account}",
    "serviceAccount:${local.organization_service_account}",
  ], var.perimeter_additional_members))
  members_dry_run = distinct(concat([
    "serviceAccount:${local.networks_service_account}",
    "serviceAccount:${local.projects_service_account}",
    "serviceAccount:${local.organization_service_account}",
  ], var.perimeter_additional_members))
  private_service_cidr       = var.restricted_private_service_cidr
  private_service_connect_ip = var.restricted_private_service_connect_ip
  bgp_asn_subnet             = local.bgp_asn_number
  default_region1            = var.default_region1
  default_region2            = var.default_region2
  domain                     = var.domain
  ingress_policies           = var.ingress_policies
  ingress_policies_dry_run   = var.ingress_policies_dry_run
  egress_policies = distinct(concat(
    local.dedicated_interconnect_egress_policy,
    var.egress_policies
  ))
  egress_policies_dry_run = distinct(concat(
    local.dedicated_interconnect_egress_policy,
    var.egress_policies_dry_run
  ))


  subnets = [
    {
      subnet_name                      = "sb-${var.environment_code}-shared-restricted-${var.default_region1}"
      subnet_ip                        = var.restricted_subnet_primary_ranges[var.default_region1]
      subnet_region                    = var.default_region1
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.restricted_vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.restricted_vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.restricted_vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.restricted_vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.restricted_vpc_flow_logs.filter_expr
      description                      = "First ${var.env} subnet example."
    },
    {
      subnet_name                      = "sb-${var.environment_code}-shared-restricted-${var.default_region2}"
      subnet_ip                        = var.restricted_subnet_primary_ranges[var.default_region2]
      subnet_region                    = var.default_region2
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.restricted_vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.restricted_vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.restricted_vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.restricted_vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.restricted_vpc_flow_logs.filter_expr
      description                      = "Second ${var.env} subnet example."
    },
    {
      subnet_name      = "sb-${var.environment_code}-shared-restricted-${var.default_region1}-proxy"
      subnet_ip        = var.restricted_subnet_proxy_ranges[var.default_region1]
      subnet_region    = var.default_region1
      subnet_flow_logs = false
      description      = "First ${var.env} proxy-only subnet example."
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    },
    {
      subnet_name      = "sb-${var.environment_code}-shared-restricted-${var.default_region2}-proxy"
      subnet_ip        = var.restricted_subnet_proxy_ranges[var.default_region2]
      subnet_region    = var.default_region2
      subnet_flow_logs = false
      description      = "Second ${var.env} proxy-only subnet example."
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    }
  ]
  secondary_ranges = {
    "sb-${var.environment_code}-shared-restricted-${var.default_region1}" = var.restricted_subnet_secondary_ranges[var.default_region1]
  }
}

/******************************************
 Base shared VPC
*****************************************/

module "base_shared_vpc" {
  source = "../base_shared_vpc"

  project_id                 = local.base_project_id
  dns_hub_project_id         = local.dns_hub_project_id
  environment_code           = var.environment_code
  private_service_cidr       = var.base_private_service_cidr
  private_service_connect_ip = var.base_private_service_connect_ip
  default_region1            = var.default_region1
  default_region2            = var.default_region2
  domain                     = var.domain
  bgp_asn_subnet             = local.bgp_asn_number

  subnets = [
    {
      subnet_name                      = "sb-${var.environment_code}-shared-base-${var.default_region1}"
      subnet_ip                        = var.base_subnet_primary_ranges[var.default_region1]
      subnet_region                    = var.default_region1
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.base_vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.base_vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.base_vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.base_vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.base_vpc_flow_logs.filter_expr
      description                      = "First ${var.env} subnet example."
    },
    {
      subnet_name                      = "sb-${var.environment_code}-shared-base-${var.default_region2}"
      subnet_ip                        = var.base_subnet_primary_ranges[var.default_region2]
      subnet_region                    = var.default_region2
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.base_vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.base_vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.base_vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.base_vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.base_vpc_flow_logs.filter_expr
      description                      = "Second ${var.env} subnet example."
    },
    {
      subnet_name      = "sb-${var.environment_code}-shared-base-${var.default_region1}-proxy"
      subnet_ip        = var.base_subnet_proxy_ranges[var.default_region1]
      subnet_region    = var.default_region1
      subnet_flow_logs = false
      description      = "First ${var.env} proxy-only subnet example."
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    },
    {
      subnet_name      = "sb-${var.environment_code}-shared-base-${var.default_region2}-proxy"
      subnet_ip        = var.base_subnet_proxy_ranges[var.default_region2]
      subnet_region    = var.default_region2
      subnet_flow_logs = false
      description      = "Second ${var.env} proxy-only subnet example."
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    }
  ]

  secondary_ranges = {
    "sb-${var.environment_code}-shared-base-${var.default_region1}" = var.base_subnet_secondary_ranges[var.default_region1]
  }
}
