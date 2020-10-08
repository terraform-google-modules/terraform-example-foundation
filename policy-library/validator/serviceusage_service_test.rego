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

package templates.gcp.GCPServiceUsageConstraintV1

template_name := "GCPServiceUsageConstraintV1"

import data.validator.test_utils as test_utils

#Importing the test data
import data.test.fixtures.serviceusage_service.assets as fixture_assets

# Importing the test constraints
import data.test.fixtures.serviceusage_service.constraints.serviceusage_allow_compute as fixture_constraint_allow
import data.test.fixtures.serviceusage_service.constraints.serviceusage_deny_cloudvisionapi as fixture_constraint_deny

test_allowed_resource_types_allowlist_violations {
	expected_resource_names := {"//serviceusage.googleapis.com/projects/123/services/cloudvision.googleapis.com"}

	test_utils.check_test_violations(fixture_assets, [fixture_constraint_allow], template_name, expected_resource_names)
}

test_allowed_resource_types_denylist_violations {
	expected_resource_names := {"//serviceusage.googleapis.com/projects/123/services/cloudvision.googleapis.com"}

	test_utils.check_test_violations(fixture_assets, [fixture_constraint_deny], template_name, expected_resource_names)
}
