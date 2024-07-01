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

func getFirewallMode(t *testing.T) string {
	mode := utils.ValFromEnv(t, "TF_VAR_example_foundations_mode")
	if mode == "HubAndSpoke" {
		return "hub-and-spoke"
	}
	return "dual-svpc"
}

func getNetworkResourceNames(envCode string, networkMode string, firewallMode string) map[string]map[string]string {
	return map[string]map[string]string{
		"base": {
			"network_name":          fmt.Sprintf("vpc-%s-shared-base%s", envCode, networkMode),
			"global_address":        fmt.Sprintf("ga-%s-shared-base%s-vpc-peering-internal", envCode, networkMode),
			"dns_zone_googleapis":   fmt.Sprintf("dz-%s-shared-base-apis", envCode),
			"dns_zone_gcr":          fmt.Sprintf("dz-%s-shared-base-gcr", envCode),
			"dns_zone_pkg_dev":      fmt.Sprintf("dz-%s-shared-base-pkg-dev", envCode),
			"dns_zone_peering_zone": fmt.Sprintf("dz-%s-shared-base-to-dns-hub", envCode),
			"dns_policy_name":       fmt.Sprintf("dp-%s-shared-base-default-policy", envCode),
			"subnet_name1":          fmt.Sprintf("sb-%s-shared-base-us-central1", envCode),
			"subnet_name2":          fmt.Sprintf("sb-%s-shared-base-us-west1", envCode),
			"region1_router1":       fmt.Sprintf("cr-%s-shared-base%s-us-central1-cr1", envCode, networkMode),
			"region1_router2":       fmt.Sprintf("cr-%s-shared-base%s-us-central1-cr2", envCode, networkMode),
			"region2_router1":       fmt.Sprintf("cr-%s-shared-base%s-us-west1-cr3", envCode, networkMode),
			"region2_router2":       fmt.Sprintf("cr-%s-shared-base%s-us-west1-cr4", envCode, networkMode),
			"firewall_policy":       fmt.Sprintf("fp-%s-%s-base-firewalls", envCode, firewallMode),
			"fw_deny_all_egress":    fmt.Sprintf("fw-%s-shared-base-65530-e-d-all-all-all", envCode),
			"fw_allow_api_egress":   fmt.Sprintf("fw-%s-shared-base-1000-e-a-allow-google-apis-all-tcp-443", envCode),
		},
		"restricted": {
			"network_name":          fmt.Sprintf("vpc-%s-shared-restricted%s", envCode, networkMode),
			"global_address":        fmt.Sprintf("ga-%s-shared-restricted%s-vpc-peering-internal", envCode, networkMode),
			"dns_zone_googleapis":   fmt.Sprintf("dz-%s-shared-restricted-apis", envCode),
			"dns_zone_gcr":          fmt.Sprintf("dz-%s-shared-restricted-gcr", envCode),
			"dns_zone_pkg_dev":      fmt.Sprintf("dz-%s-shared-restricted-pkg-dev", envCode),
			"dns_zone_peering_zone": fmt.Sprintf("dz-%s-shared-restricted-to-dns-hub", envCode),
			"dns_policy_name":       fmt.Sprintf("dp-%s-shared-restricted-default-policy", envCode),
			"subnet_name1":          fmt.Sprintf("sb-%s-shared-restricted-us-central1", envCode),
			"subnet_name2":          fmt.Sprintf("sb-%s-shared-restricted-us-west1", envCode),
			"region1_router1":       fmt.Sprintf("cr-%s-shared-restricted%s-us-central1-cr5", envCode, networkMode),
			"region1_router2":       fmt.Sprintf("cr-%s-shared-restricted%s-us-central1-cr6", envCode, networkMode),
			"region2_router1":       fmt.Sprintf("cr-%s-shared-restricted%s-us-west1-cr7", envCode, networkMode),
			"region2_router2":       fmt.Sprintf("cr-%s-shared-restricted%s-us-west1-cr8", envCode, networkMode),
			"firewall_policy":       fmt.Sprintf("fp-%s-%s-restricted-firewalls", envCode, firewallMode),
			"fw_deny_all_egress":    fmt.Sprintf("fw-%s-shared-restricted-65530-e-d-all-all-all", envCode),
			"fw_allow_api_egress":   fmt.Sprintf("fw-%s-shared-restricted-1000-e-a-allow-google-apis-all-tcp-443", envCode),
		},
	}
}

