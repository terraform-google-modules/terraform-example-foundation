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

package testutils

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

func createRenameTestFiles(t *testing.T, tempDir, targetBuild, defaultBuild string) {
	t.Helper()
	for _, name := range []string{
		filepath.Join(tempDir, fmt.Sprintf("test_%s.tf", defaultBuild)),
		filepath.Join(tempDir, fmt.Sprintf("test_%s.tf.example", targetBuild)),
		filepath.Join(tempDir, "test_other.tf"),
	} {
		if err := os.WriteFile(name, []byte("test content"), 0644); err != nil {
			t.Fatalf("Failed to create test file %s: %v", name, err)
		}
	}
}

func checkRenamedFiles(t *testing.T, tempDir, targetBuild, defaultBuild string) {
	t.Helper()
	if targetBuild == defaultBuild {
		return
	}
	assert.FileExists(t, filepath.Join(tempDir, fmt.Sprintf("test_%s.tf", targetBuild)))
	assert.NoFileExists(t, filepath.Join(tempDir, fmt.Sprintf("test_%s.tf.example", targetBuild)))
	assert.FileExists(t, filepath.Join(tempDir, fmt.Sprintf("test_%s.tf.example", defaultBuild)))
	assert.NoFileExists(t, filepath.Join(tempDir, fmt.Sprintf("test_%s.tf", defaultBuild)))
	assert.FileExists(t, filepath.Join(tempDir, "test_other.tf"))
}

func TestRenameFiles(t *testing.T) {
	const defaultBuild = "cb"
	for _, targetBuild := range AllowedBuildTypes {
		t.Run(targetBuild, func(t *testing.T) {
			tempDir := t.TempDir()
			createRenameTestFiles(t, tempDir, targetBuild, defaultBuild)
			err := RenameBuildFiles(tempDir, targetBuild)
			assert.NoError(t, err, "RenameBuildFiles failed for targetBuild %s: %v", targetBuild, err)
			checkRenamedFiles(t, tempDir, targetBuild, defaultBuild)
		})
	}
	t.Run("invalid", func(t *testing.T) {
		tempDir := t.TempDir()
		err := RenameBuildFiles(tempDir, "invalid_build_type")
		assert.Error(t, err, "RenameBuildFiles should have failed for invalid build type")
		assert.Contains(t, err.Error(), "invalid build type")
	})
}
