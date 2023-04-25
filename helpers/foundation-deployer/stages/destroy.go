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

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/mitchellh/go-testing-interface"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/steps"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"
)

const (
	MaxBuildRetries = 40
)

func DestroyBootstrapStage(t testing.TB, s steps.Steps, c CommonConf) error {
	repo := "gcp-bootstrap"
	step := "0-bootstrap"
	gcpPath := filepath.Join(c.CheckoutPath, repo)

	// remove backend.tf file
	tfDir := filepath.Join(gcpPath, "envs", "shared")
	backendF := filepath.Join(tfDir, "backend.tf")
	exist, err := utils.FileExists(backendF)
	if err != nil {
		return err
	}
	if exist {
		options := &terraform.Options{
			TerraformDir: tfDir,
			Logger:       c.Logger,
			NoColor:      true,
		}
		_, err := terraform.InitE(t, options)
		if err != nil {
			return err
		}
		err = utils.CopyFile(backendF, filepath.Join(tfDir, "backend.tf.backup"))
		if err != nil {
			return err
		}
		err = os.Remove(backendF)
		if err != nil {
			return err
		}
	}

	err = s.RunDestroyStep("gcp-bootstrap.production", func() error {
		options := &terraform.Options{
			TerraformDir: tfDir,
			Logger:       c.Logger,
			NoColor:      true,
			MigrateState: true,
		}
		conf := utils.CloneCSR(t, repo, gcpPath, "", c.Logger)
		err := conf.CheckoutBranch("production")
		if err != nil {
			return err
		}
		return destroyEnv(t, options, "")
	})
	if err != nil {
		return err
	}
	fmt.Println("end of", step, "destroy")
	return nil
}

func destroyEnv(t testing.TB, options *terraform.Options, serviceAccount string) error {
	var err error

	if serviceAccount != "" {
		err = os.Setenv("GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", serviceAccount)
		if err != nil {
			return err
		}
	}

	_, err = terraform.InitE(t, options)
	if err != nil {
		return err
	}
	_, err = terraform.DestroyE(t, options)
	if err != nil {
		return err
	}

	if serviceAccount != "" {
		err = os.Unsetenv("GOOGLE_IMPERSONATE_SERVICE_ACCOUNT")
		if err != nil {
			return err
		}
	}
	return nil
}
