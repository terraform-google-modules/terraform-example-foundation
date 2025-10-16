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
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

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
	networkMode := getNetworkMode(t)
	policyID := testutils.GetOrgACMPolicyID(t, orgID)
	require.NotEmpty(t, policyID, "Access Context Manager Policy ID must be configured in the organization for the test to proceed.")

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

	var confidentialRestrictedApisEnabled = []string{
		"confidentialcomputing.googleapis.com",
	}

	var project_sa_roles = []string{
		"roles/compute.instanceAdmin.v1",
		"roles/iam.serviceAccountAdmin",
		"roles/iam.serviceAccountUser",
	}

	for _, tt := range []struct {
		name          string
		repo          string
		baseDir       string
		sharedNetwork string
	}{
		{
			name:          "bu1_development",
			repo:          "bu1-example-app",
			baseDir:       "../../../4-projects/business_unit_1/%s",
			sharedNetwork: fmt.Sprintf("vpc-d-svpc%s", networkMode),
		},
		{
			name:          "bu1_nonproduction",
			repo:          "bu1-example-app",
			baseDir:       "../../../4-projects/business_unit_1/%s",
			sharedNetwork: fmt.Sprintf("vpc-n-svpc%s", networkMode),
		},
		{
			name:          "bu1_production",
			repo:          "bu1-example-app",
			baseDir:       "../../../4-projects/business_unit_1/%s",
			sharedNetwork: fmt.Sprintf("vpc-p-svpc%s", networkMode),
		},
	} {
		tt := tt
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			env := testutils.GetLastSplitElement(tt.name, "_")

			// networks created to retrieve output from the network step for this environment

			org := tft.NewTFBlueprintTest(t,
				tft.WithTFDir("../../../1-org/envs/shared"),
			)

			perimeterName := org.GetStringOutput("service_perimeter_name")

			shared := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(fmt.Sprintf(tt.baseDir, "shared")),
			)
			sharedCloudBuildSA := terraform.OutputMap(t, shared.GetTFOptions(), "terraform_service_accounts")[tt.repo]

			vars := map[string]interface{}{
				"remote_state_bucket":        backend_bucket,
				"folder_deletion_protection": false,
				"project_deletion_policy":    "DELETE",
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
						"floating_project",
						"peering_project",
						"shared_vpc_project",
						"confidential_space_project",
					} {
						projectID := projects.GetStringOutput(projectOutput)
						prj := gcloud.Runf(t, "projects describe %s", projectID)
						assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))

						if projectOutput == "shared_vpc_project" {

							enabledAPIS := gcloud.Runf(t, "services list --project %s --impersonate-service-account %s", projectID, terraformSA).Array()
							listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
							assert.Subset(listApis, restrictedApisEnabled, "APIs should have been enabled")

							sharedProjectNumber := projects.GetStringOutput("shared_vpc_project_number")
							floatingProjectNumber := projects.GetStringOutput("floating_project_number")
							peeringProjectNumber := projects.GetStringOutput("peering_project_number")
							perimeter, err := gcloud.RunCmdE(t, fmt.Sprintf("access-context-manager perimeters describe %s --policy %s", perimeterName, policyID))
							assert.NoError(err)
							assert.True(strings.Contains(perimeter, sharedProjectNumber), fmt.Sprintf("dry-run service perimeter %s should contain project %s", perimeterName, sharedProjectNumber))
							assert.True(strings.Contains(perimeter, floatingProjectNumber), fmt.Sprintf("dry-run service perimeter %s should contain project %s", perimeterName, floatingProjectNumber))
							assert.True(strings.Contains(perimeter, peeringProjectNumber), fmt.Sprintf("dry-run service perimeter %s should contain project %s", perimeterName, peeringProjectNumber))

							sharedVPC := gcloud.Runf(t, "compute shared-vpc get-host-project %s --impersonate-service-account %s", projectID, terraformSA)
							assert.NotEmpty(sharedVPC.Map())

							hostProjectID := sharedVPC.Get("name").String()
							hostProject := gcloud.Runf(t, "projects describe %s --impersonate-service-account %s", hostProjectID, terraformSA)
							assert.Equal("shared-vpc-host", hostProject.Get("labels.application_name").String(), "host project should have application_name label equals to shared-vpc-host")
							assert.Equal(env, hostProject.Get("labels.environment").String(), fmt.Sprintf("project should have environment label %s", env))

							hostNetwork := gcloud.Runf(t, "compute networks list --project %s --impersonate-service-account %s", hostProjectID, terraformSA).Array()[0]
							assert.Equal(tt.sharedNetwork, hostNetwork.Get("name").String(), "should have a shared vpc")

						}

						if projectOutput == "confidential_space_project" {

							enabledAPIS := gcloud.Runf(t, "services list --project %s --impersonate-service-account %s", projectID, terraformSA).Array()
							listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
							assert.Subset(listApis, confidentialRestrictedApisEnabled, "API should have been enabled")

							confidentialSpaceWorkloadSAEmail := projects.GetStringOutput("confidential_space_workload_sa")
							confidentialSpaceSAName := fmt.Sprintf("projects/%s/serviceAccounts/%s", projectID, confidentialSpaceWorkloadSAEmail)
							confidentialSpaceSA := gcloud.Runf(t, "iam service-accounts describe %s --project %s", confidentialSpaceWorkloadSAEmail, projectID)
							assert.Equal(confidentialSpaceSAName, confidentialSpaceSA.Get("name").String(), fmt.Sprintf("service account %s should exist", confidentialSpaceWorkloadSAEmail))
						}

						if projectOutput == "floating_project" {
							sharedVPC := gcloud.Runf(t, "compute shared-vpc get-host-project %s", projectID)
							assert.Empty(sharedVPC.Map())
						}

						if projectOutput == "peering_project" {

							peeringProjectSaRoles := append(project_sa_roles, "roles/resourcemanager.tagUser")
							iamFilter := fmt.Sprintf("bindings.members:'serviceAccount:%s'", sharedCloudBuildSA)
							iamOpts := gcloud.WithCommonArgs([]string{"--flatten", "bindings", "--filter", iamFilter, "--format", "json"})
							projectPolicy := gcloud.Run(t, fmt.Sprintf("projects get-iam-policy %s", projectID), iamOpts).Array()
							listRoles := testutils.GetResultFieldStrSlice(projectPolicy, "bindings.role")
							assert.Subset(listRoles, peeringProjectSaRoles, fmt.Sprintf("service account %s should have project level roles", sharedCloudBuildSA))

							peering := gcloud.Runf(t, "compute networks peerings list --project %s", projectID).Array()[0]
							assert.Contains(peering.Get("peerings.0.network").String(), tt.sharedNetwork, "should have a peering network")

							instanceRegion := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")["default_region"]
							peeringSubnetworkSelfLink := projects.GetStringOutput("peering_subnetwork_self_link")
							peeringSubnetworkSelfLinkSplitted := strings.Split(peeringSubnetworkSelfLink, "/")
							peering_subnetwork_name := peeringSubnetworkSelfLinkSplitted[len(peeringSubnetworkSelfLinkSplitted)-1]
							subnet := gcloud.Run(t, fmt.Sprintf("compute networks subnets describe %s --project %s --region %s", peering_subnetwork_name, projectID, instanceRegion))
							assert.Equal("PRIVATE", subnet.Get("purpose").String(), "Purpose should be PRIVATE")

							iapFirewallPolicy := gcloud.Run(t, fmt.Sprintf("compute network-firewall-policies list --project=%s --global", projectID)).Array()[0]
							iapFirewallPolicyName := iapFirewallPolicy.Get("name")

							iapSshRule := gcloud.Run(t, fmt.Sprintf("compute network-firewall-policies rules describe 1000 --firewall-policy=%s --global-firewall-policy --project=%s", iapFirewallPolicyName, projectID)).Array()[0]
							assert.Equal("INGRESS", iapSshRule.Get("direction").String(), "Direction should be INGRESS")
							assert.Equal("allow", iapSshRule.Get("action").String(), "Action should be ALLOW")
							assert.Equal("EFFECTIVE", iapSshRule.Get("targetSecureTags.0.state").String(), "Should be bound to an effective terget secure tag")
							assert.Equal("22", iapSshRule.Get("match.layer4Configs.0.ports.0").String(), "Protocol port should be 22")

							iapRdpRule := gcloud.Run(t, fmt.Sprintf("compute network-firewall-policies rules describe 1001 --firewall-policy=%s --global-firewall-policy --project=%s", iapFirewallPolicyName, projectID)).Array()[0]
							assert.Equal("INGRESS", iapRdpRule.Get("direction").String(), "Direction should be INGRESS")
							assert.Equal("allow", iapRdpRule.Get("action").String(), "Action should be ALLOW")
							assert.Equal("EFFECTIVE", iapRdpRule.Get("targetSecureTags.0.state").String(), "Should be bound to an effective terget secure tag")
							assert.Equal("3389", iapRdpRule.Get("match.layer4Configs.0.ports.0").String(), "Protocol port should be 3389")

						}
					}
				})

			projects.Test()
		})

	}
}
