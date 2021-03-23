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

parent_resource_id = attribute('parent_resource_id')
domains_to_allow = attribute('domains_to_allow')

boolean_policy_constraints = [
  'constraints/compute.disableNestedVirtualization',
  'constraints/compute.disableSerialPortAccess',
  'constraints/compute.disableGuestAttributesAccess',
  'constraints/compute.vmExternalIpAccess',
  'constraints/compute.skipDefaultNetworkCreation',
  'constraints/compute.requireOsLogin',
  'constraints/compute.restrictXpnProjectLienRemoval',
  'constraints/sql.restrictPublicIp',
  'constraints/iam.disableServiceAccountKeyCreation',
  'constraints/storage.uniformBucketLevelAccess',
  'constraints/iam.automaticIamGrantsForDefaultServiceAccounts'
]

control 'gcloud_policy' do
  title 'step 1-org folder organization policy tests'

  boolean_policy_constraints.each do |constraint|
    describe command("gcloud beta resource-manager org-policies list --folder=#{parent_resource_id} --format=json") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }

      let(:data) do
        if subject.exit_status.zero?
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
      if subject.exit_status.zero?
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
        let(:customer_id) do
          org = command("gcloud organizations list --filter='display_name = #{domain}' --format json")
          if org.exit_status.zero?
            JSON.parse(org.stdout)[0]['owner']['directoryCustomerId']
          else
            ''
          end
        end

        it "#{domain} should be allowed" do
          expect(data['listPolicy']).to include(
            'allowedValues' => [customer_id]
          )
        end
      end
    end
  end
end
