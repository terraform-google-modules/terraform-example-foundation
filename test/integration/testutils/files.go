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
	"strings"
)

const (
	DisableFileSuffix = ".example"
)

// AllowedBuildTypes are the CI/CD variants supported by 0-bootstrap.
// "local" is included so the integration tests can switch the bootstrap into
// the no-CI/CD variant (no Cloud Source Repositories, no Cloud Build) before applying.
var AllowedBuildTypes = []string{"cb", "github", "gitlab", "terraform_cloud", "local"}

// RenameBuildFiles activates the targetBuild variant in basePath and deactivates
// every other variant, by renaming *_<type>.tf <-> *_<type>.tf.example.
func RenameBuildFiles(basePath, targetBuild string) error {
	validBuildType := false
	for _, validType := range AllowedBuildTypes {
		if targetBuild == validType {
			validBuildType = true
			break
		}
	}
	if !validBuildType {
		return fmt.Errorf("invalid build type '%s'. Must be one of: %s", targetBuild, strings.Join(AllowedBuildTypes, ", "))
	}

	for _, buildType := range AllowedBuildTypes {
		if buildType == targetBuild {
			continue
		}
		pattern := filepath.Join(basePath, fmt.Sprintf("*_%s.tf", buildType))
		files, err := filepath.Glob(pattern)
		if err != nil {
			return fmt.Errorf("error finding files to deactivate for build type %s: %w", buildType, err)
		}
		for _, file := range files {
			newName := file + DisableFileSuffix
			if err := os.Rename(file, newName); err != nil {
				return fmt.Errorf("error renaming file %q: %w", file, err)
			}
		}
	}

	pattern := filepath.Join(basePath, fmt.Sprintf("*_%s.tf%s", targetBuild, DisableFileSuffix))
	files, err := filepath.Glob(pattern)
	if err != nil {
		return fmt.Errorf("error finding files to activate for build type %s: %w", targetBuild, err)
	}
	for _, file := range files {
		newName := strings.TrimSuffix(file, DisableFileSuffix)
		if err := os.Rename(file, newName); err != nil {
			return fmt.Errorf("error renaming file %q: %w", file, err)
		}
	}
	return nil
}

// FileExists reports whether path exists.
func FileExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}
