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

package bootstrap

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestBootstrap(t *testing.T) {
	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	bootstrap.DefineVerify(
		func(assert *assert.Assertions) {
			// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
			//bootstrap.DefaultVerify(assert)

			projectID := bootstrap.GetStringOutput("cloudbuild_project_id")
			bucketName := bootstrap.GetStringOutput("gcs_bucket_cloudbuild_artifacts")

			gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectID, "--json"})
			op := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", bucketName), gcloudArgs).Array()[0]

			assert.Equal("STANDARD", op.Get("metadata.storageClass").String(), "bucket has STANDARD storageClass")
		})
	bootstrap.Test()
}
