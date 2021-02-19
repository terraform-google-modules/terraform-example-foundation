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
dev_bu1_network_peering = attribute('dev_bu1_network_peering')
dev_bu1_project_restricted_id = attribute('dev_bu1_project_restricted')
dev_bu1_project_restricted_number = attribute('dev_bu1_project_restricted_number')
dev_bu1_restricted_vpc_service_control_perimeter_name = attribute('dev_bu1_restricted_vpc_service_control_perimeter_name')
dev_bu2_project_base = attribute('dev_bu2_project_base')
dev_bu2_project_floating = attribute('dev_bu2_project_floating')
dev_bu2_project_peering = attribute('dev_bu2_project_peering')
dev_bu2_network_peering = attribute('dev_bu2_network_peering')
dev_bu2_project_restricted_id = attribute('dev_bu2_project_restricted')
dev_bu2_project_restricted_number = attribute('dev_bu2_project_restricted_number')
dev_bu2_restricted_vpc_service_control_perimeter_name = attribute('dev_bu2_restricted_vpc_service_control_perimeter_name')

nonprod_bu1_project_base = attribute('nonprod_bu1_project_base')
nonprod_bu1_project_floating = attribute('nonprod_bu1_project_floating')
nonprod_bu1_project_peering = attribute('nonprod_bu1_project_peering')
nonprod_bu1_network_peering = attribute('nonprod_bu1_network_peering')
nonprod_bu1_project_restricted_id = attribute('nonprod_bu1_project_restricted')
nonprod_bu1_project_restricted_number = attribute('nonprod_bu1_project_restricted_number')
nonprod_bu1_restricted_vpc_service_control_perimeter_name = attribute('nonprod_bu1_restricted_vpc_service_control_perimeter_name')
nonprod_bu2_project_base = attribute('nonprod_bu2_project_base')
nonprod_bu2_project_floating = attribute('nonprod_bu2_project_floating')
nonprod_bu2_project_peering = attribute('nonprod_bu2_project_peering')
nonprod_bu2_network_peering = attribute('nonprod_bu2_network_peering')
nonprod_bu2_project_restricted_id = attribute('nonprod_bu2_project_restricted')
nonprod_bu2_project_restricted_number = attribute('nonprod_bu2_project_restricted_number')
nonprod_bu2_restricted_vpc_service_control_perimeter_name = attribute('nonprod_bu2_restricted_vpc_service_control_perimeter_name')

prod_bu1_project_base = attribute('prod_bu1_project_base')
prod_bu1_project_floating = attribute('prod_bu1_project_floating')
prod_bu1_project_peering = attribute('prod_bu1_project_peering')
prod_bu1_network_peering = attribute('prod_bu1_network_peering')
prod_bu1_project_restricted_id = attribute('prod_bu1_project_restricted')
prod_bu1_project_restricted_number = attribute('prod_bu1_project_restricted_number')
prod_bu1_restricted_vpc_service_control_perimeter_name = attribute('prod_bu1_restricted_vpc_service_control_perimeter_name')
prod_bu2_project_base = attribute('prod_bu2_project_base')
prod_bu2_project_floating = attribute('prod_bu2_project_floating')
prod_bu2_project_peering = attribute('prod_bu2_project_peering')
prod_bu2_network_peering = attribute('prod_bu2_network_peering')
prod_bu2_project_restricted_id = attribute('prod_bu2_project_restricted')
prod_bu2_project_restricted_number = attribute('prod_bu2_project_restricted_number')
prod_bu2_restricted_vpc_service_control_perimeter_name = attribute('prod_bu2_restricted_vpc_service_control_perimeter_name')

access_context_manager_policy_id = attribute('access_context_manager_policy_id')

environment_codes = %w[d n p]

environment_name = {
  'd' => 'development',
  'n' => 'non-production',
  'p' => 'production'
}
business_units = %w[bu1 bu2]

restricted_vpc_service_control_perimeter_name = {
  'd' => { 'bu1' => dev_bu1_restricted_vpc_service_control_perimeter_name, 'bu2' => dev_bu2_restricted_vpc_service_control_perimeter_name },
  'n' => { 'bu1' => nonprod_bu1_restricted_vpc_service_control_perimeter_name, 'bu2' => nonprod_bu2_restricted_vpc_service_control_perimeter_name },
  'p' => { 'bu1' => prod_bu1_restricted_vpc_service_control_perimeter_name, 'bu2' => prod_bu2_restricted_vpc_service_control_perimeter_name }
}

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

