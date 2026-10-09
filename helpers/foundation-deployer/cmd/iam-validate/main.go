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
//	go run ./cmd/iam-validate -tfvars_file <PATH TO MINIMAL .tfvars FILE>
//	go run ./cmd/iam-validate -tfvars_file <PATH TO MINIMAL .tfvars FILE> -permissions_yaml /path/to/permissions.yaml -v
//
// The tfvars file only needs: org_id, billing_account, and optionally parent_folder (or parent_folder_id)
// and foundation_code_path (unless -permissions_yaml is set).
package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"
)

// iamValidateTFVars is the minimal tfvars subset for this CLI.
type iamValidateTFVars struct {
	OrgID              string  `hcl:"org_id"`
	BillingAccount     string  `hcl:"billing_account"`
	FoundationCodePath string  `hcl:"foundation_code_path,optional"`
	ParentFolder       *string `hcl:"parent_folder,optional"`
	ParentFolderID     *string `hcl:"parent_folder_id,optional"`
	UniverseDomain     *string `hcl:"universe_domain,optional"`
}

func readIAMValidateTFVars(file string) (iamValidateTFVars, error) {
	var tfvars iamValidateTFVars
	if _, err := os.Stat(file); os.IsNotExist(err) {
		return tfvars, fmt.Errorf("tfvars file '%s' does not exist", file)
	}
	if err := utils.ReadTfvars(file, &tfvars); err != nil {
		return tfvars, fmt.Errorf("failed to load tfvars file %s: %w", file, err)
	}
	return tfvars, nil
}

func (v iamValidateTFVars) toParams() utils.IAMValidateParams {
	parentFolder := v.ParentFolder
	if parentFolder == nil {
		parentFolder = v.ParentFolderID
	}
	return utils.IAMValidateParams{
		OrgID:              v.OrgID,
		BillingAccount:     v.BillingAccount,
		FoundationCodePath: v.FoundationCodePath,
		ParentFolder:       parentFolder,
		UniverseDomain:     *v.UniverseDomain,
	}
}

func main() {
	var (
		tfvarsFile      string
		permissionsYAML string
		universeDomain  string
		verbose         bool
	)

	flag.StringVar(&tfvarsFile, "tfvars_file", "", "Full path to the Terraform .tfvars file with the configuration to be used.")
	flag.StringVar(&permissionsYAML, "permissions_yaml", "", "Optional absolute path to a permissions YAML file.")
	flag.StringVar(&universeDomain, "universe_domain", "googleapis.com", "Optional Universe Domain for Google Distributed Cloud.")
	flag.BoolVar(&verbose, "v", false, "show full output (allowed + missing permissions)")
	flag.Parse()

	if tfvarsFile == "" {
		fmt.Println("missing required flag: -tfvars_file")
		os.Exit(2)
	}

	tfvars, err := readIAMValidateTFVars(tfvarsFile)
	if err != nil {
		fmt.Printf("# Failed to read tfvars file. Error: %s\n", err.Error())
		os.Exit(1)
	}

	params := tfvars.toParams()
	if permissionsYAML != "" {
		params.IAMPermissionsYAMLPath = &permissionsYAML
	}

	err = utils.ValidateIAMPermissions(params, verbose)
	if err != nil {
		fmt.Printf("# Failed to validate IAM permissions. Error: %s\n", err.Error())
		os.Exit(1)
	}
}
