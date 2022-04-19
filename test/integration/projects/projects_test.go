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
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

type SharedData struct {
	CloudbuildSA string
}

func getPolicyID(orgID string, t *testing.T) string {
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s ", orgID), gcOpts)
	return op.String()
}

func TestProjects(t *testing.T) {

	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
	policyID := getPolicyID(orgID, t)

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
			name:  "bu1_shared",
			tfDir: "../../../4-projects/business_unit_1/shared",
		},
		{
			name:  "bu2_shared",
			tfDir: "../../../4-projects/business_unit_2/shared",
		},
	} {
		t.Run(tts.name, func(t *testing.T) {

			shared := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tts.tfDir),
			)

			shared.DefineApply(
				func(assert *assert.Assertions) {
					// perform default apply of the blueprint
					shared.DefaultApply(assert)
					// save the value of the "cloudbuild_sa" to be used in the envs tests
					sharedData[tts.name].CloudbuildSA = shared.GetStringOutput("cloudbuild_sa")
				})
			shared.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					shared.DefaultVerify(assert)
					// save the value of the "cloudbuild_sa" to be used in the envs tests
					sharedData[tts.name].CloudbuildSA = shared.GetStringOutput("cloudbuild_sa")
				})
			shared.Test()
		})

	}

	for _, tt := range []struct {
		name            string
		sharedData      string
		perimeterEnvVar string
		tfDir           string
		networkTfDir    string
	}{
		{
			name:            "bu1_development",
			sharedData:      "bu1_shared",
			perimeterEnvVar: "TF_VAR_dev_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_1/development",
			networkTfDir:    "../../../3-networks/envs/development",
		},
		{
			name:            "bu1_non-production",
			sharedData:      "bu1_shared",
			perimeterEnvVar: "TF_VAR_nonprod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_1/non-production",
			networkTfDir:    "../../../3-networks/envs/non-production",
		},
		{
			name:            "bu1_production",
			sharedData:      "bu1_shared",
			perimeterEnvVar: "TF_VAR_prod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_1/production",
			networkTfDir:    "../../../3-networks/envs/production",
		},
		{
			name:            "bu2_development",
			sharedData:      "bu2_shared",
			perimeterEnvVar: "TF_VAR_dev_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_2/development",
			networkTfDir:    "../../../3-networks/envs/development",
		},
		{
			name:            "bu2_non-production",
			sharedData:      "bu2_shared",
			perimeterEnvVar: "TF_VAR_nonprod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_2/non-production",
			networkTfDir:    "../../../3-networks/envs/non-production",
		},
		{
			name:            "bu2_production",
			sharedData:      "bu2_shared",
			perimeterEnvVar: "TF_VAR_prod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_2/production",
			networkTfDir:    "../../../3-networks/envs/production",
		},
	} {
		t.Run(tt.name, func(t *testing.T) {

			netVars := map[string]interface{}{
				"access_context_manager_policy_id": policyID,
			}
			networks := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tt.networkTfDir),
				tft.WithVars(netVars),
			)
			perimeterName := networks.GetStringOutput("restricted_service_perimeter_name")

			vars := map[string]interface{}{
				"app_infra_pipeline_cloudbuild_sa": sharedData[tt.sharedData].CloudbuildSA,
				"perimeter_name":                   perimeterName,
				"access_context_manager_policy_id": policyID,
			}
			projects := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tt.tfDir),
				tft.WithVars(vars),
			)
			projects.DefineVerify(
				func(assert *assert.Assertions) {
					baseProjectID := projects.GetStringOutput("base_shared_vpc_project")
					op1 := gcloud.Run(t, fmt.Sprintf("projects describe %s", baseProjectID))
					assert.True(op1.Exists(), "project %s should exist", baseProjectID)
				})
			projects.Test()
		})

	}
}
