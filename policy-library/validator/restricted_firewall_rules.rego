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

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)

	# Update params (set all missing params to their default value)
	rules_params := update_params(params.rules[_])
	mode := lib.get_default(params, "mode", "denylist")

	asset := input.asset
	asset.asset_type == "compute.googleapis.com/Firewall"

	match_mode := lib.get_default(params, "exemptions_mode", "exact")
	check_for_exemptions(asset.name, constraint, match_mode)

	fw_rule = asset.resource.data

	is_valid(mode, fw_rule, rules_params)

	message := sprintf("%s Firewall rule is prohibited.", [asset.name])
	metadata := {
		"resource": asset.name,
		"restricted_rules": rules_params,
	}
}

###########################
# Rule Utilities
###########################

# update_params - set all the default to input parameters
# All parameters are optional. update_params set all missing parameters to "any"
update_params(params) = updated_params {
	updated_params := {
		"direction": lib.get_default(params, "direction", "any"),
		"rule_type": lib.get_default(params, "rule_type", "any"),
		"port": lib.get_default(params, "port", "any"),
		"protocol": lib.get_default(params, "protocol", "any"),
		"source_ranges": lib.get_default(params, "source_ranges", ["any"]),
		"target_ranges": lib.get_default(params, "target_ranges", ["any"]),
		"source_tags": lib.get_default(params, "source_tags", ["any"]),
		"target_tags": lib.get_default(params, "target_tags", ["any"]),
		"source_service_accounts": lib.get_default(params, "source_service_accounts", ["any"]),
		"target_service_accounts": lib.get_default(params, "target_service_accounts", ["any"]),
		"enabled": lib.get_default(params, "enabled", "any"),
	}
}

is_valid(mode, fw_rule, params) {
	mode == "denylist"
	fw_rule_is_restricted(fw_rule, params)
}

is_valid(mode, fw_rule, params) {
	mode == "allowlist"
	not fw_rule_is_restricted(fw_rule, params)
}

# fw_rule_is_restricted for Ingress rules
fw_rule_is_restricted(fw_rule, params) {
	# check direction
	fw_rule_check_direction(fw_rule, params.direction)

	# check rule type
	fw_rule_check_rule_type(fw_rule, params.rule_type)

	ip_configs := fw_rule_get_ip_configs(fw_rule, params.rule_type)

	# check protocol and port
	fw_rule_check_protocol_and_port(ip_configs, params.protocol, params.port)

	# Check sources (ip ranges and/or tags and/or service accounts)
	fw_rule_check_all_sources(fw_rule, params)

	# Check targets
	fw_rule_check_all_targets(fw_rule, params)

	fw_rule_check_enabled(fw_rule, params.enabled)
}

#### Check direction functions

# fw_rule_check_direction when direction is set to any
fw_rule_check_direction(fw_rule, direction) {
	direction == "any"
}

# fw_rule_check_direction when direction is not set to any
fw_rule_check_direction(fw_rule, direction) {
	direction != "any"
	lower(direction) == lower(fw_rule.direction)
}

#### Check Type functions

# fw_rule_check_type when rule_type is set to any
fw_rule_check_rule_type(fw_rule, rule_type) {
	rule_type == "any"
}

# fw_rule_check_direction when direction is not set to any
fw_rule_check_rule_type(fw_rule, rule_type) {
	rule_type != "any"

	# test that the key exists in the fw_rule (allowed or denied)
	fw_rule[lower(rule_type)]
}

##### Get IP Config from rule

### fw_rule_get_ip_configs when rule_type is set to any and rule is allowed type
fw_rule_get_ip_configs(fw_rule, rule_type) = ip_configs {
	rule_type == "any"
	ip_configs = fw_rule.allowed
}

### fw_rule_get_ip_configs when rule_type is set to any and rule is allowed type
fw_rule_get_ip_configs(fw_rule, rule_type) = ip_configs {
	rule_type == "any"
	ip_configs = fw_rule.denied
}

