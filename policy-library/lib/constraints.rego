#
# Copyright 2021 Google LLC
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

package validator.gcp.lib

# Function to fetch the constraint spec
# Usage:
# get_constraint_params(constraint, params)

get_constraint_params(constraint) = params {
	params := constraint.spec.parameters
}

# Function to fetch constraint info
# Usage:
# get_constraint_info(constraint, info)

get_constraint_info(constraint) = info {
	info := {
		"name": constraint.metadata.name,
		"kind": constraint.kind,
	}
}
