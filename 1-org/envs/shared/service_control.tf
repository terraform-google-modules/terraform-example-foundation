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

/******************************************
 Shared VPC
*****************************************/

locals {
  supported_restricted_service = [
    "serviceusage.googleapis.com",
    "essentialcontacts.googleapis.com",
    "accessapproval.googleapis.com",
    "adsdatahub.googleapis.com",
    "aiplatform.googleapis.com",
    "alloydb.googleapis.com",
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
    "confidentialcomputing.googleapis.com",
  ]

  restricted_services         = length(var.custom_restricted_services) != 0 ? var.custom_restricted_services : local.supported_restricted_service
  restricted_services_dry_run = length(var.custom_restricted_services_dry_run) != 0 ? var.custom_restricted_services : local.supported_restricted_service

  access_level_name         = module.service_control.access_level_name
  access_level_dry_run_name = module.service_control.access_level_name_dry_run

  shared_vpc_projects_numbers = [
    for v in values({
      for k, m in module.environment_network :
      k => m.shared_vpc_project_number
    }) : tostring(v)
  ]

  projects = var.enable_hub_and_spoke ? (concat([
    local.seed_project_number,
    module.org_audit_logs.project_number,
    module.org_billing_export.project_number,
    module.common_kms.project_number,
    module.org_secrets.project_number,
    module.interconnect.project_number,
    module.network_hub[0].project_number,
    module.scc_notifications.project_number,
    ], local.shared_vpc_projects_numbers)) : (concat([
    local.seed_project_number,
    module.org_audit_logs.project_number,
    module.org_billing_export.project_number,
    module.common_kms.project_number,
    module.org_secrets.project_number,
    module.interconnect.project_number,
    module.scc_notifications.project_number,
  ], local.shared_vpc_projects_numbers))

  projects_dry_run = var.enable_hub_and_spoke ? (concat([
    local.seed_project_number,
    module.org_audit_logs.project_number,
    module.org_billing_export.project_number,
    module.common_kms.project_number,
    module.org_secrets.project_number,
    module.interconnect.project_number,
    module.network_hub[0].project_number,
    module.scc_notifications.project_number,
    ], local.shared_vpc_projects_numbers)) : (concat([
    local.seed_project_number,
    module.org_audit_logs.project_number,
    module.org_billing_export.project_number,
    module.common_kms.project_number,
    module.org_secrets.project_number,
    module.interconnect.project_number,
    module.scc_notifications.project_number,
  ], local.shared_vpc_projects_numbers))

  project_keys = var.enable_hub_and_spoke ? [
    "prj-b-seed",
    "prj-org-audit",
    "prj-org-billing",
    "prj-org-kms",
    "prj-org-secrets",
    "prj-org-interconnect",
    "prj-org-scc",
    "prj-net-hub-svpc",
    "prj-net-p-svpc",
    "prj-net-d-svpc",
    "prj-net-n-svpc",
    ] : [
    "prj-b-seed",
    "prj-org-audit",
    "prj-org-billing",
    "prj-org-kms",
    "prj-org-secrets",
    "prj-org-interconnect",
    "prj-org-scc",
    "prj-net-p-svpc",
    "prj-net-d-svpc",
    "prj-net-n-svpc",
  ]

  project_keys_dry_run = var.enable_hub_and_spoke ? [
    "prj-b-seed",
    "prj-org-audit",
    "prj-org-billing",
    "prj-org-kms",
    "prj-org-secrets",
    "prj-org-interconnect",
    "prj-org-scc",
    "prj-net-hub-svpc",
    "prj-net-p-svpc",
    "prj-net-d-svpc",
    "prj-net-n-svpc",
    ] : [
    "prj-b-seed",
    "prj-org-audit",
    "prj-org-billing",
    "prj-org-kms",
    "prj-org-secrets",
    "prj-org-interconnect",
    "prj-org-scc",
    "prj-net-p-svpc",
    "prj-net-d-svpc",
    "prj-net-n-svpc",
  ]

  projects_map = zipmap(
    local.project_keys,
    [for p in local.projects : "${p}"]
  )

  projects_map_dry_run = zipmap(
    local.project_keys_dry_run,
    [for p in local.projects_dry_run : "${p}"]
  )

  base_ingress_keys = [
    "billing_sa_to_prj",
    "sinks_sa_to_logs",
    "service_cicd_to_seed",
    "cicd_to_seed",
  ]

  app_infra_ingress_keys_dry_run = [
    "cicd_to_app_infra",
    "cicd_to_seed_app_infra",
    "cicd_to_net_env",
  ]

  scc_ingress_key_dry_run = "cai_monitoring_to_scc"

  app_infra_ingress_keys = [
    "cicd_to_app_infra",
    "cicd_to_seed_app_infra",
    "cicd_to_net_env",
  ]

  scc_ingress_key = "cai_monitoring_to_scc"

  ingress_policies_keys_dry_run = concat(
    local.base_ingress_keys,
    var.required_ingress_rules_app_infra_dry_run ? local.app_infra_ingress_keys_dry_run : [],
    var.enable_scc_resources_in_terraform ? [local.scc_ingress_key_dry_run] : [],
    var.ingress_policies_keys_dry_run
  )

  ingress_policies_keys = concat(
    local.base_ingress_keys,
    var.required_ingress_rules_app_infra ? local.app_infra_ingress_keys : [],
    var.enable_scc_resources_in_terraform ? [local.scc_ingress_key] : [],
    var.ingress_policies_keys
  )

  egress_policies_keys_dry_run = var.required_egress_rules_app_infra_dry_run ? concat(["seed_to_cicd", "org_sa_to_scc", "app_infra_to_cicd"], var.egress_policies_keys_dry_run) : concat(["seed_to_cicd", "org_sa_to_scc"], var.egress_policies_keys_dry_run)
  egress_policies_keys         = var.required_egress_rules_app_infra ? concat(["seed_to_cicd", "org_sa_to_scc", "app_infra_to_cicd"], var.egress_policies_keys) : concat(["seed_to_cicd", "org_sa_to_scc"], var.egress_policies_keys)
  app_infra_targets_sorted     = sort(local.app_infra_targets)
  app_infra_to_resources       = local.app_infra_project_number != null ? ["projects/${local.app_infra_project_number}"] : []

  required_egress_rules_dry_run = [
    {
      title = "ER seed -> cicd"
      from = {
        identities = [
          "serviceAccount:${local.cloudbuild_project_number}@cloudbuild.gserviceaccount.com",
        ]
        sources = {
          resources = [
            "projects/${local.seed_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.cloudbuild_project_number}"
        ]
        operations = {
          "cloudbuild.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "ER seed -> scc"
      from = {
        identities = [
          "serviceAccount:${local.organization_service_account}",
        ]
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${module.scc_notifications.project_number}"
        ]
        operations = {
          "cloudasset.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_egress_rules_app_infra_dry_run = [
    {
      title = "ER app infra -> cicd"
      from = {
        identities = compact([local.app_infra_pipeline_identity])
        sources = {
          resources = local.app_infra_pipeline_source_projects
        }
      }
      to = {
        resources = [
          "projects/${local.cloudbuild_project_number}"
        ]
        operations = {
          "cloudbuild.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_ingress_rules_dry_run = [
    {
      title = "IR billing"
      from = {
        identities = [
          "serviceAccount:billing-export-bigquery@system.gserviceaccount.com",
        ]
        sources = {
          access_levels = ["*"]
        }
      }
      to = {
        resources = [
          "projects/${module.org_billing_export.project_number}"
        ]
        operations = {
          "logging.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR sinks"
      from = {
        identities = [
          "serviceAccount:service-${local.parent_id}@gcp-sa-logging.iam.gserviceaccount.com",
          "serviceAccount:service-b-${local.billing_account}@gcp-sa-logging.iam.gserviceaccount.com",
        ]
        sources = {
          access_levels = ["*"]
        }
      }
      to = {
        resources = [
          "projects/${module.org_audit_logs.project_number}"
        ]
        operations = {
          "logging.googleapis.com" = {
            methods = ["*"]
          }
          "pubsub.googleapis.com" = {
            methods = ["*"]
          }
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR service cicd -> seed"
      from = {
        identities = [
          "serviceAccount:service-${local.cloudbuild_project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com",
        ]
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.seed_project_number}"
        ]
        operations = {
          "iam.googleapis.com" = {
            methods = ["*"]
          }
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR cicd -> seed"
      from = {
        identities = [
          "serviceAccount:${local.cloudbuild_project_number}@cloudbuild.gserviceaccount.com",
        ]
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.seed_project_number}"
        ]
        operations = {
          "cloudbuild.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_ingress_rule_scc_dry_run = [
    {
      title = "CAI -> SCC"
      from = {
        identities = [
          try("serviceAccount:${google_service_account.cai_monitoring_builder[0].email}", null)
        ]
        sources = {
          access_levels = ["*"]
        }
      }
      to = {
        resources = [
          "projects/${module.scc_notifications.project_number}"
        ]
        operations = {
          "logging.googleapis.com" = {
            methods = ["*"]
          }
          "artifactregistry.googleapis.com" = {
            methods = ["*"]
          }
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_ingress_rules_app_infra_dry_run = [
    {
      title = "IR cicd -> app infra"
      from = {
        identities = compact([local.app_infra_cicd_identity])
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = local.app_infra_to_resources
        operations = {
          "storage.googleapis.com" = {
            methods = ["*"]
          }
          "logging.googleapis.com" = {
            methods = ["*"]
          }
          "iamcredentials.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR app infra -> seed"
      from = {
        identities = compact([local.app_infra_cicd_identity])
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.seed_project_number}"
        ]
        operations = {
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR app infra -> prjs"
      from = {
        identities = compact([local.app_infra_cicd_identity])
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = local.app_infra_targets_sorted
        operations = {
          "iam.googleapis.com" = {
            methods = ["*"]
          }
          "compute.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_ingress_rules = [
    {
      title = "IR billing"
      from = {
        identities = [
          "serviceAccount:billing-export-bigquery@system.gserviceaccount.com",
        ]
        sources = {
          access_levels = ["*"]
        }
      }
      to = {
        resources = [
          "projects/${module.org_billing_export.project_number}"
        ]
        operations = {
          "logging.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR sinks"
      from = {
        identities = [
          "serviceAccount:service-${local.parent_id}@gcp-sa-logging.iam.gserviceaccount.com",
          "serviceAccount:service-b-${local.billing_account}@gcp-sa-logging.iam.gserviceaccount.com",
        ]
        sources = {
          access_levels = ["*"]
        }
      }
      to = {
        resources = [
          "projects/${module.org_audit_logs.project_number}"
        ]
        operations = {
          "logging.googleapis.com" = {
            methods = ["*"]
          }
          "pubsub.googleapis.com" = {
            methods = ["*"]
          }
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR service cicd -> seed"
      from = {
        identities = [
          "serviceAccount:service-${local.cloudbuild_project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com",
        ]
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.seed_project_number}"
        ]
        operations = {
          "iam.googleapis.com" = {
            methods = ["*"]
          }
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR cicd -> seed"
      from = {
        identities = [
          "serviceAccount:${local.cloudbuild_project_number}@cloudbuild.gserviceaccount.com"
        ]
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.seed_project_number}"
        ]
        operations = {
          "cloudbuild.googleapis.com" = { methods = ["*"] }
        }
      }
    },
  ]

  required_ingress_rule_scc = [
    {
      title = "CAI -> SCC"
      from = {
        identities = [
          try("serviceAccount:${google_service_account.cai_monitoring_builder[0].email}", null)
        ]
        sources = { access_levels = ["*"] }
      }
      to = {
        resources = [
          "projects/${module.scc_notifications.project_number}"
        ]
        operations = {
          "logging.googleapis.com" = {
            methods = ["*"]
          }
          "artifactregistry.googleapis.com" = {
            methods = ["*"]
          }
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_ingress_rules_app_infra = [
    {
      title = "IR cicd -> app infra"
      from = {
        identities = compact([local.app_infra_cicd_identity])
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = local.app_infra_to_resources
        operations = {
          "storage.googleapis.com" = {
            methods = ["*"]
          }
          "logging.googleapis.com" = {
            methods = ["*"]
          }
          "iamcredentials.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR app infra -> seed"
      from = {
        identities = compact([local.app_infra_cicd_identity])
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.seed_project_number}"
        ]
        operations = {
          "storage.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "IR app infra -> prjs"
      from = {
        identities = compact([local.app_infra_cicd_identity])
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = local.app_infra_targets_sorted
        operations = {
          "iam.googleapis.com" = {
            methods = ["*"]
          }
          "compute.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_egress_rules = [
    {
      title = "ER seed -> cicd"
      from = {
        identities = [
          "serviceAccount:${local.cloudbuild_project_number}@cloudbuild.gserviceaccount.com"
        ]
        sources = {
          resources = [
            "projects/${local.seed_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${local.cloudbuild_project_number}"
        ]
        operations = {
          "cloudbuild.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
    {
      title = "ER cicd -> scc"
      from = {
        identities = [
          "serviceAccount:${local.organization_service_account}"
        ]
        sources = {
          resources = [
            "projects/${local.cloudbuild_project_number}"
          ]
        }
      }
      to = {
        resources = [
          "projects/${module.scc_notifications.project_number}"
        ]
        operations = {
          "cloudasset.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_egress_rules_app_infra = [
    {
      title = "ER app infra -> cicd"
      from = {
        identities = compact([local.app_infra_pipeline_identity])
        sources = {
          resources = local.app_infra_pipeline_source_projects
        }
      }
      to = {
        resources = [
          "projects/${local.cloudbuild_project_number}"
        ]
        operations = {
          "cloudbuild.googleapis.com" = {
            methods = ["*"]
          }
        }
      }
    },
  ]

  required_ingress_rules_list_dry_run = concat(
    local.required_ingress_rules_dry_run,
    var.required_ingress_rules_app_infra_dry_run ? local.required_ingress_rules_app_infra_dry_run : [],
    var.enable_scc_resources_in_terraform ? local.required_ingress_rule_scc_dry_run : [],
    var.ingress_policies_dry_run
  )

  required_ingress_rules_list = concat(
    local.required_ingress_rules,
    var.required_ingress_rules_app_infra ? local.required_ingress_rules_app_infra : [],
    var.enable_scc_resources_in_terraform ? local.required_ingress_rule_scc : [],
    var.ingress_policies
  )
}

module "service_control" {
  source = "../../modules/service_control"

  access_context_manager_policy_id = var.access_context_manager_policy_id
  restricted_services              = local.restricted_services
  restricted_services_dry_run      = local.restricted_services_dry_run
  members = distinct(concat([
    "serviceAccount:${local.networks_service_account}",
    "serviceAccount:${local.projects_service_account}",
    "serviceAccount:${local.organization_service_account}",
    "serviceAccount:${local.environment_service_account}",
  ], var.perimeter_additional_members))
  members_dry_run = distinct(concat([
    "serviceAccount:${local.networks_service_account}",
    "serviceAccount:${local.projects_service_account}",
    "serviceAccount:${local.organization_service_account}",
    "serviceAccount:${local.environment_service_account}",
  ], var.perimeter_additional_members))
  resources                     = [for k in local.project_keys : local.projects_map[k]]
  resource_keys                 = local.project_keys
  resources_dry_run             = [for k in local.project_keys_dry_run : local.projects_map_dry_run[k]]
  resource_keys_dry_run         = local.project_keys_dry_run
  ingress_policies_keys_dry_run = local.ingress_policies_keys_dry_run
  ingress_policies_keys         = local.ingress_policies_keys
  egress_policies_keys_dry_run  = local.egress_policies_keys_dry_run
  egress_policies_keys          = local.egress_policies_keys

  ingress_policies_dry_run = local.required_ingress_rules_list_dry_run
  ingress_policies         = local.required_ingress_rules_list

  egress_policies_dry_run = concat(
    local.required_egress_rules_dry_run,
    var.required_egress_rules_app_infra_dry_run ? local.required_egress_rules_app_infra_dry_run : [],
    var.egress_policies_dry_run
  )

  egress_policies = concat(
    local.required_egress_rules,
    var.required_egress_rules_app_infra ? local.required_egress_rules_app_infra : [],
    var.egress_policies
  )

  depends_on = [
    time_sleep.wait_projects
  ]
}