func TestNetworks(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	orgID := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")["org_id"]
	networkMode := getNetworkMode(t)
	firewallMode := getFirewallMode(t)
	policyID := testutils.GetOrgACMPolicyID(t, orgID)
	require.NotEmpty(t, policyID, "Access Context Manager Policy ID must be configured in the organization for the test to proceed.")

	// Configure impersonation for test execution
	terraformSA := bootstrap.GetStringOutput("networks_step_terraform_service_account_email")
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSA)

	backend_bucket := bootstrap.GetStringOutput("gcs_bucket_tfstate")
	backendConfig := map[string]interface{}{
		"bucket": backend_bucket,
	}

	restrictedServices := []string{
		"accessapproval.googleapis.com",
		"adsdatahub.googleapis.com",
		"aiplatform.googleapis.com",
		"alloydb.googleapis.com",
		"alpha-documentai.googleapis.com",
		"analyticshub.googleapis.com",
		"apigee.googleapis.com",
		"apigeeconnect.googleapis.com",
		"artifactregistry.googleapis.com",
		"assuredworkloads.googleapis.com",
		"automl.googleapis.com",
		"baremetalsolution.googleapis.com",
		"batch.googleapis.com",
		"bigquery.googleapis.com",
		"bigquerydatapolicy.googleapis.com",
		"bigquerydatatransfer.googleapis.com",
		"bigquerymigration.googleapis.com",
		"bigqueryreservation.googleapis.com",
		"bigtable.googleapis.com",
		"binaryauthorization.googleapis.com",
		"cloud.googleapis.com",
		"cloudasset.googleapis.com",
		"cloudbuild.googleapis.com",
		"clouddebugger.googleapis.com",
		"clouddeploy.googleapis.com",
		"clouderrorreporting.googleapis.com",
		"cloudfunctions.googleapis.com",
		"cloudkms.googleapis.com",
		"cloudprofiler.googleapis.com",
		"cloudresourcemanager.googleapis.com",
		"cloudscheduler.googleapis.com",
		"cloudsearch.googleapis.com",
		"cloudtrace.googleapis.com",
		"composer.googleapis.com",
		"compute.googleapis.com",
		"connectgateway.googleapis.com",
		"contactcenterinsights.googleapis.com",
		"container.googleapis.com",
		"containeranalysis.googleapis.com",
		"containerfilesystem.googleapis.com",
		"containerregistry.googleapis.com",
		"containerthreatdetection.googleapis.com",
		"datacatalog.googleapis.com",
		"dataflow.googleapis.com",
		"datafusion.googleapis.com",
		"datamigration.googleapis.com",
		"dataplex.googleapis.com",
		"dataproc.googleapis.com",
		"datastream.googleapis.com",
		"dialogflow.googleapis.com",
		"dlp.googleapis.com",
		"dns.googleapis.com",
		"documentai.googleapis.com",
		"domains.googleapis.com",
		"eventarc.googleapis.com",
		"file.googleapis.com",
		"firebaseappcheck.googleapis.com",
		"firebaserules.googleapis.com",
		"firestore.googleapis.com",
		"gameservices.googleapis.com",
		"gkebackup.googleapis.com",
		"gkeconnect.googleapis.com",
		"gkehub.googleapis.com",
		"healthcare.googleapis.com",
		"iam.googleapis.com",
		"iamcredentials.googleapis.com",
		"iaptunnel.googleapis.com",
		"ids.googleapis.com",
		"integrations.googleapis.com",
		"kmsinventory.googleapis.com",
		"krmapihosting.googleapis.com",
		"language.googleapis.com",
		"lifesciences.googleapis.com",
		"logging.googleapis.com",
		"managedidentities.googleapis.com",
		"memcache.googleapis.com",
		"meshca.googleapis.com",
		"meshconfig.googleapis.com",
		"metastore.googleapis.com",
		"ml.googleapis.com",
		"monitoring.googleapis.com",
		"networkconnectivity.googleapis.com",
		"networkmanagement.googleapis.com",
		"networksecurity.googleapis.com",
		"networkservices.googleapis.com",
		"notebooks.googleapis.com",
		"opsconfigmonitoring.googleapis.com",
		"orgpolicy.googleapis.com",
		"osconfig.googleapis.com",
		"oslogin.googleapis.com",
		"privateca.googleapis.com",
		"pubsub.googleapis.com",
		"pubsublite.googleapis.com",
		"recaptchaenterprise.googleapis.com",
		"recommender.googleapis.com",
		"redis.googleapis.com",
		"retail.googleapis.com",
		"run.googleapis.com",
		"secretmanager.googleapis.com",
		"servicecontrol.googleapis.com",
		"servicedirectory.googleapis.com",
		"spanner.googleapis.com",
		"speakerid.googleapis.com",
		"speech.googleapis.com",
		"sqladmin.googleapis.com",
		"storage.googleapis.com",
		"storagetransfer.googleapis.com",
		"sts.googleapis.com",
		"texttospeech.googleapis.com",
		"timeseriesinsights.googleapis.com",
		"tpu.googleapis.com",
		"trafficdirector.googleapis.com",
		"transcoder.googleapis.com",
		"translate.googleapis.com",
		"videointelligence.googleapis.com",
		"vision.googleapis.com",
		"visionai.googleapis.com",
		"vmmigration.googleapis.com",
		"vpcaccess.googleapis.com",
		"webrisk.googleapis.com",
		"workflows.googleapis.com",
		"workstations.googleapis.com",
	}

	cidrRanges := map[string]map[string][]string{
		"development": {
			"base":       []string{"10.0.64.0/18", "10.1.64.0/18"},
			"restricted": []string{"10.8.64.0/18", "10.9.64.0/18"},
		},
		"nonproduction": {
			"base":       []string{"10.0.128.0/18", "10.1.128.0/18"},
			"restricted": []string{"10.8.128.0/18", "10.9.128.0/18"},
		},
		"production": {
			"base":       []string{"10.0.192.0/18", "10.1.192.0/18"},
			"restricted": []string{"10.8.192.0/18", "10.9.192.0/18"},
		},
	}

	googleapisCIDR := map[string]map[string]string{
		"development": {
			"base":       "10.17.0.2",
			"restricted": "10.17.0.6",
		},
		"nonproduction": {
			"base":       "10.17.0.3",
			"restricted": "10.17.0.7",
		},
		"production": {
			"base":       "10.17.0.4",
			"restricted": "10.17.0.8",
		},
	}

	ingressPolicies := []map[string]interface{}{
		{
			"from": map[string]interface{}{
				"sources": map[string][]string{
					"access_levels": {"*"},
				},
				"identity_type": "ANY_IDENTITY",
			},
			"to": map[string]interface{}{
				"resources": []string{"*"},
				"operations": map[string]map[string][]string{
					"storage.googleapis.com": {
						"methods": {
							"google.storage.objects.get",
							"google.storage.objects.list",
						},
					},
				},
			},
		},
	}

	egressPolicies := []map[string]interface{}{
		{
			"from": map[string]interface{}{
				"sources": map[string][]string{
					"access_levels": {"*"},
				},
				"identity_type": "ANY_IDENTITY",
			},
			"to": map[string]interface{}{
				"resources": []string{"*"},
				"operations": map[string]map[string][]string{
					"storage.googleapis.com": {
						"methods": {
							"google.storage.objects.get",
							"google.storage.objects.list",
						},
					},
				},
			},
		},
	}

	for _, envName := range []string{
		"development",
		"nonproduction",
		"production",
	} {
		envName := envName
		t.Run(envName, func(t *testing.T) {
			t.Parallel()

			vars := map[string]interface{}{
				"access_context_manager_policy_id": policyID,
				"remote_state_bucket":              backend_bucket,
				"ingress_policies":                 ingressPolicies,
				"egress_policies":                  egressPolicies,
				"perimeter_additional_members":     []string{},
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
				tft.WithRetryableTerraformErrors(testutils.RetryableTransientErrors, 10, 2*time.Minute),
				tft.WithPolicyLibraryPath("/workspace/policy-library", bootstrap.GetTFSetupStringOutput("project_id")),
				tft.WithBackendConfig(backendConfig),
			)
			networks.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					// Comment DefaultVerify because proxy-only subnets tries to change `ipv6_access_type` from `INTERNAL` to `null` on every run (plan and apply)
					// Module issue: https://github.com/terraform-google-modules/terraform-google-network/issues/528
					// Resource issue: https://github.com/hashicorp/terraform-provider-google/issues/16801
					// Resource issue: https://github.com/hashicorp/terraform-provider-google/issues/16804
					// networks.DefaultVerify(assert)

					servicePerimeterLink := fmt.Sprintf("accessPolicies/%s/servicePerimeters/%s", policyID, networks.GetStringOutput("restricted_service_perimeter_name"))
					accessLevel := fmt.Sprintf("accessPolicies/%s/accessLevels/%s", policyID, networks.GetStringOutput("access_level_name_dry_run"))
					networkNames := getNetworkResourceNames(envCode, networkMode, firewallMode)

					servicePerimeter, err := gcloud.RunCmdE(t, fmt.Sprintf("access-context-manager perimeters dry-run describe %s --policy %s", servicePerimeterLink, policyID))
					assert.NoError(err)
					perimeterName := networks.GetStringOutput("restricted_service_perimeter_name")
					assert.True(strings.Contains(servicePerimeter, perimeterName), fmt.Sprintf("service perimeter %s should exist", perimeterName))
					assert.True(strings.Contains(servicePerimeter, accessLevel), fmt.Sprintf("service perimeter %s should have access level %s", servicePerimeterLink, accessLevel))
					for _, service := range restrictedServices {
						assert.True(strings.Contains(servicePerimeter, service), fmt.Sprintf("service perimeter %s should restrict all supported services", servicePerimeterLink))
					}

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
							dnsZone := gcloud.Runf(t, "dns managed-zones describe %s --project %s --impersonate-service-account %s", dnsName, projectID, terraformSA)
							assert.Equal(dnsName, dnsZone.Get("name").String(), fmt.Sprintf("dnsZone %s should exist", dnsName))
						}

						networkName := networkNames[networkType]["network_name"]
						networkUrl := fmt.Sprintf("https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s", projectID, networkName)
						dnsPolicyName := networkNames[networkType]["dns_policy_name"]
						dnsPolicy := gcloud.Runf(t, "dns policies describe %s --project %s --impersonate-service-account %s", dnsPolicyName, projectID, terraformSA)
						assert.True(dnsPolicy.Get("enableInboundForwarding").Bool(), fmt.Sprintf("dns policy %s should have inbound forwarding enabled", dnsPolicyName))
						assert.Equal(networkUrl, dnsPolicy.Get("networks.0.networkUrl").String(), fmt.Sprintf("dns policy %s should be on network %s", dnsPolicyName, networkName))

						//compute networks describe %s --project %s
						projectNetwork := gcloud.Runf(t, "compute networks describe %s --project %s --impersonate-service-account %s", networkName, projectID, terraformSA)
						assert.Equal(networkName, projectNetwork.Get("name").String(), fmt.Sprintf("network %s should exist", networkName))

						//gcloud compute addresses describe NAME --global
						globalAddressName := networkNames[networkType]["global_address"]
						globalAddress := gcloud.Runf(t, "compute addresses describe %s --global --project %s --impersonate-service-account %s", globalAddressName, projectID, terraformSA)
						assert.Equal(globalAddressName, globalAddress.Get("name").String(), fmt.Sprintf("global address %s should exist", globalAddressName))

						subnetName1 := networkNames[networkType]["subnet_name1"]
						usCentral1Range := cidrRanges[envName][networkType][0]
						subnet1 := gcloud.Runf(t, "compute networks subnets describe %s --region us-central1 --project %s --impersonate-service-account %s", subnetName1, projectID, terraformSA)
						assert.Equal(subnetName1, subnet1.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnetName1))
						assert.Equal(usCentral1Range, subnet1.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", usCentral1Range))

						subnetName2 := networkNames[networkType]["subnet_name2"]
						usWest1Range := cidrRanges[envName][networkType][1]
						subnet2 := gcloud.Runf(t, "compute networks subnets describe %s --region us-west1 --project %s --impersonate-service-account %s", subnetName2, projectID, terraformSA)
						assert.Equal(subnetName2, subnet2.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnetName2))
						assert.Equal(usWest1Range, subnet2.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", usWest1Range))

						denyAllEgressName := networkNames[networkType]["fw_deny_all_egress"]
						denyAllEgressRule := gcloud.Runf(t, "compute network-firewall-policies rules describe 65530 --firewall-policy %s --global-firewall-policy --project %s --impersonate-service-account %s", networkNames[networkType]["firewall_policy"], projectID, terraformSA).Array()[0]
						assert.Equal(denyAllEgressName, denyAllEgressRule.Get("ruleName").String(), fmt.Sprintf("firewall rule %s should exist", denyAllEgressName))
						assert.Equal("EGRESS", denyAllEgressRule.Get("direction").String(), fmt.Sprintf("firewall rule %s direction should be EGRESS", denyAllEgressName))
						assert.Equal("deny", denyAllEgressRule.Get("action").String(), fmt.Sprintf("firewall rule %s action should be deny", denyAllEgressName))
						assert.True(denyAllEgressRule.Get("enableLogging").Bool(), fmt.Sprintf("firewall rule %s should have log configuration enabled", denyAllEgressName))
						assert.Equal("0.0.0.0/0", denyAllEgressRule.Get("match.destIpRanges").Array()[0].String(), fmt.Sprintf("firewall rule %s destination ranges should be 0.0.0.0/0", denyAllEgressName))

						allowApiEgressName := networkNames[networkType]["fw_allow_api_egress"]
						allowApiEgressRule := gcloud.Runf(t, "compute network-firewall-policies rules describe 1000 --firewall-policy %s --global-firewall-policy --project %s --impersonate-service-account %s", networkNames[networkType]["firewall_policy"], projectID, terraformSA).Array()[0]
						assert.Equal(allowApiEgressName, allowApiEgressRule.Get("ruleName").String(), fmt.Sprintf("firewall rule %s should exist", allowApiEgressName))
						assert.Equal("EGRESS", allowApiEgressRule.Get("direction").String(), fmt.Sprintf("firewall rule %s direction should be EGRESS", allowApiEgressName))
						assert.Equal("allow", allowApiEgressRule.Get("action").String(), fmt.Sprintf("firewall rule %s action should be allow", allowApiEgressName))
						assert.True(allowApiEgressRule.Get("enableLogging").Bool(), fmt.Sprintf("firewall rule %s should have log configuration enabled", allowApiEgressName))
						assert.Equal(googleapisCIDR[envName][networkType], allowApiEgressRule.Get("match.destIpRanges").Array()[0].String(), fmt.Sprintf("firewall rule %s destination ranges should be %s", allowApiEgressName, googleapisCIDR[envName][networkType]))

						if networkMode == "" {
							for _, router := range []struct {
								router string
								region string
							}{
								{
									router: "region1_router1",
									region: "us-central1",
								},
								{
									router: "region1_router2",
									region: "us-central1",
								},
								{
									router: "region2_router1",
									region: "us-west1",
								},
								{
									router: "region2_router2",
									region: "us-west1",
								},
							} {

								routerName := networkNames[networkType][router.router]
								computeRouter := gcloud.Runf(t, "compute routers describe %s --region %s --project %s --impersonate-service-account %s", routerName, router.region, projectID, terraformSA)
								networkSelfLink := fmt.Sprintf("https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s", projectID, networkNames[networkType]["network_name"])
								assert.Equal(routerName, computeRouter.Get("name").String(), fmt.Sprintf("router %s should exist", routerName))
								assert.Equal("64514", computeRouter.Get("bgp.asn").String(), fmt.Sprintf("router %s should have bgp asm 64514", routerName))
								assert.Equal(1, len(computeRouter.Get("bgp.advertisedIpRanges").Array()), fmt.Sprintf("router %s should have only one advertised IP range", routerName))
								assert.Equal(googleapisCIDR[envName][networkType], computeRouter.Get("bgp.advertisedIpRanges.0.range").String(), fmt.Sprintf("router %s should have only range %s", routerName, googleapisCIDR[envName][networkType]))
								assert.Equal(networkSelfLink, computeRouter.Get("network").String(), fmt.Sprintf("router %s should have be from network %s", routerName, networkNames[networkType]["network_name"]))
							}
						}
					}
				})
			networks.Test()
		})

	}
}
