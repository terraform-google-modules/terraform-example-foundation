# Copyright 2019 Google LLC
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

package templates.gcp.GCPIAMRestrictServiceAccountKeyTypeConstraintV1

all_violations[violation] {
	resource := data.test.fixtures.gcp_iam_restrict_service_account_key_type.assets[_]
	constraint := data.test.fixtures.gcp_iam_restrict_service_account_key_type.constraints

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

# Count total violations
test_service_account_key_type_violations_count {
	count(all_violations) == 1
}

test_service_account_key_type_violation_basic {
	violation_resources := {r | r = all_violations[_].details.resource}
	violation_resources == {"//iam.googleapis.com/projects/forseti-system-test/serviceAccounts/111111-compute@developer.gserviceaccount.com/keys/1234567890abcdef"}
}
