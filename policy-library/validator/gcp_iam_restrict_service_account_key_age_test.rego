# Copyright 2020 Google LLC
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

package templates.gcp.GCPIAMRestrictServiceAccountKeyAgeConstraintV1

template_name := "GCPIAMRestrictServiceAccountKeyAgeConstraintV1"

import data.validator.test_utils as test_utils

import data.test.fixtures.gcp_iam_restrict_service_account_key_age.assets as fixture_assets
import data.test.fixtures.gcp_iam_restrict_service_account_key_age.constraints as fixture_constraints

# Confirm total violations count
test_service_account_key_age_ninety_days_violations_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.ninety_days], template_name, 2)
}

test_service_account_key_age_one_hundred_days_violations_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.one_hundred_days], template_name, 2)
}

# Confirm violation resources
test_service_account_key_age_ninety_days_resources {
	resource_names := {"//iam.googleapis.com/projects/forseti-system-test/serviceAccounts/111111-compute@developer.gserviceaccount.com/keys/testkeyageover90days", "//iam.googleapis.com/projects/forseti-system-test/serviceAccounts/111111-compute@developer.gserviceaccount.com/keys/testkeyageover100days"}
	test_utils.check_test_violations(fixture_assets, [fixture_constraints.ninety_days], template_name, resource_names)
}

test_service_account_key_age_one_hundred_days_resources {
	resource_names := {"//iam.googleapis.com/projects/forseti-system-test/serviceAccounts/111111-compute@developer.gserviceaccount.com/keys/testkeyageover90days", "//iam.googleapis.com/projects/forseti-system-test/serviceAccounts/111111-compute@developer.gserviceaccount.com/keys/testkeyageover100days"}
	test_utils.check_test_violations(fixture_assets, [fixture_constraints.one_hundred_days], template_name, resource_names)
}
