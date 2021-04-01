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

cloudbuild_project_id = attribute('cloudbuild_project_id')
branches_regex = '^(development|non\\-production|production)$'
cloud_source_repos = [
  'gcp-org',
  'gcp-environments',
  'gcp-networks',
  'gcp-projects'
]

control 'gcloud_cloudbuild' do
  title 'Cloudbuild sub-module GCP Resources'

  cloud_source_repos.each do |repo|
    describe command(
      "gcloud beta builds triggers list \
      --project #{cloudbuild_project_id} \
      --filter \"trigger_template.branch_name='#{branches_regex}' AND \
      trigger_template.repo_name='#{repo}' AND \
      substitutions._TF_ACTION='apply'\" --format=json"
    ) do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }

      let(:data) do
        if subject.exit_status.zero?
          JSON.parse(subject.stdout)
        else
          {}
        end
      end

      describe "trigger for repo #{repo} and branch name #{branches_regex}" do
        it 'should exist' do
          expect(data).to_not be_empty
        end
      end
    end

    describe command(
      "gcloud beta builds triggers list \
      --project #{cloudbuild_project_id} \
      --filter \"trigger_template.branch_name='#{branches_regex}' AND \
      trigger_template.repo_name='#{repo}' AND \
      substitutions._TF_ACTION='plan' AND \
      trigger_template.invert_regex=true\" --format=json"
    ) do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }

      let(:data) do
        if subject.exit_status.zero?
          JSON.parse(subject.stdout)
        else
          {}
        end
      end

      describe "trigger for repo #{repo} and branch name #{branches_regex}" do
        it 'should exist' do
          expect(data).to_not be_empty
        end
      end
    end
  end
end
