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

scc_notifications_project_id = attribute('scc_notifications_project_id')
scc_notification_name = attribute('scc_notification_name')
parent_resource_type = attribute('parent_resource_type')
parent_resource_id = attribute('parent_resource_id')
org_id = attribute('org_id')
domains_to_allow = attribute('domains_to_allow')

boolean_policy_constraints = [
  'constraints/compute.disableNestedVirtualization',
  'compute.disableSerialPortAccess',
  'constraints/compute.disableGuestAttributesAccess',
  'constraints/compute.vmExternalIpAccess',
  'constraints/compute.skipDefaultNetworkCreation',
  'constraints/compute.restrictXpnProjectLienRemoval',
  'constraints/sql.restrictPublicIp',
  'constraints/iam.disableServiceAccountKeyCreation',
  'constraints/storage.uniformBucketLevelAccess'
]

control 'gcloud' do
  title 'gcloud step 1-org tests'

  describe command("gcloud alpha scc notifications describe #{scc_notification_name} --organization=#{org_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    it 'SCC notifications PubSub topic should be top-scc-notification' do
      expect(data).to include(
        'pubsubTopic' => "projects/#{scc_notifications_project_id}/topics/top-scc-notification"
      )
    end
  end

  if parent_resource_type == 'folder'

    boolean_policy_constraints.each do |constraint|
      describe command("gcloud beta resource-manager org-policies list --folder=#{parent_resource_id} --format=json") do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq '' }

        let(:data) do
          if subject.exit_status == 0
            JSON.parse(subject.stdout).select { |x| x['constraint'] == constraint }[0]
          else
            {}
          end
        end

        describe "boolean folder org policy #{constraint}" do
          it 'should exist' do
            expect(data).to_not be_empty
          end
        end
      end
    end

    describe command("gcloud beta resource-manager org-policies list --folder=#{parent_resource_id} --format=json") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }

      let(:data) do
        if subject.exit_status == 0
          JSON.parse(subject.stdout).select { |x| x['constraint'] == 'constraints/iam.allowedPolicyMemberDomains' }[0]
        else
          {}
        end
      end

      describe 'list folder org policy iam.allowedPolicyMemberDomains' do
        it 'should exist' do
          expect(data).to_not be_empty
        end

        domains_to_allow.each do |domain|
          it "domain #{domain} should be allowed" do
            expect(data['listPolicy']).to include(
              'allowedValues' => [domain]
            )
          end
        end
      end
    end
  end
end
