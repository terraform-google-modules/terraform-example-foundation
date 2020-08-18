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
prod_bu1_project_restricted_id = attribute('prod_bu1_project_restricted')
prod_bu1_project_restricted_number = attribute('prod_bu1_project_restricted_number')
prod_bu1_restricted_vpc_service_control_perimeter_name = attribute('prod_bu1_restricted_vpc_service_control_perimeter_name')
prod_bu1_restricted_enabled_apis = attribute('prod_bu1_restricted_enabled_apis')
access_context_manager_policy_id = attribute('access_context_manager_policy_id')

prod_bu2_project_base = attribute('prod_bu2_project_base')
prod_bu2_project_floating = attribute('prod_bu2_project_floating')
prod_bu2_project_restricted_id = attribute('prod_bu2_project_restricted')
prod_bu2_project_restricted_number = attribute('prod_bu2_project_restricted_number')
prod_bu2_restricted_vpc_service_control_perimeter_name = attribute('prod_bu2_restricted_vpc_service_control_perimeter_name')
prod_bu2_restricted_enabled_apis = attribute('prod_bu2_restricted_enabled_apis')


control 'gcp-production' do
  title 'gcp step 4-projects test production'

  describe google_project(project: prod_bu1_project_floating) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_bu1_project_restricted_id) do
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

  describe google_project(project: prod_bu2_project_restricted_id) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: prod_bu2_project_base) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  prod_bu1_restricted_enabled_apis.each do |api|
    describe google_project_service(
      project: prod_bu1_project_restricted_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  prod_bu2_restricted_enabled_apis.each do |api|
    describe google_project_service(
      project: prod_bu2_project_restricted_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end
end


control 'gcloud-production' do
  title 'gcloud step 4-projects test production'

  describe command("gcloud access-context-manager perimeters describe #{prod_bu1_restricted_vpc_service_control_perimeter_name}  --policy #{access_context_manager_policy_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Access Context Manager perimeter #{prod_bu1_restricted_vpc_service_control_perimeter_name}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

      it "should include #{prod_bu1_project_restricted_id} project" do
        expect(data['status']['resources']).to include(
          "projects/#{prod_bu1_project_restricted_number}"
        )
      end
    end
  end

  describe command("gcloud access-context-manager perimeters describe #{prod_bu2_restricted_vpc_service_control_perimeter_name} --policy #{access_context_manager_policy_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Access Context Manager perimeter #{prod_bu2_restricted_vpc_service_control_perimeter_name}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

      it "should include #{prod_bu2_project_restricted_id} project" do
        expect(data['status']['resources']).to include(
          "projects/#{prod_bu2_project_restricted_number}"
        )
      end
    end
  end
end

