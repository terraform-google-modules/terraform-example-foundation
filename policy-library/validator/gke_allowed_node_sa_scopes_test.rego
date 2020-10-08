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

package templates.gcp.GCPGKEAllowedNodeSAConstraintV1

import data.validator.gcp.lib as lib

default_scopes_violations[violation] {
	resource := data.test.fixtures.gke_allowed_node_sa_scopes.assets[_]
	constraint := data.test.fixtures.gke_allowed_node_sa_scopes.constraints.allowed_gke_node_sa_scope_default

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

customized_scopes_violations[violation] {
	resource := data.test.fixtures.gke_allowed_node_sa_scopes.assets[_]
	constraint := data.test.fixtures.gke_allowed_node_sa_scopes.constraints.allowed_gke_node_sa_scope_customized

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

test_default_violations {
	count(default_scopes_violations) == 1
	resource_names := {x | x = default_scopes_violations[_].details.resource}
	expected_resource_name := {"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2"}

	resource_names == expected_resource_name
}

test_customized_violations {
	count(customized_scopes_violations) == 2
	resource_names := {x | x = customized_scopes_violations[_].details.resource}
	expected_resource_name := {
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2",
	}

	resource_names == expected_resource_name
}
