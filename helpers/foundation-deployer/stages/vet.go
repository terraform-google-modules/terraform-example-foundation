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
	"path/filepath"
	"strings"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/mitchellh/go-testing-interface"
	"github.com/tidwall/gjson"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
)

// TerraformVet runs gcloud terraform vet on the plan of the provided terraform directory
func TerraformVet(t testing.TB, terraformDir, policyPath, project string) error {

	fmt.Println("")
	fmt.Println("# Running gcloud terraform vet")
	fmt.Println("")

	options := &terraform.Options{
		TerraformDir: terraformDir,
		Logger:       logger.Discard,
		NoColor:      true,
		PlanFilePath: filepath.Join(os.TempDir(), "plan.tfplan"),
	}
	_, err := terraform.PlanE(t, options)
	if err != nil {
		return err
	}
	jsonPlan, err := terraform.ShowE(t, options)
	if err != nil {
		return err
	}
	jsonFile, err := utils.WriteTmpFileWithExtension(jsonPlan, "json")
	defer os.Remove(jsonFile)
	defer os.Remove(options.PlanFilePath)
	if err != nil {
		return err
	}
	command := fmt.Sprintf("beta terraform vet %s --policy-library=%s --project=%s --quiet", jsonFile, policyPath, project)
	result, err := gcloud.RunCmdE(t, command)
	if err != nil && !(strings.Contains(err.Error(), "Validating resources") && strings.Contains(err.Error(), "done")) {
		return err
	}
	if !gjson.Valid(result) {
		return fmt.Errorf("Error parsing output, invalid json: %s", result)
	}

	if len(gjson.Parse(result).Array()) > 0 {
		return fmt.Errorf("Policy violations found: %s", result)
	}
	fmt.Println("")
	fmt.Println("# The configuration passed tf vet.")
	fmt.Println("")
	return nil
}
