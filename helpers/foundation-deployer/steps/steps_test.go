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

package steps

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestProcessSteps(t *testing.T) {
	// Loading an existing file
	e, err := LoadSteps("./testdata/existing.json")
	assert.NoError(t, err)
	assert.True(t, e.IsStepComplete("test"), "check if 'test' is 'COMPLETED' should be true")
	assert.False(t, e.IsStepComplete("unit"), "check if 'unit' is 'COMPLETED' should be false")

	// Loading a new file
	s, err := LoadSteps(filepath.Join(t.TempDir(), "new.json"))
	assert.NoError(t, err)

	// CompleteStep
	assert.False(t, s.IsStepComplete("unit"), "check if 'unit' is 'COMPLETED' should be false")
	err = s.CompleteStep("unit")
	assert.NoError(t, err)
	assert.True(t, s.IsStepComplete("unit"), "check if 'unit' is 'COMPLETED' should be true")

	// FailStep
	msg := "step failed"
	err = s.FailStep("fail", msg)
	assert.NoError(t, err)
	assert.False(t, s.IsStepComplete("fail"), "check if 'fail' is 'COMPLETED' should be false")
	assert.Equal(t, s.GetStepError("fail"), msg, "step should have failed")

	// DestroyStep
	assert.False(t, s.IsStepDestroyed("old"), "check if 'old' is 'DESTROYED' should be false")
	err = s.DestroyStep("old")
	assert.NoError(t, err)
	assert.True(t, s.IsStepDestroyed("old"), "check if 'old' is 'DESTROYED' should be true")

	// ResetStep
	err = s.CompleteStep("reset")
	assert.NoError(t, err)
	err = s.CompleteStep("reset.one")
	assert.NoError(t, err)
	assert.True(t, s.IsStepComplete("reset"), "check if 'reset is 'COMPLETED' should be true")
	assert.True(t, s.IsStepComplete("reset.one"), "check if 'reset.one' is 'COMPLETED' should be true")

	err = s.ResetStep("reset.one")
	assert.NoError(t, err)

	assert.False(t, s.IsStepComplete("reset.one"), "check if 'reset.one' is 'COMPLETED' should be false")
	assert.False(t, s.IsStepComplete("reset"), "check if 'reset' is 'COMPLETED' should be false")

	// RunStep
	assert.False(t, s.IsStepComplete("good"), "check if 'good' is 'COMPLETED' should be false")
	err = s.RunStep("good", func() error {
		return nil
	})
	assert.NoError(t, err)
	assert.True(t, s.IsStepComplete("good"), "check if 'good' is 'COMPLETED' should be true")

	badStepMsg := "bad step"
	assert.False(t, s.IsStepComplete("bad"), "check if 'bad' is 'COMPLETED' should be false")
	err = s.RunStep("bad", func() error {
		return fmt.Errorf(badStepMsg)
	})
	assert.Error(t, err)
	assert.False(t, s.IsStepComplete("bad"), "check if 'bad' is 'COMPLETED' should be false")
	assert.Equal(t, s.GetStepError("bad"), badStepMsg, "step 'bad' should have failed")

	// complete states are not executed again
	assert.True(t, s.IsStepComplete("good"), "check if 'good' is 'COMPLETED' should be true")
	err = s.RunStep("good", func() error {
		return fmt.Errorf("will fail if executed")
	})
	assert.NoError(t, err)
	assert.True(t, s.IsStepComplete("good"), "check if 'good' is 'COMPLETED' should be true")

	// RunDestroyStep
	assert.False(t, s.IsStepDestroyed("unit"), "check if 'unit' is 'DESTROYED' should be false")
	err = s.RunDestroyStep("unit", func() error {
		return nil
	})
	assert.NoError(t, err)
	assert.True(t, s.IsStepDestroyed("unit"), "check if 'unit' is 'DESTROYED' should be true")

	err = s.CompleteStep("destroy")
	assert.NoError(t, err)
	assert.False(t, s.IsStepDestroyed("destroy"), "check if 'destroy' is 'DESTROYED' should be false")
	err = s.RunDestroyStep("destroy", func() error {
		return fmt.Errorf(badStepMsg)
	})
	assert.Error(t, err)
	assert.False(t, s.IsStepDestroyed("destroy"), "check if 'destroy' is 'DESTROYED' should be false")
	assert.Equal(t, s.GetStepError("destroy"), badStepMsg, "step 'destroy' should have failed")

	err = s.DestroyStep("gone")
	assert.NoError(t, err)
	assert.True(t, s.IsStepDestroyed("gone"), "check if 'gone' is 'DESTROYED' should be true")
	err = s.RunDestroyStep("gone", func() error {
		return fmt.Errorf("will fail if executed")
	})
	assert.NoError(t, err)
	assert.True(t, s.IsStepDestroyed("gone"), "check if 'gone' is 'DESTROYED' should be true")

	// ListSteps
	expectedSteps := []string{
		"bad FAILED error:bad step",
		"destroy FAILED error:bad step",
		"fail FAILED error:step failed",
		"gone DESTROYED",
		"good COMPLETED",
		"old DESTROYED",
		"reset PENDING",
		"reset.one PENDING",
		"unit DESTROYED",
	}
	assert.ElementsMatch(t, expectedSteps, s.ListSteps())
}
