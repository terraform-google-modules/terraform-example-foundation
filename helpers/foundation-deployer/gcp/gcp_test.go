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
	"os"
	"path/filepath"
	gotest "testing"

	"github.com/mitchellh/go-testing-interface"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func TestGetLastBuildStatus(t *gotest.T) {
	current, err := os.ReadFile(filepath.Join(".", "testdata", "success_build.json"))
	assert.NoError(t, err)
	gcp := GCP{
		Runf: func(t testing.TB, cmd string, args ...interface{}) gjson.Result {
			return gjson.Result{
				Type: gjson.JSON,
				Raw:  fmt.Sprintf("[%s]", string(current[:])),
			}
		},
		sleepTime: 1,
	}
	status := gcp.GetLastBuildStatus(t, "prj-b-cicd-0123", "us-central1", "filter")
	assert.Equal(t, StatusSuccess, status)

	current, err = os.ReadFile(filepath.Join(".", "testdata", "failure_build.json"))
	assert.NoError(t, err)
	status = gcp.GetLastBuildStatus(t, "prj-b-cicd-0123", "us-central1", "filter")
	assert.Equal(t, StatusFailure, status)
}

func TestGetFinalBuildState(t *gotest.T) {

	queued, err := os.ReadFile(filepath.Join(".", "testdata", "queued_build.json"))
	assert.NoError(t, err)
	failure, err := os.ReadFile(filepath.Join(".", "testdata", "failure_build.json"))
	assert.NoError(t, err)
	runfCalls := []gjson.Result{
		{Type: gjson.JSON,
			Raw: string(queued[:])},
		{Type: gjson.JSON,
			Raw: string(failure[:])},
	}
	callCount := 0
	gcp := GCP{
		Runf: func(t testing.TB, cmd string, args ...interface{}) gjson.Result {
			resp := runfCalls[callCount]
			callCount = callCount + 1
			return resp
		},
		sleepTime: 1,
	}

	status2, err := gcp.GetFinalBuildState(t, "prj-b-cicd-0123", "us-central1", "buildID", 40)
	assert.NoError(t, err)
	assert.Equal(t, StatusFailure, status2)
	assert.Equal(t, callCount, 2, "Runf must be called twice")
}

func TestWaitBuildSuccess(t *gotest.T) {

	working, err := os.ReadFile(filepath.Join(".", "testdata", "working_build.json"))
	assert.NoError(t, err)

	failure, err := os.ReadFile(filepath.Join(".", "testdata", "failure_build.json"))
	assert.NoError(t, err)

	callCount := 0
	runfCalls := []gjson.Result{
		{Type: gjson.JSON,
			Raw: fmt.Sprintf("[%s]", string(working[:]))},
		{Type: gjson.JSON,
			Raw: string(working[:])},
		{Type: gjson.JSON,
			Raw: string(failure[:])},
	}

	gcp := GCP{
		Runf: func(t testing.TB, cmd string, args ...interface{}) gjson.Result {
			resp := runfCalls[callCount]
			callCount = callCount + 1
			return resp
		},
		sleepTime: 1,
	}

	err = gcp.WaitBuildSuccess(t, "prj-b-cicd-0123", "us-central1", "repo","", "failed_test_for_WaitBuildSuccess", 40)
	assert.Error(t, err, "should have failed")
	assert.Contains(t, err.Error(), "failed_test_for_WaitBuildSuccess", "should have failed with custom info")
	assert.Equal(t, callCount, 3, "Runf must be called three times")
}

func TestWaitBuildTimeout(t *gotest.T) {

	working, err := os.ReadFile(filepath.Join(".", "testdata", "working_build.json"))
	assert.NoError(t, err)

	callCount := 0
	runfCalls := []gjson.Result{
		{Type: gjson.JSON,
			Raw: fmt.Sprintf("[%s]", string(working[:]))},
		{Type: gjson.JSON,
			Raw: string(working[:])},
		{Type: gjson.JSON,
			Raw: string(working[:])},
		{Type: gjson.JSON,
			Raw: string(working[:])},
	}

	gcp := GCP{
		Runf: func(t testing.TB, cmd string, args ...interface{}) gjson.Result {
			resp := runfCalls[callCount]
			callCount = callCount + 1
			return resp
		},
		sleepTime: 1,
	}

	err = gcp.WaitBuildSuccess(t, "prj-b-cicd-0123", "us-central1", "repo","", "failed_test_for_WaitBuildSuccess", 1)
	assert.Error(t, err, "should have failed")
	assert.Contains(t, err.Error(), "timeout waiting for build '736f4689-2497-4382-afd0-b5f0f50eea5b' execution", "should have failed with timeout error")
	assert.Equal(t, callCount, 3, "Runf must be called three times")
}
