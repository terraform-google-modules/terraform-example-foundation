// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package projects

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestProjects(t *testing.T) {

	for _, tt := range []struct {
		name  string
		tfDir string
	}{
		{
			name: "bu1_shared",
			tfDir: "../../../4-projects/business_unit_1/shared",
		},
		{
			name: "bu1_development",
			tfDir: "../../../4-projects/business_unit_1/development",
		},
		{
			name: "bu1_non-production",
			tfDir: "../../../4-projects/business_unit_1/non-production",
		},
		{
			name: "bu1_production",
			tfDir: "../../../4-projects/business_unit_1/production",
		},
		{
			name: "bu2_shared",
			tfDir: "../../../4-projects/business_unit_2/shared",
		},
		{
			name: "bu2_development",
			tfDir: "../../../4-projects/business_unit_2/development",
		},
		{
			name: "bu2_non-production",
			tfDir: "../../../4-projects/business_unit_2/non-production",
		},
		{
			name: "bu2_production",
			tfDir: "../../../4-projects/business_unit_2/production",
		},
	}{
		t.Run(tt.name, func(t *testing.T) {
			projects := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tt.tfDir),
			)
			projects.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					projects.DefaultVerify(assert)
				})
			projects.Test()
		})

	}
}
