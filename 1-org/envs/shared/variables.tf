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

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "default_region" {
  description = "Default region for BigQuery resources."
  type        = string
}

variable "enable_hub_and_spoke" {
  description = "Enable Hub-and-Spoke architecture."
  type        = bool
  default     = false
}

variable "billing_data_users" {
  description = "Google Workspace or Cloud Identity group that have access to billing data set."
  type        = string
}

variable "audit_data_users" {
  description = "Google Workspace or Cloud Identity group that have access to audit logs."
  type        = string
}

variable "domains_to_allow" {
  description = "The list of domains to allow users from in IAM. Used by Domain Restricted Sharing Organization Policy. Must include the domain of the organization you are deploying the foundation. To add other domains you must also grant access to these domains to the terraform service account used in the deploy."
  type        = list(string)
}

variable "enable_os_login_policy" {
  description = "Enable OS Login Organization Policy."
  type        = bool
  default     = false
}

variable "audit_logs_table_expiration_days" {
  description = "Period before tables expire for all audit logs in milliseconds. Default is 30 days."
  type        = number
  default     = 30
}

variable "scc_notification_name" {
  description = "Name of the Security Command Center Notification. It must be unique in the organization. Run `gcloud scc notifications describe <scc_notification_name> --organization=org_id` to check if it already exists."
  type        = string
}

variable "skip_gcloud_download" {
  description = "Whether to skip downloading gcloud (assumes gcloud is already available outside the module. If set to true you, must ensure that Gcloud Alpha module is installed.)"
  type        = bool
  default     = true
}

variable "scc_notification_filter" {
  description = "Filter used to create the Security Command Center Notification, you can see more details on how to create filters in https://cloud.google.com/security-command-center/docs/how-to-api-filter-notifications#create-filter"
  type        = string
  default     = "state = \"ACTIVE\""
}

variable "parent_folder" {
  description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step."
  type        = string
  default     = ""
}

variable "create_access_context_manager_access_policy" {
  description = "Whether to create access context manager access policy"
  type        = bool
  default     = true
}

variable "data_access_logs_enabled" {
  description = "Enable Data Access logs of types DATA_READ, DATA_WRITE and ADMIN_READ for all GCP services. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access"
  type        = bool
  default     = true
}

variable "log_export_storage_location" {
  description = "The location of the storage bucket used to export logs."
  type        = string
  default     = "US"
}

variable "log_export_storage_force_destroy" {
  description = "(Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present."
  type        = bool
  default     = false
}

variable "log_export_storage_versioning" {
  description = "(Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted."
  type        = bool
  default     = false
}

variable "audit_logs_table_delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "log_export_storage_retention_policy" {
  description = "Configuration of the bucket's data retention policy for how long objects in the bucket should be retained."
  type = object({
    is_locked             = bool
    retention_period_days = number
  })
  default = null
}

variable "dns_hub_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the DNS hub project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "dns_hub_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the DNS hub project."
  type        = string
  default     = null
}

variable "dns_hub_project_budget_amount" {
  description = "The amount to use as the budget for the DNS hub project."
  type        = number
  default     = 1000
}

variable "base_net_hub_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the base net hub project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "base_net_hub_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the base net hub project."
  type        = string
  default     = null
}

variable "base_net_hub_project_budget_amount" {
  description = "The amount to use as the budget for the base net hub project."
  type        = number
  default     = 1000
}

variable "restricted_net_hub_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the restricted net hub project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "restricted_net_hub_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the restricted net hub project."
  type        = string
  default     = null
}

variable "restricted_net_hub_project_budget_amount" {
  description = "The amount to use as the budget for the restricted net hub project."
  type        = number
  default     = 1000
}

variable "interconnect_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the Dedicated Interconnect project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "interconnect_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the Dedicated Interconnect project."
  type        = string
  default     = null
}

variable "interconnect_project_budget_amount" {
  description = "The amount to use as the budget for the Dedicated Interconnect project."
  type        = number
  default     = 1000
}

variable "org_secrets_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the org secrets project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "org_secrets_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the org secrets project."
  type        = string
  default     = null
}

variable "org_secrets_project_budget_amount" {
  description = "The amount to use as the budget for the org secrets project."
  type        = number
  default     = 1000
}


variable "org_billing_logs_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the org billing logs project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "org_billing_logs_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the org billing logs project."
  type        = string
  default     = null
}

variable "org_billing_logs_project_budget_amount" {
  description = "The amount to use as the budget for the org billing logs project."
  type        = number
  default     = 1000
}

variable "org_audit_logs_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the org audit logs project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "org_audit_logs_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the org audit logs project."
  type        = string
  default     = null
}

variable "org_audit_logs_project_budget_amount" {
  description = "The amount to use as the budget for the org audit logs project."
  type        = number
  default     = 1000
}

variable "scc_notifications_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the SCC notifications project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "scc_notifications_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the SCC notifications project."
  type        = string
  default     = null
}

variable "scc_notifications_project_budget_amount" {
  description = "The amount to use as the budget for the SCC notifications project."
  type        = number
  default     = 1000
}

variable "project_prefix" {
  description = "Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters."
  type        = string
  default     = "prj"
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "gcp_platform_viewer" {
  description = "G Suite or Cloud Identity group that have the ability to view resource information across the Google Cloud organization."
  type        = string
  default     = null
}

variable "gcp_security_reviewer" {
  description = "G Suite or Cloud Identity group that members are part of the security team responsible for reviewing cloud security."
  type        = string
  default     = null
}

variable "gcp_network_viewer" {
  description = "G Suite or Cloud Identity group that members are part of the networking team and review network configurations"
  type        = string
  default     = null
}

variable "gcp_scc_admin" {
  description = "G Suite or Cloud Identity group that can administer Security Command Center."
  type        = string
  default     = null
}

variable "gcp_audit_viewer" {
  description = "Members are part of an audit team and view audit logs in the logging project."
  type        = string
  default     = null
}

variable "gcp_global_secrets_admin" {
  description = "G Suite or Cloud Identity group that members are responsible for putting secrets into Secrets Manager."
  type        = string
  default     = null
}

variable "gcp_org_admin_user" {
  description = "Identity that has organization administrator permissions."
  type        = string
  default     = null
}

variable "gcp_billing_creator_user" {
  description = "Identity that can create billing accounts."
  type        = string
  default     = null
}

variable "gcp_billing_admin_user" {
  description = "Identity that has billing administrator permissions"
  type        = string
  default     = null
}