restricted_projects_number = {
  'd' => { 'bu1' => dev_bu1_project_restricted_number, 'bu2' => dev_bu2_project_restricted_number },
  'n' => { 'bu1' => nonprod_bu1_project_restricted_number, 'bu2' => nonprod_bu2_project_restricted_number },
  'p' => { 'bu1' => prod_bu1_project_restricted_number, 'bu2' => prod_bu2_project_restricted_number }
}

peering_networks = {
  'd' => { 'bu1' => dev_bu1_network_peering, 'bu2' => dev_bu2_network_peering },
  'n' => { 'bu1' => nonprod_bu1_network_peering, 'bu2' => nonprod_bu2_network_peering },
  'p' => { 'bu1' => prod_bu1_network_peering, 'bu2' => prod_bu2_network_peering }
}

control 'gcloud-projects' do
  title 'gcloud step 4-projects tests'
  environment_codes.each do |environment_code|
    business_units.each do |business_unit|

      describe command("gcloud access-context-manager perimeters describe #{restricted_vpc_service_control_perimeter_name[environment_code][business_unit]} --policy #{access_context_manager_policy_id} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout)
          else
            {}
          end
        end

        describe "Access Context Manager perimeter #{restricted_vpc_service_control_perimeter_name[environment_code][business_unit]}" do
          it 'should exist' do
            expect(data).to_not be_empty
          end

          it "should include #{restricted_projects_id[environment_code][business_unit]} project" do
            expect(data['status']['resources']).to include(
              "projects/#{restricted_projects_number[environment_code][business_unit]}"
            )
          end
        end
      end

      describe command("gcloud compute shared-vpc get-host-project #{restricted_projects_id[environment_code][business_unit]} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout)
          else
            {}
          end
        end

        describe "Verifies if #{restricted_projects_id[environment_code][business_unit]}" do
          it 'is attached to a host project' do
            expect(data).to_not be_empty
          end

          it 'is attached to a project with application_name label equals to restricted-shared-vpc-host' do
            expect JSON.parse(command("gcloud projects describe #{data['name']} --format=json").stdout)['labels']['application_name'].should eq 'restricted-shared-vpc-host'
          end

          it "is attached to a project with environment label equals to #{environment_name[environment_code]}" do
            expect JSON.parse(command("gcloud projects describe #{data['name']} --format=json").stdout)['labels']['environment'].should eq environment_name[environment_code]
          end

          it "is attached to the VPC with name equals to vpc-#{environment_code}-shared-restricted" do
            expect JSON.parse(command("gcloud compute networks list --project #{data['name']} --format=json").stdout)[0]['name'].should eq "vpc-#{environment_code}-shared-restricted"
          end
        end
      end

      describe command("gcloud compute shared-vpc get-host-project #{base_projects_id[environment_code][business_unit]} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout)
          else
            {}
          end
        end

        describe "Verifies if #{base_projects_id[environment_code][business_unit]}" do
          it 'is attached to a host project' do
            expect(data).to_not be_empty
          end

          it 'is attached to a project with application_name label equals to base-shared-vpc-host' do
            expect JSON.parse(command("gcloud projects describe #{data['name']} --format=json").stdout)['labels']['application_name'].should eq 'base-shared-vpc-host'
          end

          it "is attached to a project with environment label equals to #{environment_name[environment_code]}" do
            expect JSON.parse(command("gcloud projects describe #{data['name']} --format=json").stdout)['labels']['environment'].should eq environment_name[environment_code]
          end

          it "is attached to the VPC with name equals to vpc-#{environment_code}-shared-base" do
            expect JSON.parse(command("gcloud compute networks list --project #{data['name']} --format=json").stdout)[0]['name'].should eq "vpc-#{environment_code}-shared-base"
          end
        end
      end

      describe command("gcloud compute shared-vpc get-host-project #{floating_projects_id[environment_code][business_unit]} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout)
          else
            {}
          end
        end
        describe "Verifies if #{floating_projects_id[environment_code][business_unit]}" do
          it 'is NOT attached to a host project' do
            expect(data).to be_empty
          end
        end
      end

      describe command("gcloud compute networks peerings list --project #{peering_projects_id[environment_code][business_unit]} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout)
          else
            {}
          end
        end

        describe "Verifies if #{peering_projects_id[environment_code][business_unit]}" do
          it 'has a network' do
            expect(data).to_not be_empty
          end

          it "has a peering with #{peering_networks[environment_code][business_unit]['network']}" do
            expect(data[0]['peerings'][0]['network'].should eq peering_networks[environment_code][business_unit]['network'])
          end
        end
      end
    end
  end
end
