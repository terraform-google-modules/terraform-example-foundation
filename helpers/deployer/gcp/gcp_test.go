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

package gcp

import (
	"fmt"
	gotest "testing"

	"github.com/mitchellh/go-testing-interface"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func TestGetLastBuildStatus(t *gotest.T) {
	currentStatus := "SUCCESS"
	basicGCP := GCP{
		Runf: func(t testing.TB, cmd string, args ...interface{}) gjson.Result {
			return gjson.Result{
				Type: gjson.JSON,
				Raw:  fmt.Sprintf("[{\"status\": \"%s\"}]", currentStatus),
			}
		},
		sleepTime: 1,
	}
	status := basicGCP.GetLastBuildStatus(t, "project", "region", "filter")
	assert.Equal(t, "SUCCESS", status)

	currentStatus = "FAILURE"
	status = basicGCP.GetLastBuildStatus(t, "project", "region", "filter")
	assert.Equal(t, "FAILURE", status)
}

func TestGetFinalBuildState(t *gotest.T) {

	runfCalls := []gjson.Result{
		{Type: gjson.JSON,
			Raw: "{\"status\": \"QUEUED\"}"},
		{Type: gjson.JSON,
			Raw: "{\"status\": \"FAILURE\"}"},
	}
	callCount := 0
	seqGCP := GCP{
		Runf: func(t testing.TB, cmd string, args ...interface{}) gjson.Result {
			resp := runfCalls[callCount]
			callCount = callCount + 1
			return resp
		},
		sleepTime: 1,
	}

	status2 := seqGCP.GetFinalBuildState(t, "project", "region", "buildID")
	assert.Equal(t, "FAILURE", status2)
	assert.Equal(t, callCount, 2, "Runf must be called twice")
}

func TestWaitBuildSuccess(t *gotest.T) {

	callCount := 0
	runfCalls := []gjson.Result{
		{Type: gjson.JSON,
			Raw: "[{\"id\": \"test_build_id\",\"status\": \"WORKING\"}]"},
		{Type: gjson.JSON,
			Raw: "{\"status\": \"WORKING\"}"},
		{Type: gjson.JSON,
			Raw: "{\"status\": \"FAILURE\"}"},
	}

	seqGCP := GCP{
		Runf: func(t testing.TB, cmd string, args ...interface{}) gjson.Result {
			resp := runfCalls[callCount]
			callCount = callCount + 1
			return resp
		},
		sleepTime: 1,
	}

	err := seqGCP.WaitBuildSuccess(t, "project", "region", "repo", "failed_test_for_WaitBuildSuccess")
	assert.Error(t, err, "should have failed")
	assert.Contains(t, err.Error(), "failed_test_for_WaitBuildSuccess", "should have failed with custom info")
	assert.Equal(t, callCount, 3, "Runf must be called three times")
}
