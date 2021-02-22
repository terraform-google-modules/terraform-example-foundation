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

dns_hub_project_id = attribute('dns_hub_project_id')
policy_name = 'dp-dns-hub-default-policy'
dns_hub_network_url = "https://www.googleapis.com/compute/v1/projects/#{dns_hub_project_id}/global/networks/vpc-c-dns-hub"

control 'gcloud_dns_hub' do
  title 'step 3 dns hub gcloud tests'

  describe command("gcloud dns policies list --project #{dns_hub_project_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout).select { |x| x['name'] == policy_name }[0]
      else
        {}
      end
    end

    describe "DNS Hub policy #{policy_name}" do
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
