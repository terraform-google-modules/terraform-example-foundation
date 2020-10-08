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

package templates.gcp.GCPAppengineLocationConstraintV1

template_name := "GCPAppengineLocationConstraintV1"

import data.validator.test_utils as test_utils

#Importing the test data
import data.test.fixtures.appengine_location.assets as fixture_assets

# Importing the test constraints
import data.test.fixtures.appengine_location.constraints as fixture_constraint

test_appengine_location_violations {
	expected_resource_names := {
		"//appengine.googleapis.com/apps/cf-test-project-1",
		"//appengine.googleapis.com/apps/cf-test-project-2",
	}

	test_utils.check_test_violations(fixture_assets, [fixture_constraint], template_name, expected_resource_names)
}
