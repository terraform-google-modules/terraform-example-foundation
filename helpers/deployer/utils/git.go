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

type GitRepo struct {
	conf *git.CmdCfg
}

// CloneCSR clones a Google Cloud Source repository and returns a CmdConfig pointing to the repository.
func CloneCSR(t testing.TB, name, path, project string, logger *logger.Logger) GitRepo {
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		gcloud.Runf(t, "source repos clone %s %s --project %s", name, path, project)
	}
	return GitRepo{
		conf: git.NewCmdConfig(t, git.WithDir(path), git.WithLogger(logger)),
	}
}

// GetCurrentBranch gets the current branch in the repository.
func (g GitRepo) GetCurrentBranch() (string, error) {
	return g.conf.RunCmdE("branch", "-q", "--show-current")
}

// HasUpstream check it a branch has an upstream branch configured.
func (g GitRepo) HasUpstream(branch, remote string) (bool, error) {
	s, err := g.conf.RunCmdE("status", "-sb")
	if err != nil {
		return false, err
	}
	if strings.Contains(s, fmt.Sprintf("## %s...%s/%s", branch, remote, branch)) {
		return true, nil
	}
	return false, nil
}

// PushBranch pushes a branch to 'remote' repository .
func (g GitRepo) PushBranch(branch, remote string) error {
	_, err := g.conf.RunCmdE("push", "--set-upstream", remote, branch)
	return err
}

// CheckoutBranch checkouts a branch.
// If the branch does not exist it will be created.
func (g GitRepo) CheckoutBranch(branch string) error {
	c, err := g.GetCurrentBranch()
	if err != nil {
		return err
	}
	if c == branch {
		return nil
	}
	_, err = g.conf.RunCmdE("checkout", "-b", branch)
	if err != nil && strings.Contains(err.Error(), "already exists") {
		_, err = g.conf.RunCmdE("checkout", branch)
	}
	return err
}

// CommitFiles commit files it there are pending changes.
func (g GitRepo) CommitFiles(msg string) error {
	s, err := g.conf.RunCmdE("status", "-s")
	if err != nil {
		return err
	}
	if s == "" {
		return nil
	}
	_, err = g.conf.RunCmdE("add", ".")
	if err != nil {
		return err
	}
	_, err = g.conf.RunCmdE("commit", "-m", fmt.Sprintf("'%s'", msg))
	return err
}

// AddRemote adds a remote to the repository
func (g GitRepo) AddRemote(name, url string) error {
	_, err := g.conf.RunCmdE("remote", "add", name, url)
	return err
}

// GetCommitSha gets the commit SHA of the last commit of the current branch
func (g GitRepo) GetCommitSha() (string, error) {
	return g.conf.RunCmdE("rev-parse", "HEAD")
}
