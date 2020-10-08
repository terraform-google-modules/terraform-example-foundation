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

package templates.gcp.GCPSQLInstanceTypeConstraintV1

import data.validator.gcp.lib as lib

#Importing the test data
import data.test.fixtures.sql_instance_type.assets as fixture_assets

# Importing the test constraints
import data.test.fixtures.sql_instance_type.constraints.allow_all as sql_type_allow_all_types
import data.test.fixtures.sql_instance_type.constraints.deny_all as sql_type_deny_all
import data.test.fixtures.sql_instance_type.constraints.mysql as sql_type_allow_mysql_only
import data.test.fixtures.sql_instance_type.constraints.postgres as sql_type_deny_postgres
import data.test.fixtures.sql_instance_type.constraints.sql as sql_type_deny_mysql_and_sql

# Find all violations on our test cases
find_all_violations[violation] {
	resources := data.resources[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as resources
		 with input.constraint as constraint

	violation := issues[_]
}

postgres_violations[violation] {
	constraints := [sql_type_deny_postgres]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

sql_violations[violation] {
	constraints := [sql_type_deny_mysql_and_sql]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

mysql_violations[violation] {
	constraints := [sql_type_allow_mysql_only]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

allow_all_violations[violation] {
	constraints := [sql_type_allow_all_types]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

deny_all_violations[violation] {
	constraints := [sql_type_deny_all]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_sql_instance_type_postgres_violations {
	violations := postgres_violations

	count(violations) == 1

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_name := {"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/test-postgres-instance"}

	resource_names == expected_resource_name

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

test_sql_instance_type_mysql_violations {
	violations := mysql_violations

	count(violations) == 2

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_name := {
		"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/test-sql-server",
		"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/test-postgres-instance",
	}

	resource_names == expected_resource_name

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

test_sql_instance_type_sqlserver_violations {
	violations := sql_violations

	count(violations) == 2

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_name := {
		"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/test-sql-server",
		"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/forseti-server-db-7c2ae462",
	}

	resource_names == expected_resource_name

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

test_sql_instance_type_allow_all_violations {
	violations := allow_all_violations
	count(violations) == 0
}

test_sql_instance_type_deny_all_violations {
	violations := deny_all_violations

	count(violations) == 3

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_name := {
		"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/test-sql-server",
		"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/forseti-server-db-7c2ae462",
		"//cloudsql.googleapis.com/projects/cf-gcp-forseti-project/instances/test-postgres-instance",
	}

	resource_names == expected_resource_name

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}
