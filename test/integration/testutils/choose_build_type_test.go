// Copyright 2024 Google LLC
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

package testutils

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func findRepoRoot(t *testing.T) string {
	t.Helper()
	dir, err := os.Getwd()
	require.NoError(t, err)

	for {
		if _, err := os.Stat(filepath.Join(dir, "scripts", "choose_build_type.sh")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			t.Fatal("Could not find repository root containing scripts/choose_build_type.sh")
		}
		dir = parent
	}
}

func setupMockFoundation(t *testing.T, repoRoot, tempDir string) {
	t.Helper()

	// Copy scripts/choose_build_type.sh
	require.NoError(t, os.MkdirAll(filepath.Join(tempDir, "scripts"), 0755))
	scriptContent, err := os.ReadFile(filepath.Join(repoRoot, "scripts", "choose_build_type.sh"))
	require.NoError(t, err)
	scriptDest := filepath.Join(tempDir, "scripts", "choose_build_type.sh")
	require.NoError(t, os.WriteFile(scriptDest, scriptContent, 0755))

	// Mock 0-bootstrap
	bootstrapDir := filepath.Join(tempDir, "0-bootstrap")
	require.NoError(t, os.MkdirAll(bootstrapDir, 0755))
	for _, bt := range AllowedBuildTypes {
		suffix := ".example"
		if bt == "cb" {
			suffix = ""
		}
		require.NoError(t, os.WriteFile(filepath.Join(bootstrapDir, fmt.Sprintf("build_%s.tf%s", bt, suffix)), []byte("# test"), 0644))
		require.NoError(t, os.WriteFile(filepath.Join(bootstrapDir, fmt.Sprintf("outputs_%s.tf%s", bt, suffix)), []byte("# test"), 0644))
	}

	// Mock 4-projects shared
	projectsSharedDir := filepath.Join(tempDir, "4-projects", "business_unit_1", "shared")
	require.NoError(t, os.MkdirAll(projectsSharedDir, 0755))
	for _, bt := range []string{"cb", "github", "gitlab", "local"} {
		suffix := ".example"
		if bt == "cb" {
			suffix = ""
		}
		require.NoError(t, os.WriteFile(filepath.Join(projectsSharedDir, fmt.Sprintf("main_%s.tf%s", bt, suffix)), []byte("# test"), 0644))
	}
	require.NoError(t, os.WriteFile(filepath.Join(projectsSharedDir, "versions_github.tf.example"), []byte("# test"), 0644))
	require.NoError(t, os.WriteFile(filepath.Join(projectsSharedDir, "versions_gitlab.tf.example"), []byte("# test"), 0644))

	// Mock 5-app-infra
	appInfraDir := filepath.Join(tempDir, "5-app-infra", "business_unit_1", "development")
	require.NoError(t, os.MkdirAll(appInfraDir, 0755))
	for _, bt := range []string{"cb", "github", "gitlab", "local"} {
		suffix := ".example"
		if bt == "cb" {
			suffix = ""
		}
		require.NoError(t, os.WriteFile(filepath.Join(appInfraDir, fmt.Sprintf("versions_%s.tf%s", bt, suffix)), []byte("# test"), 0644))
	}

	// Mock pruned directories (.terraform and .git)
	prunedTerraform := filepath.Join(bootstrapDir, ".terraform", "modules")
	require.NoError(t, os.MkdirAll(prunedTerraform, 0755))
	require.NoError(t, os.WriteFile(filepath.Join(prunedTerraform, "module_cb.tf"), []byte("# untouched"), 0644))

	prunedGit := filepath.Join(tempDir, ".git", "hooks")
	require.NoError(t, os.MkdirAll(prunedGit, 0755))
	require.NoError(t, os.WriteFile(filepath.Join(prunedGit, "hook_cb.tf"), []byte("# untouched"), 0644))
}

func TestChooseBuildTypeScript_Validation(t *testing.T) {
	repoRoot := findRepoRoot(t)
	scriptPath := filepath.Join(repoRoot, "scripts", "choose_build_type.sh")

	tests := []struct {
		name          string
		args          []string
		expectContent string
	}{
		{"no_arguments", []string{}, "Usage:"},
		{"help_flag", []string{"-h"}, "Usage:"},
		{"long_help_flag", []string{"--help"}, "Usage:"},
		{"empty_argument", []string{""}, "Usage:"},
		{"invalid_runner", []string{"invalid_runner"}, "Error: Invalid build type"},
		{"arbitrary_flag", []string{"--foo"}, "Error: Invalid build type"},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			cmd := exec.Command(scriptPath, tc.args...)
			output, err := cmd.CombinedOutput()
			assert.Error(t, err, "choose_build_type.sh should fail for %s", tc.name)
			assert.Contains(t, string(output), tc.expectContent)
		})
	}
}

