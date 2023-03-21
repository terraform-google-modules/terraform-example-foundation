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
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/git"
)

func createLocalRepo(t *testing.T, repo string) string {
	dir := t.TempDir()
	local := filepath.Join(dir, repo)
	err := os.MkdirAll(local, 0755)
	assert.NoError(t, err)
	conf := git.NewCmdConfig(t, git.WithDir(local))
	conf.Init()
	f := filepath.Join(local, "README.md")
	err = os.WriteFile(f, []byte("# Testing\n"), 0644)
	assert.NoError(t, err)
	conf.AddAll()
	conf.CommitWithMsg("Initial commit", nil)
	return local
}

func TestGit(t *testing.T) {
	repo := createLocalRepo(t, "my-git-repo")
	originPath := filepath.Join(t.TempDir(), "my-git-repo-origin")
	err := CopyDirectory(repo, originPath)
	assert.NoError(t, err)

	local := CloneRepo(t, "my-git-repo", repo, "")
	_, err = local.RunCmdE("remote", "add", "origin", originPath)
	assert.NoError(t, err)

	err = CheckoutBranch(local, "unit-test")
	assert.NoError(t, err)

	localBranch, err := GetCurrentBranch(local)
	assert.Equal(t, localBranch, "unit-test", "current branch should be 'unit-test'")

	err = os.WriteFile(filepath.Join(repo, "go.mod"), []byte("module example.com/test\n"), 0644)
	assert.NoError(t, err)

	err = CommitFiles(local, "add go mod file")
	assert.NoError(t, err)

	err = PushBranch(local, "unit-test")
	assert.NoError(t, err)

	hasRemote, err := HasRemoteTRacking(local, "unit-test")
	assert.NoError(t, err)
	assert.True(t, hasRemote, "branch 'unit-test' should have a remote")

	origin := CloneRepo(t, "my-git-repo", originPath, "")
	files, err := FindFiles(originPath, "go.mod")
	assert.NoError(t, err)
	assert.Len(t, files, 0, "'go.mod' file should not exist on main branch")

	err = CheckoutBranch(origin, "unit-test")
	assert.NoError(t, err)
	files, err = FindFiles(originPath, "go.mod")
	assert.NoError(t, err)
	assert.Len(t, files, 1, "'go.mod' file should exist on 'unit-test' branch")
}
