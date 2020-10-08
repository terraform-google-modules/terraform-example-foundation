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

package templates.gcp.GKEClusterVersionConstraintV1

# Importing the test data
import data.test.fixtures.gke_cluster_version.assets as fixture_assets

# Importing the test constraints for testing master version
import data.test.fixtures.gke_cluster_version.constraints.master_version_allowlist_all as master_version_allowlist_all
import data.test.fixtures.gke_cluster_version.constraints.master_version_allowlist_none as master_version_allowlist_none
import data.test.fixtures.gke_cluster_version.constraints.master_version_allowlist_one as master_version_allowlist_one
import data.test.fixtures.gke_cluster_version.constraints.master_version_allowlist_one_exemption as master_version_allowlist_one_exemption
import data.test.fixtures.gke_cluster_version.constraints.master_version_denylist_all as master_version_denylist_all
import data.test.fixtures.gke_cluster_version.constraints.master_version_denylist_none as master_version_denylist_none
import data.test.fixtures.gke_cluster_version.constraints.master_version_denylist_one as master_version_denylist_one
import data.test.fixtures.gke_cluster_version.constraints.master_version_denylist_one_exemption as master_version_denylist_one_exemption

# Importing the test constraints for testing node version
import data.test.fixtures.gke_cluster_version.constraints.node_version_allowlist_all as node_version_allowlist_all
import data.test.fixtures.gke_cluster_version.constraints.node_version_allowlist_none as node_version_allowlist_none
import data.test.fixtures.gke_cluster_version.constraints.node_version_allowlist_one as node_version_allowlist_one
import data.test.fixtures.gke_cluster_version.constraints.node_version_allowlist_one_exemption as node_version_allowlist_one_exemption
import data.test.fixtures.gke_cluster_version.constraints.node_version_denylist_all as node_version_denylist_all
import data.test.fixtures.gke_cluster_version.constraints.node_version_denylist_none as node_version_denylist_none
import data.test.fixtures.gke_cluster_version.constraints.node_version_denylist_one as node_version_denylist_one
import data.test.fixtures.gke_cluster_version.constraints.node_version_denylist_one_exemption as node_version_denylist_one_exemption

import data.validator.test_utils as test_utils

template_name := "GKEClusterVersionConstraintV1"

# Test logic for node version allowlisting/denylisting
test_target_version_match_count_allowlist_node_version {
	target_version_match_count("allowlist", match_count)
	match_count == 0
}

test_target_version_match_count_denylist_node_version {
	target_version_match_count("denylist", match_count)
	match_count == 1
}

# Test for master version no violations with no assets
test_gke_cluster_no_assets_master_version {
	test_utils.check_test_violations_count([], [], template_name, 0)
}

# Test master version empty denylist
test_gke_cluster_denylist_none_master_version {
	test_utils.check_test_violations_count(fixture_assets, [master_version_denylist_none], template_name, 0)
}

# Test master version empty allowlist
test_gke_cluster_master_version_allowlist_none_master_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/pso-cicd8/zones/us-west1-b/clusters/canary-west",
		"//container.googleapis.com/projects/cicd-prod/zones/us-west1-a/clusters/redditmobile-canary-west",
		"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster",
		"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging",
	}

	test_utils.check_test_violations(fixture_assets, [master_version_allowlist_none], template_name, expected_resource_names)
}

# Test master version denylist with single version
test_gke_cluster_denylist_one_master_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/pso-cicd8/zones/us-west1-b/clusters/canary-west",
		"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging",
	}

	test_utils.check_test_violations(fixture_assets, [master_version_denylist_one], template_name, expected_resource_names)
}

# Test master version allowlist with single version
test_gke_cluster_allowlist_one_master_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/cicd-prod/zones/us-west1-a/clusters/redditmobile-canary-west",
		"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster",
	}

	test_utils.check_test_violations(fixture_assets, [master_version_allowlist_one], template_name, expected_resource_names)
}

# Test master version denylist with single version and one exemption
test_gke_cluster_denylist_one_exemption_master_version {
	expected_resource_names := {"//container.googleapis.com/projects/pso-cicd8/zones/us-west1-b/clusters/canary-west"}
	test_utils.check_test_violations(fixture_assets, [master_version_denylist_one_exemption], template_name, expected_resource_names)
}

# Test master version allowlist with single version and one exemption
test_gke_cluster_allowlist_one_exemption_master_version {
	expected_resource_names := {"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster"}
	test_utils.check_test_violations(fixture_assets, [master_version_allowlist_one_exemption], template_name, expected_resource_names)
}