func TestChooseBuildTypeScript_MultiStageSwitching(t *testing.T) {
	repoRoot := findRepoRoot(t)
	tempDir := t.TempDir()
	setupMockFoundation(t, repoRoot, tempDir)

	scriptPath := filepath.Join(tempDir, "scripts", "choose_build_type.sh")

	for _, target := range AllowedBuildTypes {
		t.Run(target, func(t *testing.T) {
			cmd := exec.Command(scriptPath, target)
			cmd.Dir = tempDir
			output, err := cmd.CombinedOutput()
			require.NoError(t, err, "choose_build_type.sh %s failed: %s", target, string(output))

			// Check 0-bootstrap
			bootstrapDir := filepath.Join(tempDir, "0-bootstrap")
			assert.FileExists(t, filepath.Join(bootstrapDir, fmt.Sprintf("build_%s.tf", target)))
			assert.NoFileExists(t, filepath.Join(bootstrapDir, fmt.Sprintf("build_%s.tf.example", target)))

			for _, other := range AllowedBuildTypes {
				if other != target {
					assert.FileExists(t, filepath.Join(bootstrapDir, fmt.Sprintf("build_%s.tf.example", other)))
					assert.NoFileExists(t, filepath.Join(bootstrapDir, fmt.Sprintf("build_%s.tf", other)))
				}
			}

			// Check 4-projects shared (for types present in shared)
			sharedDir := filepath.Join(tempDir, "4-projects", "business_unit_1", "shared")
			if target != "terraform_cloud" {
				assert.FileExists(t, filepath.Join(sharedDir, fmt.Sprintf("main_%s.tf", target)))
				assert.NoFileExists(t, filepath.Join(sharedDir, fmt.Sprintf("main_%s.tf.example", target)))
			}

			// Check versions_*.tf in shared
			if target == "github" {
				assert.FileExists(t, filepath.Join(sharedDir, "versions_github.tf"))
				assert.NoFileExists(t, filepath.Join(sharedDir, "versions_github.tf.example"))
				assert.FileExists(t, filepath.Join(sharedDir, "versions_gitlab.tf.example"))
			} else if target == "gitlab" {
				assert.FileExists(t, filepath.Join(sharedDir, "versions_gitlab.tf"))
				assert.NoFileExists(t, filepath.Join(sharedDir, "versions_gitlab.tf.example"))
				assert.FileExists(t, filepath.Join(sharedDir, "versions_github.tf.example"))
			}

			// Check pruned directories remain completely untouched
			assert.FileExists(t, filepath.Join(bootstrapDir, ".terraform", "modules", "module_cb.tf"))
			assert.NoFileExists(t, filepath.Join(bootstrapDir, ".terraform", "modules", "module_cb.tf.example"))
			assert.FileExists(t, filepath.Join(tempDir, ".git", "hooks", "hook_cb.tf"))
			assert.NoFileExists(t, filepath.Join(tempDir, ".git", "hooks", "hook_cb.tf.example"))
		})
	}

	// Validate clean round-trip restoration back to default "cb"
	t.Run("roundtrip_cb_restore", func(t *testing.T) {
		cmd := exec.Command(scriptPath, "cb")
		cmd.Dir = tempDir
		output, err := cmd.CombinedOutput()
		require.NoError(t, err, "choose_build_type.sh restore cb failed: %s", string(output))

		assert.FileExists(t, filepath.Join(tempDir, "0-bootstrap", "build_cb.tf"))
		assert.NoFileExists(t, filepath.Join(tempDir, "0-bootstrap", "build_cb.tf.example"))
		assert.FileExists(t, filepath.Join(tempDir, "4-projects", "business_unit_1", "shared", "main_cb.tf"))
		assert.NoFileExists(t, filepath.Join(tempDir, "4-projects", "business_unit_1", "shared", "main_cb.tf.example"))
	})
}

func TestChooseBuildTypeScript_StandaloneFallback(t *testing.T) {
	repoRoot := findRepoRoot(t)
	tempDir := t.TempDir()

	// Only scripts directory and some standalone files in tempDir root (no 0-bootstrap or 4-projects)
	require.NoError(t, os.MkdirAll(filepath.Join(tempDir, "scripts"), 0755))
	scriptContent, err := os.ReadFile(filepath.Join(repoRoot, "scripts", "choose_build_type.sh"))
	require.NoError(t, err)
	scriptDest := filepath.Join(tempDir, "scripts", "choose_build_type.sh")
	require.NoError(t, os.WriteFile(scriptDest, scriptContent, 0755))

	require.NoError(t, os.WriteFile(filepath.Join(tempDir, "build_cb.tf"), []byte("# cb"), 0644))
	require.NoError(t, os.WriteFile(filepath.Join(tempDir, "build_github.tf.example"), []byte("# gh"), 0644))

	cmd := exec.Command(scriptDest, "github")
	cmd.Dir = tempDir
	output, err := cmd.CombinedOutput()
	require.NoError(t, err, "choose_build_type.sh fallback failed: %s", string(output))

	assert.FileExists(t, filepath.Join(tempDir, "build_github.tf"))
	assert.NoFileExists(t, filepath.Join(tempDir, "build_github.tf.example"))
	assert.FileExists(t, filepath.Join(tempDir, "build_cb.tf.example"))
	assert.NoFileExists(t, filepath.Join(tempDir, "build_cb.tf"))
}
