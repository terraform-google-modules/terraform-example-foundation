
package stages

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"
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

func TestGetDestroyEnvironments(t *testing.T) {
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

func TestCopyCICDConfig_ProductionOnlyDeploy(t *testing.T) {
	tempFoundation := t.TempDir()
	tempCheckout := t.TempDir()

	err := os.MkdirAll(filepath.Join(tempFoundation, "build"), 0755)
	assert.NoError(t, err)

	err = os.WriteFile(filepath.Join(tempFoundation, "build", "cloudbuild-tf-apply.yaml"), []byte("apply"), 0644)
	assert.NoError(t, err)
	err = os.WriteFile(filepath.Join(tempFoundation, "build", "cloudbuild-tf-plan.yaml"), []byte("plan"), 0644)
	assert.NoError(t, err)

	tfWrapperContent := `leaf_regex_plan="^(development|nonproduction|production|shared)$"`
	err = os.WriteFile(filepath.Join(tempFoundation, "build", "tf-wrapper.sh"), []byte(tfWrapperContent), 0755)
	assert.NoError(t, err)

	// test productionOnlyDeploy = true
	repoDir := filepath.Join(tempCheckout, "test-repo-prod-only")
	err = os.MkdirAll(repoDir, 0755)
	assert.NoError(t, err)

	err = copyCICDConfig(t, utils.GitRepo{}, tempFoundation, tempCheckout, "test-repo-prod-only", BuildTypeCBCSR, true)
	assert.NoError(t, err)

	content, err := os.ReadFile(filepath.Join(repoDir, "tf-wrapper.sh"))
	assert.NoError(t, err)
	assert.Contains(t, string(content), `leaf_regex_plan="^(production|shared)$"`)

	// test productionOnlyDeploy = false
	repoDirDefault := filepath.Join(tempCheckout, "test-repo-default")
	err = os.MkdirAll(repoDirDefault, 0755)
	assert.NoError(t, err)

	err = copyCICDConfig(t, utils.GitRepo{}, tempFoundation, tempCheckout, "test-repo-default", BuildTypeCBCSR, false)
	assert.NoError(t, err)

	contentDefault, err := os.ReadFile(filepath.Join(repoDirDefault, "tf-wrapper.sh"))
	assert.NoError(t, err)
	assert.Contains(t, string(contentDefault), `leaf_regex_plan="^(development|nonproduction|production|shared)$"`)
}
