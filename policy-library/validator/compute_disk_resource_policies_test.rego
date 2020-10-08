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

package templates.gcp.GCPComputeDiskResourcePoliciesConstraintV1

template_name := "GCPComputeDiskResourcePoliciesConstraintV1"

import data.validator.test_utils as test_utils

import data.test.fixtures.compute_disk_resource_policies.assets.disks as fixture_disks
import data.test.fixtures.compute_disk_resource_policies.assets.instances as fixture_instances
import data.test.fixtures.compute_disk_resource_policies.constraints as fixture_constraints

# Test logic for allowlisting/denylisting
test_target_resource_policies_match_count_allowlist {
	target_resource_policies_match_count("allowlist", match_count)
	match_count == 0
}

test_target_resource_policies_match_count_denylist {
	target_resource_policies_match_count("denylist", match_count)
	match_count == 1
}

test_compute_disk_resource_policies_no_assets {
	test_utils.check_test_violations_count([], [], template_name, 0)
}

test_compute_disk_resource_policies_no_constraints {
	test_utils.check_test_violations_count(fixture_disks, [], template_name, 0)
}

test_compute_disk_resource_policies_invalid_asset {
	test_utils.check_test_violations_count(fixture_instances, [], template_name, 0)
}

test_compute_disk_resource_policies_default {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.resource_policies_default], template_name, 0)
}

test_compute_disk_resource_policies_denylist_none {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.denylist_none], template_name, 0)
}

test_compute_disk_resource_policies_allowlist_none {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.allowlist_none], template_name, count(fixture_disks))
}

test_compute_disk_resource_policies_denylist_one {
	resource_names := {"//compute.googleapis.com/projects/my-test-project/zones/europe-north1-c/disks/incorrect-resource-policies"}
	test_utils.check_test_violations(fixture_disks, [fixture_constraints.denylist_one], template_name, resource_names)
}

test_compute_disk_resource_policies_denylist_one_exemption {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.denylist_one_exemption], template_name, 0)
}

test_compute_disk_resource_policies_allowlist_one {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.allowlist_one], template_name, count(fixture_disks) - 1)
}

test_compute_disk_resource_policies_allowlist_one_exemption {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.allowlist_one_exemption], template_name, count(fixture_disks) - 2)
}

test_compute_disk_resource_policies_denylist_all {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.denylist_all], template_name, count(fixture_disks) - 1)
}

# Test allowlist with all resource_policies
test_compute_disk_resource_policies_allowlist_all {
	test_utils.check_test_violations_count(fixture_disks, [fixture_constraints.allowlist_all], template_name, 0)
}
