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

package testutils

import (
	"context"
	"fmt"
	"io"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/logger"
	"golang.org/x/oauth2/google"
)

func CheckAPIEnabled(t *testing.T, projectID, api string) (bool, error) {
	logger.Log(t, fmt.Sprintf("checking if API %s is enabled in project %s", api, projectID))
	httpClient, err := google.DefaultClient(context.Background(), "https://www.googleapis.com/auth/cloud-platform")
	if err != nil {
		return true, err
	}
	serviceUsageEndpoint := fmt.Sprintf("https://serviceusage.googleapis.com/v1/projects/%s/services/%s", projectID, api)
	resp, err := httpClient.Get(serviceUsageEndpoint)
	if err != nil {
		return true, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return true, err
	}
	result := utils.ParseJSONResult(t, string(body))
	resultName := result.Get("name").String()
	resultState := result.Get("state").String()
	if !strings.Contains(resultName, api) || resultState != "ENABLED" {
		return true, fmt.Errorf("API %s is not enabled in project %s", api, projectID)
	}
	logger.Log(t, fmt.Sprintf("API %s is enabled in project %s", api, projectID))
	return false, nil
}
