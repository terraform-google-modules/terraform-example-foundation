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

prod_env_folder = attribute('prod_env_folder')
prod_monitoring_project_id = attribute('prod_monitoring_project_id')
prod_base_shared_vpc_project_id = attribute('prod_base_shared_vpc_project_id')
prod_restricted_shared_vpc_project_id = attribute('prod_restricted_shared_vpc_project_id')
prod_env_secrets_project_id = attribute('prod_env_secrets_project_id')
monitoring_group = attribute('monitoring_group')

monitoring_project_apis = ['logging.googleapis.com', 'monitoring.googleapis.com']
networking_project_apis = ['compute.googleapis.com',
                           'dns.googleapis.com',
                           'servicenetworking.googleapis.com',
                           'container.googleapis.com',
                           'logging.googleapis.com']
secret_project_apis = ['secretmanager.googleapis.com', 'logging.googleapis.com']

control 'production' do
  title 'gcp step 2-envs test production'

  describe google_resourcemanager_folder(name: prod_env_folder) do
    it { should exist }
    its('display_name') { should eq 'fldr-production' }
  end

  describe google_project(project: prod_monitoring_project_id) do
    it { should exist }
    its('project_id') { should cmp prod_monitoring_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_base_shared_vpc_project_id) do
    it { should exist }
    its('project_id') { should cmp prod_base_shared_vpc_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_restricted_shared_vpc_project_id) do
    it { should exist }
    its('project_id') { should cmp prod_restricted_shared_vpc_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_env_secrets_project_id) do
    it { should exist }
    its('project_id') { should cmp prod_env_secrets_project_id }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  monitoring_project_apis.each do |api|
    describe google_project_service(
      project: prod_monitoring_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  networking_project_apis.each do |api|
    describe google_project_service(
      project: prod_base_shared_vpc_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end

    describe google_project_service(
      project: prod_restricted_shared_vpc_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  secret_project_apis.each do |api|
    describe google_project_service(
      project: prod_env_secrets_project_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  describe google_project_iam_binding(project: prod_monitoring_project_id,  role: 'roles/monitoring.editor') do
    it { should exist }
    its('members') {should include "group:#{monitoring_group}" }
  end
end
