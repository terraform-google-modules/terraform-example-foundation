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
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/mitchellh/go-testing-interface"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/steps"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"
	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

const (
	MaxBuildRetries = 40
)

func DestroyBootstrapStage(t testing.TB, s steps.Steps, c CommonConf) error {

	if err := forceBackendMigration(t, BootstrapRepo, "envs", "shared", c); err != nil {
		return err
	}

	stageConf := StageConf{
		Stage:         BootstrapStep,
		Step:          BootstrapStep,
		Repo:          BootstrapRepo,
		GroupingUnits: []string{"envs"},
		Envs:          []string{"shared"},
	}
	return destroyStage(t, stageConf, s, c)
}

// forceBackendMigration removes backend.tf file to force migration of the
// terraform state from GCS to the local directory.
// Before changing the backend we ensure it is has been initialized.
func forceBackendMigration(t testing.TB, repo, groupUnit, env string, c CommonConf) error {
	tfDir := filepath.Join(c.CheckoutPath, repo, groupUnit, env)
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
		options.MigrateState = true
		_, err = terraform.InitE(t, options)
		if err != nil {
			return err
		}
	}
	return nil
}

func DestroyOrgStage(t testing.TB, s steps.Steps, outputs BootstrapOutputs, c CommonConf) error {
	stageConf := StageConf{
		Stage:         OrgRepo,
		StageSA:       outputs.OrgSA,
		CICDProject:   outputs.CICDProject,
		Step:          OrgStep,
		Repo:          OrgRepo,
		GroupingUnits: []string{"envs"},
		Envs:          []string{"shared"},
	}
	return destroyStage(t, stageConf, s, c)
}

func DestroyEnvStage(t testing.TB, s steps.Steps, outputs BootstrapOutputs, c CommonConf) error {
	stageConf := StageConf{
		Stage:         EnvironmentsRepo,
		StageSA:       outputs.EnvsSA,
		CICDProject:   outputs.CICDProject,
		Step:          EnvironmentsStep,
		Repo:          EnvironmentsRepo,
		GroupingUnits: []string{"envs"},
		Envs:          []string{"development", "nonproduction", "production"},
	}
	return destroyStage(t, stageConf, s, c)
}

func DestroyNetworksStage(t testing.TB, s steps.Steps, outputs BootstrapOutputs, c CommonConf) error {
	step := GetNetworkStep(c.EnableHubAndSpoke)
	stageConf := StageConf{
		Stage:         NetworksRepo,
		StageSA:       outputs.NetworkSA,
		CICDProject:   outputs.CICDProject,
		Step:          step,
		Repo:          NetworksRepo,
		HasManualStep: true,
		GroupingUnits: []string{"envs"},
		Envs:          []string{"development", "nonproduction", "production"},
	}
	return destroyStage(t, stageConf, s, c)
}

func DestroyProjectsStage(t testing.TB, s steps.Steps, outputs BootstrapOutputs, c CommonConf) error {
	stageConf := StageConf{
		Stage:         ProjectsRepo,
		StageSA:       outputs.ProjectsSA,
		CICDProject:   outputs.CICDProject,
		Step:          ProjectsStep,
		Repo:          ProjectsRepo,
		HasManualStep: true,
		GroupingUnits: []string{"business_unit_1"},
		Envs:          []string{"development", "nonproduction", "production"},
	}
	return destroyStage(t, stageConf, s, c)
}

func DestroyExampleAppStage(t testing.TB, s steps.Steps, outputs InfraPipelineOutputs, c CommonConf) error {
	stageConf := StageConf{
		Stage:         AppInfraRepo,
		StageSA:       outputs.TerraformSA,
		CICDProject:   outputs.InfraPipeProj,
		Step:          AppInfraStep,
		Repo:          AppInfraRepo,
		GroupingUnits: []string{"business_unit_1"},
		Envs:          []string{"development", "nonproduction", "production"},
	}
	return destroyStage(t, stageConf, s, c)
}

func destroyStage(t testing.TB, sc StageConf, s steps.Steps, c CommonConf) error {
	gcpPath := filepath.Join(c.CheckoutPath, sc.Repo)
	for _, e := range sc.Envs {
		err := s.RunDestroyStep(fmt.Sprintf("%s.%s", sc.Repo, e), func() error {
			for _, g := range sc.GroupingUnits {
				options := &terraform.Options{
					TerraformDir:             filepath.Join(gcpPath, g, e),
					Logger:                   c.Logger,
					NoColor:                  true,
					RetryableTerraformErrors: testutils.RetryableTransientErrors,
					MaxRetries:               2,
					TimeBetweenRetries:       2 * time.Minute,
				}
				conf := utils.CloneCSR(t, sc.Repo, gcpPath, sc.CICDProject, c.Logger)
				branch := e
				if branch == "shared" {
					branch = "production"
				}
				err := conf.CheckoutBranch(branch)
				if err != nil {
					return err
				}
				err = destroyEnv(t, options, sc.StageSA)
				if err != nil {
					return err
				}
			}
			return nil
		})
		if err != nil {
			return err
		}
	}
	groupingUnits := []string{}
	if sc.HasManualStep {
		groupingUnits = sc.GroupingUnits
	}
	for _, g := range groupingUnits {
		err := s.RunDestroyStep(fmt.Sprintf("%s.%s.apply-shared", sc.Repo, g), func() error {
			options := &terraform.Options{
				TerraformDir:             filepath.Join(gcpPath, g, "shared"),
				Logger:                   c.Logger,
				NoColor:                  true,
				RetryableTerraformErrors: testutils.RetryableTransientErrors,
				MaxRetries:               2,
				TimeBetweenRetries:       2 * time.Minute,
			}
			conf := utils.CloneCSR(t, ProjectsRepo, gcpPath, sc.CICDProject, c.Logger)
			err := conf.CheckoutBranch("production")
			if err != nil {
				return err
			}
			return destroyEnv(t, options, sc.StageSA)
		})
		if err != nil {
			return err
		}
	}

	fmt.Println("end of", sc.Step, "destroy")
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
