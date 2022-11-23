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

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

func getPolicyID(t *testing.T, orgID string) string {
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s ", orgID), gcOpts)
	return op.String()
}

func isHubAndSpokeMode(t *testing.T) bool {
	mode := utils.ValFromEnv(t, "TF_VAR_example_foundations_mode")
	return mode == "HubAndSpoke"
}

func TestShared(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	orgID := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")["org_id"]
	policyID := getPolicyID(t, orgID)

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
			}

			// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
			shared.DefaultVerify(assert)

			projectID := shared.GetStringOutput("dns_hub_project_id")
			networkName := "vpc-c-dns-hub"
			dnsHubNetworkUrl := fmt.Sprintf("https://www.googleapis.com/compute/v1/projects/%s/global/networks/vpc-c-dns-hub", projectID)
			dnsPolicyName := "dp-dns-hub-default-policy"

			dnsPolicy := gcloud.Runf(t, "dns policies describe %s --project %s", dnsPolicyName, projectID)
			assert.True(dnsPolicy.Get("enableInboundForwarding").Bool(), fmt.Sprintf("dns policy %s should have inbound forwarding enabled", dnsPolicyName))
			assert.Equal(dnsHubNetworkUrl, dnsPolicy.Get("networks.0.networkUrl").String(), fmt.Sprintf("dns policy %s should be on network %s", dnsPolicyName, networkName))

			dnsFwZoneName := "fz-dns-hub"
			dnsZone := gcloud.Runf(t, "dns managed-zones describe %s --project %s", dnsFwZoneName, projectID)
			assert.Equal(dnsFwZoneName, dnsZone.Get("name").String(), fmt.Sprintf("dnsZone %s should exist", dnsFwZoneName))

			projectNetwork := gcloud.Runf(t, "compute networks describe %s --project %s", networkName, projectID)
			assert.Equal(networkName, projectNetwork.Get("name").String(), fmt.Sprintf("network %s should exist", networkName))

			for _, subnet := range []struct {
				name      string
				cidrRange string
				region    string
			}{
				{
					name:      "sb-c-dns-hub-us-central1",
					cidrRange: "172.16.0.128/25",
					region:    "us-central1",
				},
				{
					name:      "sb-c-dns-hub-us-west1",
					cidrRange: "172.16.0.0/25",
					region:    "us-west1",
				},
			} {
				sub := gcloud.Runf(t, "compute networks subnets describe %s --region %s --project %s", subnet.name, subnet.region, projectID)
				assert.Equal(subnet.name, sub.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnet.name))
				assert.Equal(subnet.cidrRange, sub.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", subnet.cidrRange))
			}

			bgpAdvertisedIpRange := "35.199.192.0/19"

			for _, router := range []struct {
				name   string
				region string
			}{
				{
					name:   "cr-c-dns-hub-us-west1-cr1",
					region: "us-west1",
				},
				{
					name:   "cr-c-dns-hub-us-west1-cr2",
					region: "us-west1",
				},
				{
					name:   "cr-c-dns-hub-us-central1-cr3",
					region: "us-central1",
				},
				{
					name:   "cr-c-dns-hub-us-central1-cr4",
					region: "us-central1",
				},
			} {
				computeRouter := gcloud.Runf(t, "compute routers describe %s --region %s --project %s", router.name, router.region, projectID)
				assert.Equal(router.name, computeRouter.Get("name").String(), fmt.Sprintf("router %s should exist", router.name))
				assert.Equal("64667", computeRouter.Get("bgp.asn").String(), fmt.Sprintf("router %s should have bgp asm 64667", router.name))
				assert.Equal(1, len(computeRouter.Get("bgp.advertisedIpRanges").Array()), fmt.Sprintf("router %s should have only one advertised IP range", router.name))
				assert.Equal(bgpAdvertisedIpRange, computeRouter.Get("bgp.advertisedIpRanges.0.range").String(), fmt.Sprintf("router %s should have only range %s", router.name, bgpAdvertisedIpRange))
				assert.Equal(dnsHubNetworkUrl, computeRouter.Get("network").String(), fmt.Sprintf("router %s should have be from network vpc-c-dns-hub", router.name))
			}
		})
	shared.Test()
}
