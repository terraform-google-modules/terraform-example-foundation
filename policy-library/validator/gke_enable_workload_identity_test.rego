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

package templates.gcp.GCPGKEEnableWorkloadIdentityConstraintV1

import data.test.fixtures.gke_enable_workload_identity.assets as fixture_assets
import data.test.fixtures.gke_enable_workload_identity.constraints as fixture_constraints
import data.validator.gcp.lib as lib

import data.validator.test_utils as test_utils

template_name := "GCPGKEEnableWorkloadIdentityConstraintV1"

test_disabled_workload_identity {
	expected_resource_names = {"//container.googleapis.com/projects/testproject/zones/us-central1-c/clusters/workloadidentity-disabled"}

	test_utils.check_test_violations(fixture_assets, [fixture_constraints.enable_gke_workload_identity], template_name, expected_resource_names)
}
