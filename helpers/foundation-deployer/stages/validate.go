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
	"strings"

	"github.com/mitchellh/go-testing-interface"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/gcp"
)

const (
	replaceME     = "REPLACE_ME"
	exampleDotCom = "example.com"
)

// ValidateDirectories checks if the required directories exist
func ValidateDirectories(g GlobalTFVars) error {
	_, err := os.Stat(g.FoundationCodePath)
	if os.IsNotExist(err) {
		return fmt.Errorf("Stopping execution, FoundationCodePath directory '%s' does not exits\n", g.FoundationCodePath)
	}
	_, err = os.Stat(g.CodeCheckoutPath)
	if os.IsNotExist(err) {
		return fmt.Errorf("Stopping execution, CodeCheckoutPath directory '%s' does not exits\n", g.CodeCheckoutPath)
	}
	return nil
}

// ValidateBasicFields validates if the values for the required field were provided
func ValidateBasicFields(t testing.TB, g GlobalTFVars) {
	gcpConf := gcp.NewGCP()
	fmt.Println("")
	fmt.Println("# Validating tfvar file.")
	if g.OrgID != replaceME {
		if g.HasValidatorProj() && gcpConf.HasSccNotification(t, g.OrgID, g.SccNotificationName) {
			fmt.Printf("# Notification '%s' exists in organization '%s'. Chose a different one.\n", g.SccNotificationName, g.OrgID)
			fmt.Printf("# See existing Notifications for organization '%s'.\n", g.OrgID)
			fmt.Printf("# gcloud scc notifications list organizations/%s --filter=\"name:organizations/%s/notificationConfigs/%s\" --format=\"value(name)\"\n", g.OrgID, g.OrgID, g.SccNotificationName)
			fmt.Println("")
		}
		if g.HasValidatorProj() && !g.CreateUniqueTagKey && gcpConf.HasTagKey(t, g.OrgID, "environment") {
			fmt.Printf("# Tag key 'environment' exists in organization '%s'.\n", g.OrgID)
			fmt.Println("# Set variable 'create_unique_tag_key' to 'true' in the tfvar file.")
			fmt.Println("")
		}
	}

	g.CheckString(replaceME)

	if strings.Contains(g.Domain, exampleDotCom) {
		fmt.Println("# Replace value 'example.com' for input 'domain'")
	}
	if g.Domain != "" && g.Domain[len(g.Domain)-1:] != "." {
		fmt.Println("# Value for input 'domain' must end with '.'")
	}
	for _, d := range g.DomainsToAllow {
		if strings.Contains(d, exampleDotCom) {
			fmt.Println("# Replace value 'example.com' for input 'domains_to_allow'")
		}
	}
	for _, e := range g.EssentialContactsDomains {
		if strings.Contains(e, exampleDotCom) {
			fmt.Println("# Replace value 'example.com' for input 'essential_contacts_domains_to_allow'")
		}
		if e != "" && e[0:1] != "@" {
			fmt.Printf("# Essential contacts must start with '@': '%s'\n", e)
		}
	}
	for _, p := range g.PerimeterAdditionalMembers {
		if strings.Contains(p, exampleDotCom) {
			fmt.Printf("# Replace value for input 'perimeter_additional_members': '%s'\n", p)
		}
		if strings.Contains(p, "group:") {
			fmt.Printf("# VPC Service Controls does not allow groups in the perimeter: '%s'\n", p)
		}
	}
}

// ValidateDestroyFlags checks if the flags to allow the destruction of the infrastructure are enabled
func ValidateDestroyFlags(t testing.TB, g GlobalTFVars) {
	flags := []string{}

	if g.BucketForceDestroy == nil || !*g.BucketForceDestroy {
		flags = append(flags, "bucket_force_destroy")
	}
	if g.AuditLogsTableDeleteContentsOnDestroy == nil || !*g.AuditLogsTableDeleteContentsOnDestroy {
		flags = append(flags, "audit_logs_table_delete_contents_on_destroy")
	}
	if g.LogExportStorageForceDestroy == nil || !*g.LogExportStorageForceDestroy {
		flags = append(flags, "log_export_storage_force_destroy")
	}
	if g.BucketTfstateKmsForceDestroy == nil || !*g.BucketTfstateKmsForceDestroy {
		flags = append(flags, "bucket_tfstate_kms_force_destroy")
	}

	if len(flags) > 0 {
		fmt.Println("# To use the feature to destroy the deployment created by this helper,")
		fmt.Println("# please set the following flags to 'true' in the tfvars file:")
		fmt.Printf("# %s\n", strings.Join(flags, ", "))
	}
}
