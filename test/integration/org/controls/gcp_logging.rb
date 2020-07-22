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

org_audit_logs_project_id = attribute('org_audit_logs_project_id')
org_billing_logs_project_id = attribute('org_billing_logs_project_id')
parent_resource_id = attribute('parent_resource_id')

bigquery_logs_datasets = [
  'activity_logs',
  'system_event',
  'data_access',
  'vpc_flow',
  'firewall_rules',
  'access_transparency'
]

control 'gcp_logging' do
  title 'step 1-org logging tests'

  bigquery_logs_datasets.each do |dataset|
    describe google_bigquery_dataset(
      project: org_audit_logs_project_id,
      name: dataset
    ) do
      it { should exist }
    end
  end

  describe google_bigquery_dataset(
    project: org_billing_logs_project_id,
    name: 'billing_data'
  ) do
    it { should exist }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'bigquery_activity_logs'
  ) do
    it { should exist }
    its('filter') do
      should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Factivity"'
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should match(/activity_logs/) }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'bigquery_system_event_logs'
  ) do
    it { should exist }
    its('filter') do
      should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Fsystem_event"'
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should match(/system_event/) }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'bigquery_data_access_logs'
  ) do
    it { should exist }
    its('filter') do
      should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Fdata_access"'
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should match(/data_access/) }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'bigquery_vpc_flow_logs'
  ) do
    it { should exist }
    its('filter') do
      should cmp 'logName: "/logs/compute.googleapis.com%2Fvpc_flows"'
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should match(/vpc_flow/) }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'bigquery_firewall_rules_logs'
  ) do
    it { should exist }
    its('filter') do
      should cmp 'logName: "/logs/compute.googleapis.com%2Ffirewall"'
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should match(/firewall_rules/) }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'bigquery_access_transparency_logs'
  ) do
    it { should exist }
    its('filter') do
      should cmp 'logName: "/logs/cloudaudit.googleapis.com%2Faccess_transparency"'
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should match(/access_transparency/) }
  end
end
