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

control "gcp" do
    title "gcp step 1-org tests"

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

    describe google_pubsub_topic(project: scc_notifications_project_id, name: 'top-scc-notification') do
        it { should exist }
    end

    describe google_pubsub_subscription(project: scc_notifications_project_id, name: 'sub-scc-notification') do
        it { should exist }
    end

    describe google_bigquery_dataset(project: org_audit_logs_project_id, name: "activity_logs") do
        it { should exist }
    end

    describe google_bigquery_dataset(project: org_audit_logs_project_id, name: "system_event") do
        it { should exist }
    end

    describe google_bigquery_dataset(project: org_audit_logs_project_id, name: "data_access") do
        it { should exist }
    end

    describe google_bigquery_dataset(project: org_audit_logs_project_id, name: "vpc_flow") do
        it { should exist }
    end

    describe google_bigquery_dataset(project: org_audit_logs_project_id, name: "firewall_rules") do
        it { should exist }
    end

    describe google_bigquery_dataset(project: org_audit_logs_project_id, name: "access_transparency") do
        it { should exist }
    end

end
