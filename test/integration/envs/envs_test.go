// Copyright 2022 Google LLC
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

package envs

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestEnvs(t *testing.T) {

	for _, tt := range []struct {
		tfDir string
	}{
		{
			tfDir: "../../../3-networks/envs/development",
		},
		{
			tfDir: "../../../3-networks/envs/non-production",
		},
		{
			tfDir: "../../../3-networks/envs/production",
		},
	} {
		envs := tft.NewTFBlueprintTest(t,
			tft.WithTFDir(tt.ftDir),
		)
		envs.DefineVerify(
			func(assert *assert.Assertions) {
				// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
				envs.DefaultVerify(assert)
			})
		envs.Test()
	}
}