### fw_rule_get_ip_configs when rule_type is not set to any
fw_rule_get_ip_configs(fw_rule, rule_type) = ip_configs {
	rule_type != "any"
	ip_configs = fw_rule[rule_type]
}

#### Check protocol + port functions

# fw_rule_check_protocol when one ip_configs is set to "all"
fw_rule_check_protocol_and_port(ip_configs, protocol, port) {
	ip_configs[_].IPProtocol == "all"
}

# fw_rule_check_protocol when protocol is set to any
fw_rule_check_protocol_and_port(ip_configs, protocol, port) {
	protocol == "any"
	fw_rule_check_port(ip_configs[_], port)
}

# fw_rule_check_protocol when protocol is not set to any
fw_rule_check_protocol_and_port(ip_configs, protocol, port) {
	protocol != "any"

	# Check if the protocol is in the rule
	ip_configs[i].IPProtocol == protocol

	# Check if the associated port is also a match
	fw_rule_check_port(ip_configs[i], port)
}

# fw_rule_check_port when protocol is set to any
fw_rule_check_port(ip_configs, port) {
	port == "any"
}

# fw_rule_check_port when protocol is tcp, udp or all AND port is not set (i.e all ports match)
fw_rule_check_port(ip_config, port) {
	protocol_with_ports := {"tcp", "udp", "all"}

	# only for protocol with ports or "all" - since it includes tcp and udp
	ip_config.IPProtocol == protocol_with_ports[_]

	# if port is not set in ip_config, any port passed as a param matches
	not ip_config.ports
}

# fw_rule_check_port when port is all and there are no ports
fw_rule_check_port(ip_config, port) {
	port == "all"

	# check if the port matches
	not ip_config.ports
}

# fw_rule_check_port when port is all and the fw rule exposes ports 0-65535
fw_rule_check_port(ip_config, port) {
	port == "all"

	# check if the port matches
	range_match("0-65535", ip_config.ports[_])
}

# fw_rule_check_port when port is all and the fw rule exposes ports 1-65535
fw_rule_check_port(ip_config, port) {
	port == "all"

	# check if the port matches
	range_match("1-65535", ip_config.ports[_])
}

# fw_rule_check_port when port is a single number
fw_rule_check_port(ip_config, port) {
	port != "all"
	port != "any"
	not re_match("-", port)

	# check if the port matches
	rule_ports := ip_config.ports

	# check if port is in one of rule_ports values
	port_is_in_values(port, rule_ports[_])
}

# fw_rule_check_port when port is a range (e.g 100-200)
fw_rule_check_port(ip_config, port) {
	port != "all"
	port != "any"
	re_match("-", port)

	# check if the port range is included in the fw_rule port
	rule_ports := ip_config.ports

	rule_port := rule_ports[_]

	# check if port range is included in one of rule_ports values
	# Note: if rule_port is not a range, range_match will return False
	range_match(port, rule_port)
}

# port_is_in_values if rule_port is not a range
# Note: only called when port is not a range
port_is_in_values(port, rule_port) {
	# check if rule_port is not a range
	not re_match("-", rule_port)

	# test if rule port matches
	rule_port == port
}

# port_is_in_values if rule_port is a range
# Note: only called when port is not a range
port_is_in_values(port, rule_port) {
	# check if rule_port is a range
	re_match("-", rule_port)

	# build a simple port-port range to test if it belongs to rule_port range
	port_range := sprintf("%s-%s", [port, port])

	# Check if port is included in rule port
	range_match(port_range, rule_port)
}

# range_match tests if test_range is included in target_range
# returns true if test_range is equal to, or included in target_range
range_match(test_range, target_range) {
	# check if target_range is a range
	re_match("-", target_range)

	# check if test_range is a range
	re_match("-", test_range)

	# getting the target range bounds
	target_range_bounds := split(target_range, "-")
	target_low_bound := to_number(target_range_bounds[0])
	target_high_bound := to_number(target_range_bounds[1])

	# getting the test range bounds
	test_range_bounds := split(test_range, "-")
	test_low_bound := to_number(test_range_bounds[0])
	test_high_bound := to_number(test_range_bounds[1])

	# check if test low bound is >= target low bound and target high bound >= test high bound
	test_low_bound >= target_low_bound

	test_high_bound <= target_high_bound
}

