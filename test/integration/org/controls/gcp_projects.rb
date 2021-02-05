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

common_folder_name = attribute('common_folder_name')
org_audit_logs_project_id = attribute('org_audit_logs_project_id')
org_billing_logs_project_id = attribute('org_billing_logs_project_id')
org_secrets_project_id = attribute('org_secrets_project_id')
interconnect_project_id = attribute('interconnect_project_id')
scc_notifications_project_id = attribute('scc_notifications_project_id')
dns_hub_project_id = attribute('dns_hub_project_id')
base_net_hub_project_id = attribute('base_net_hub_project_id')
restricted_net_hub_project_id = attribute('restricted_net_hub_project_id')
enable_hub_and_spoke = attribute('enable_hub_and_spoke')


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

control 'gcp_projects' do
  title 'step 1-org projects tests'

  describe google_resourcemanager_folder(name: common_folder_name) do
    it { should exist }
    its('display_name') { should eq 'fldr-common' }
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

  if enable_hub_and_spoke
    describe google_project(project: base_net_hub_project_id) do
      it { should exist }
      its('project_id') { should cmp base_net_hub_project_id }
      its('lifecycle_state') { should cmp 'ACTIVE' }
    end

    describe google_project(project: restricted_net_hub_project_id) do
      it { should exist }
      its('project_id') { should cmp restricted_net_hub_project_id }
      its('lifecycle_state') { should cmp 'ACTIVE' }
    end

  else
    describe base_net_hub_project_id do
      it { should should be nil }
    end

    describe restricted_net_hub_project_id do
      it { should should be nil }
    end
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
end
