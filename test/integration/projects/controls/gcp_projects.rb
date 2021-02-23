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
dev_bu1_project_floating = attribute('dev_bu1_project_floating')
dev_bu1_project_peering = attribute('dev_bu1_project_peering')
dev_bu1_project_restricted_id = attribute('dev_bu1_project_restricted')
dev_bu2_project_base = attribute('dev_bu2_project_base')
dev_bu2_project_floating = attribute('dev_bu2_project_floating')
dev_bu2_project_peering = attribute('dev_bu2_project_peering')
dev_bu2_project_restricted_id = attribute('dev_bu2_project_restricted')

nonprod_bu1_project_base = attribute('nonprod_bu1_project_base')
nonprod_bu1_project_floating = attribute('nonprod_bu1_project_floating')
nonprod_bu1_project_peering = attribute('nonprod_bu1_project_peering')
nonprod_bu1_project_restricted_id = attribute('nonprod_bu1_project_restricted')
nonprod_bu2_project_base = attribute('nonprod_bu2_project_base')
nonprod_bu2_project_floating = attribute('nonprod_bu2_project_floating')
nonprod_bu2_project_peering = attribute('nonprod_bu2_project_peering')
nonprod_bu2_project_restricted_id = attribute('nonprod_bu2_project_restricted')

prod_bu1_project_base = attribute('prod_bu1_project_base')
prod_bu1_project_floating = attribute('prod_bu1_project_floating')
prod_bu1_project_peering = attribute('prod_bu1_project_peering')
prod_bu1_project_restricted_id = attribute('prod_bu1_project_restricted')
prod_bu2_project_base = attribute('prod_bu2_project_base')
prod_bu2_project_floating = attribute('prod_bu2_project_floating')
prod_bu2_project_peering = attribute('prod_bu2_project_peering')
prod_bu2_project_restricted_id = attribute('prod_bu2_project_restricted')
restricted_enabled_apis = ['accesscontextmanager.googleapis.com', 'billingbudgets.googleapis.com']

shared_bu1_build_project = attribute('shared_bu1_build_project')
shared_bu2_build_project = attribute('shared_bu2_build_project')
shared_apis_enabled = ['cloudbuild.googleapis.com','sourcerepo.googleapis.com','cloudkms.googleapis.com']

environment_codes = %w[d n p]
business_units = %w[bu1 bu2]

base_projects_id = {
  'd' => { 'bu1' => dev_bu1_project_base, 'bu2' => dev_bu2_project_base },
  'n' => { 'bu1' => nonprod_bu1_project_base, 'bu2' => nonprod_bu2_project_base },
  'p' => { 'bu1' => prod_bu1_project_base, 'bu2' => prod_bu2_project_base }
}

restricted_projects_id = {
  'd' => { 'bu1' => dev_bu1_project_restricted_id, 'bu2' => dev_bu2_project_restricted_id },
  'n' => { 'bu1' => nonprod_bu1_project_restricted_id, 'bu2' => nonprod_bu2_project_restricted_id },
  'p' => { 'bu1' => prod_bu1_project_restricted_id, 'bu2' => prod_bu2_project_restricted_id }
}

floating_projects_id = {
  'd' => { 'bu1' => dev_bu1_project_floating, 'bu2' => dev_bu2_project_floating },
  'n' => { 'bu1' => nonprod_bu1_project_floating, 'bu2' => nonprod_bu2_project_floating },
  'p' => { 'bu1' => prod_bu1_project_floating, 'bu2' => prod_bu2_project_floating }
}

peering_projects_id = {
  'd' => { 'bu1' => dev_bu1_project_peering, 'bu2' => dev_bu2_project_peering },
  'n' => { 'bu1' => nonprod_bu1_project_peering, 'bu2' => nonprod_bu2_project_peering },
  'p' => { 'bu1' => prod_bu1_project_peering, 'bu2' => prod_bu2_project_peering }
}

shared_project_id = {
  's' => { 'bu1' => shared_bu1_build_project, 'bu2' => shared_bu2_build_project }
}

control 'gcp-projects' do
  title 'gcp step 4-projects tests'

  environment_codes.each do |environment_code|
    business_units.each do |business_unit|
      describe google_project(project: base_projects_id[environment_code][business_unit]) do
        it { should exist }
        its('lifecycle_state') { should cmp 'ACTIVE' }
      end

      describe google_project(project: floating_projects_id[environment_code][business_unit]) do
        it { should exist }
        its('lifecycle_state') { should cmp 'ACTIVE' }
      end

      describe google_project(project: restricted_projects_id[environment_code][business_unit]) do
        it { should exist }
        its('lifecycle_state') { should cmp 'ACTIVE' }
      end

      describe google_project(project: peering_projects_id[environment_code][business_unit]) do
        it { should exist }
        its('lifecycle_state') { should cmp 'ACTIVE' }
      end

      restricted_enabled_apis.each do |api|
        describe google_project_service(
          project: restricted_projects_id[environment_code][business_unit],
          name: api
        ) do
          it { should exist }
          its('state') { should cmp 'ENABLED' }
        end
      end
    end
  end

  business_units.each do |business_unit|
    describe google_project(project: shared_project_id['s'][business_unit]) do
      it { should exist }
      its('lifecycle_state') { should cmp 'ACTIVE' }
    end
    shared_apis_enabled.each do |api|
      describe google_project_service(
        project: shared_project_id['s'][business_unit],
        name: api
      ) do
        it { should exist }
        its('state') { should cmp 'ENABLED' }
      end
    end
  end
end
