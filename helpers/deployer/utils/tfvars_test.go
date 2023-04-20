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
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestWriteReadTfvars(t *testing.T) {

	type nested struct {
		Name  string `cty:"name"`
		Value string `cty:"value"`
	}

	type tfvars struct {
		Required string    `hcl:"required"`
		Slice    []string  `hcl:"slice"`
		Optional *string   `hcl:"optional"`
		Nested   *[]nested `hcl:"nested"`
	}

	optional := "no"
	nestedValue := nested{
		Name:  "cloud",
		Value: "GCP",
	}
	tests := []struct {
		name string
		tfv  tfvars
	}{
		{
			name: "required",
			tfv: tfvars{
				Required: "yes",
				Slice:    []string{"one", "two"},
			},
		},
		{
			name: "optional",
			tfv: tfvars{
				Required: "yes",
				Slice:    []string{"one", "two"},
				Optional: &optional,
				Nested:   &[]nested{nestedValue},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			dir := t.TempDir()
			file := filepath.Join(dir, "test.tfvars")
			err := WriteTfvars(file, tt.tfv)
			assert.NoError(t, err)

			var read tfvars
			err = ReadTfvars(file, &read)
			assert.NoError(t, err)
			assert.Equal(t, tt.tfv.Required, read.Required, "Required value should be %s", tt.tfv.Required)
			assert.Equal(t, tt.tfv.Optional, read.Optional, "Optional value should be equal")
			assert.Equal(t, tt.tfv.Nested, read.Nested, "Nested value should be equal")
			assert.Len(t, read.Slice, 2, "Slice should have 2 elements")
			assert.Contains(t, read.Slice, "one", "Slice should have element 'one'")
			assert.Contains(t, read.Slice, "two", "Slice should have element 'two'")
			if tt.name == "optional" {
				assert.Equal(t, *read.Optional, "no", "Optional value should be 'no'")
				assert.Contains(t, *read.Nested, nestedValue, "Should have the nested value")
			} else {
				assert.Nil(t, read.Optional, "Optional value should be 'nil'")
				assert.Nil(t, read.Nested, "Nested value should be 'nil'")
			}
		})
	}
}
