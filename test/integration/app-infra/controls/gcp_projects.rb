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

dev_bu1_project_id = attribute('dev_bu1_project_id')
dev_bu1_instances_zones = attribute('dev_bu1_instances_zones')
dev_bu1_instances_names = attribute('dev_bu1_instances_names')

nonprod_bu1_project_id = attribute('nonprod_bu1_project_id')
nonprod_bu1_instances_zones = attribute('nonprod_bu1_instances_zones')
nonprod_bu1_instances_names = attribute('nonprod_bu1_instances_names')

prod_bu1_project_id = attribute('prod_bu1_project_id')
prod_bu1_instances_names = attribute('prod_bu1_instances_names')
prod_bu1_instances_zones = attribute('prod_bu1_instances_zones')
index = 0

control 'gcp-app-infra' do
  title 'gcp step 5-app-infra tests'
  dev_bu1_instances_names.each do |dev_bu1_instance_name|
    describe google_compute_instance(project: dev_bu1_project_id, zone: dev_bu1_instances_zones[index], name: dev_bu1_instance_name) do
      it { should exist }
      its('machine_type') { should match 'f1-micro' }
    end
    index += 1
  end

  index = 0
  nonprod_bu1_instances_names.each do |nonprod_bu1_instance_name|
    describe google_compute_instance(project: nonprod_bu1_project_id, zone: nonprod_bu1_instances_zones[index], name: nonprod_bu1_instance_name) do
      it { should exist }
      its('machine_type') { should match 'f1-micro' }
    end
    index += 1
  end

  index = 0
  prod_bu1_instances_names.each do |prod_bu1_instance_name|
    describe google_compute_instance(project: prod_bu1_project_id, zone: prod_bu1_instances_zones[index], name: prod_bu1_instance_name) do
      it { should exist }
      its('machine_type') { should match 'f1-micro' }
    end
    index += 1
  end
end
