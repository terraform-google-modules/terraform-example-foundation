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

cloudbuild_project_id = attribute('cloudbuild_project_id')
gcs_bucket_cloudbuild_artifacts = attribute('gcs_bucket_cloudbuild_artifacts')
csr_repos = attribute('csr_repos')

filenames = ['cloudbuild-tf-plan.yaml', 'cloudbuild-tf-apply.yaml']
branches_regex = ['(dev|nonprod|prod)', '[^dev|nonprod|prod]']

control 'cloudbuild' do
  title 'Cloudbuild sub-module GCP Resources'

  describe google_project(project: cloudbuild_project_id) do
    it { should exist }
  end

  describe google_storage_bucket(name: gcs_bucket_cloudbuild_artifacts) do
    it { should exist }
  end

  csr_repos.each do |repo, _|
    describe google_sourcerepo_repository(project: cloudbuild_project_id, name: repo) do
      it { should exist }
    end
  end

  google_cloudbuild_triggers(project: cloudbuild_project_id).ids.each do |id|
    describe google_cloudbuild_trigger(project: cloudbuild_project_id, id: id) do
      its('filename') { should be_in filenames }
      its('trigger_template.branch_name') { should be_in branches_regex }
      its('trigger_template.repo_name') { should be_in csr_repos.keys }
    end
  end
end
