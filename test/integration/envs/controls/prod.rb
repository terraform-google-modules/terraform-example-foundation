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

prod_env_folder = attribute('prod_env_folder')
prod_monitoring_editor_role = attribute('prod_monitoring_editor_role')
prod_monitoring_project_id = attribute('prod_monitoring_project_id')
prod_base_shared_vpc_project_id = attribute('prod_base_shared_vpc_project_id')
prod_restricted_shared_vpc_project_id = attribute('prod_restricted_shared_vpc_project_id')
prod_env_secrets_project_id = attribute('prod_env_secrets_project_id')

control nonprod do
    title 'gcp step 2-envs test nonprod'

    describe google_resourcemanager_folder(name: nonprod_env_folder) do
        it {should exist}
        its('display_name') { should eq 'nonprod' }
    end

    describe google_project(name: nonprod_monitoring_project_id) do
        it {should exist}
        its('project_id') { should cmp nonprod_monitoring_project_id }
        its('lifecycle_state') { should cmp 'ACTIVE' }
    end

    describe google_project(name: nonprod_base_shared_vpc_project_id) do
        it {should exist}
        its('project_id') { should cmp nonprod_base_shared_vpc_project_id }
        its('lifecycle_state') { should cmp 'ACTIVE' }
    end

    describe google_project(name: nonprod_restricted_shared_vpc_project_id) do
        it {should exist}
        its('project_id') { should cmp nonprod_restricted_shared_vpc_project_id }
        its('lifecycle_state') { should cmp 'ACTIVE' }
    end

    describe google_project(name: nonprod_env_secrets_project_id) do
        it {should exist}
        its('project_id') { should cmp nonprod_env_secrets_project_id }
        its('lifecycle_state') { should cmp 'ACTIVE' }
    end

    describe google_project_service(
        project: nonprod_monitoring_project_id,
        name: 'logging.googleapis.com'
    ) do
        it { should exist }
        its('state') { should cmp 'ENABLED' }
    end

    describe google_project_service(
       project: nonprod_monitoring_project_id,
       name: 'monitoring.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end

    describe google_project_service(
        project: nonprod_base_shared_vpc_project_id,
        name: 'compute.googleapis.com'
    ) do
        it { should exist }
        its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_base_shared_vpc_project_id,
       name: 'dns.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end

    describe google_project_service(
        project: nonprod_base_shared_vpc_project_id,
        name: 'servicenetworking.googleapis.com'
    ) do
        it { should exist }
        its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_base_shared_vpc_project_id,
       name: 'container.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_base_shared_vpc_project_id,
       name: 'logging.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end

    describe google_project_service(
        project: nonprod_restricted_shared_vpc_project_id,
        name: 'compute.googleapis.com'
    ) do
        it { should exist }
        its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_restricted_shared_vpc_project_id,
       name: 'dns.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end

    describe google_project_service(
        project: nonprod_restricted_shared_vpc_project_id,
        name: 'servicenetworking.googleapis.com'
    ) do
        it { should exist }
        its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_restricted_shared_vpc_project_id,
       name: 'container.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_restricted_shared_vpc_project_id,
       name: 'logging.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_env_secrets_project_id,
       name: 'secretmanager.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end
    
    describe google_project_service(
       project: nonprod_env_secrets_project_id,
       name: 'logging.googleapis.com'
    ) do
       it { should exist }
       its('state') { should cmp 'ENABLED' }
    end

    google_project_iam_bindings(project: nonprod_monitoring_project_id).where(iam_binding_role: "roles/monitoring.editor") do
        it { should exist }
        # its('members') {should include 'group:${var.monitoring_workspace_users}' }
    end
end
