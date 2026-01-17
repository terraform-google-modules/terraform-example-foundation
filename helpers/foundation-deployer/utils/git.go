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
	"net/url"
	"os"
	"os/exec"
	"path"
	"strings"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/git"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/mitchellh/go-testing-interface"
)

type GitRepo struct {
	conf *git.CmdCfg
}

// GitClone clones git repositories, supporting CSR, Github and Gitlab type of source control
func GitClone(t testing.TB, repositoryType, repositoryName, repositoryURL, path, project string, logger *logger.Logger) GitRepo {
	if repositoryType == "CSR" {
		return cloneCSR(t, repositoryName, path, project, logger)
	}
	return cloneGit(t, repositoryURL, path, logger)
}

// CloneCSR clones a Google Cloud Source repository and returns a CmdConfig pointing to the repository.
func cloneCSR(t testing.TB, repositoryName, path, project string, logger *logger.Logger) GitRepo {
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		gcloud.Runf(t, "source repos clone %s %s --project %s", repositoryName, path, project)
	}
	return GitRepo{
		conf: git.NewCmdConfig(t, git.WithDir(path), git.WithLogger(logger)),
	}
}

func GetRepoOnly(t testing.TB, path string, logger *logger.Logger) GitRepo {
	return GitRepo{
		conf: git.NewCmdConfig(t, git.WithDir(path), git.WithLogger(logger)),
	}
}

// cloneGit clones a Github or Gitlab repository and returns a CmdConfig pointing to the repository.
func cloneGit(t testing.TB, repositoryUrl, path string, logger *logger.Logger) GitRepo {
	_, err := os.Stat(path)

	if os.IsNotExist(err) {
		cmd := exec.Command("git", "clone", repositoryUrl, path)
		_, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("Error executing git command: %v", err)
		}
		fmt.Printf("repo cloned at path:\n%s\n", path)
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

func BuildGitHubURL(owner, repoName, token string) string {
	return fmt.Sprintf("https://oauth2:%s@github.com/%s/%s.git", token, owner, repoName)
}

func BuildGitLabURL(owner, repoName, token string) string {
	return fmt.Sprintf("https://oauth2:%s@gitlab.com/%s/%s.git", token, owner, repoName)
}

// ExtractRepoNameFromGitHubURL parses a GitHub URL and returns the repository name.
func ExtractRepoNameFromGitHubURL(githubURL string) (string, error) {
	parsedURL, err := url.Parse(githubURL)
	if err != nil {
		return "", fmt.Errorf("failed to parse URL: %w", err)
	}

	repoNameWithSuffix := path.Base(parsedURL.Path)
	if repoNameWithSuffix == "" || repoNameWithSuffix == "." || repoNameWithSuffix == "/" {
		return "", fmt.Errorf("could not find a repository name in the URL path: %s", githubURL)
	}

	repoName := strings.TrimSuffix(repoNameWithSuffix, ".git")
	if repoName == "" {
		return "", fmt.Errorf("extracted repository name is empty after processing: %s", githubURL)
	}
	return repoName, nil
}

// Merge merges the specified branch into the currently checked out branch.
func (g GitRepo) Merge(branch string) error {
	_, err := g.conf.RunCmdE("merge", "--no-edit", branch)
	return err
}
