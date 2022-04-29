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
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

type SharedData struct {
	CloudbuildSA string
}

func getPolicyID(t *testing.T, orgID string) string {
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s ", orgID), gcOpts)
	return op.String()
}

func TestProjects(t *testing.T) {

	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
	policyID := getPolicyID(t, orgID)

	var sharedData = map[string]string {
		"bu1": "",
		"bu2": "",
	}

	var restricted_apis_enabled = []string {
		"accesscontextmanager.googleapis.com",
		"billingbudgets.googleapis.com",
	}

	var shared_apis_enabled = []string {
		"cloudbuild.googleapis.com",
		"sourcerepo.googleapis.com",
		"cloudkms.googleapis.com",
	}

	for _, tts := range []struct {
		name  string
		tfDir string
	}{
		{
			name:  "bu1",
			tfDir: "../../../4-projects/business_unit_1/shared",
		},
		{
			name:  "bu2",
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
					sharedData[tts.name] = shared.GetStringOutput("cloudbuild_sa")
				})
			shared.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					shared.DefaultVerify(assert)
					// save the value of the "cloudbuild_sa" to be used in the envs tests
					sharedData[tts.name] = shared.GetStringOutput("cloudbuild_sa")

					projectID := shared.GetStringOutput("cloudbuild_project_id")
					prj := gcloud.Run(t, fmt.Sprintf("projects describe %s", projectID))
					assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))

					gcOpts := gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "value(config.name)"})
					enabledAPIS := gcloud.Run(t, "services list", gcOpts).Array()
					assert.Subset(enabledAPIS, shared_apis_enabled, "APIs should have been enabled")
				})
			shared.Test()
		})

	}

	for _, tt := range []struct {
		name            string
		perimeterEnvVar string
		tfDir           string
	}{
		{
			name:            "bu1_development",
			perimeterEnvVar: "TF_VAR_dev_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_1/development",
		},
		{
			name:            "bu1_non-production",
			perimeterEnvVar: "TF_VAR_nonprod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_1/non-production",
		},
		{
			name:            "bu1_production",
			perimeterEnvVar: "TF_VAR_prod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_1/production",
		},
		{
			name:            "bu2_development",
			perimeterEnvVar: "TF_VAR_dev_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_2/development",
		},
		{
			name:            "bu2_non-production",
			perimeterEnvVar: "TF_VAR_nonprod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_2/non-production",
		},
		{
			name:            "bu2_production",
			perimeterEnvVar: "TF_VAR_prod_restricted_service_perimeter_name",
			tfDir:           "../../../4-projects/business_unit_2/production",
		},
	} {
		t.Run(tt.name, func(t *testing.T) {

			env := strings.Split(tt.name, "_")
			netVars := map[string]interface{}{
				"access_context_manager_policy_id": policyID,
			}
			// networks created to retrieve output from the network step for this environment
			networks := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(fmt.Sprintf("../../../3-networks/envs/%s", env[1])),
				tft.WithVars(netVars),
			)
			perimeterName := networks.GetStringOutput("restricted_service_perimeter_name")

			vars := map[string]interface{}{
				"app_infra_pipeline_cloudbuild_sa": sharedData[env[0]],
				"perimeter_name":                   perimeterName,
				"access_context_manager_policy_id": policyID,
			}

			projects := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tt.tfDir),
				tft.WithVars(vars),
			)
			projects.DefineVerify(
				func(assert *assert.Assertions) {

					for _, projectOutput := range []string {
						"base_shared_vpc_project",
						"floating_project",
						"peering_project",
						"restricted_shared_vpc_project",
					} {
						projectID := projects.GetStringOutput(projectOutput)
						prj := gcloud.Run(t, fmt.Sprintf("projects describe %s", projectID))
						assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))

						if projectOutput == "restricted_shared_vpc_project" {
							gcOpts := gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "value(config.name)"})
							enabledAPIS := gcloud.Run(t, "services list", gcOpts).Array()
							assert.Subset(enabledAPIS, restricted_apis_enabled, "APIs should have been enabled")
						}
					}

				})

			projects.Test()
		})

	}
}
