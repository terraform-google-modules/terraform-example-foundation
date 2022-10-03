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
  gcp_scc_admin         = var.gcp_groups.scc_admin == null ? local.group_org_admins : var.gcp_groups.scc_admin
  gcp_platform_viewer   = var.gcp_groups.platform_viewer == null ? local.group_org_admins : var.gcp_groups.platform_viewer
  gcp_security_reviewer = var.gcp_groups.security_reviewer == null ? local.group_org_admins : var.gcp_groups.security_reviewer
  gcp_network_viewer    = var.gcp_groups.network_viewer == null ? local.group_org_admins : var.gcp_groups.network_viewer

  # Notification categories details: https://cloud.google.com/resource-manager/docs/managing-notification-contacts#notification-categories
  categories_map = {
    "BILLING"         = setunion([local.group_billing_admins, var.billing_data_users])
    "LEGAL"           = setunion([local.group_org_admins, var.audit_data_users])
    "PRODUCT_UPDATES" = setunion([local.gcp_scc_admin, local.gcp_platform_viewer])
    "SECURITY"        = setunion([local.gcp_scc_admin, local.gcp_security_reviewer])
    "SUSPENSION"      = [local.group_org_admins]
    "TECHNICAL"       = setunion([local.gcp_platform_viewer, local.gcp_security_reviewer, local.gcp_network_viewer])
  }

  # Convert a map indexed by category to a map indexed by email
  # this way is simpler to understand and maintain than the opposite
  # google_essential_contacts_contact resource needs one email with a list of categories
  contacts_list = transpose(local.categories_map)
}

resource "google_essential_contacts_contact" "essential_contacts" {
  for_each                            = local.contacts_list
  parent                              = local.parent
  email                               = each.key
  language_tag                        = var.essential_contacts_language
  notification_category_subscriptions = each.value
}
