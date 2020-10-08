#
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

package templates.gcp.GCPAppEngineServiceVersionsConstraintV1

template_name := "GCPAppEngineServiceVersionsConstraintV1"

import data.validator.test_utils as test_utils

import data.test.fixtures.app_service_versions.assets as fixture_assets
import data.test.fixtures.app_service_versions.constraints as fixture_constraints

test_violations_with_default_constraint {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.default_constraint], template_name, 1)
}

violations_with_custom_constraint := test_utils.get_test_violations(fixture_assets, [fixture_constraints.custom_count], template_name)

test_violations_with_custom_constraint {
	count(violations_with_custom_constraint) == 2
}

test_violation_3_versions {
	violation := violations_with_custom_constraint[_]

	violation.details.resource = "//appengine.googleapis.com/apps/test-ae-example/services/three-versions"
}

test_violation_2_versions {
	violation := violations_with_custom_constraint[_]

	violation.details.resource = "//appengine.googleapis.com/apps/test-ae-example/services/two-versions"
}
