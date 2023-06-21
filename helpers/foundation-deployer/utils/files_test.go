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

func writeTempFile(dir, name, content string) (string, error) {
	f := filepath.Join(dir, name)
	err := os.WriteFile(f, []byte(content), 0644)
	return f, err
}

func TestCopyFile(t *testing.T) {
	filename := "copy_file_test.txt"
	src, err := writeTempFile(t.TempDir(), filename, "test of copy file func")
	assert.NoError(t, err)
	dest := filepath.Join(t.TempDir(), filename)

	err = CopyFile(src, dest)
	assert.NoError(t, err)

	s, err := os.Stat(dest)
	assert.NoError(t, err)
	assert.Equal(t, filename, s.Name())
}

func TestCopyDirectory(t *testing.T) {
	// create src dir
	src := filepath.Join(t.TempDir(), "base")
	inner := filepath.Join(src, "one", "two", "three", "four")
	err := os.MkdirAll(inner, 0755)
	assert.NoError(t, err)
	// create a sample file
	filename := "copy_dir_test.txt"
	fileContent := "test of copy dir func"
	_, err = writeTempFile(inner, filename, fileContent)
	assert.NoError(t, err)

	dest := filepath.Join(t.TempDir(), "base")
	err = CopyDirectory(src, dest)
	assert.NoError(t, err)

	destFile := filepath.Join(dest, "one", "two", "three", "four", filename)
	s, err := os.Stat(destFile)
	assert.NoError(t, err)
	assert.Equal(t, filename, s.Name())

	r, err := os.ReadFile(destFile)
	assert.NoError(t, err)
	assert.Equal(t, r, []byte(fileContent), "file content should be the same")
}

func TestReplaceStringInFile(t *testing.T) {
	f, err := writeTempFile(t.TempDir(), "to_replace.txt", "OLD")
	assert.NoError(t, err)

	err = ReplaceStringInFile(f, "OLD", "new")
	assert.NoError(t, err)

	r, err := os.ReadFile(f)
	assert.NoError(t, err)
	assert.Equal(t, r, []byte("new"), "value should have been replaced from 'OLD' to 'new'")
}

func TestFindFiles(t *testing.T) {
	base := t.TempDir()
	dest := filepath.Join(base, "one", "two", "three", "four")
	err := os.MkdirAll(dest, 0755)
	assert.NoError(t, err)
	filename := "find_file_test.txt"
	_, err = writeTempFile(dest, filename, "test of find file func")
	assert.NoError(t, err)

	files, err := FindFiles(base, filename)
	assert.NoError(t, err)

	assert.Len(t, files, 1, "must have found only one file")
	assert.Equal(t, filepath.Join(base, "one", "two", "three", "four", filename), files[0])
}
