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
)

func TestCopyFile(t *testing.T) {
	d, err := os.Getwd()
	assert.NoError(t, err)
	src := filepath.Join(d, "files_test.go")
	dest := filepath.Join(t.TempDir(), "files_test.go")
	err = CopyFile(src, dest)
	assert.NoError(t, err)

	s, err := os.Stat(dest)
	assert.NoError(t, err)
	assert.Equal(t, "files_test.go", s.Name())
}

func TestCopyDirectory(t *testing.T) {
	src, err := os.Getwd()
	assert.NoError(t, err)

	dest := filepath.Join(t.TempDir(), "utils")
	err = CopyDirectory(src, dest)
	assert.NoError(t, err)

	s, err := os.Stat(filepath.Join(dest, "files_test.go"))
	assert.NoError(t, err)
	assert.Equal(t, "files_test.go", s.Name())
}

func TestReplaceStringInFile(t *testing.T) {
	f := filepath.Join(t.TempDir(), "to_replace.txt")
	err := os.WriteFile(f, []byte("OLD"), 0644)
	assert.NoError(t, err)

	err = ReplaceStringInFile(f, "OLD", "new")
	assert.NoError(t, err)

	r, err := os.ReadFile(f)
	assert.NoError(t, err)
	assert.Equal(t, r, []byte("new"), "value should have been replaced from 'OLD' to 'new'")
}

func TestFindFiles(t *testing.T) {
	src, err := os.Getwd()
	assert.NoError(t, err)
	base := t.TempDir()
	dest := filepath.Join(base, "one", "two", "three", "four")

	err = CopyDirectory(src, dest)
	assert.NoError(t, err)
	files, err := FindFiles(base, "files_test.go")
	assert.NoError(t, err)

	assert.Len(t, files, 1, "must have found only one file")
	assert.Equal(t, filepath.Join(base, "one", "two", "three", "four", "files_test.go"), files[0])
}
