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

package templates.gcp.GCPRestrictedFirewallRulesConstraintV1

template_name := "GCPRestrictedFirewallRulesConstraintV1"

import data.validator.test_utils as test_utils

# Importing the test data
import data.test.fixtures.restricted_firewall_rules.assets.exemption as exemption_fixture_assets
import data.test.fixtures.restricted_firewall_rules.assets.protocol_and_all_ports as protocol_and_all_ports_fixture_assets
import data.test.fixtures.restricted_firewall_rules.assets.protocol_and_port as protocol_and_port_fixture_assets
import data.test.fixtures.restricted_firewall_rules.assets.sources as sources_fixture_assets
import data.test.fixtures.restricted_firewall_rules.assets.targets as targets_fixture_assets

# Importing the denylist test constraints
import data.test.fixtures.restricted_firewall_rules.constraints.all.denylist as all_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.misc.advanced.denylist as misc_advanced_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.misc.basic.denylist as misc_basic_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.protocol_and_all_ports.denylist as protocol_and_all_ports_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.protocol_and_port.advanced.denylist as protocol_and_port_advanced_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.protocol_and_port.basic.denylist as protocol_and_port_basic_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.sources.advanced.denylist as sources_advanced_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.sources.basic.denylist as sources_basic_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.targets.advanced.denylist as targets_advanced_fixture_constraint_denylist
import data.test.fixtures.restricted_firewall_rules.constraints.targets.basic.denylist as targets_basic_fixture_constraint_denylist

# Importing the allowlist test constraints
import data.test.fixtures.restricted_firewall_rules.constraints.all.allowlist as all_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.misc.advanced.allowlist as misc_advanced_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.misc.basic.allowlist as misc_basic_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.protocol_and_all_ports.allowlist as protocol_and_all_ports_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.protocol_and_port.advanced.allowlist as protocol_and_port_advanced_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.protocol_and_port.basic.allowlist as protocol_and_port_basic_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.sources.advanced.allowlist as sources_advanced_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.sources.basic.allowlist as sources_basic_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.targets.advanced.allowlist as targets_advanced_fixture_constraint_allowlist
import data.test.fixtures.restricted_firewall_rules.constraints.targets.basic.allowlist as targets_basic_fixture_constraint_allowlist

# Importing the exemption test constraints
import data.test.fixtures.restricted_firewall_rules.constraints.exemption.exact as exemption_exact_constraint
import data.test.fixtures.restricted_firewall_rules.constraints.exemption.regex as exemption_regex_constraint
import data.test.fixtures.restricted_firewall_rules.constraints.exemption.unset as exemption_unset_constraint

# Test protocol and all ports
test_protocol_and_all_ports_count {
	test_utils.check_test_violations_count(protocol_and_all_ports_fixture_assets, [protocol_and_all_ports_fixture_constraint_denylist], template_name, 4)
}

test_protocol_and_all_ports_count_allowlist {
	test_utils.check_test_violations_count(protocol_and_all_ports_fixture_assets, [protocol_and_all_ports_fixture_constraint_allowlist], template_name, 6)
}

test_protocol_and_all_ports_resources {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-udp-all",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range1",
	}

	test_utils.check_test_violations_resources(protocol_and_all_ports_fixture_assets, [protocol_and_all_ports_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_protocol_and_all_ports_resources_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-udp-all",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range-no-violation",
	}

	test_utils.check_test_violations_resources(protocol_and_all_ports_fixture_assets, [protocol_and_all_ports_fixture_constraint_allowlist], template_name, expected_resource_names)
}

