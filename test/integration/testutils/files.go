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

package testutils

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// disableFileSuffix marks a build-type file as inactive (e.g. build_cb.tf.example).
const disableFileSuffix = ".example"

// AllowedBuildTypes are the CI/CD variants supported by 0-bootstrap. This mirrors
// helpers/foundation-deployer/utils/files.go and 0-bootstrap/scripts/choose_build_type.sh,
// with "local" added so the integration tests can switch the bootstrap into the
// no-CI/CD variant (no Cloud Source Repositories, no Cloud Build) before applying.
var AllowedBuildTypes = []string{"cb", "github", "gitlab", "terraform_cloud", "local"}

// CurrentBuildType returns the build type currently active in basePath, detected
// by the active build_<type>.tf file (i.e. without the .example suffix). It returns
// an empty string if no build type is active. Callers use it to record the original
// state so it can be restored on teardown, keeping the checkout non-destructive.
func CurrentBuildType(basePath string) (string, error) {
	for _, bt := range AllowedBuildTypes {
		active, err := fileExists(filepath.Join(basePath, fmt.Sprintf("build_%s.tf", bt)))
		if err != nil {
			return "", err
		}
		if active {
			return bt, nil
		}
	}
	return "", nil
}

// RenameBuildFiles activates the targetBuild variant in basePath and deactivates
// every other variant, by renaming *_<type>.tf <-> *_<type>.tf.example. It is
// idempotent (re-running with an already-active target is a no-op) and mirrors the
// logic of 0-bootstrap/scripts/choose_build_type.sh. Base files without a
// _<type> suffix (main.tf, sa.tf, variables.tf, outputs.tf, ...) are never touched.
//
// NOTE: this mutates the working tree at basePath. When used against the shared
// ../../../0-bootstrap checkout, callers must restore the original build type on
// teardown. An abrupt interruption (panic/kill) before teardown can leave the tree
// switched, the same caveat as disable_tf_files.sh / restore_tf_files.sh.
func RenameBuildFiles(basePath, targetBuild string) error {
	if !isAllowedBuildType(targetBuild) {
		return fmt.Errorf("invalid build type %q, must be one of: %s", targetBuild, strings.Join(AllowedBuildTypes, ", "))
	}

	// Deactivate all other build types: *_<type>.tf -> *_<type>.tf.example
	for _, bt := range AllowedBuildTypes {
		if bt == targetBuild {
			continue
		}
		pattern := filepath.Join(basePath, fmt.Sprintf("*_%s.tf", bt))
		files, err := filepath.Glob(pattern)
		if err != nil {
			return fmt.Errorf("finding files to deactivate for build type %q: %w", bt, err)
		}
		for _, file := range files {
			newName := file + disableFileSuffix
			if err := os.Rename(file, newName); err != nil {
				return fmt.Errorf("deactivating %q: %w", file, err)
			}
		}
	}

	// Activate the target: *_<target>.tf.example -> *_<target>.tf
	pattern := filepath.Join(basePath, fmt.Sprintf("*_%s.tf%s", targetBuild, disableFileSuffix))
	files, err := filepath.Glob(pattern)
	if err != nil {
		return fmt.Errorf("finding files to activate for build type %q: %w", targetBuild, err)
	}
	for _, file := range files {
		newName := strings.TrimSuffix(file, disableFileSuffix)
		if err := os.Rename(file, newName); err != nil {
			return fmt.Errorf("activating %q: %w", file, err)
		}
	}
	return nil
}

func isAllowedBuildType(bt string) bool {
	for _, v := range AllowedBuildTypes {
		if v == bt {
			return true
		}
	}
	return false
}

// fileExists reports whether path exists.
func fileExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}
