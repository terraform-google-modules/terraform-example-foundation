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

package validator.test_utils

get_test_violations(test_assets, test_constraints, test_template) = violations {
	violations := [violation |
		violations := data.templates.gcp[test_template].deny with input.asset as test_assets[_]
			 with input.constraint as test_constraints[_]

		violation := violations[_]
	]

	trace(sprintf("violations %s", [violations]))
}

check_test_violations_count(test_assets, test_constraints, test_template, expected_count) {
	violations := get_test_violations(test_assets, test_constraints, test_template)
	count(violations) == expected_count
}

check_test_violations_resources(test_assets, test_constraints, test_template, expected_resource_names) {
	violations := get_test_violations(test_assets, test_constraints, test_template)
	resource_names := {x | x = violations[_].details.resource}
	resource_names == expected_resource_names
}

# This is to check for other field names from violations besides resource
check_test_violations_metadata(test_assets, test_constraints, test_template, field_name, field_values) {
	violations := get_test_violations(test_assets, test_constraints, test_template)
	resource_names := {x | x = violations[_].details[field_name]}
	resource_names == field_values
}

check_test_violations_signature(test_assets, test_constraints, test_template) {
	violations := get_test_violations(test_assets, test_constraints, test_template)
	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

check_test_violations(test_assets, test_constraints, test_template, expected_resource_names) {
	check_test_violations_count(test_assets, test_constraints, test_template, count(expected_resource_names))
	check_test_violations_resources(test_assets, test_constraints, test_template, expected_resource_names)
	check_test_violations_signature(test_assets, test_constraints, test_template)
}
