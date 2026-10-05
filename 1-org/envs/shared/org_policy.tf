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
  organization_id = local.parent_folder != "" ? null : local.org_id
  folder_id       = local.parent_folder != "" ? local.parent_folder : null
  policy_for      = local.parent_folder != "" ? "folder" : "organization"

  essential_contacts_domains_to_allow = concat(
    [for domain in var.essential_contacts_domains_to_allow : domain if can(regex("^@.*$", domain)) == true],
    [for domain in var.essential_contacts_domains_to_allow : "@${domain}" if can(regex("^@.*$", domain)) == false]
  )

  boolean_type_organization_policies = toset(compact([
    "compute.disableNestedVirtualization",
    "compute.disableSerialPortAccess",
    var.universe_domain == "googleapis.com" ? "compute.skipDefaultNetworkCreation" : "",
    "compute.restrictXpnProjectLienRemoval",
    "compute.disableVpcExternalIpv6",
    "compute.setNewProjectDefaultToZonalDNSOnly",
    "compute.requireOsLogin",
    "sql.restrictPublicIp",
    "sql.restrictAuthorizedNetworks",
    "iam.disableServiceAccountKeyCreation",
    "iam.automaticIamGrantsForDefaultServiceAccounts",
    "iam.disableServiceAccountKeyUpload",
    "storage.uniformBucketLevelAccess",
    "storage.publicAccessPrevention"
  ]))

  private_pools                    = [local.cloud_build_private_worker_pool_id]
  access_context_manager_policy_id = var.create_access_context_manager_access_policy ? google_access_context_manager_access_policy.access_policy[0].id : var.access_context_manager_policy_id
}

module "organization_policies_type_boolean" {
  source   = "terraform-google-modules/org-policy/google"
  version  = "~> 7.0"
  for_each = local.boolean_type_organization_policies

  organization_id = local.organization_id
  folder_id       = local.folder_id
  policy_for      = local.policy_for
  policy_type     = "boolean"
  enforce         = "true"
  constraint      = "constraints/${each.value}"
}

/******************************************
  Compute org policies
*******************************************/

module "org_vm_external_ip_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 7.0"

  organization_id = local.organization_id
  folder_id       = local.folder_id
  policy_for      = local.policy_for
  policy_type     = "list"
  enforce         = "true"
  constraint      = "constraints/compute.vmExternalIpAccess"
}

module "restrict_protocol_fowarding" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 7.0"

  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = ["INTERNAL"]
  allow_list_length = 1
  constraint        = "constraints/compute.restrictProtocolForwardingCreationForTypes"
}

/******************************************
  IAM
*******************************************/

resource "time_sleep" "wait_logs_export" {
  create_duration = var.logs_export_sleep_duration

  depends_on = [
    module.logs_export
  ]
}

module "org_domain_restricted_sharing" {
  source  = "terraform-google-modules/org-policy/google//modules/domain_restricted_sharing"
  version = "~> 7.0"

  organization_id       = local.organization_id
  folder_id             = local.folder_id
  policy_for            = local.policy_for
  domains_to_allow      = var.universe_domain == "googleapis.com" ? var.domains_to_allow : []
  principal_set_org_ids = var.principal_set_org_ids

  depends_on = [
    time_sleep.wait_logs_export
  ]
}

resource "null_resource" "input_validation" {
  lifecycle {
    precondition {
      condition     = length(var.domains_to_allow) > 0 || length(var.principal_set_org_ids) > 0
      error_message = "Error: You must provide at least one domain in 'domains_to_allow' or at least one Org ID in 'principal_set_org_ids'."
    }
  }
}

/******************************************
  Essential Contacts
*******************************************/

module "domain_restricted_contacts" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 7.0"
  count   = var.universe_domain == "googleapis.com" ? 1 : 0 # automatic in Sovereign baseline

  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow_list_length = length(local.essential_contacts_domains_to_allow)
  allow             = local.essential_contacts_domains_to_allow
  constraint        = "constraints/essentialcontacts.allowedContactDomains"
}

/******************************************
  Cloud build
*******************************************/

module "allowed_worker_pools" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 7.0"
  count   = var.universe_domain == "googleapis.com" && var.enforce_allowed_worker_pools && local.cloud_build_private_worker_pool_id != "" ? 1 : 0

  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow_list_length = length(local.private_pools)
  allow             = local.private_pools
  constraint        = "constraints/cloudbuild.allowedWorkerPools"
}

/******************************************
  Access Context Manager Policy
*******************************************/

resource "google_access_context_manager_access_policy" "access_policy" {
  count  = var.create_access_context_manager_access_policy ? 1 : 0
  parent = "organizations/${local.org_id}"
  title  = "default policy"
}
