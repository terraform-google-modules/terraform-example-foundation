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
	"bytes"
	"io/fs"
	"os"
	"path/filepath"
)

const (
	TerraformTempDir  = ".terraform"
	TerraformLockFile = ".terraform.lock.hcl"
)

// CopyFile copies a single file from the src path to the dest path
func CopyFile(src string, dest string) error {
	s, err := os.Stat(src)
	if err != nil {
		return err
	}
	buf, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	return os.WriteFile(dest, buf, s.Mode())
}

// CopyDirectory copies a directory and the files and directories under it.
func CopyDirectory(src string, dest string) error {
	err := os.MkdirAll(dest, 0755)
	if err != nil {
		return err
	}
	files, err := os.ReadDir(src)
	if err != nil {
		return err
	}
	for _, f := range files {
		if f.Name() == TerraformTempDir || f.Name() == TerraformLockFile {
			continue
		}
		if f.IsDir() {
			err = CopyDirectory(filepath.Join(src, f.Name()), filepath.Join(dest, f.Name()))
			if err != nil {
				return err
			}
		} else {
			err = CopyFile(filepath.Join(src, f.Name()), filepath.Join(dest, f.Name()))
			if err != nil {
				return err
			}
		}
	}
	return nil
}

// ReplaceStringInFile replaces a string in a file with a new value.
func ReplaceStringInFile(filename, old, new string) error {
	f, err := os.ReadFile(filename)
	if err != nil {
		return err
	}
	return os.WriteFile(filename, bytes.Replace(f, []byte(old), []byte(new), -1), 0644)
}

// FindFiles find files with the given filename under the directory skipping terraform temp dir.
func FindFiles(dir, filename string) ([]string, error) {
	found := []string{}
	err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if d.IsDir() && d.Name() == TerraformTempDir {
			return filepath.SkipDir
		}
		if d.Name() == filename {
			found = append(found, path)
		}
		return nil
	})
	return found, err
}

// FileExists check if a give file exists
func FileExists(filename string) (bool, error) {
	_, err := os.Stat(filename)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}
