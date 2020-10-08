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

package templates.gcp.GCPSQLMaintenanceWindowConstraintV1

import data.test.fixtures.sql_maintenance_window.assets as fixture_assets
import data.test.fixtures.sql_maintenance_window.constraints as fixture_constraints

find_violations[violation] {
	asset := data.test_assets[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as asset with input.constraint as constraint
	violation := issues[_]
}

# without parameters the constraint should still detect sql instances without maintenance window
no_parameter[violation] {
	constraints := [fixture_constraints.no_parameter]
	found_violations := find_violations with data.test_assets as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_no_parameter_count {
	count(no_parameter) == 2
}

test_no_parameter_list {
	found_violations := no_parameter
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-db-test/instances/mysqlv2-nomaintenance"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-db-test/instances/postgres-nomaintenance"
}

# with an empty hours field the constraint should detect sql insta nceswithout maintenance window
no_hour[violation] {
	constraints := [fixture_constraints.no_hour]
	found_violations := find_violations with data.test_assets as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_no_hour_count {
	count(no_hour) == 2
}

test_no_hour_list {
	found_violations := no_hour
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-db-test/instances/mysqlv2-nomaintenance"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-db-test/instances/postgres-nomaintenance"
}

specific_hours[violation] {
	constraints := [fixture_constraints.specific_hours]
	found_violations := find_violations with data.test_assets as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_specific_hours_count {
	count(specific_hours) == 3
}

test_specific_hours_list {
	found_violations := specific_hours
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-db-test/instances/mysqlv2-nomaintenance"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-db-test/instances/postgres-nomaintenance"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-cai-test/instances/brunore-mon-3pm"
}

exemption[violation] {
	constraints := [fixture_constraints.exemption]
	found_violations := find_violations with data.test_assets as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_exemption_count {
	count(exemption) == 1
}

test_exemption_list {
	found_violations := exemption
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/brunore-db-test/instances/postgres-nomaintenance"
}
