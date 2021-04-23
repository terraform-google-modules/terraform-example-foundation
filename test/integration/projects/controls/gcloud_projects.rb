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

enable_hub_and_spoke = attribute('enable_hub_and_spoke')

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

shared_vpc_mode = enable_hub_and_spoke ? "-spoke" : ""

dev_bu1_project_base_sa = attribute('dev_bu1_project_base_sa')
dev_bu2_project_base_sa = attribute('dev_bu2_project_base_sa')
nonprod_bu1_project_base_sa = attribute('nonprod_bu1_project_base_sa')
nonprod_bu2_project_base_sa = attribute('nonprod_bu2_project_base_sa')
prod_bu1_project_base_sa = attribute('prod_bu1_project_base_sa')
prod_bu2_project_base_sa = attribute('prod_bu2_project_base_sa')

shared_bu1_cb_sa = attribute('shared_bu1_cb_sa')
shared_bu1_artifact_buckets = attribute('shared_bu1_artifact_buckets')
shared_bu1_state_buckets = attribute('shared_bu1_state_buckets')
shared_bu1_plan_triggers = attribute('shared_bu1_plan_triggers')
shared_bu1_apply_triggers = attribute('shared_bu1_apply_triggers')
shared_bu2_cb_sa = attribute('shared_bu2_cb_sa')
shared_bu2_artifact_buckets = attribute('shared_bu2_artifact_buckets')
shared_bu2_state_buckets = attribute('shared_bu2_state_buckets')
shared_bu2_plan_triggers = attribute('shared_bu2_plan_triggers')
shared_bu2_apply_triggers = attribute('shared_bu2_apply_triggers')

shared_bu1_default_region = attribute('shared_bu1_default_region')
shared_bu1_tf_runner_artifact_repo = attribute('shared_bu1_tf_runner_artifact_repo')
shared_bu1_build_project = attribute('shared_bu1_build_project')
shared_bu2_default_region = attribute('shared_bu2_default_region')
shared_bu2_tf_runner_artifact_repo = attribute('shared_bu2_tf_runner_artifact_repo')
shared_bu2_build_project = attribute('shared_bu2_build_project')

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

base_project_sa = {
  'd' => { 'bu1' => dev_bu1_project_base_sa, 'bu2' => dev_bu2_project_base_sa },
  'n' => { 'bu1' => nonprod_bu1_project_base_sa, 'bu2' => nonprod_bu2_project_base_sa },
  'p' => { 'bu1' => prod_bu1_project_base_sa, 'bu2' => prod_bu2_project_base_sa }
}

cloudbuild_sa = {
  'bu1' => shared_bu1_cb_sa, 'bu2' => shared_bu2_cb_sa
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

artifact_register = {
  'bu1' => {
    'default_region' => shared_bu1_default_region,
    'tf_runner_artifact_repo' => shared_bu1_tf_runner_artifact_repo,
    'project_id' => shared_bu1_build_project
  },
  'bu2' => {
    'default_region' => shared_bu2_default_region,
    'tf_runner_artifact_repo' => shared_bu2_tf_runner_artifact_repo,
    'project_id' => shared_bu2_build_project
  },
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

      describe command("gcloud iam service-accounts get-iam-policy #{base_project_sa[environment_code][business_unit]} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout)
          else
            {}
          end
        end

        describe "#{base_project_sa[environment_code][business_unit]} IAM Policy" do
          it 'should exist' do
            expect(data).to_not be_empty
          end
          it "#{cloudbuild_sa[business_unit]} Cloud Build SA should have the right role for impersonation on #{base_project_sa[environment_code][business_unit]} SA" do
            expect(data['bindings'][0]['members']).to include(
              "serviceAccount:#{cloudbuild_sa[business_unit]}"
            )
            expect(data['bindings'][0]['role']).to eq "roles/iam.serviceAccountTokenCreator"
          end
        end
      end

      describe command("gcloud projects get-iam-policy #{base_projects_id[environment_code][business_unit]} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout)
          else
            {}
          end
        end

        describe "#{base_projects_id[environment_code][business_unit]} IAM Policy" do
          it 'should exist' do
            expect(data).to_not be_empty
          end
          it "#{base_project_sa[environment_code][business_unit]} Base project SA should have the Editor role on #{base_projects_id[environment_code][business_unit]}" do
            expect(data['bindings'][1]['members']).to include(
              "serviceAccount:#{base_project_sa[environment_code][business_unit]}"
            )
            expect(data['bindings'][1]['role']).to eq "roles/editor"
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

          it "is attached to the VPC with name equals to vpc-#{environment_code}-shared-restricted#{shared_vpc_mode}" do
            expect JSON.parse(command("gcloud compute networks list --project #{data['name']} --format=json").stdout)[0]['name'].should eq "vpc-#{environment_code}-shared-restricted#{shared_vpc_mode}"
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

          it "is attached to the VPC with name equals to vpc-#{environment_code}-shared-base#{shared_vpc_mode}" do
            expect JSON.parse(command("gcloud compute networks list --project #{data['name']} --format=json").stdout)[0]['name'].should eq "vpc-#{environment_code}-shared-base#{shared_vpc_mode}"
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
            expect(data[0]['peerings'][0]['network'].should eq peering_networks[environment_code][business_unit][:network])
          end
        end
      end
    end
  end
  business_units.each do |business_unit|
    describe command("gcloud artifacts repositories describe #{artifact_register[business_unit]['tf_runner_artifact_repo']} --project=#{artifact_register[business_unit]['project_id']} --location=#{artifact_register[business_unit]['default_region']} --format=json") do
      its(:exit_status) { should eq 0 }

      let(:data) do
        if subject.exit_status.zero?
          JSON.parse(subject.stdout)
        else
          {}
        end
      end

      describe "Artifact Repository #{artifact_register[business_unit]['tf_runner_artifact_repo']} in #{artifact_register[business_unit]['project_id']}" do
        it 'should exist' do
          expect(data).to_not be_empty
        end

        it "Artifact repo name should be projects/#{artifact_register[business_unit]['project_id']}/locations/#{artifact_register[business_unit]['default_region']}/repositories/#{artifact_register[business_unit]['tf_runner_artifact_repo']}" do
          expect(data['name']).to eq "projects/#{artifact_register[business_unit]['project_id']}/locations/#{artifact_register[business_unit]['default_region']}/repositories/#{artifact_register[business_unit]['tf_runner_artifact_repo']}"
        end
      end
    end
  end
end
