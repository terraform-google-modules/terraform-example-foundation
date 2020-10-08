#
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

package templates.gcp.GCPStorageBucketRetentionConstraintV1

# Importing the test data
import data.test.fixtures.storage_bucket_retention.assets.buckets_all as fixture_assets_all
import data.test.fixtures.storage_bucket_retention.assets.buckets_delete_action_no_age as fixture_assets_no_age
import data.test.fixtures.storage_bucket_retention.assets.buckets_delete_action_versions as fixture_assets_versions
import data.test.fixtures.storage_bucket_retention.assets.buckets_multiple_delete_action as fixture_assets_multiple_delete_action
import data.test.fixtures.storage_bucket_retention.assets.buckets_no_action as fixture_assets_no_action
import data.test.fixtures.storage_bucket_retention.assets.buckets_non_delete_action as fixture_assets_non_delete_action

# Importing the test constraints
import data.test.fixtures.storage_bucket_retention.constraints.max_retention_only as max_retention_only
import data.test.fixtures.storage_bucket_retention.constraints.max_retention_only_one_exemption as max_retention_only_one_exemption
import data.test.fixtures.storage_bucket_retention.constraints.min_max_retention as min_max_retention
import data.test.fixtures.storage_bucket_retention.constraints.min_max_retention_one_exemption as min_max_retention_one_exemption
import data.test.fixtures.storage_bucket_retention.constraints.min_retention_only as min_retention_only
import data.test.fixtures.storage_bucket_retention.constraints.min_retention_only_one_exemption as min_retention_only_one_exemption

# Find all violations on our test cases
find_all_violations[violation] {
	resources := data.resources[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as resources
		 with input.constraint as constraint

	violation := issues[_]
}

# Test for no violations with no assets
test_storage_bucket_retention_no_assets {
	violations := find_all_violations with data.resources as []

	count(violations) == 0
}

# Test for maximum retention when buckets have multiple delete actions
violations_with_maximum_retention_multiple_delete_actions[violation] {
	constraints := [max_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_multiple_delete_action
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_max_retention_multiple_delete_actions {
	violations := violations_with_maximum_retention_multiple_delete_actions

	count(violations) == 1

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions"}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for maximum retention when buckets have no actions
violations_with_maximum_retention_no_action[violation] {
	constraints := [max_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_no_action
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_max_retention_no_action {
	violations := violations_with_maximum_retention_no_action

	count(violations) == count(fixture_assets_no_action)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-server-612d6ab-no-action",
		"//storage.googleapis.com/forseti-client-c9e3dd73-no-action",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for maximum retention when buckets have non delete actions
violations_with_maximum_retention_non_delete_action[violation] {
	constraints := [max_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_non_delete_action
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_max_retention_non_delete_action {
	violations := violations_with_maximum_retention_non_delete_action

	count(violations) == count(fixture_assets_non_delete_action)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-client-c9e3dd73-non-delete-actions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for maximum retention when bucket age is greater
violations_with_maximum_retention_age[violation] {
	constraints := [max_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_multiple_delete_action
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_max_retention_age {
	violations := violations_with_maximum_retention_age

	count(violations) == 1

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions"}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for maximum retention when 'age' condition does not exist in Delete action
violations_with_maximum_retention_no_age[violation] {
	constraints := [max_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_no_age
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_max_retention_age {
	violations := violations_with_maximum_retention_no_age

	count(violations) == count(fixture_assets_no_age)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-delete-action-no-age",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for maximum retention with all conditions
violations_with_maximum_retention_all[violation] {
	constraints := [max_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_all
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_max_retention_all {
	violations := violations_with_maximum_retention_all

	count(violations) == count(fixture_assets_all)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions",
		"//storage.googleapis.com/forseti-server-612d6ab-no-action",
		"//storage.googleapis.com/forseti-client-c9e3dd73-no-action",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-client-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-versions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum retention when bucket age is less than
violations_with_minimum_retention_age[violation] {
	constraints := [min_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_multiple_delete_action
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_min_retention_age {
	violations := violations_with_minimum_retention_age

	count(violations) == count(fixture_assets_multiple_delete_action)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-multiple-delete-actions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum retention when 'numNewerVersions' condition is 0 or does not exist
violations_with_minimum_retention_versions[violation] {
	constraints := [min_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_versions
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_min_retention_versions {
	violations := violations_with_minimum_retention_versions

	count(violations) == 1

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-versions"}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum retention with all conditions (except createdBefore due to real time dependence)
violations_with_minimum_retention_all[violation] {
	constraints := [min_retention_only]
	violations := find_all_violations with data.resources as fixture_assets_all
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_min_retention_all {
	violations := violations_with_minimum_retention_all

	count(violations) == 4

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-versions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum maximum retention with all conditions (except createdBefore due to real time dependence)
violations_with_minimum_maximum_retention_all[violation] {
	constraints := [min_max_retention]
	violations := find_all_violations with data.resources as fixture_assets_all
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_min_max_retention_all {
	violations := violations_with_minimum_maximum_retention_all

	count(violations) == count(fixture_assets_all)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions",
		"//storage.googleapis.com/forseti-server-612d6ab-no-action",
		"//storage.googleapis.com/forseti-client-c9e3dd73-no-action",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-client-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-versions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for maximum retention with all conditions and one exemption
violations_with_maximum_retention_all_one_exemption[violation] {
	constraints := [max_retention_only_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets_all
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_max_retention_all_one_exemption {
	violations := violations_with_maximum_retention_all_one_exemption

	count(violations) == 7

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-client-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions",
		"//storage.googleapis.com/forseti-server-612d6ab-no-action",
		"//storage.googleapis.com/forseti-client-c9e3dd73-no-action",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-client-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-versions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum retention with all conditions and one exemption (except createdBefore due to real time dependence)
violations_with_minimum_retention_all_one_exemption[violation] {
	constraints := [min_retention_only_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets_all
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_min_retention_all_one_exemption {
	violations := violations_with_minimum_retention_all_one_exemption

	count(violations) == 3

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-client-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-versions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum maximum retention with all conditions and one exemption (except createdBefore due to real time dependence)
violations_with_minimum_maximum_retention_all_one_exemption[violation] {
	constraints := [min_max_retention_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets_all
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_storage_bucket_retention_min_max_retention_all_one_exemption {
	violations := violations_with_minimum_maximum_retention_all_one_exemption

	count(violations) == 7

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//storage.googleapis.com/forseti-client-c9e3dd73-delete-action-no-age",
		"//storage.googleapis.com/forseti-client-c9e3dd73-multiple-delete-actions",
		"//storage.googleapis.com/forseti-server-612d6ab-no-action",
		"//storage.googleapis.com/forseti-client-c9e3dd73-no-action",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-client-c9e3dd73-non-delete-actions",
		"//storage.googleapis.com/forseti-cai-export-c9e3dd73-delete-action-versions",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}
