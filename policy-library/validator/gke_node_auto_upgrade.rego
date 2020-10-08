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

package templates.gcp.GCPGKENodeAutoUpgradeConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	asset := input.asset
	asset.asset_type == "container.googleapis.com/Cluster"

	container := asset.resource.data
	node_pools := lib.get_default(container, "nodePools", [])
	node_pool := node_pools[_]
	not auto_upgrade_enabled(node_pool)

	message := sprintf("Auto upgrade is not enabled on node pool '%v'.", [node_pool.name])

	metadata := {"resource": asset.name, "node_pool": node_pool.name}
}

###########################
# Rule Utilities
###########################
auto_upgrade_enabled(node_pool) {
	management := lib.get_default(node_pool, "management", {})
	auto_upgrade_enabled := lib.get_default(management, "autoUpgrade", false)
	auto_upgrade_enabled == true
}
