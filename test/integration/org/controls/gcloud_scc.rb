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

scc_notifications_project_id = attribute('scc_notifications_project_id')
scc_notification_name = attribute('scc_notification_name')
org_id = attribute('org_id')

control 'gcloud_scc' do
  title 'step 1-org scc notifications tests'

  describe command("gcloud scc notifications describe #{scc_notification_name} --organization=#{org_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:data) do
      if subject.exit_status.zero?
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    it 'The SCC notifications PubSub topic should be top-scc-notification' do
      expect(data).to include(
        'pubsubTopic' => "projects/#{scc_notifications_project_id}/topics/top-scc-notification"
      )
    end
  end
end
