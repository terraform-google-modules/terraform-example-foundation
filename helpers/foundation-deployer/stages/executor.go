// Copyright 2025 Google LLC
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
	"github.com/mitchellh/go-testing-interface"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/gcp"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/github"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/gitlab"
)

type Executor interface {
	WaitBuildSuccess(t testing.TB, commitSha, failureMsg string) error
}

type GCPExecutor struct {
	executor gcp.GCP
	project  string
	region   string
	repo     string
}

func (e *GCPExecutor) WaitBuildSuccess(t testing.TB, commitSha, failureMsg string) error {
	return e.executor.WaitBuildSuccess(t, e.project, e.region, e.repo, commitSha, failureMsg, MaxBuildRetries, MaxErrorRetries, TimeBetweenErrorRetries)
}

func NewGCPExecutor(project, region, repo string) *GCPExecutor {
	return &GCPExecutor{
		project: project,
		region:  region,
		repo:    repo,
	}
}

type GitHubExecutor struct {
	executor github.GH
	owner    string
	repo     string
	token    string
}

func NewGitHubExecutor(owner, repo, token string) *GitHubExecutor {
	return &GitHubExecutor{
		executor: github.NewGH(),
		owner:    owner,
		repo:     repo,
		token:    token,
	}
}

func (e *GitHubExecutor) WaitBuildSuccess(t testing.TB, commitSha, failureMsg string) error {
	return e.executor.WaitBuildSuccess(t, e.owner, e.repo, e.token, commitSha, failureMsg, MaxBuildRetries, MaxErrorRetries, TimeBetweenErrorRetries)
}

type GitLabExecutor struct {
	executor gitlab.GL
	owner    string
	project  string
	token    string
}

func NewGitLabExecutor(owner, project, token string) *GitLabExecutor {
	return &GitLabExecutor{
		executor: gitlab.NewGL(),
		owner:    owner,
		project:  project,
		token:    token,
	}
}

func (e *GitLabExecutor) WaitBuildSuccess(t testing.TB, commitSha, failureMsg string) error {
	return e.executor.WaitBuildSuccess(t, e.owner, e.project, e.token, commitSha, failureMsg, MaxBuildRetries, MaxErrorRetries, TimeBetweenErrorRetries)
}
