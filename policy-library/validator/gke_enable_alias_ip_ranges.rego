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

package templates.gcp.GCPGKEEnableAliasIPRangesConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	asset := input.asset
	asset.asset_type == "container.googleapis.com/Cluster"

	cluster := asset.resource.data
	alias_ip_ranges_disabled(cluster)

	message := sprintf("Alias IP ranges are disabled in cluster %v.", [asset.name])
	metadata := {"resource": asset.name}
}

###########################
# Rule Utilities
###########################
alias_ip_ranges_disabled(cluster) {
	# Has ipAllocationPolicyField, and useIpAliases is false
	ipAllocationPolicyField := lib.has_field(cluster, "ipAllocationPolicy")
	ipAllocationPolicyField == true

	ipAllocationPolicy := lib.get_default(cluster, "ipAllocationPolicy", {})
	useIpAliases := lib.get_default(ipAllocationPolicy, "useIpAliases", true)
	useIpAliases != true
}

alias_ip_ranges_disabled(cluster) {
	# Doesn't have ipAllocationPolicyField
	ipAllocationPolicy := lib.has_field(cluster, "ipAllocationPolicy")
	ipAllocationPolicy != true
}
