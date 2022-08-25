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

package networks

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
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

func getNetworkResourceNames(envCode string, networkMode string) map[string]map[string]string {
	return map[string]map[string]string{
		"base": {
			"network_name":          fmt.Sprintf("vpc-%s-shared-base%s", envCode, networkMode),
			"global_address":        fmt.Sprintf("ga-%s-shared-base%s-vpc-peering-internal", envCode, networkMode),
			"dns_zone_googleapis":   fmt.Sprintf("dz-%s-shared-base-apis", envCode),
			"dns_zone_gcr":          fmt.Sprintf("dz-%s-shared-base-gcr", envCode),
			"dns_zone_pkg_dev":      fmt.Sprintf("dz-%s-shared-base-pkg-dev", envCode),
			"dns_zone_peering_zone": fmt.Sprintf("dz-%s-shared-base-to-dns-hub", envCode),
			"dns_policy_name":       fmt.Sprintf("dp-%s-shared-base-default-policy", envCode),
			"subnet_name1":          fmt.Sprintf("sb-%s-shared-base-us-west1", envCode),
			"subnet_name2":          fmt.Sprintf("sb-%s-shared-base-us-central1", envCode),
			"region1_router1":       fmt.Sprintf("cr-%s-shared-base%s-us-west1-cr1", envCode, networkMode),
			"region1_router2":       fmt.Sprintf("cr-%s-shared-base%s-us-west1-cr2", envCode, networkMode),
			"region2_router1":       fmt.Sprintf("cr-%s-shared-base%s-us-central1-cr3", envCode, networkMode),
			"region2_router2":       fmt.Sprintf("cr-%s-shared-base%s-us-central1-cr4", envCode, networkMode),
			"fw_deny_all_egress":    fmt.Sprintf("fw-%s-shared-base-65535-e-d-all-all-all", envCode),
			"fw_allow_api_egress":   fmt.Sprintf("fw-%s-shared-base-65534-e-a-allow-google-apis-all-tcp-443", envCode),
		},
		"restricted": {
			"network_name":          fmt.Sprintf("vpc-%s-shared-restricted%s", envCode, networkMode),
			"global_address":        fmt.Sprintf("ga-%s-shared-restricted%s-vpc-peering-internal", envCode, networkMode),
			"dns_zone_googleapis":   fmt.Sprintf("dz-%s-shared-restricted-apis", envCode),
			"dns_zone_gcr":          fmt.Sprintf("dz-%s-shared-restricted-gcr", envCode),
			"dns_zone_pkg_dev":      fmt.Sprintf("dz-%s-shared-restricted-pkg-dev", envCode),
			"dns_zone_peering_zone": fmt.Sprintf("dz-%s-shared-restricted-to-dns-hub", envCode),
			"dns_policy_name":       fmt.Sprintf("dp-%s-shared-restricted-default-policy", envCode),
			"subnet_name1":          fmt.Sprintf("sb-%s-shared-restricted-us-west1", envCode),
			"subnet_name2":          fmt.Sprintf("sb-%s-shared-restricted-us-central1", envCode),
			"region1_router1":       fmt.Sprintf("cr-%s-shared-restricted%s-us-west1-cr5", envCode, networkMode),
			"region1_router2":       fmt.Sprintf("cr-%s-shared-restricted%s-us-west1-cr6", envCode, networkMode),
			"region2_router1":       fmt.Sprintf("cr-%s-shared-restricted%s-us-central1-cr7", envCode, networkMode),
			"region2_router2":       fmt.Sprintf("cr-%s-shared-restricted%s-us-central1-cr8", envCode, networkMode),
			"fw_deny_all_egress":    fmt.Sprintf("fw-%s-shared-restricted-65535-e-d-all-all-all", envCode),
			"fw_allow_api_egress":   fmt.Sprintf("fw-%s-shared-restricted-65534-e-a-allow-google-apis-all-tcp-443", envCode),
		},
	}
}

