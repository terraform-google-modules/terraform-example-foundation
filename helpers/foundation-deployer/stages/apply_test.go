
package stages

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetEnvironments(t *testing.T) {
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
			name:     "production_only_deploy is not set",
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
