// Copyright 2026 Google LLC
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

// Command iam-validate runs IAM permissions validation (TestIamPermissions) for the ADC
// principal only, using the same logic as foundation-deployer -validate.
//
// See [github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils.ValidateIAMPermissions]
// and [github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils.IAMValidateParams]
// for resources checked. Optional permissions YAML via -permissions_yaml (absolute path).
//
//	cd helpers/foundation-deployer
//	go run ./cmd/iam-validate -tfvars_file <PATH TO 'global.tfvars' FILE>
//	go run ./cmd/iam-validate -tfvars_file <PATH TO 'global.tfvars' FILE> -permissions_yaml /path/to/permissions.yaml -v
package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/stages"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"
)

func main() {
	var (
		tfvarsFile      string
		permissionsYAML string
		verbose         bool
	)

	flag.StringVar(&tfvarsFile, "tfvars_file", "", "Full path to the Terraform .tfvars file with the configuration to be used.")
	flag.StringVar(&permissionsYAML, "permissions_yaml", "", "Optional absolute path to a permissions YAML file.")
	flag.BoolVar(&verbose, "v", false, "show full output (allowed + missing permissions)")
	flag.Parse()

	if tfvarsFile == "" {
		fmt.Println("missing required flag: -tfvars_file")
		os.Exit(2)
	}

	globalTFVars, err := stages.ReadGlobalTFVars(tfvarsFile)
	if err != nil {
		fmt.Printf("# Failed to read GlobalTFVars file. Error: %s\n", err.Error())
		os.Exit(1)
	}

	params := utils.IAMValidateParams{
		OrgID:              globalTFVars.OrgID,
		FoundationCodePath: globalTFVars.FoundationCodePath,
		ParentFolder:       globalTFVars.ParentFolder,
		BillingAccount:     globalTFVars.BillingAccount,
	}
	if permissionsYAML != "" {
		params.IAMPermissionsYAMLPath = &permissionsYAML
	}

	err = utils.ValidateIAMPermissions(params, verbose)
	if err != nil {
		fmt.Printf("# Failed to validate IAM permissions. Error: %s\n", err.Error())
		os.Exit(1)
	}
}
