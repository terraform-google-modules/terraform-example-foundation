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
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"
)

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
