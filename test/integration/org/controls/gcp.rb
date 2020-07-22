# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

common_folder_name = attribute('common_folder_name')
org_audit_logs_project_id = attribute('org_audit_logs_project_id')
org_billing_logs_project_id = attribute('org_billing_logs_project_id')
org_secrets_project_id = attribute('org_secrets_project_id')
interconnect_project_id = attribute('interconnect_project_id')
scc_notifications_project_id = attribute('scc_notifications_project_id')
dns_hub_project_id = attribute('dns_hub_project_id')
parent_resource_type = attribute('parent_resource_type')
parent_resource_id = attribute('parent_resource_id')
domains_to_allow = attribute('domains_to_allow')

bigquery_logs_datasets = [
  'activity_logs',
  'system_event',
  'data_access',
  'vpc_flow',
  'firewall_rules',
  'access_transparency'
]

dns_hub_apis = [
  'compute.googleapis.com',
  'dns.googleapis.com',
  'servicenetworking.googleapis.com',
  'logging.googleapis.com',
  'cloudresourcemanager.googleapis.com'
]

scc_notifications_apis = [
  'logging.googleapis.com',
  'pubsub.googleapis.com',
  'securitycenter.googleapis.com'
]

org_secrets_apis = [
  'logging.googleapis.com',
  'secretmanager.googleapis.com'
]

logs_apis = [
  'logging.googleapis.com',
  'bigquery.googleapis.com'
]

boolean_policy_constraints = [
  'constraints/compute.disableNestedVirtualization',
  'constraints/compute.disableSerialPortAccess',
  'constraints/compute.disableGuestAttributesAccess',
  'constraints/compute.vmExternalIpAccess',
  'constraints/compute.skipDefaultNetworkCreation',
  'constraints/compute.restrictXpnProjectLienRemoval',
  'constraints/sql.restrictPublicIp',
  'constraints/iam.disableServiceAccountKeyCreation',
  'constraints/storage.uniformBucketLevelAccess'
]

control 'gcp' do
  title 'gcp step 1-org tests'

  describe google_resourcemanager_folder(name: common_folder_name) do
    it { should exist }
    its('display_name') { should eq 'common' }
  end

  describe google_project(project: org_audit_logs_project_id) do
    it { should exist }
    its('project_id') { should cmp org_audit_logs_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: org_billing_logs_project_id) do
    it { should exist }
    its('project_id') { should cmp org_billing_logs_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: org_secrets_project_id) do
    it { should exist }
    its('project_id') { should cmp org_secrets_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: interconnect_project_id) do
    it { should exist }
    its('project_id') { should cmp interconnect_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: dns_hub_project_id) do
    it { should exist }
    its('project_id') { should cmp dns_hub_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: scc_notifications_project_id) do
    it { should exist }
    its('project_id') { should cmp scc_notifications_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  logs_apis.each do |api|
    describe google_project_service(
      project: org_audit_logs_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  logs_apis.each do |api|
    describe google_project_service(
      project: org_billing_logs_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  org_secrets_apis.each do |api|
    describe google_project_service(
      project: org_secrets_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  scc_notifications_apis.each do |api|
    describe google_project_service(
      project: scc_notifications_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  dns_hub_apis.each do |api|
    describe google_project_service(
      project: dns_hub_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  describe google_pubsub_topic(
    project: scc_notifications_project_id,
    name: 'top-scc-notification'
  ) do
    it { should exist }
  end

  describe google_pubsub_subscription(
    project: scc_notifications_project_id,
    name: 'sub-scc-notification'
  ) do
    it { should exist }
  end

  bigquery_logs_datasets.each do |dataset|
    describe google_bigquery_dataset(
      project: org_audit_logs_project_id,
      name: dataset
    ) do
      it { should exist }
    end
  end

  if parent_resource_type == 'folder'

    describe google_logging_folder_log_sink(
      folder: parent_resource_id,
      name: 'bigquery_activity_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Factivity"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/activity_logs/) }
    end

    describe google_logging_folder_log_sink(
      folder: parent_resource_id,
      name: 'bigquery_system_event_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Fsystem_event"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/system_event/) }
    end

    describe google_logging_folder_log_sink(
      folder: parent_resource_id,
      name: 'bigquery_data_access_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Fdata_access"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/data_access/) }
    end

    describe google_logging_folder_log_sink(
      folder: parent_resource_id,
      name: 'bigquery_vpc_flow_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/compute.googleapis.com%2Fvpc_flows"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/vpc_flow/) }
    end

    describe google_logging_folder_log_sink(
      folder: parent_resource_id,
      name: 'bigquery_firewall_rules_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/compute.googleapis.com%2Ffirewall"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/firewall_rules/) }
    end

    describe google_logging_folder_log_sink(
      folder: parent_resource_id,
      name: 'bigquery_access_transparency_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Faccess_transparency"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/access_transparency/) }
    end

  else

    describe google_logging_organization_log_sink(
      organization: parent_resource_id,
      name: 'bigquery_activity_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Factivity"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/activity_logs/) }
    end

    describe google_logging_organization_log_sink(
      organization: parent_resource_id,
      name: 'bigquery_system_event_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Fsystem_event"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/system_event/) }
    end

    describe google_logging_organization_log_sink(
      organization: parent_resource_id,
      name: 'bigquery_data_access_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Fdata_access"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/data_access/) }
    end

    describe google_logging_organization_log_sink(
      organization: parent_resource_id,
      name: 'bigquery_vpc_flow_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/compute.googleapis.com%2Fvpc_flows"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/vpc_flow/) }
    end

    describe google_logging_organization_log_sink(
      organization: parent_resource_id,
      name: 'bigquery_firewall_rules_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/compute.googleapis.com%2Ffirewall"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/firewall_rules/) }
    end

    describe google_logging_organization_log_sink(
      organization: parent_resource_id,
      name: 'bigquery_access_transparency_logs'
    ) do
      it { should exist }
      its('filter') {
        should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Faccess_transparency"'
      }
      its('include_children') { should cmp 'true' }
      its('destination') { should match(/access_transparency/) }
    end

    boolean_policy_constraints.each do |constraint|
      describe google_organization_policy(
        name: "organizations/#{parent_resource_id}",
        constraint: constraint
      ) do
        it { should exist }
        its('boolean_policy.enforced') { should be true }
      end
    end

    describe google_organization_policy(
      name: "organizations/#{parent_resource_id}",
      constraint: 'constraints/iam.allowedPolicyMemberDomains'
    ) do
      it { should exist }
      domains_to_allow.each do |domain|
        customer_id = google_organization(display_name: domain).directory_customer_id
        its('list_policy.allowed_values') { should include customer_id }
      end
    end
  end
end
