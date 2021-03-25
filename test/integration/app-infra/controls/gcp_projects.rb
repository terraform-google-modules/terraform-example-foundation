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

dev_bu1_project_base = attribute('dev_bu1_project_base')
dev_bu1_instance_zone = attribute('dev_bu1_instance_zone')
dev_bu1_instance_name = attribute('dev_bu1_instance_name')

nonprod_bu1_project_base = attribute('nonprod_bu1_project_base')
nonprod_bu1_instance_zone = attribute('nonprod_bu1_instance_zone')
nonprod_bu1_instance_name = attribute('nonprod_bu1_instance_name')

prod_bu1_project_base = attribute('prod_bu1_project_base')
prod_bu1_instance_zone = attribute('prod_bu1_instance_zone')
prod_bu1_instance_name = attribute('prod_bu1_instance_name')

control 'gcp-app-infra' do
  title 'gcp step 5-app-infra tests'

  describe google_compute_instance(project: dev_bu1_project_base, zone: dev_bu1_instance_zone, name: dev_bu1_instance_name) do
    it { should exist }
    its('machine_type') { should match 'n1-standard-1' }
    its('tags.items') { should include 'foo' }
    its('tags.items') { should include 'bar' }
    its('tag_count') { should cmp 2 }
    its('service_account_scopes') { should include 'https://www.googleapis.com/auth/compute.readonly' }
    its('metadata_keys') { should include '123' }
    its('metadata_values') { should include 'asdf' }
  end

  describe google_compute_instance(project: nonprod_bu1_project_base, zone: nonprod_bu1_instance_zone, name: nonprod_bu1_instance_name) do
    it { should exist }
    its('machine_type') { should match 'n1-standard-1' }
    its('tags.items') { should include 'foo' }
    its('tags.items') { should include 'bar' }
    its('tag_count') { should cmp 2 }
    its('service_account_scopes') { should include 'https://www.googleapis.com/auth/compute.readonly' }
    its('metadata_keys') { should include '123' }
    its('metadata_values') { should include 'asdf' }
  end

  describe google_compute_instance(project: prod_bu1_project_base, zone: prod_bu1_instance_zone, name: prod_bu1_instance_name) do
    it { should exist }
    its('machine_type') { should match 'n1-standard-1' }
    its('tags.items') { should include 'foo' }
    its('tags.items') { should include 'bar' }
    its('tag_count') { should cmp 2 }
    its('service_account_scopes') { should include 'https://www.googleapis.com/auth/compute.readonly' }
    its('metadata_keys') { should include '123' }
    its('metadata_values') { should include 'asdf' }
  end
end
