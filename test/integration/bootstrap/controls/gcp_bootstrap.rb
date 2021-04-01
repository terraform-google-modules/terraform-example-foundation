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

org_id = attribute('org_id')
seed_project_id = attribute('seed_project_id')
gcs_bucket_tfstate = attribute('gcs_bucket_tfstate')
terraform_service_account = attribute('terraform_service_account')

activate_apis = [
  'serviceusage.googleapis.com',
  'servicenetworking.googleapis.com',
  'compute.googleapis.com',
  'logging.googleapis.com',
  'bigquery.googleapis.com',
  'cloudresourcemanager.googleapis.com',
  'cloudbilling.googleapis.com',
  'iam.googleapis.com',
  'admin.googleapis.com',
  'appengine.googleapis.com',
  'storage-api.googleapis.com',
  'monitoring.googleapis.com',
  'pubsub.googleapis.com',
  'securitycenter.googleapis.com',
  'accesscontextmanager.googleapis.com'
]

sa_org_iam_permissions = [
  'roles/accesscontextmanager.policyAdmin',
  'roles/billing.user',
  'roles/compute.networkAdmin',
  'roles/compute.xpnAdmin',
  'roles/iam.securityAdmin',
  'roles/iam.serviceAccountAdmin',
  'roles/logging.configWriter',
  'roles/orgpolicy.policyAdmin',
  'roles/resourcemanager.folderAdmin',
  'roles/securitycenter.notificationConfigEditor',
  'roles/resourcemanager.organizationViewer'
]

org_name = "organizations/#{org_id}"

control 'gcp_bootstrap' do
  title 'Bootstrap module GCP resources'

  describe google_project(project: seed_project_id) do
    it { should exist }
  end

  describe google_storage_bucket(name: gcs_bucket_tfstate) do
    it { should exist }
  end

  describe google_service_account(project: seed_project_id, name: terraform_service_account) do
    it { should exist }
  end

  sa_org_iam_permissions.each do |role|
    describe google_organization_iam_binding(name: org_name, role: role) do
      it { should exist }
      its('members') { should include "serviceAccount:#{terraform_service_account}" }
    end
  end

  activate_apis.each do |api|
    describe google_project_service(project: seed_project_id, name: api) do
      it { should exist }
      its('state') { should cmp 'ENABLED' }
    end
  end
end
