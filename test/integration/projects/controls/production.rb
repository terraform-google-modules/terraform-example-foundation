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

prod_bu1_project_base = attribute('prod_bu1_project_base')
prod_bu1_project_floating = attribute('prod_bu1_project_floating')
prod_bu1_project_restricted = attribute('prod_bu1_project_restricted')

prod_bu2_project_base = attribute('prod_bu2_project_base')
prod_bu2_project_floating = attribute('prod_bu2_project_floating')
prod_bu2_project_restricted = attribute('prod_bu2_project_restricted')

control 'production' do
  title 'gcp step 4-projects test production'

  describe google_project(project: prod_bu1_project_floating) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_bu1_project_restricted) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_bu1_project_base) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_bu2_project_floating) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_bu2_project_restricted) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_bu2_project_base) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end
end
