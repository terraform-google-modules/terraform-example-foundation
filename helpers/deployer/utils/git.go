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

package utils

import (
	"fmt"
	"os"
	"strings"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/git"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/mitchellh/go-testing-interface"
)

// CloneRepo clones a Google cloud source repository and returns a CmdConfig pointing to the repository.
func CloneRepo(t testing.TB, name, path, project string) *git.CmdCfg {
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		gcloud.Runf(t, "source repos clone %s %s --project %s", name, path, project)
	}
	return git.NewCmdConfig(t, git.WithDir(path), git.WithLogger(logger.Default))
}

// GetCurrentBranch getes the current branch in the repository.
func GetCurrentBranch(conf *git.CmdCfg) (string, error) {
	b, err := conf.RunCmdE("branch", "-q", "--show-current")
	if err != nil {
		return "", err
	}
	return b, nil
}

// HasRemoteTRacking check it a branch has a remote upstream configured.
func HasRemoteTRacking(conf *git.CmdCfg, branch string) (bool, error) {
	s, err := conf.RunCmdE("status", "-sb")
	if err != nil {
		return false, err
	}
	if strings.Contains(s, fmt.Sprintf("## %s...origin/%s", branch, branch)) {
		return true, nil
	}
	return false, nil
}

// PushBranch pushes a branch to remote origin.
// If the branch does not have a upstream it will be set.
func PushBranch(conf *git.CmdCfg, branch string) error {
	exits, err := HasRemoteTRacking(conf, branch)
	if err != nil {
		return err
	}
	if !exits {
		_, err := conf.RunCmdE("push", "--set-upstream", "origin", branch)
		if err != nil {
			return err
		}
	} else {
		_, err := conf.RunCmdE("push")
		if err != nil {
			return err
		}
	}
	return nil
}

// CheckoutBranch checkouts a branch.
// If the branch does not exist it will be created.
func CheckoutBranch(conf *git.CmdCfg, branch string) error {
	c, err := GetCurrentBranch(conf)
	if err != nil {
		return err
	}
	if c != branch {
		_, err := conf.RunCmdE("checkout", "-b", branch)
		if err != nil {
			if strings.Contains(err.Error(), "already exists") {
				_, err := conf.RunCmdE("checkout", branch)
				if err != nil {
					return err
				}
			} else {
				return err
			}
		}
	}
	return nil
}

// CommitFiles commit files it there are pending changes.
func CommitFiles(conf *git.CmdCfg, msg string) error {
	s, err := conf.RunCmdE("status", "-s")
	if err != nil {
		return err
	}
	if s != "" {
		_, err = conf.RunCmdE("add", ".")
		if err != nil {
			return err
		}
		_, err = conf.RunCmdE("commit", "-m", fmt.Sprintf("'%s'", msg))
		return err
	}
	return nil
}
