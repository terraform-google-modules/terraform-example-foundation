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

# has_field tests
test_has_field_exists {
	obj := {"a": "b"}
	true == has_field(obj, "a")
}

# False is a tricky special case, as false responses would create an undefined document unless
# they are explicitly tested for
test_has_field_false {
	obj := {"a": false}
	true == has_field(obj, "a")
}

test_has_field_no_field {
	obj := {}
	false == has_field(obj, "a")
}

# get_default_tests
test_get_default_exists {
	obj := {"a": "b"}
	"b" == get_default(obj, "a", "q")
}

test_get_default_not_exists {
	obj := {}
	"q" == get_default(obj, "a", "q")
}

test_get_default_has_false {
	obj := {"a": false}
	false == get_default(obj, "a", "b")
}
