// Copyright 2024 Google LLC
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
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetEnvironments_Function(t *testing.T) {
	tests := []struct {
		name                 string
		productionOnlyDeploy bool
		isDestroy            bool
		expected             []string
	}{
		{
			name:                 "apply mode with productionOnlyDeploy true",
			productionOnlyDeploy: true,
			isDestroy:            false,
			expected:             []string{"production"},
		},
		{
			name:                 "apply mode with productionOnlyDeploy false",
			productionOnlyDeploy: false,
			isDestroy:            false,
			expected:             []string{"production", "nonproduction", "development"},
		},
		{
			name:                 "destroy mode with productionOnlyDeploy true",
			productionOnlyDeploy: true,
			isDestroy:            true,
			expected:             []string{"production"},
		},
		{
			name:                 "destroy mode with productionOnlyDeploy false (reverse order)",
			productionOnlyDeploy: false,
			isDestroy:            true,
			expected:             []string{"development", "nonproduction", "production"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := GetEnvironments(tt.productionOnlyDeploy, tt.isDestroy)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestGetEnvironments_GlobalTFVars(t *testing.T) {
	trueValue := true
	falseValue := false

	tests := []struct {
		name     string
		tfvars   GlobalTFVars
		expected []string
	}{
		{
			name: "production_only_deploy is true",
			tfvars: GlobalTFVars{
				ProductionOnlyDeploy: &trueValue,
			},
			expected: []string{"production"},
		},
		{
			name: "production_only_deploy is false",
			tfvars: GlobalTFVars{
				ProductionOnlyDeploy: &falseValue,
			},
			expected: []string{"production", "nonproduction", "development"},
		},
		{
			name:     "production_only_deploy is nil / unset",
			tfvars:   GlobalTFVars{},
			expected: []string{"production", "nonproduction", "development"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.expected, getEnvironments(tt.tfvars))
		})
	}
}

func TestGetDestroyEnvironments_CommonConf(t *testing.T) {
	tests := []struct {
		name     string
		conf     CommonConf
		expected []string
	}{
		{
			name: "production_only_deploy is true",
			conf: CommonConf{
				ProductionOnlyDeploy: true,
			},
			expected: []string{"production"},
		},
		{
			name: "production_only_deploy is false",
			conf: CommonConf{
				ProductionOnlyDeploy: false,
			},
			expected: []string{"development", "nonproduction", "production"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.expected, getDestroyEnvironments(tt.conf))
		})
	}
}
