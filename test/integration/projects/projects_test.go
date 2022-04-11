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

type SharedData struct {
	string CloudbuildSA
}

func TestProjects(t *testing.T) {

	var sharedData = map[string]*SharedData{
		"bu1_shared": {
			CloudbuildSA: "",
		},
		"bu2_shared": {
			CloudbuildSA: "",
		},
	}

	for _, tts := range []struct {
		name  string
		tfDir string
	}{
		{
			name: "bu1_shared",
			tfDir: "../../../4-projects/business_unit_1/shared",
		},
		{
			name: "bu2_shared",
			tfDir: "../../../4-projects/business_unit_2/shared",
		},

	}{
		t.Run(tts.name, func(t *testing.T) {
			shared := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tts.tfDir),
			)
            shared.DefineApply(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					shared.DefaultApply(assert)
					sharedData[tts.name].CloudbuildSA = shared.GetStringOutput("cloudbuild_sa")
				})
			shared.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					shared.DefaultVerify(assert)
					sharedData[tts.name].CloudbuildSA = shared.GetStringOutput("cloudbuild_sa")
				})
			shared.Test()
		})

	}

	for _, tt := range []struct {
		name  string
		sharedData string
		tfDir string
	}{
		{
			name: "bu1_development",
			sharedData: "bu1_shared",
			tfDir: "../../../4-projects/business_unit_1/development",
		},
		{
			name: "bu1_non-production",
			sharedData: "bu1_shared",
			tfDir: "../../../4-projects/business_unit_1/non-production",
		},
		{
			name: "bu1_production",
			sharedData: "bu1_shared",
			tfDir: "../../../4-projects/business_unit_1/production",
		},
		{
			name: "bu2_development",
			sharedData: "bu2_shared",
			tfDir: "../../../4-projects/business_unit_2/development",
		},
		{
			name: "bu2_non-production",
			sharedData: "bu2_shared",
			tfDir: "../../../4-projects/business_unit_2/non-production",
		},
		{
			name: "bu2_production",
			sharedData: "bu2_shared",
			tfDir: "../../../4-projects/business_unit_2/production",
		},
	}{
		t.Run(tt.name, func(t *testing.T) {
			vars := map[string]string{
				"app_infra_pipeline_cloudbuild_sa": sharedData[tt.sharedData].CloudbuildSA,
			}
			projects := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tt.tfDir),
				tft.WithVars(vars),
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