#### Check sources functions

# fw_rule_check_sources returns true if all sources matches based on parameters
# checks for source ranges, tags and service accounts
fw_rule_check_all_sources(fw_rule, params) {
	# Check that source ranges AND source tags AND source service accounts match
	fw_rule_check_source_range(fw_rule, params.source_ranges[_])
	fw_rule_check_source_tag(fw_rule, params.source_tags[_])
	fw_rule_check_source_sas(fw_rule, params.source_service_accounts[_])
}

# fw_rule_check_source when source range is passed
fw_rule_check_source_range(fw_rule, source_range) {
	# test if sourceRanges exists in the rule
	fw_rule.sourceRanges

	# check that source ranges are set
	fw_rule_ranges = fw_rule.sourceRanges

	# check if any range matches
	# no CIDR matching logic at this time
	source_range == fw_rule_ranges[_]
}

# fw_rule_check_source_range if source_ranges is set to "*"
fw_rule_check_source_range(fw_rule, source_range) {
	source_range == "*"

	# Check that at least a source range is set
	fw_rule.sourceRanges
}

# fw_rule_check_source_range if source_ranges is set to any (default)
fw_rule_check_source_range(fw_rule, source_range) {
	source_range == "any"
}

# fw_rule_check_source when source tag is passed and is not "*"
fw_rule_check_source_tag(fw_rule, source_tag) {
	source_tag != "*"

	# check that the rule source tags are set
	fw_rule_source_tags := fw_rule.sourceTags

	# check if the input tag matches any tag in the rule
	re_match(source_tag, fw_rule_source_tags[_])
}

# fw_rule_check_source_tag if source tag is set to "*"
fw_rule_check_source_tag(fw_rule, source_tag) {
	source_tag == "*"

	# Verify that we have a source tag set, regardless of its value
	fw_rule.sourceTags
}

# fw_rule_check_source_tag if source tag is set to any (default)
fw_rule_check_source_tag(fw_rule, source_tag) {
	source_tag == "any"
}

# fw_rule_check_source when source service account is passed and is not "*"
fw_rule_check_source_sas(fw_rule, source_service_account) {
	source_service_account != "*"

	# check that source service accounts are set
	fw_rule_source_sas = fw_rule.sourceServiceAccounts

	# check if the rule service account matches
	re_match(source_service_account, fw_rule_source_sas[_])
}

# fw_rule_check_source_sas if source service account is set to "*"
fw_rule_check_source_sas(fw_rule, source_service_account) {
	source_service_account == "*"

	# Verify that we have a source service account set, regardless of its value
	fw_rule.sourceServiceAccounts
}

# fw_rule_check_source_sas if source service account is set to any
fw_rule_check_source_sas(fw_rule, source_service_account) {
	source_service_account == "any"
}

#### Check targets functions

# fw_rule_check_targets returns true if all targets match based on parameters
# checks for target ranges, tags and service accounts
fw_rule_check_all_targets(fw_rule, params) {
	# Check that target ranges AND target tags AND target service accounts match
	fw_rule_check_target_range(fw_rule, params.target_ranges[_])
	fw_rule_check_target_tag(fw_rule, params.target_tags[_])
	fw_rule_check_target_sas(fw_rule, params.target_service_accounts[_])
}

# fw_rule_check_target when target range is passed
fw_rule_check_target_range(fw_rule, target_range) {
	# test if destinationRanges exists in the rule
	fw_rule.destinationRanges

	# check that target ranges are set
	fw_rule_ranges = fw_rule.destinationRanges

	# check if any range matches
	# no CIDR matching logic at this time
	target_range == fw_rule_ranges[_]
}