# Test master version denylist with all versions
test_gke_cluster_denylist_all_master_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/pso-cicd8/zones/us-west1-b/clusters/canary-west",
		"//container.googleapis.com/projects/cicd-prod/zones/us-west1-a/clusters/redditmobile-canary-west",
		"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster",
		"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging",
	}

	test_utils.check_test_violations(fixture_assets, [master_version_denylist_all], template_name, expected_resource_names)
}

# Test master version allowlist with all versions
test_gke_cluster_allowlist_all_master_version {
	test_utils.check_test_violations_count(fixture_assets, [master_version_allowlist_all], template_name, 0)
}

# Test node version empty denylist
test_gke_cluster_denylist_none_node_version {
	test_utils.check_test_violations_count(fixture_assets, [node_version_denylist_none], template_name, 0)
}

# Test node version empty allowlist
test_gke_cluster_allowlist_none_node_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/pso-cicd8/zones/us-west1-b/clusters/canary-west",
		"//container.googleapis.com/projects/cicd-prod/zones/us-west1-a/clusters/redditmobile-canary-west",
		"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster",
		"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging",
	}

	test_utils.check_test_violations(fixture_assets, [node_version_allowlist_none], template_name, expected_resource_names)
}

# Test node version denylist with single version
test_gke_cluster_denylist_one_node_version {
	expected_resource_names := {"//container.googleapis.com/projects/pso-cicd8/zones/us-west1-b/clusters/canary-west"}
	test_utils.check_test_violations(fixture_assets, [node_version_denylist_one], template_name, expected_resource_names)
}

# Test node version allowlist with single version
test_gke_cluster_allowlist_one_node_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/cicd-prod/zones/us-west1-a/clusters/redditmobile-canary-west",
		"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging",
		"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster",
	}

	test_utils.check_test_violations(fixture_assets, [node_version_allowlist_one], template_name, expected_resource_names)
}

# Test node version denylist with versions and one exemption
test_gke_cluster_denylist_one_exemption_node_version {
	expected_resource_names := {"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"}
	test_utils.check_test_violations(fixture_assets, [node_version_denylist_one_exemption], template_name, expected_resource_names)
}

# Test node version allowlist with versions and one exemption
test_gke_cluster_allowlist_one_exemption_node_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging",
		"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster",
	}

	test_utils.check_test_violations(fixture_assets, [node_version_allowlist_one_exemption], template_name, expected_resource_names)
}

# Test node version denylist with all versions
test_gke_cluster_denylist_all_node_version {
	expected_resource_names := {
		"//container.googleapis.com/projects/pso-cicd8/zones/us-west1-b/clusters/canary-west",
		"//container.googleapis.com/projects/cicd-prod/zones/us-west1-a/clusters/redditmobile-canary-west",
		"//container.googleapis.com/projects/release-2-19-0-gke/zones/us-central1-a/clusters/forseti-cluster",
		"//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging",
	}

	test_utils.check_test_violations(fixture_assets, [node_version_denylist_all], template_name, expected_resource_names)
}

# Test node version allowlist with all versions
test_gke_cluster_allowlist_all_node_version {
	test_utils.check_test_violations_count(fixture_assets, [node_version_allowlist_all], template_name, 0)
}

# Test glob functionality
test_glob_functionality_all_projects_zones_clusters {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/*/zones/*/clusters/*"}

	is_exempt(exempt_list, asset_name)
}

test_glob_functionality_all_projects_zones_clusters_super_glob {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/**"}

	is_exempt(exempt_list, asset_name)
}

test_glob_functionality_one_char {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/*/zones/us-west1-?/clusters/*"}

	is_exempt(exempt_list, asset_name)
}

test_glob_functionality_char_range {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/*/zones/us-west1-[a-c]/clusters/*"}

	is_exempt(exempt_list, asset_name)
}

test_glob_functionality_char_range_not {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/*/zones/us-west1-[!a-c]/clusters/*"}

	not is_exempt(exempt_list, asset_name)
}

test_glob_functionality_all_projects_wrong_zone {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/*/zones/us-west1-b/clusters/*"}

	not is_exempt(exempt_list, asset_name)
}

test_glob_functionality_wrong_cluster {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/*/zones/*/clusters/exempt-cluster"}

	not is_exempt(exempt_list, asset_name)
}

test_glob_functionality_all_projects_no_delimiter {
	asset_name := "//container.googleapis.com/projects/cicd-staging/zones/us-west1-a/clusters/redditmobile-staging"
	exempt_list := {"//container.googleapis.com/projects/*"}

	not is_exempt(exempt_list, asset_name)
}
