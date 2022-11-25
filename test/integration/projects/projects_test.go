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
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

func getPolicyID(t *testing.T, orgID string) string {
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s ", orgID), gcOpts)
	return op.String()
}

func getNetworkMode(t *testing.T) string {
	mode := utils.ValFromEnv(t, "TF_VAR_example_foundations_mode")
	if mode == "HubAndSpoke" {
		return "-spoke"
	}
	return ""
}

func TestProjects(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	orgID := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")["org_id"]
	policyID := getPolicyID(t, orgID)
	networkMode := getNetworkMode(t)

	// Configure impersonation for test execution
	terraformSA := bootstrap.GetStringOutput("projects_step_terraform_service_account_email")
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSA)

	projects_backend_bucket := bootstrap.GetStringOutput("projects_gcs_bucket_tfstate")
	backendConfig := map[string]interface{}{
		"bucket": projects_backend_bucket,
	}
	backend_bucket := bootstrap.GetStringOutput("gcs_bucket_tfstate")

	var restrictedApisEnabled = []string{
		"accesscontextmanager.googleapis.com",
		"billingbudgets.googleapis.com",
	}

	var project_sa_roles = []string{
		"roles/compute.instanceAdmin.v1",
		"roles/iam.serviceAccountAdmin",
		"roles/iam.serviceAccountUser",
	}

	for _, tt := range []struct {
		name              string
		repo              string
		baseDir           string
		baseNetwork       string
		restrictedNetwork string
	}{
		{
			name:              "bu1_development",
			repo:              "bu1-example-app",
			baseDir:           "../../../4-projects/business_unit_1/%s",
			baseNetwork:       fmt.Sprintf("vpc-d-shared-base%s", networkMode),
			restrictedNetwork: fmt.Sprintf("vpc-d-shared-restricted%s", networkMode),
		},
		{
			name:              "bu1_non-production",
			repo:              "bu1-example-app",
			baseDir:           "../../../4-projects/business_unit_1/%s",
			baseNetwork:       fmt.Sprintf("vpc-n-shared-base%s", networkMode),
			restrictedNetwork: fmt.Sprintf("vpc-n-shared-restricted%s", networkMode),
		},
		{
			name:              "bu1_production",
			repo:              "bu1-example-app",
			baseDir:           "../../../4-projects/business_unit_1/%s",
			baseNetwork:       fmt.Sprintf("vpc-p-shared-base%s", networkMode),
			restrictedNetwork: fmt.Sprintf("vpc-p-shared-restricted%s", networkMode),
		},
		{
			name:              "bu2_development",
			repo:              "bu2-example-app",
			baseDir:           "../../../4-projects/business_unit_2/%s",
			baseNetwork:       fmt.Sprintf("vpc-d-shared-base%s", networkMode),
			restrictedNetwork: fmt.Sprintf("vpc-d-shared-restricted%s", networkMode),
		},
		{
			name:              "bu2_non-production",
			repo:              "bu2-example-app",
			baseDir:           "../../../4-projects/business_unit_2/%s",
			baseNetwork:       fmt.Sprintf("vpc-n-shared-base%s", networkMode),
			restrictedNetwork: fmt.Sprintf("vpc-n-shared-restricted%s", networkMode),
		},
		{
			name:              "bu2_production",
			repo:              "bu2-example-app",
			baseDir:           "../../../4-projects/business_unit_2/%s",
			baseNetwork:       fmt.Sprintf("vpc-p-shared-base%s", networkMode),
			restrictedNetwork: fmt.Sprintf("vpc-p-shared-restricted%s", networkMode),
		},
	} {
		t.Run(tt.name, func(t *testing.T) {

			env := testutils.GetLastSplitElement(tt.name, "_")
			netVars := map[string]interface{}{
				"access_context_manager_policy_id": policyID,
			}

			// networks created to retrieve output from the network step for this environment
			var networkTFDir string
			if networkMode == "" {
				networkTFDir = "../../../3-networks-dual-svpc/envs/%s"
			} else {
				networkTFDir = "../../../3-networks-hub-and-spoke/envs/%s"
			}

			networks := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(fmt.Sprintf(networkTFDir, env)),
				tft.WithVars(netVars),
			)
			perimeterName := networks.GetStringOutput("restricted_service_perimeter_name")

			shared := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(fmt.Sprintf(tt.baseDir, "shared")),
			)
			sharedCloudBuildSA := terraform.OutputMap(t, shared.GetTFOptions(), "terraform_service_accounts")[tt.repo]

			vars := map[string]interface{}{
				"remote_state_bucket": backend_bucket,
			}

			projects := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(fmt.Sprintf(tt.baseDir, env)),
				tft.WithVars(vars),
				tft.WithBackendConfig(backendConfig),
				tft.WithRetryableTerraformErrors(testutils.RetryableTransientErrors, 1, 2*time.Minute),
				tft.WithPolicyLibraryPath("/workspace/policy-library", bootstrap.GetTFSetupStringOutput("project_id")),
			)

			projects.DefineVerify(
				func(assert *assert.Assertions) {

					for _, projectOutput := range []string{
						"base_shared_vpc_project",
						"floating_project",
						"peering_project",
						"restricted_shared_vpc_project",
					} {
						projectID := projects.GetStringOutput(projectOutput)
						prj := gcloud.Runf(t, "projects describe %s", projectID)
						assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))

						if projectOutput == "restricted_shared_vpc_project" {

							enabledAPIS := gcloud.Runf(t, "services list --project %s --impersonate-service-account %s", projectID, terraformSA).Array()
							listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
							assert.Subset(listApis, restrictedApisEnabled, "APIs should have been enabled")

							restrictedProjectNumber := projects.GetStringOutput("restricted_shared_vpc_project_number")
							perimeter := gcloud.Runf(t, "access-context-manager perimeters describe %s --policy %s", perimeterName, policyID)
							listResources := utils.GetResultStrSlice(perimeter.Get("status.resources").Array())
							assert.Contains(listResources, fmt.Sprintf("projects/%s", restrictedProjectNumber), "restricted project should be in the perimeter")

							sharedVPC := gcloud.Runf(t, "compute shared-vpc get-host-project %s --impersonate-service-account %s", projectID, terraformSA)
							assert.NotEmpty(sharedVPC.Map())

							hostProjectID := sharedVPC.Get("name").String()
							hostProject := gcloud.Runf(t, "projects describe %s --impersonate-service-account %s", hostProjectID, terraformSA)
							assert.Equal("restricted-shared-vpc-host", hostProject.Get("labels.application_name").String(), "host project should have application_name label equals to base-shared-vpc-host")
							assert.Equal(env, hostProject.Get("labels.environment").String(), fmt.Sprintf("project should have environment label %s", env))

							hostNetwork := gcloud.Runf(t, "compute networks list --project %s --impersonate-service-account %s", hostProjectID, terraformSA).Array()[0]
							assert.Equal(tt.restrictedNetwork, hostNetwork.Get("name").String(), "should have a shared vpc")

						}

						if projectOutput == "base_shared_vpc_project" {

							iamFilter := fmt.Sprintf("bindings.members:'serviceAccount:%s'", sharedCloudBuildSA)
							iamOpts := gcloud.WithCommonArgs([]string{"--flatten", "bindings", "--filter", iamFilter, "--format", "json"})
							projectPolicy := gcloud.Run(t, fmt.Sprintf("projects get-iam-policy %s", projectID), iamOpts).Array()
							listRoles := testutils.GetResultFieldStrSlice(projectPolicy, "bindings.role")
							assert.Subset(listRoles, project_sa_roles, fmt.Sprintf("service account %s should have project level roles", sharedCloudBuildSA))

							sharedVPC := gcloud.Runf(t, "compute shared-vpc get-host-project %s", projectID)
							assert.NotEmpty(sharedVPC.Map())

							hostProjectID := sharedVPC.Get("name").String()
							hostProject := gcloud.Runf(t, "projects describe %s", hostProjectID)
							assert.Equal("base-shared-vpc-host", hostProject.Get("labels.application_name").String(), "host project should have application_name label equals to base-shared-vpc-host")
							assert.Equal(env, hostProject.Get("labels.environment").String(), fmt.Sprintf("project should have environment label %s", env))

							hostNetwork := gcloud.Runf(t, "compute networks list --project %s", hostProjectID).Array()[0]
							assert.Equal(tt.baseNetwork, hostNetwork.Get("name").String(), "should have a shared vpc")

						}

						if projectOutput == "floating_project" {
							sharedVPC := gcloud.Runf(t, "compute shared-vpc get-host-project %s", projectID)
							assert.Empty(sharedVPC.Map())
						}

						if projectOutput == "peering_project" {
							peering := gcloud.Runf(t, "compute networks peerings list --project %s", projectID).Array()[0]
							assert.Contains(peering.Get("peerings.0.network").String(), tt.baseNetwork, "should have a peering network")
						}
					}
				})

			projects.Test()
		})

	}
}