func TestNetworks(t *testing.T) {

	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
	policyID := getPolicyID(t, orgID)
	networkMode := getNetworkMode(t)

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	// Configure impersonation for test execution
	terraformSA := bootstrap.GetStringOutput("networks_step_terraform_service_account_email")
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSA)

	restrictedServices := []string{
		"bigquery.googleapis.com",
		"storage.googleapis.com",
	}

	cidrRanges := map[string]map[string][]string{
		"development": {
			"base":       []string{"10.0.64.0/21", "10.1.64.0/21"},
			"restricted": []string{"10.8.64.0/21", "10.9.64.0/21"},
		},
		"non-production": {
			"base":       []string{"10.0.128.0/21", "10.1.128.0/21"},
			"restricted": []string{"10.8.128.0/21", "10.9.128.0/21"},
		},
		"production": {
			"base":       []string{"10.0.192.0/21", "10.1.192.0/21"},
			"restricted": []string{"10.8.192.0/21", "10.9.192.0/21"},
		},
	}

	googleapisCIDR := map[string]string{
		"base":       "10.3.0.5",
		"restricted": "10.3.0.5",
	}

	for _, envName := range []string{
		"development",
		"non-production",
		"production",
	} {
		t.Run(envName, func(t *testing.T) {

			vars := map[string]interface{}{
				"access_context_manager_policy_id": policyID,
				"terraform_service_account":        terraformSA,
			}

			var tfdDir string
			if networkMode == "" {
				tfdDir = "../../../3-networks-dual-svpc/envs/%s"
			} else {
				tfdDir = "../../../3-networks-hub-and-spoke/envs/%s"
			}

			envCode := string(envName[0:1])
			networks := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(fmt.Sprintf(tfdDir, envName)),
				tft.WithVars(vars),
			)
			networks.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					networks.DefaultVerify(assert)

					servicePerimeterLink := fmt.Sprintf("accessPolicies/%s/servicePerimeters/%s", policyID, networks.GetStringOutput("restricted_service_perimeter_name"))
					accessLevel := fmt.Sprintf("accessPolicies/%s/accessLevels/%s", policyID, networks.GetStringOutput("restricted_access_level_name"))
					networkNames := getNetworkResourceNames(envCode, networkMode)

					servicePerimeter := gcloud.Runf(t, "access-context-manager perimeters describe %s --policy %s", servicePerimeterLink, policyID)
					assert.Equal(servicePerimeterLink, servicePerimeter.Get("name").String(), fmt.Sprintf("service perimeter %s should exist", servicePerimeterLink))
					listLevels := utils.GetResultStrSlice(servicePerimeter.Get("status.accessLevels").Array())
					assert.Contains(listLevels, accessLevel, fmt.Sprintf("service perimeter %s should have access level %s", servicePerimeterLink, accessLevel))
					listServices := utils.GetResultStrSlice(servicePerimeter.Get("status.restrictedServices").Array())
					assert.Subset(listServices, restrictedServices, fmt.Sprintf("service perimeter %s should restrict 'bigquery.googleapis.com' and 'storage.googleapis.com'", servicePerimeterLink))

					for _, networkType := range []string{
						"base",
						"restricted",
					} {
						projectID := networks.GetStringOutput(fmt.Sprintf("%s_host_project_id", networkType))

						for _, dnsType := range []string{
							"dns_zone_googleapis",
							"dns_zone_gcr",
							"dns_zone_pkg_dev",
							"dns_zone_peering_zone",
						} {
							dnsName := networkNames[networkType][dnsType]
							dnsZone := gcloud.Runf(t, "dns managed-zones describe %s --project %s", dnsName, projectID)
							assert.Equal(dnsName, dnsZone.Get("name").String(), fmt.Sprintf("dnsZone %s should exist", dnsName))
						}

						networkName := networkNames[networkType]["network_name"]
						networkUrl := fmt.Sprintf("https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s", projectID, networkName)
						dnsPolicyName := networkNames[networkType]["dns_policy_name"]
						dnsPolicy := gcloud.Runf(t, "dns policies describe %s --project %s", dnsPolicyName, projectID)
						assert.True(dnsPolicy.Get("enableInboundForwarding").Bool(), fmt.Sprintf("dns policy %s should have inbound forwarding enabled", dnsPolicyName))
						assert.Equal(networkUrl, dnsPolicy.Get("networks.0.networkUrl").String(), fmt.Sprintf("dns policy %s should be on network %s", dnsPolicyName, networkName))

						//compute networks describe %s --project %s
						projectNetwork := gcloud.Runf(t, "compute networks describe %s --project %s", networkName, projectID)
						assert.Equal(networkName, projectNetwork.Get("name").String(), fmt.Sprintf("network %s should exist", networkName))

						//gcloud compute addresses describe NAME --global
						globalAddressName := networkNames[networkType]["global_address"]
						globalAddress := gcloud.Runf(t, "compute addresses describe %s --global --project %s", globalAddressName, projectID)
						assert.Equal(globalAddressName, globalAddress.Get("name").String(), fmt.Sprintf("global address %s should exist", globalAddressName))

						subnetName1 := networkNames[networkType]["subnet_name1"]
						usWest1Range := cidrRanges[envName][networkType][0]
						subnet1 := gcloud.Runf(t, "compute networks subnets describe %s --region us-west1 --project %s", subnetName1, projectID)
						assert.Equal(subnetName1, subnet1.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnetName1))
						assert.Equal(usWest1Range, subnet1.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", usWest1Range))

						subnetName2 := networkNames[networkType]["subnet_name2"]
						usCentral1Range := cidrRanges[envName][networkType][1]
						subnet2 := gcloud.Runf(t, "compute networks subnets describe %s --region us-central1 --project %s", subnetName2, projectID)
						assert.Equal(subnetName2, subnet2.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnetName2))
						assert.Equal(usCentral1Range, subnet2.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", usCentral1Range))

						denyAllEgressName := networkNames[networkType]["fw_deny_all_egress"]
						denyAllEgressRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", denyAllEgressName, projectID)
						assert.Equal(denyAllEgressName, denyAllEgressRule.Get("name").String(), fmt.Sprintf("firewall rule %s should exist", denyAllEgressName))
						assert.Equal("EGRESS", denyAllEgressRule.Get("direction").String(), fmt.Sprintf("firewall rule %s direction should be EGRESS", denyAllEgressName))
						assert.True(denyAllEgressRule.Get("logConfig.enable").Bool(), fmt.Sprintf("firewall rule %s should have log configuration enabled", denyAllEgressName))
						assert.Equal("0.0.0.0/0", denyAllEgressRule.Get("destinationRanges").Array()[0].String(), fmt.Sprintf("firewall rule %s destination ranges should be 0.0.0.0/0", denyAllEgressName))
						assert.Equal(1, len(denyAllEgressRule.Get("denied").Array()), fmt.Sprintf("firewall rule %s should have only one denied", denyAllEgressName))
						assert.Equal(1, len(denyAllEgressRule.Get("denied.0").Map()), fmt.Sprintf("firewall rule %s should have only one denied only with no ports", denyAllEgressName))
						assert.Equal("all", denyAllEgressRule.Get("denied.0.IPProtocol").String(), fmt.Sprintf("firewall rule %s should deny all protocols", denyAllEgressName))

						allowApiEgressName := networkNames[networkType]["fw_allow_api_egress"]
						allowApiEgressRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", allowApiEgressName, projectID)
						assert.Equal(allowApiEgressName, allowApiEgressRule.Get("name").String(), fmt.Sprintf("firewall rule %s should exist", allowApiEgressName))
						assert.Equal("EGRESS", allowApiEgressRule.Get("direction").String(), fmt.Sprintf("firewall rule %s direction should be EGRESS", allowApiEgressName))
						assert.True(allowApiEgressRule.Get("logConfig.enable").Bool(), fmt.Sprintf("firewall rule %s should have log configuration enabled", allowApiEgressName))
						assert.Equal(googleapisCIDR[networkType], allowApiEgressRule.Get("destinationRanges").Array()[0].String(), fmt.Sprintf("firewall rule %s destination ranges should be %s", allowApiEgressName, googleapisCIDR[networkType]))
						assert.Equal(1, len(allowApiEgressRule.Get("allowed").Array()), fmt.Sprintf("firewall rule %s should have only one allowed", allowApiEgressName))
						assert.Equal(2, len(allowApiEgressRule.Get("allowed.0").Map()), fmt.Sprintf("firewall rule %s should have only one allowed only with protocol end ports", allowApiEgressName))
						assert.Equal("tcp", allowApiEgressRule.Get("allowed.0.IPProtocol").String(), fmt.Sprintf("firewall rule %s should allow tcp protocol", allowApiEgressName))
						assert.Equal(1, len(allowApiEgressRule.Get("allowed.0.ports").Array()), fmt.Sprintf("firewall rule %s should allow only one port", allowApiEgressName))
						assert.Equal("443", allowApiEgressRule.Get("allowed.0.ports.0").String(), fmt.Sprintf("firewall rule %s should allow port 443", allowApiEgressName))

						if networkMode == "" {
							for _, router := range []struct {
								router string
								region string
							}{
								{
									router: "region1_router1",
									region: "us-west1",
								},
								{
									router: "region1_router2",
									region: "us-west1",
								},
								{
									router: "region2_router1",
									region: "us-central1",
								},
								{
									router: "region2_router2",
									region: "us-central1",
								},
							} {

								routerName := networkNames[networkType][router.router]
								computeRouter := gcloud.Runf(t, "compute routers describe %s --region %s --project %s", routerName, router.region, projectID)
								networkSelfLink := fmt.Sprintf("https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s", projectID, networkNames[networkType]["network_name"])
								assert.Equal(routerName, computeRouter.Get("name").String(), fmt.Sprintf("router %s should exist", routerName))
								assert.Equal("64514", computeRouter.Get("bgp.asn").String(), fmt.Sprintf("router %s should have bgp asm 64514", routerName))
								assert.Equal(1, len(computeRouter.Get("bgp.advertisedIpRanges").Array()), fmt.Sprintf("router %s should have only one advertised IP range", routerName))
								assert.Equal(googleapisCIDR[networkType], computeRouter.Get("bgp.advertisedIpRanges.0.range").String(), fmt.Sprintf("router %s should have only range %s", routerName, googleapisCIDR[networkType]))
								assert.Equal(networkSelfLink, computeRouter.Get("network").String(), fmt.Sprintf("router %s should have be from network %s", routerName, networkNames[networkType]["network_name"]))
							}
						}
					}
				})
			networks.Test()
		})

	}
}
