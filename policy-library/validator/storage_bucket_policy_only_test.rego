#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package templates.gcp.GCPStorageBucketPolicyOnlyConstraintV1

resources_in_violation[resource] {
	asset := data.test.fixtures.storage_bucket_policy_only.assets[_]
	constraint := data.test.fixtures.storage_bucket_policy_only.constraints.require_bucket_policy_only
	issues := deny with input.asset as asset
		 with input.constraint as constraint

	resource := issues[_].details.resource
}

test_storage_bucket_policy_only_enabled {
	not resources_in_violation["//storage.googleapis.com/my-storage-bucket-with-bucketpolicyonly"]
}

test_storage_bucket_policy_only_violations_no_data {
	resources_in_violation["//storage.googleapis.com/my-storage-bucket-with-no-bucketpolicyonly-data"]
}

test_storage_bucket_policy_only_violations_null_data {
	resources_in_violation["//storage.googleapis.com/my-storage-bucket-with-null-bucketpolicyonly"]
}
