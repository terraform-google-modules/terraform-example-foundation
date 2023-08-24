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
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
)

const (
	completedStatus = "COMPLETED"
	destroyedStatus = "DESTROYED"
	failedStatus    = "FAILED"
	pendingStatus   = "PENDING"
)

type Step struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Error  string `json:"error"`
}

type Steps struct {
	File  string          `json:"file"`
	Steps map[string]Step `json:"steps"`
}

// String creates a string representation of the step
func (s Step) String() string {
	if s.Error == "" {
		return fmt.Sprintf("%s %s", s.Name, s.Status)
	}
	return fmt.Sprintf("%s %s error:%s", s.Name, s.Status, s.Error)
}

// DeleteStepsFile deletes the whole steps file
func DeleteStepsFile(file string) error {
	_, err := os.Stat(file)
	if err != nil && !os.IsNotExist(err) {
		return err
	}
	if !os.IsNotExist(err) {
		return os.Remove(file)
	}
	return nil
}

// LoadSteps loads a previous execution steps from the given file.
func LoadSteps(file string) (Steps, error) {
	var s Steps
	_, err := os.Stat(file)
	if err != nil && !os.IsNotExist(err) {
		return s, err
	}
	if os.IsNotExist(err) {
		fmt.Printf("# creating new steps file '%s'.\n", file)
		s = Steps{
			File: file,
		}
	} else {
		f, err := os.ReadFile(file)
		if err != nil {
			return s, err
		}
		err = json.Unmarshal(f, &s)
		if err != nil {
			return s, err
		}
		s.File = file
	}
	if s.Steps == nil {
		s.Steps = map[string]Step{}
	}
	return s, nil
}

// SaveSteps saves the current execution state of the steps in the file that was loaded.
func (s Steps) SaveSteps() error {
	f, err := json.MarshalIndent(s, "", "    ")
	if err != nil {
		return err
	}
	return os.WriteFile(s.File, f, 0644)
}

// CompleteStep marks a given step as completed.
func (s Steps) CompleteStep(name string) error {
	s.Steps[name] = Step{
		Name:   name,
		Status: completedStatus,
	}
	err := s.SaveSteps()
	if err != nil {
		return err
	}
	fmt.Printf("# completing step '%s' execution\n", name)
	return nil
}

// IsStepComplete checks if the given step is completed.
func (s Steps) IsStepComplete(name string) bool {
	v, ok := s.Steps[name]
	if ok {
		return v.Status == completedStatus
	}
	return false
}

// StepExists checks if the given step exists
func (s Steps) StepExists(name string) bool {
	_, ok := s.Steps[name]
	return ok
}

// FailStep marks a given step as failed and saves the error message.
func (s Steps) FailStep(name string, err string) error {
	s.Steps[name] = Step{
		Name:   name,
		Status: failedStatus,
		Error:  err,
	}
	e := s.SaveSteps()
	if e != nil {
		return e
	}
	return nil
}

func isNested(name string) bool {
	return strings.Contains(name, ".")
}

func parent(name string) string {
	return strings.Split(name, ".")[0]
}

// ResetStep resets the execution status of a given step and its parent.
func (s Steps) ResetStep(name string) error {
	s.Steps[name] = Step{
		Name:   name,
		Status: pendingStatus,
	}
	err := s.SaveSteps()
	if err != nil {
		return err
	}
	fmt.Printf("# resetting step '%s' execution\n", name)
	if isNested(name) {
		return s.ResetStep(parent(name))
	}
	return nil
}

// GetStepError gets the error message save in an step.
func (s Steps) GetStepError(name string) string {
	v, ok := s.Steps[name]
	if ok {
		return v.Error
	}
	return ""
}

// ListSteps lists the executed steps.
func (s Steps) ListSteps() []string {
	l := []string{}
	for _, v := range s.Steps {
		l = append(l, v.String())
	}
	sort.Strings(l)
	return l
}

// RunStep executes a step and marks it as completed or failed.
// Completed steps are not executed again.
func (s Steps) RunStep(step string, f func() error) error {
	if s.IsStepComplete(step) {
		fmt.Printf("# skipping step '%s' execution\n", step)
		return nil
	}
	fmt.Printf("# starting step '%s' execution\n", step)
	err := f()
	if err != nil {
		e := s.FailStep(step, err.Error())
		if e != nil {
			return fmt.Errorf("error on FailStep %v, original error %w", e, err)
		}
		return err
	}
	return s.CompleteStep(step)
}

// IsStepDestroyed checks is the step was destroyed
func (s Steps) IsStepDestroyed(name string) bool {
	v, ok := s.Steps[name]
	if ok {
		return v.Status == destroyedStatus
	}
	return false
}

// DestroyStep destroys the given step
func (s Steps) DestroyStep(name string) error {
	s.Steps[name] = Step{
		Name:   name,
		Status: destroyedStatus,
	}
	err := s.SaveSteps()
	if err != nil {
		return err
	}
	fmt.Printf("# destroying step '%s'\n", name)
	return nil
}

// RunDestroyStep destroys a step and marks it as destroyed or failed.
func (s Steps) RunDestroyStep(step string, f func() error) error {
	if s.IsStepDestroyed(step) || !s.StepExists(step) {
		fmt.Printf("# skipping step '%s' destruction\n", step)
		return nil
	}
	fmt.Printf("# starting step '%s' destruction\n", step)
	err := f()
	if err != nil {
		e := s.FailStep(step, err.Error())
		if e != nil {
			return fmt.Errorf("error on FailStep %v, original error %w", e, err)
		}
		return err
	}
	return s.DestroyStep(step)
}
