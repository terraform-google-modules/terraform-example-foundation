// Copyright 2025 Google LLC
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

package github

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"github.com/google/go-github/v58/github"
	"github.com/mitchellh/go-testing-interface"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"

	"golang.org/x/oauth2"
)

const (
	StatusQueued         = "queued"
	StatusPending        = "pending"
	StatusWaiting        = "waiting"
	StatusWorking        = "in_progress"
	statusCompleted      = "completed"
	StatusSuccess        = "success"
	StatusFailure        = "failure"
	StatusCancelled      = "cancelled"
	StatusTimeout        = "timed_out"
	StatusNeutral        = "neutral"
	StatusSkipped        = "skipped"
	StatusActionRequired = "action_required"
)

type GH struct {
	TriggerNewBuild func(t testing.TB, ctx context.Context, owner, repo, token, commitSha string, runID int64) (int64, string, string, error)
	sleepTime       time.Duration
}

// NewGH creates a new wrapper for The GitHub API
func NewGH() GH {
	return GH{
		TriggerNewBuild: triggerNewBuild,
		sleepTime:       20,
	}
}

// triggerNewBuild triggers a new action execution
func triggerNewBuild(t testing.TB, ctx context.Context, owner, repo, token, commitSha string, runID int64) (int64, string, string, error) {
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	resp, err := client.Actions.RerunWorkflowByID(ctx, owner, repo, runID)
	if err != nil {
		return 0, "", "", fmt.Errorf("error re-running workflow: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		bodyBytes, err := io.ReadAll(resp.Body)
		if err != nil {
			return 0, "", "", fmt.Errorf("error re-running workflow status: %d body parsing error: %v", resp.StatusCode, err)
		}
		return 0, "", "", fmt.Errorf("error re-running workflow status: %d body: %s", resp.StatusCode, string(bodyBytes))
	}

	opts := &github.ListWorkflowRunsOptions{
		HeadSHA: commitSha,
		ListOptions: github.ListOptions{
			PerPage: 1,
			Page:    1,
		},
	}

	// wait action creation
	time.Sleep(30 * time.Second)

	runs, _, err := client.Actions.ListRepositoryWorkflowRuns(ctx, owner, repo, opts)

	if err != nil {
		return 0, "", "", fmt.Errorf("error listing workflow runs: %v", err)
	}

	if len(runs.WorkflowRuns) == 0 {
		return 0, "", "", fmt.Errorf("no workflow runs found for repo %s/%s", owner, repo)
	}

	var newRunID int64
	if runs.WorkflowRuns[0].ID != nil {
		newRunID = *runs.WorkflowRuns[0].ID
	}

	var status string
	if runs.WorkflowRuns[0].Status != nil {
		status = *runs.WorkflowRuns[0].Status
	}

	var conclusion string
	if runs.WorkflowRuns[0].Conclusion != nil {
		conclusion = *runs.WorkflowRuns[0].Conclusion
	}

	return newRunID, status, conclusion, nil
}

// GetLastActionState returns the state of the latest action
func (g GH) GetLastActionState(t testing.TB, ctx context.Context, owner, repo, token, commitSha string) (int64, string, string, error) {
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	opts := &github.ListWorkflowRunsOptions{
		HeadSHA: commitSha,
		ListOptions: github.ListOptions{
			PerPage: 1,
		},
	}

	runs, _, err := client.Actions.ListRepositoryWorkflowRuns(ctx, owner, repo, opts)

	if err != nil {
		return 0, "", "", fmt.Errorf("error listing workflow runs: %v", err)
	}

	if len(runs.WorkflowRuns) == 0 {
		return 0, "", "", fmt.Errorf("no action workflow found for repo: %s/%s", owner, repo)
	}

	var runID int64
	var status string
	var conclusion string

	if runs.WorkflowRuns[0].ID != nil {
		runID = *runs.WorkflowRuns[0].ID
	}
	if runs.WorkflowRuns[0].Status != nil {
		status = *runs.WorkflowRuns[0].Status
	}
	if runs.WorkflowRuns[0].Conclusion != nil {
		conclusion = *runs.WorkflowRuns[0].Conclusion
	}

	return runID, status, conclusion, nil
}

// GetActionState returns the state of a given action
func (g GH) GetActionState(t testing.TB, ctx context.Context, owner, repo, token string, runID int64) (string, string, error) {
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	run, _, err := client.Actions.GetWorkflowRunByID(ctx, owner, repo, runID)
	if err != nil {
		return "", "", fmt.Errorf("error getting workflow run: %v", err)
	}

	var status string
	if run.Status != nil {
		status = *run.Status
	}

	var conclusion string
	if run.Conclusion != nil {
		conclusion = *run.Conclusion
	}
	return status, conclusion, nil
}

// GetBuildLogs returns the execution logs of an action
func (g GH) GetBuildLogs(t testing.TB, ctx context.Context, owner, repo, token string, runID int64) (string, error) {
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	listJobsOpts := &github.ListWorkflowJobsOptions{
		ListOptions: github.ListOptions{PerPage: 10},
	}
	jobs, _, err := client.Actions.ListWorkflowJobs(ctx, owner, repo, runID, listJobsOpts)
	if err != nil {
		return "", fmt.Errorf("error listing jobs for run %d: %v", runID, err)
	}

	for _, job := range jobs.Jobs {
		if job.Status == nil || job.Conclusion == nil {
			continue
		}

		if *job.Status == statusCompleted && *job.Conclusion == StatusFailure {
			jobID := *job.ID

			logURL, resp, err := client.Actions.GetWorkflowJobLogs(ctx, owner, repo, jobID, 3)
			if err != nil {
				return "", fmt.Errorf("error: Could not get log URL for job %d: %v", jobID, err)
			}
			if resp.StatusCode != http.StatusFound {
				return "", fmt.Errorf("error: Expected a 302 redirect for job logs, but got %s", resp.Status)
			}

			logContentResp, err := http.Get(logURL.String())
			if err != nil {
				return "", fmt.Errorf("error: Could not download logs from %s: %v", logURL, err)
			}

			defer func() {
				err := logContentResp.Body.Close()
				if err != nil {
					fmt.Fprintf(os.Stderr, "error closing execution log file: %s", err)
				}
			}()

			if logContentResp.StatusCode != http.StatusOK {
				return "", fmt.Errorf("error: Expected status 200 OK from log URL, but got %s", logContentResp.Status)
			}

			bodyBytes, err := io.ReadAll(logContentResp.Body)
			if err != nil {
				return "", fmt.Errorf("error reading response body: %v", err)
			}
			return string(bodyBytes), nil
		}
	}
	return "", nil
}

// GetFinalActionState returns the final state of an action
func (g GH) GetFinalActionState(t testing.TB, ctx context.Context, owner, repo, token string, runID int64, maxBuildRetry int) (string, string, error) {
	var status, conclusion string
	var err error
	count := 0
	fmt.Printf("waiting for action %d execution.\n", runID)
	status, conclusion, err = g.GetActionState(t, ctx, owner, repo, token, runID)
	if err != nil {
		return "", "", err
	}
	fmt.Printf("action status is %s\n", status)
	for status != statusCompleted {
		fmt.Printf("action status is %s\n", status)
		if count >= maxBuildRetry {
			return "", "", fmt.Errorf("timeout waiting for action '%d' execution", runID)
		}
		count = count + 1
		time.Sleep(g.sleepTime * time.Second)
		status, conclusion, err = g.GetActionState(t, ctx, owner, repo, token, runID)
		if err != nil {
			return "", "", err
		}
	}
	fmt.Printf("final action state is %s\n", conclusion)
	return status, conclusion, nil
}

// WaitBuildSuccess waits for the current build in a repo to finish.
func (g GH) WaitBuildSuccess(t testing.TB, owner, repo, token, commitSha, failureMsg string, maxBuildRetry, maxErrorRetries int, timeBetweenErrorRetries time.Duration) error {
	var status, conclusion string
	var runID int64
	var err error

	ctx := context.Background()
	// wait action creation
	time.Sleep(30 * time.Second)

	runID, status, conclusion, err = g.GetLastActionState(t, ctx, owner, repo, token, commitSha)
	if err != nil {
		return err
	}
	for i := 0; i < maxErrorRetries; i++ {
		if status != statusCompleted {
			_, conclusion, err = g.GetFinalActionState(t, ctx, owner, repo, token, runID, maxBuildRetry)
			if err != nil {
				return err
			}
		}

		if conclusion != StatusSuccess {
			logs, err := g.GetBuildLogs(t, ctx, owner, repo, token, runID)
			if err != nil {
				return err
			}
			if utils.IsRetryableError(t, logs) {
				return fmt.Errorf("%s\nSee:\nhttps://github.com/%s/%s/actions/runs/%d\nfor details", failureMsg, owner, repo, runID)
			}
			fmt.Println("build failed with retryable error. a new build will be triggered.")
		} else {
			return nil // Build succeeded
		}

		// Trigger a new build
		runID, status, conclusion, err = g.TriggerNewBuild(t, ctx, owner, repo, token, commitSha, runID)
		if err != nil {
			return fmt.Errorf("failed to trigger new action (attempt %d/%d): %w", i+1, maxErrorRetries, err)
		}
		fmt.Printf("triggered new action with ID: %d (attempt %d/%d)\n", runID, i+1, maxErrorRetries)
		if i < maxErrorRetries-1 {
			time.Sleep(timeBetweenErrorRetries) // Wait before retrying
		}
	}
	return fmt.Errorf("%s action failed after %d retries", failureMsg, maxErrorRetries)
}
