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

acm_policy_name = attribute('access_context_manager_policy_id')

enable_hub_and_spoke = attribute('enable_hub_and_spoke')

dev_restricted_access_level_name = attribute('dev_restricted_access_level_name')
nonprod_restricted_access_level_name = attribute('nonprod_restricted_access_level_name')
prod_restricted_access_level_name = attribute('prod_restricted_access_level_name')

dev_restricted_service_perimeter_name = attribute('dev_restricted_service_perimeter_name')
nonprod_restricted_service_perimeter_name = attribute('nonprod_restricted_service_perimeter_name')
prod_restricted_service_perimeter_name = attribute('prod_restricted_service_perimeter_name')

restricted_dev_project_id = attribute('dev_restricted_host_project_id')
restricted_nonprod_project_id = attribute('nonprod_restricted_host_project_id')
restricted_prod_project_id = attribute('prod_restricted_host_project_id')

base_dev_project_id = attribute('dev_base_host_project_id')
base_nonprod_project_id = attribute('nonprod_base_host_project_id')
base_prod_project_id = attribute('prod_base_host_project_id')

environment_codes = %w(d n p)

access_level_names = {
  'd' => dev_restricted_access_level_name,
  'n' => nonprod_restricted_access_level_name,
  'p' => prod_restricted_access_level_name
}

perimeters_names = {
  'd' => dev_restricted_service_perimeter_name,
  'n' => nonprod_restricted_service_perimeter_name,
  'p' => prod_restricted_service_perimeter_name
}

projects_id = {
  'd' => { 'base' => base_dev_project_id, 'restricted' => restricted_dev_project_id },
  'n' => { 'base' => base_nonprod_project_id, 'restricted' => restricted_nonprod_project_id },
  'p' => { 'base' => base_prod_project_id, 'restricted' => restricted_prod_project_id }
}

types = %w(base restricted)

restricted_services = ['bigquery.googleapis.com', 'storage.googleapis.com']

control 'gcloud_networks' do
  title 'step 3 networks gcloud tests'

  environment_codes.each do |environment_code|
    service_perimeter_name = "accessPolicies/#{acm_policy_name}/servicePerimeters/#{perimeters_names[environment_code]}"
    access_levels = ["accessPolicies/#{acm_policy_name}/accessLevels/#{access_level_names[environment_code]}"]

    types.each do |type|
      vpc_name = enable_hub_and_spoke ? "#{environment_code}-shared-#{type}-spoke" : "#{environment_code}-shared-#{type}"
      network_name = "vpc-#{vpc_name}"

      dns_hub_network_url = "https://www.googleapis.com/compute/v1/projects/#{projects_id[environment_code][type]}/global/networks/#{network_name}"

      dns_policy_name = "dp-#{environment_code}-shared-base-default-policy"

      dns_policy_name = 'default-policy' if type == 'restricted'

      describe command("gcloud dns policies list --project #{projects_id[environment_code][type]} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status.zero?
            JSON.parse(subject.stdout).select { |x| x['name'] == dns_policy_name }[0]
          else
            {}
          end
        end

        describe "DNS policy #{dns_policy_name}" do
          it 'should exist' do
            expect(data).to_not be_empty
          end

          it 'should enable inbound fowarding' do
            expect(data).to include(
              'enableInboundForwarding' => true
            )
          end

          it "should have network url #{dns_hub_network_url}" do
            expect(data['networks'][0]).to include(
              'networkUrl' => dns_hub_network_url
            )
          end
        end
      end
    end

    describe command("gcloud access-context-manager perimeters list --policy=#{acm_policy_name} --format json") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }

      let(:data) do
        if subject.exit_status.zero?
          JSON.parse(subject.stdout).select { |x| x['name'] == service_perimeter_name }[0]
        else
          {}
        end
      end

      describe "Service perimiter name #{perimeters_names[environment_code]}" do
        it 'should exist' do
          expect(data).to_not be_empty
        end

        it "should have accessLevels #{access_levels}" do
          expect(data['status']).to include(
            'accessLevels' => access_levels
          )
        end

        it "should have restrictedServices #{restricted_services}" do
          expect(data['status']).to include(
            'restrictedServices' => restricted_services
          )
        end
      end
    end
  end
end
