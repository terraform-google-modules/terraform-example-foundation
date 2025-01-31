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

package shared

import (
	"fmt"
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

func isHubAndSpokeMode(t *testing.T) bool {
	mode := utils.ValFromEnv(t, "TF_VAR_example_foundations_mode")
	return mode == "HubAndSpoke"
}

func TestShared(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	orgID := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")["org_id"]
	policyID := testutils.GetOrgACMPolicyID(t, orgID)
	require.NotEmpty(t, policyID, "Access Context Manager Policy ID must be configured in the organization for the test to proceed.")

	// Configure impersonation for test execution
	terraformSA := bootstrap.GetStringOutput("networks_step_terraform_service_account_email")
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSA)
	backend_bucket := bootstrap.GetStringOutput("gcs_bucket_tfstate")

	backendConfig := map[string]interface{}{
		"bucket": backend_bucket,
	}

	vars := map[string]interface{}{
		"remote_state_bucket": backend_bucket,
	}
	var tfdDir string
	if isHubAndSpokeMode(t) {
		vars["access_context_manager_policy_id"] = policyID
		vars["perimeter_additional_members"] = []string{}
		tfdDir = "../../../3-networks-hub-and-spoke/envs/shared"
	} else {
		tfdDir = "../../../3-networks-dual-svpc/envs/shared"
	}

	shared := tft.NewTFBlueprintTest(t,
		tft.WithTFDir(tfdDir),
		tft.WithVars(vars),
		tft.WithRetryableTerraformErrors(testutils.RetryableTransientErrors, 1, 2*time.Minute),
		tft.WithPolicyLibraryPath("/workspace/policy-library", bootstrap.GetTFSetupStringOutput("project_id")),
		tft.WithBackendConfig(backendConfig),
	)
	shared.DefineVerify(
		func(assert *assert.Assertions) {

			// do a time.Sleep to wait for propagation of VPC Service Controls configuration in the Hub and Spoke network mode
			if isHubAndSpokeMode(t) {
				time.Sleep(60 * time.Second)

				// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
				// Comment DefaultVerify because proxy-only subnets tries to change `ipv6_access_type` from `INTERNAL` to `null` on every run (plan and apply)
				// Module issue: https://github.com/terraform-google-modules/terraform-google-network/issues/528
				// Resource issue: https://github.com/hashicorp/terraform-provider-google/issues/16801
				// Resource issue: https://github.com/hashicorp/terraform-provider-google/issues/16804
				// shared.DefaultVerify(assert)

				dnsFwZoneName := "fz-dns-hub"
				bgpAdvertisedIpRange := "35.199.192.0/19"

				baseProjectID := shared.GetStringOutput("base_host_project_id")
				baseNetworkName := shared.GetStringOutput("base_network_name")
				baseDNSPolicyName := shared.GetStringOutput("base_dns_policy")
				baseDNSHubNetworkUrl := fmt.Sprintf("https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s", baseProjectID, baseNetworkName)

				baseDNSPolicy := gcloud.Runf(t, "dns policies describe %s --project %s", baseDNSPolicyName, baseProjectID) ///////
				assert.True(baseDNSPolicy.Get("enableInboundForwarding").Bool(), fmt.Sprintf("dns policy %s should have inbound forwarding enabled", baseDNSPolicyName))
				assert.Equal(baseDNSHubNetworkUrl, baseDNSPolicy.Get("networks.0.networkUrl").String(), fmt.Sprintf("dns policy %s should be on network %s", baseDNSPolicyName, baseNetworkName))

				baseDNSZone := gcloud.Runf(t, "dns managed-zones describe %s --project %s", dnsFwZoneName, baseProjectID)
				assert.Equal(dnsFwZoneName, baseDNSZone.Get("name").String(), fmt.Sprintf("baseDNSZone %s should exist", dnsFwZoneName)) //

				baseProjectNetwork := gcloud.Runf(t, "compute networks describe %s --project %s", baseNetworkName, baseProjectID)
				assert.Equal(baseNetworkName, baseProjectNetwork.Get("name").String(), fmt.Sprintf("network %s should exist", baseNetworkName))

				for _, subnet := range []struct {
					name      string
					cidrRange string
					region    string
				}{
					{
						name:      "sb-c-shared-base-hub-us-west1",
						cidrRange: "10.1.0.0/18",
						region:    "us-west1",
					},
					{
						name:      "sb-c-shared-base-hub-us-central1",
						cidrRange: "10.0.0.0/18",
						region:    "us-central1",
					},
				} {
					baseSubnet := gcloud.Runf(t, "compute networks subnets describe %s --region %s --project %s", subnet.name, subnet.region, baseProjectID)
					assert.Equal(subnet.name, baseSubnet.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnet.name))
					assert.Equal(subnet.cidrRange, baseSubnet.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", subnet.cidrRange))
				}

				for _, router := range []struct {
					name   string
					region string
				}{
					{
						name:   "cr-c-shared-base-hub-us-central1-cr1",
						region: "us-central1",
					},
					{
						name:   "cr-c-shared-base-hub-us-central1-cr2",
						region: "us-central1",
					},
					{
						name:   "cr-c-shared-base-hub-us-west1-cr3",
						region: "us-west1",
					},
					{
						name:   "cr-c-shared-base-hub-us-west1-cr4",
						region: "us-west1",
					},
				} {
					baseComputeRouter := gcloud.Runf(t, "compute routers describe %s --region %s --project %s", router.name, router.region, baseProjectID)
					assert.Equal(router.name, baseComputeRouter.Get("name").String(), fmt.Sprintf("router %s should exist", router.name))
					assert.Equal("64514", baseComputeRouter.Get("bgp.asn").String(), fmt.Sprintf("router %s should have bgp asm 64514", router.name))
					assert.Equal(bgpAdvertisedIpRange, baseComputeRouter.Get("bgp.advertisedIpRanges.0.range").String(), fmt.Sprintf("router %s should have range %s", router.name, bgpAdvertisedIpRange))
					assert.Equal(baseDNSHubNetworkUrl, baseComputeRouter.Get("network").String(), fmt.Sprintf("router %s should be on network vpc-c-shared-base-hub", router.name))
				}

				restrictedProjectID := shared.GetStringOutput("restricted_host_project_id")
				restrictedNetworkName := shared.GetStringOutput("restricted_network_name")
				restrictedDNSPolicyName := shared.GetStringOutput("restricted_dns_policy")
				restrictedDNSHubNetworkUrl := fmt.Sprintf("https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s", restrictedProjectID, restrictedNetworkName)

				restrictedDNSPolicy := gcloud.Runf(t, "dns policies describe %s --project %s", restrictedDNSPolicyName, restrictedProjectID)
				assert.True(restrictedDNSPolicy.Get("enableInboundForwarding").Bool(), fmt.Sprintf("dns policy %s should have inbound forwarding enabled", restrictedDNSPolicyName))
				assert.Equal(restrictedDNSHubNetworkUrl, restrictedDNSPolicy.Get("networks.0.networkUrl").String(), fmt.Sprintf("dns policy %s should be on network %s", restrictedDNSPolicyName, restrictedNetworkName))

				restrictedDNSZone := gcloud.Runf(t, "dns managed-zones describe %s --project %s", dnsFwZoneName, restrictedProjectID)
				assert.Equal(dnsFwZoneName, restrictedDNSZone.Get("name").String(), fmt.Sprintf("restrictedDNSZone %s should exist", dnsFwZoneName))

				restrictedProjectNetwork := gcloud.Runf(t, "compute networks describe %s --project %s", restrictedNetworkName, restrictedProjectID)
				assert.Equal(restrictedNetworkName, restrictedProjectNetwork.Get("name").String(), fmt.Sprintf("network %s should exist", restrictedNetworkName))

				for _, subnet := range []struct {
					name      string
					cidrRange string
					region    string
				}{
					{
						name:      "sb-c-shared-restricted-hub-us-west1",
						cidrRange: "10.9.0.0/18",
						region:    "us-west1",
					},
					{
						name:      "sb-c-shared-restricted-hub-us-central1",
						cidrRange: "10.8.0.0/18",
						region:    "us-central1",
					},
				} {
					restrictedSubnet := gcloud.Runf(t, "compute networks subnets describe %s --region %s --project %s", subnet.name, subnet.region, restrictedProjectID)
					assert.Equal(subnet.name, restrictedSubnet.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnet.name))
					assert.Equal(subnet.cidrRange, restrictedSubnet.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", subnet.cidrRange))
				}

				for _, router := range []struct {
					name   string
					region string
				}{
					{
						name:   "cr-c-shared-restricted-hub-us-central1-cr5",
						region: "us-central1",
					},
					{
						name:   "cr-c-shared-restricted-hub-us-central1-cr6",
						region: "us-central1",
					},
					{
						name:   "cr-c-shared-restricted-hub-us-west1-cr7",
						region: "us-west1",
					},
					{
						name:   "cr-c-shared-restricted-hub-us-west1-cr8",
						region: "us-west1",
					},
				} {
					restrictedComputeRouter := gcloud.Runf(t, "compute routers describe %s --region %s --project %s", router.name, router.region, restrictedProjectID)
					assert.Equal(router.name, restrictedComputeRouter.Get("name").String(), fmt.Sprintf("router %s should exist", router.name))
					assert.Equal("64514", restrictedComputeRouter.Get("bgp.asn").String(), fmt.Sprintf("router %s should have bgp asm 64514", router.name))
					assert.Equal(bgpAdvertisedIpRange, restrictedComputeRouter.Get("bgp.advertisedIpRanges.0.range").String(), fmt.Sprintf("router %s should have range %s", router.name, bgpAdvertisedIpRange))
					assert.Equal(restrictedDNSHubNetworkUrl, restrictedComputeRouter.Get("network").String(), fmt.Sprintf("router %s should be on network vpc-c-shared-restricted-hub", router.name))
				}
			}
		})
	shared.Test()
}
