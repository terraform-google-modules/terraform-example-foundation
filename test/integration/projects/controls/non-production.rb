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

nonprod_bu1_project_base = attribute('nonprod_bu1_project_base')
nonprod_bu1_project_floating = attribute('nonprod_bu1_project_floating')
nonprod_bu1_project_restricted_id = attribute('nonprod_bu1_project_restricted')
nonprod_bu1_project_restricted_number = attribute('nonprod_bu1_project_restricted_number')
nonprod_bu1_restricted_vpc_service_control_perimeter_name = attribute('nonprod_bu1_restricted_vpc_service_control_perimeter_name')
nonprod_bu1_restricted_enabled_apis = attribute('nonprod_bu1_restricted_enabled_apis')
access_context_manager_policy_id = attribute('access_context_manager_policy_id')

nonprod_bu2_project_base = attribute('nonprod_bu2_project_base')
nonprod_bu2_project_floating = attribute('nonprod_bu2_project_floating')
nonprod_bu2_project_restricted_id = attribute('nonprod_bu2_project_restricted')
nonprod_bu2_project_restricted_number = attribute('nonprod_bu2_project_restricted_number')
nonprod_bu2_restricted_vpc_service_control_perimeter_name = attribute('nonprod_bu2_restricted_vpc_service_control_perimeter_name')
nonprod_bu2_restricted_enabled_apis = attribute('nonprod_bu2_restricted_enabled_apis')


control 'gcp-non-production' do
  title 'gcp step 4-projects test non-production'

  describe google_project(project: nonprod_bu1_project_floating) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: nonprod_bu1_project_restricted_id) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: nonprod_bu1_project_base) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: nonprod_bu2_project_floating) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: nonprod_bu2_project_restricted_id) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  describe google_project(project: nonprod_bu2_project_base) do
    it { should exist }
    its('lifecycle_state') { should cmp 'ACTIVE' }
  end

  nonprod_bu1_restricted_enabled_apis.each do |api|
    describe google_project_service(
      project: nonprod_bu1_project_restricted_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end

  nonprod_bu2_restricted_enabled_apis.each do |api|
    describe google_project_service(
      project: nonprod_bu2_project_restricted_id,
      name: api
    ) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end
end


control 'gcloud-non-production' do
  title 'gcloud step 4-projects test non-production'

  describe command("gcloud access-context-manager perimeters describe #{nonprod_bu1_restricted_vpc_service_control_perimeter_name}  --policy #{access_context_manager_policy_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Access Context Manager perimeter #{nonprod_bu1_restricted_vpc_service_control_perimeter_name}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

      it "should include #{nonprod_bu1_project_restricted_id} project" do
        expect(data['status']['resources']).to include(
          "projects/#{nonprod_bu1_project_restricted_number}"
        )
      end
    end
  end

  describe command("gcloud access-context-manager perimeters describe #{nonprod_bu2_restricted_vpc_service_control_perimeter_name} --policy #{access_context_manager_policy_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Access Context Manager perimeter #{nonprod_bu2_restricted_vpc_service_control_perimeter_name}" do
      it 'should exist' do
        expect(data).to_not be_empty
      end

      it "should include #{nonprod_bu2_project_restricted_id} project" do
        expect(data['status']['resources']).to include(
          "projects/#{nonprod_bu2_project_restricted_number}"
        )
      end
    end
  end
  describe command("gcloud compute shared-vpc get-host-project #{nonprod_bu1_project_floating} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies if #{nonprod_bu1_project_floating}" do
      it 'is not attached to any host project' do
        expect(data).to be_empty
      end
    end
  end

  describe command("gcloud compute shared-vpc get-host-project #{nonprod_bu2_project_floating} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies if #{nonprod_bu2_project_floating}" do
      it 'is not attached to any host project' do
        expect(data).to be_empty
      end
    end
  end

  describe command("gcloud compute shared-vpc get-host-project #{nonprod_bu1_project_restricted_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies if #{nonprod_bu1_project_restricted_id}" do
      it 'is attached to a host project' do
        expect(data).to_not be_empty
      end
    end
  end

  describe command("gcloud compute shared-vpc get-host-project #{nonprod_bu2_project_restricted_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies if #{nonprod_bu2_project_restricted_id}" do
      it 'is attached to a host project' do
        expect(data).to_not be_empty
      end
    end
  end

  describe command("gcloud compute shared-vpc get-host-project #{nonprod_bu1_project_base} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies if #{nonprod_bu1_project_base}" do
      it 'is attached to a host project' do
        expect(data).to_not be_empty
      end
    end
  end

  describe command("gcloud compute shared-vpc get-host-project #{nonprod_bu2_project_base} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "Verifies if #{nonprod_bu2_project_base}" do
      it 'is attached to a host project' do
        expect(data).to_not be_empty
      end
    end
  end
end