# Tests sources constraint on port and protocol test data
test_restricted_firewall_rule_protocol_and_port_violations_basic {
	# Basic constraint violations

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-6",
	}

	test_utils.check_test_violations(protocol_and_port_fixture_assets, [protocol_and_port_basic_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_protocol_and_port_violations_basic_allowlist {
	# Basic constraint violations

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-7",
	}

	test_utils.check_test_violations(protocol_and_port_fixture_assets, [protocol_and_port_basic_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_protocol_and_port_violations_advanced {
	# Advanced constraint violations

	# Note: the following resources raise 2 violations for the advanced constraint:
	# * cf-test-fw-rule-2
	# * cf-test-fw-rule-3
	# * cf-test-fw-rule-5

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-6",
	}

	test_utils.check_test_violations_count(protocol_and_port_fixture_assets, [protocol_and_port_advanced_fixture_constraint_denylist], template_name, 9)
	test_utils.check_test_violations_resources(protocol_and_port_fixture_assets, [protocol_and_port_advanced_fixture_constraint_denylist], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(protocol_and_port_fixture_assets, [protocol_and_port_advanced_fixture_constraint_denylist], template_name)
}

test_restricted_firewall_rule_protocol_and_port_violations_advanced_allowlist {
	# Advanced constraint violations

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-7",
	}

	test_utils.check_test_violations_count(protocol_and_port_fixture_assets, [protocol_and_port_advanced_fixture_constraint_allowlist], template_name, 7)
	test_utils.check_test_violations_resources(protocol_and_port_fixture_assets, [protocol_and_port_advanced_fixture_constraint_allowlist], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(protocol_and_port_fixture_assets, [protocol_and_port_advanced_fixture_constraint_allowlist], template_name)
}

# Tests sources constraint on sources test data
test_restricted_firewall_rule_sources_violations_basic {
	# Basic constraint violations

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-7",
	}

	test_utils.check_test_violations(sources_fixture_assets, [sources_basic_fixture_constraint_denylist], template_name, expected_resource_names)
}

# Tests sources constraint on sources test data
test_restricted_firewall_rule_sources_violations_basic_allowlist {
	# Basic constraint violations

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-11",
	}

	test_utils.check_test_violations(sources_fixture_assets, [sources_basic_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_sources_violations_advanced {
	# Advanced constraint violations

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-6",
	}

	test_utils.check_test_violations(sources_fixture_assets, [sources_advanced_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_sources_violations_advanced_allowlist {
	# Advanced constraint violations

	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-11",
	}

	test_utils.check_test_violations_count(sources_fixture_assets, [sources_advanced_fixture_constraint_allowlist], template_name, 22)
	test_utils.check_test_violations_resources(sources_fixture_assets, [sources_advanced_fixture_constraint_allowlist], template_name, expected_resource_names)
}

# Test targets constraint on targets test data
test_restricted_firewall_rule_targets_violations_basic {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-11",
	}

	test_utils.check_test_violations(targets_fixture_assets, [targets_basic_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_targets_violations_basic_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-10",
	}

	test_utils.check_test_violations(targets_fixture_assets, [targets_basic_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_targets_violations_advanced {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-9",
	}

	test_utils.check_test_violations(targets_fixture_assets, [targets_advanced_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_targets_violations_advanced_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-11",
	}

	test_utils.check_test_violations_count(targets_fixture_assets, [targets_advanced_fixture_constraint_allowlist], template_name, 22)
	test_utils.check_test_violations_resources(targets_fixture_assets, [targets_advanced_fixture_constraint_allowlist], template_name, expected_resource_names)
}

# Tests the misc constraint on misc test data
test_restricted_firewall_rule_misc_violations_advanced_protocol_and_ports {
	test_utils.check_test_violations_count(protocol_and_port_fixture_assets, [misc_advanced_fixture_constraint_denylist], template_name, 0)
}

test_restricted_firewall_rule_misc_violations_advanced_protocol_and_ports_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-7",
	}

	test_utils.check_test_violations_count(protocol_and_port_fixture_assets, [misc_advanced_fixture_constraint_allowlist], template_name, 16)
	test_utils.check_test_violations_resources(protocol_and_port_fixture_assets, [misc_advanced_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_advanced_sources {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-11",
	}

	test_utils.check_test_violations(sources_fixture_assets, [misc_advanced_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_advanced_sources_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-11",
	}

	test_utils.check_test_violations_resources(sources_fixture_assets, [misc_advanced_fixture_constraint_allowlist], template_name, expected_resource_names)
	test_utils.check_test_violations_count(sources_fixture_assets, [misc_advanced_fixture_constraint_allowlist], template_name, 22)
}

test_restricted_firewall_rule_misc_violations_advanced_targets {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-11",
	}

	test_utils.check_test_violations(targets_fixture_assets, [misc_advanced_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_advanced_targets_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-11",
	}

	test_utils.check_test_violations_count(targets_fixture_assets, [misc_advanced_fixture_constraint_allowlist], template_name, 22)
	test_utils.check_test_violations_resources(targets_fixture_assets, [misc_advanced_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_basic_protocol_and_ports {
	test_utils.check_test_violations_count(protocol_and_port_fixture_assets, [misc_basic_fixture_constraint_denylist], template_name, 0)
}

test_restricted_firewall_rule_misc_violations_basic_protocol_and_ports_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-7",
	}

	test_utils.check_test_violations(protocol_and_port_fixture_assets, [misc_basic_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_basic_sources {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-10",
	}

	test_utils.check_test_violations(sources_fixture_assets, [misc_basic_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_basic_sources_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-11",
	}

	test_utils.check_test_violations(sources_fixture_assets, [misc_basic_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_basic_targets {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-10",
	}

	test_utils.check_test_violations(targets_fixture_assets, [misc_basic_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_misc_violations_basic_targets_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-11",
	}

	test_utils.check_test_violations(targets_fixture_assets, [misc_basic_fixture_constraint_allowlist], template_name, expected_resource_names)
}

# Tests "all" constraint on "all" test data
test_restricted_firewall_rule_all_violations_protocol_and_port {
	test_utils.check_test_violations_count(protocol_and_port_fixture_assets, [all_fixture_constraint_denylist], template_name, 0)
}

test_restricted_firewall_rule_all_violations_protocol_and_port_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-7",
	}

	test_utils.check_test_violations_count(protocol_and_port_fixture_assets, [all_fixture_constraint_allowlist], template_name, 16)
	test_utils.check_test_violations_resources(protocol_and_port_fixture_assets, [all_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_all_violations_sources {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-11",
	}

	test_utils.check_test_violations(sources_fixture_assets, [all_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_all_violations_sources_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-source-11",
	}

	test_utils.check_test_violations_count(sources_fixture_assets, [all_fixture_constraint_allowlist], template_name, 18)
	test_utils.check_test_violations_resources(sources_fixture_assets, [all_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_all_violations_targets {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-11",
	}

	test_utils.check_test_violations(targets_fixture_assets, [all_fixture_constraint_denylist], template_name, expected_resource_names)
}

test_restricted_firewall_rule_all_violations_targets_allowlist {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-1",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-2",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-3",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-4",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-5",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-6",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-7",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-8",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-9",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-10",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-target-11",
	}

	test_utils.check_test_violations_count(targets_fixture_assets, [all_fixture_constraint_allowlist], template_name, 20)
	test_utils.check_test_violations_resources(targets_fixture_assets, [all_fixture_constraint_allowlist], template_name, expected_resource_names)
}

test_exemptions_unset {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-udp-all",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range1",
	}

	test_utils.check_test_violations_resources(exemption_fixture_assets, [exemption_unset_constraint], template_name, expected_resource_names)
}

test_exemptions_exact {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range0",
	}

	test_utils.check_test_violations_resources(exemption_fixture_assets, [exemption_exact_constraint], template_name, expected_resource_names)
}

test_exemptions_regex {
	expected_resource_names := {
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range0",
		"//compute.googleapis.com/projects/cf-gcp-challenge-dev/global/firewalls/cf-test-fw-rule-tcp-all-port-range1",
	}

	test_utils.check_test_violations_resources(exemption_fixture_assets, [exemption_regex_constraint], template_name, expected_resource_names)
}
