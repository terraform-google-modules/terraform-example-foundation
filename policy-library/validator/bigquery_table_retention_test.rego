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

package templates.gcp.GCPBigQueryTableRetentionConstraintV1

# Importing the test data
import data.test.fixtures.bigquery_table_retention.assets as fixture_assets

# Importing the test constraints
import data.test.fixtures.bigquery_table_retention.constraints.max_retention_only as max_retention_only
import data.test.fixtures.bigquery_table_retention.constraints.max_retention_only_one_exemption as max_retention_only_one_exemption
import data.test.fixtures.bigquery_table_retention.constraints.min_max_retention as min_max_retention
import data.test.fixtures.bigquery_table_retention.constraints.min_max_retention_one_exemption as min_max_retention_one_exemption
import data.test.fixtures.bigquery_table_retention.constraints.min_retention_only as min_retention_only
import data.test.fixtures.bigquery_table_retention.constraints.min_retention_only_one_exemption as min_retention_only_one_exemption

# Find all violations on our test cases
find_all_violations[violation] {
	resources := data.resources[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as resources
		 with input.constraint as constraint

	violation := issues[_]
}

# Test for no violations with no assets
test_bigquery_table_retention_no_assets {
	violations := find_all_violations with data.resources as []

	count(violations) == 0
}

# Test for maximum retention
violations_with_maximum_retention[violation] {
	constraints := [max_retention_only]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_bigquery_table_retention_max_retention {
	violations := violations_with_maximum_retention

	count(violations) == 2

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//bigquery.googleapis.com/projects/forseti-ia/datasets/forseti/tables/forseti_fw_rules",
		"//bigquery.googleapis.com/projects/forseti-ia/datasets/forseti_ml/tables/sample_data",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum retention
violations_with_minimum_retention[violation] {
	constraints := [min_retention_only]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_bigquery_table_retention_min_retention {
	violations := violations_with_minimum_retention

	count(violations) == 1

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {"//bigquery.googleapis.com/projects/forseti-test-110/datasets/my_bq_dataset/tables/my_bq_table"}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum and maximum retention
violations_with_minimum_maximum_retention[violation] {
	constraints := [min_max_retention]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_bigquery_table_retention_min_max_retention {
	violations := violations_with_minimum_maximum_retention

	count(violations) == count(fixture_assets)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//bigquery.googleapis.com/projects/forseti-test-110/datasets/my_bq_dataset/tables/my_bq_table",
		"//bigquery.googleapis.com/projects/forseti-ia/datasets/forseti/tables/forseti_fw_rules",
		"//bigquery.googleapis.com/projects/forseti-ia/datasets/forseti_ml/tables/sample_data",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for maximum retention with one exemption
violations_with_maximum_retention_one_exemption[violation] {
	constraints := [max_retention_only_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_bigquery_table_retention_max_retention_one_exemption {
	violations := violations_with_maximum_retention_one_exemption

	count(violations) == 1

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {"//bigquery.googleapis.com/projects/forseti-ia/datasets/forseti_ml/tables/sample_data"}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test for minimum retention with one exemption
violations_with_minimum_retention_one_exemption[violation] {
	constraints := [min_retention_only_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_bigquery_table_retention_min_retention_one_exemption {
	violations := violations_with_minimum_retention_one_exemption

	count(violations) == 0
}

# Test for minimum and maximum retention with one exception
violations_with_minimum_maximum_retention_one_exception[violation] {
	constraints := [min_max_retention_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_bigquery_table_retention_min_max_retention_one_exception {
	violations := violations_with_minimum_maximum_retention_one_exception

	count(violations) == 2

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//bigquery.googleapis.com/projects/forseti-ia/datasets/forseti/tables/forseti_fw_rules",
		"//bigquery.googleapis.com/projects/forseti-ia/datasets/forseti_ml/tables/sample_data",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}
