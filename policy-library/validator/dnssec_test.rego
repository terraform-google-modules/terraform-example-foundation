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

package templates.gcp.GCPDNSSECConstraintV1

all_violations[violation] {
	resource := data.test.fixtures.dnssec.assets[_]
	constraint := data.test.fixtures.dnssec.constraints.require_dnssec

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

# Confirm total violations count
test_dnssec_violations_count {
	count(all_violations) == 2
}

test_dnssec_violations_basic {
	violation_resources := {r | r = all_violations[_].details.resource}
	violation_resources == {
		"//dns.googleapis.com/projects/186783260185/managedZones/wrong-off",
		"//dns.googleapis.com/projects/186783260185/managedZones/wrong-transfer",
	}
}
