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
    [for domain in var.essential_contacts_domains_to_allow : "${domain}" if can(regex("^@.*$", domain)) == true],
    [for domain in var.essential_contacts_domains_to_allow : "@${domain}" if can(regex("^@.*$", domain)) == false]
  )
  boolean_type_organization_policies = {
    org_disable_nested_virtualization = {
      constraint = "constraints/compute.disableNestedVirtualization"
    }
    org_disable_serial_port_access = {
      constraint = "constraints/compute.disableSerialPortAccess"
    }
    org_compute_disable_guest_attributes_access = {
      constraint = "constraints/compute.disableGuestAttributesAccess"
    }
    org_skip_default_network = {
      constraint = "constraints/compute.skipDefaultNetworkCreation"
    }
    org_shared_vpc_lien_removal = {
      constraint = "constraints/compute.restrictXpnProjectLienRemoval"
    }
    disable_vpc_external_ipv6 = {
      constraint = "constraints/compute.disableVpcExternalIpv6"
    }
    internal_dns_on_new_project_to_zonal_dns_only = {
      constraint = "constraints/compute.setNewProjectDefaultToZonalDNSOnly"
    }
    org_cloudsql_external_ip_access = {
      constraint = "constraints/sql.restrictPublicIp"
    }
    org_disable_sa_key_creation = {
      constraint = "constraints/iam.disableServiceAccountKeyCreation"
    }
    org_disable_automatic_iam_grants_on_default_service_accounts = {
      constraint = "constraints/iam.automaticIamGrantsForDefaultServiceAccounts"
    }
    disable_service_account_key_upload = {
      constraint = "constraints/iam.disableServiceAccountKeyUpload"
    }
    org_enforce_bucket_level_access = {
      constraint = "constraints/storage.uniformBucketLevelAccess"
    }
  }
}

module "organization_policies_type_boolean" {
  for_each        = local.boolean_type_organization_policies
  source          = "terraform-google-modules/org-policy/google"
  version         = "~> 5.1"
  organization_id = local.organization_id
  folder_id       = local.folder_id
  policy_for      = local.policy_for
  policy_type     = "boolean"
  enforce         = "true"
  constraint      = each.value.constraint
}

/******************************************
  Compute org policies
*******************************************/

module "org_vm_external_ip_access" {
  source          = "terraform-google-modules/org-policy/google"
  version         = "~> 5.1"
  organization_id = local.organization_id
  folder_id       = local.folder_id
  policy_for      = local.policy_for
  policy_type     = "list"
  enforce         = "true"
  constraint      = "constraints/compute.vmExternalIpAccess"
}

module "org_shared_require_os_login" {
  source          = "terraform-google-modules/org-policy/google"
  count           = var.enable_os_login_policy ? 1 : 0
  version         = "~> 5.1"
  organization_id = local.organization_id
  folder_id       = local.folder_id
  policy_for      = local.policy_for
  policy_type     = "boolean"
  enforce         = "true"
  constraint      = "constraints/compute.requireOsLogin"
}

module "restrict_protocol_fowarding" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 5.1"
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

module "org_domain_restricted_sharing" {
  source           = "terraform-google-modules/org-policy/google//modules/domain_restricted_sharing"
  version          = "~> 5.1"
  organization_id  = local.organization_id
  folder_id        = local.folder_id
  policy_for       = local.policy_for
  domains_to_allow = var.domains_to_allow
}

/******************************************
  Essential Contacts
*******************************************/

module "domain_restricted_contacts" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 5.1"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow_list_length = length(local.essential_contacts_domains_to_allow)
  allow             = local.essential_contacts_domains_to_allow
  constraint        = "constraints/essentialcontacts.allowedContactDomains"
}

/******************************************
  Access Context Manager Policy
*******************************************/

resource "google_access_context_manager_access_policy" "access_policy" {
  count  = var.create_access_context_manager_access_policy ? 1 : 0
  parent = "organizations/${local.org_id}"
  title  = "default policy"
}
