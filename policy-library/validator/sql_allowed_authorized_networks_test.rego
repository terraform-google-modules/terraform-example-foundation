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

package templates.gcp.GCPSQLAllowedAuthorizedNetworksConstraintV1

import data.test.fixtures.sql_allowed_authorized_networks.constraints as fixture_constraints

# Find all violations of data.test_constraints.
find_violations[violation] {
	resource := data.test.fixtures.sql_allowed_authorized_networks.assets[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

test_sql_allowed_authorized_networks_default {
	constraints := [fixture_constraints.default_params]
	violations := find_violations with data.test_constraints as constraints
	count(violations) == 1

	violation := violations[_]
	violation.details.resource == "//cloudsql.googleapis.com/projects/noble-history-87417/instances/authorized-networks-35"
}

test_sql_allowed_authorized_networks_ssl_enabled {
	constraints := [fixture_constraints.ssl_enabled]
	violations := find_violations with data.test_constraints as constraints
	count(violations) == 1

	violation := violations[_]
	violation.details.resource == "//cloudsql.googleapis.com/projects/noble-history-87417/instances/authorized-networks-35"
}

test_sql_allowed_authorized_networks_allowlist {
	constraints := [fixture_constraints.allowlist]
	violations := find_violations with data.test_constraints as constraints
	count(violations) == 0
}
