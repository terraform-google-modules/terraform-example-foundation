// Copyright 2023 Google LLC
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

package stages

import (
	"fmt"
	"os"
	"reflect"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/deployer/utils"
)

// ServerAddress is the element for TargetNameServerAddresses
type ServerAddress struct {
	Ipv4Address    string `cty:"ipv4_address"`
	ForwardingPath string `cty:"forwarding_path"`
}

// GlobalTFVars contains all the configuration for the deploy
type GlobalTFVars struct {
	OrgID                                 string          `hcl:"org_id"`
	BillingAccount                        string          `hcl:"billing_account"`
	GroupOrgAdmins                        string          `hcl:"group_org_admins"`
	GroupBillingAdmins                    string          `hcl:"group_billing_admins"`
	BillingDataUsers                      string          `hcl:"billing_data_users"`
	MonitoringWorkspaceUsers              string          `hcl:"monitoring_workspace_users"`
	AuditDataUsers                        string          `hcl:"audit_data_users"`
	DefaultRegion                         string          `hcl:"default_region"`
	ParentFolder                          *string         `hcl:"parent_folder"`
	Domain                                string          `hcl:"domain"`
	DomainsToAllow                        []string        `hcl:"domains_to_allow"`
	EssentialContactsDomains              []string        `hcl:"essential_contacts_domains_to_allow"`
	PerimeterAdditionalMembers            []string        `hcl:"perimeter_additional_members"`
	TargetNameServerAddresses             []ServerAddress `hcl:"target_name_server_addresses"`
	SccNotificationName                   string          `hcl:"scc_notification_name"`
	ProjectPrefix                         *string         `hcl:"project_prefix"`
	FolderPrefix                          *string         `hcl:"folder_prefix"`
	BucketForceDestroy                    *bool           `hcl:"bucket_force_destroy"`
	AuditLogsTableDeleteContentsOnDestroy *bool           `hcl:"audit_logs_table_delete_contents_on_destroy"`
	LogExportStorageForceDestroy          *bool           `hcl:"log_export_storage_force_destroy"`
	EnableHubAndSpoke                     bool            `hcl:"enable_hub_and_spoke"`
	EnableHubAndSpokeTransitivity         bool            `hcl:"enable_hub_and_spoke_transitivity"`
	CreateUniqueTagKey                    bool            `hcl:"create_unique_tag_key"`
	ProjectsKMSLocation                   string          `hcl:"projects_kms_location"`
	ProjectsGCSLocation                   string          `hcl:"projects_gcs_location"`
	CodeCheckoutPath                      string          `hcl:"code_checkout_path"`
	FoundationCodePath                    string          `hcl:"foundation_code_path"`
	ValidatorProjectId                    *string         `hcl:"validator_project_id"`
}

// HasValidatorProj checks if a Validator Project was provided
func (g GlobalTFVars) HasValidatorProj() bool {
	return g.ValidatorProjectId != nil && *g.ValidatorProjectId != "" && *g.ValidatorProjectId != "EXISTING_PROJECT_ID"
}

// CheckString checks if any of the string fields in the GlobalTFVars has the given string
func (g GlobalTFVars) CheckString(s string) {
	f := reflect.ValueOf(g)
	for i := 0; i < f.NumField(); i++ {
		if f.Field(i).Kind() == reflect.String && f.Field(i).Interface() == s {
			fmt.Printf("# Replace value '%s' for input '%s'\n", s, f.Type().Field(i).Tag.Get("hcl"))
		}
	}
}

// ReadGlobalTFVars reads the tfvars file that has all the configuration for the deploy
func ReadGlobalTFVars(file string) (GlobalTFVars, error) {
	var globalTfvars GlobalTFVars
	if file == "" {
		return globalTfvars, fmt.Errorf("tfvars file is required.")
	}
	_, err := os.Stat(file)
	if os.IsNotExist(err) {
		return globalTfvars, fmt.Errorf("tfvars file '%s' does not exits\n", file)
	}
	err = utils.ReadTfvars(file, &globalTfvars)
	if err != nil {
		return globalTfvars, fmt.Errorf("Failed to load tfvars file %s. Error: %s\n", file, err.Error())
	}
	return globalTfvars, nil
}
