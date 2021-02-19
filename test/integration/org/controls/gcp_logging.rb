# Copyright 2021 Google LLC
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
logs_export_storage_bucket_name = attribute('logs_export_storage_bucket_name')
logs_export_pubsub_topic = attribute('logs_export_pubsub_topic')
main_logs_filter = [
  'logName: /logs/cloudaudit.googleapis.com%2Factivity',
  'logName: /logs/cloudaudit.googleapis.com%2Fsystem_event',
  'logName: /logs/cloudaudit.googleapis.com%2Fdata_access',
  'logName: /logs/compute.googleapis.com%2Fvpc_flows',
  'logName: /logs/compute.googleapis.com%2Ffirewall',
  'logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency'
]

control 'gcp_logging' do
  title 'step 1-org logging tests'

  describe google_bigquery_dataset(
    project: org_audit_logs_project_id,
    name: 'audit_logs'
  ) do
    it { should exist }
  end

  describe google_bigquery_dataset(
    project: org_billing_logs_project_id,
    name: 'billing_data'
  ) do
    it { should exist }
  end

  describe google_storage_bucket(
    name: logs_export_storage_bucket_name
  ) do
    it { should exist }
  end

  describe google_pubsub_topic(
    project: org_audit_logs_project_id,
    name: logs_export_pubsub_topic
  ) do
    it { should exist }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'sk-c-logging-bq'
  ) do
    it { should exist }
    main_logs_filter.each do |filter|
      its('filter') do
        should include filter
      end
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should cmp "bigquery.googleapis.com/projects/#{org_audit_logs_project_id}/datasets/audit_logs" }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'sk-c-logging-bkt'
  ) do
    it { should exist }
    its('filter') do
      should be_nil
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should cmp "storage.googleapis.com/#{logs_export_storage_bucket_name}" }
  end

  describe google_logging_folder_log_sink(
    folder: parent_resource_id,
    name: 'sk-c-logging-pub'
  ) do
    it { should exist }
    main_logs_filter.each do |filter|
      its('filter') do
        should include filter
      end
    end
    its('include_children') { should cmp 'true' }
    its('destination') { should cmp "pubsub.googleapis.com/projects/#{org_audit_logs_project_id}/topics/#{logs_export_pubsub_topic}" }
  end
end