# fw_rule_check_target_range if target_ranges is set to "*"
fw_rule_check_target_range(fw_rule, target_range) {
	target_range == "*"

	# Check that at least a target range is set
	fw_rule.destinationRanges
}

# fw_rule_check_target_range if target_ranges is set to any (default)
fw_rule_check_target_range(fw_rule, target_range) {
	target_range == "any"
}

# fw_rule_check_target when target tag is passed and is not "*"
fw_rule_check_target_tag(fw_rule, target_tag) {
	target_tag != "*"

	# check that the rule target tags are set
	fw_rule_target_tags := fw_rule.targetTags

	# check if the input tag matches any tag in the rule
	re_match(target_tag, fw_rule_target_tags[_])
}

# fw_rule_check_target_tag if target tag is set to "*"
fw_rule_check_target_tag(fw_rule, target_tag) {
	target_tag == "*"

	# Verify that we have a target tag set, regardless of its value
	fw_rule.targetTags
}

# fw_rule_check_target_tag if target tag is set to any (default)
fw_rule_check_target_tag(fw_rule, target_tag) {
	target_tag == "any"
}

# fw_rule_check_target when target service account is passed and is not "*"
fw_rule_check_target_sas(fw_rule, target_service_account) {
	target_service_account != "*"

	# check that target service accounts are set
	fw_rule_target_sas = fw_rule.targetServiceAccounts

	# check if the rule service account matches
	re_match(target_service_account, fw_rule_target_sas[_])
}

# fw_rule_check_target_sas if target service account is set to "*"
fw_rule_check_target_sas(fw_rule, target_service_account) {
	target_service_account == "*"

	# Verify that we have a target service account set, regardless of its value
	fw_rule.targetServiceAccounts
}

# fw_rule_check_target_sas if target service account is set to any
fw_rule_check_target_sas(fw_rule, target_service_account) {
	target_service_account == "any"
}

#### Check enabled functions

# fw_rule_check_enabled when enabled is set to any
fw_rule_check_enabled(fw_rule, enabled) {
	enabled == "any"
}

# fw_rule_check_enabled when enabled is not set to any
fw_rule_check_enabled(fw_rule, enabled) {
	enabled != "any"

	# the following test only works when enabled is a boolean too
	is_boolean(enabled)
	enabled != fw_rule.disabled
}

# fw_rule_check_enabled when enabled is not set to "true" (string)
# This function is just for convenience when the enabled parameter is a string instead of a boolean
fw_rule_check_enabled(fw_rule, enabled) {
	enabled != "any"
	is_string(enabled)

	# this is necessary as cast_boolean does not work on strings...
	lower(enabled) == "true"
	not fw_rule.disabled
}

# fw_rule_check_enabled when enabled is not set to "false" (string)
# This function is just for convenience when the enabled parameter is a string instead of a boolean
fw_rule_check_enabled(fw_rule, enabled) {
	enabled != "any"
	is_string(enabled)

	# this is necessary as cast_boolean does not work on strings...
	lower(enabled) == "false"
	fw_rule.disabled
}

# Check for exempted resources in regex mode
check_for_exemptions(asset_name, constraint, exemptions_mode) {
	exemptions_mode == "regex"
	lib.get_constraint_params(constraint, params)
	exempt_list := params.exemptions
	not re_match_name(asset_name, exempt_list)
}

# Check for exempted resources in exact mode (default)
check_for_exemptions(asset_name, constraint, exemptions_mode) {
	exemptions_mode == "exact"
	lib.get_constraint_params(constraint, params)
	exempt_list := params.exemptions
	matches := {asset_name} & cast_set(exempt_list)
	count(matches) == 0
}

# Check for empty exemption mode
check_for_exemptions(asset_name, constraint, exemptions_mode) {
	lib.has_field(constraint.spec.parameters, "exemptions") == false
}

re_match_name(name, filters) {
	re_match(filters[_], name)
}
