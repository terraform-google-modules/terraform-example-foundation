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

package gitlab

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/mitchellh/go-testing-interface"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"

	gitlab "gitlab.com/gitlab-org/api/client-go"
)

const (
	StatusCreated            = "created"
	StatusManual             = "manual"
	StatusPending            = "pending"
	StatusPreparing          = "preparing"
	StatusSkipped            = "skipped"
	StatusWaitingForResource = "waiting_for_resource"
	StatusScheduled          = "scheduled"
	StatusRunning            = "running"
	StatusSuccess            = "success"
	StatusFailed             = "failed"
	StatusCancelled          = "canceled"
	StatusCanceling          = "canceling"
)

type GL struct {
	TriggerNewBuild func(t testing.TB, ctx context.Context, owner, project, token string, jobID int) (int, error)
	sleepTime       time.Duration
}

// NewGL creates a new GitLab wrapper for The GitLab API
func NewGL() GL {
	return GL{
		TriggerNewBuild: triggerNewBuild,
		sleepTime:       20,
	}
}

// triggerNewBuild triggers a new job execution
func triggerNewBuild(t testing.TB, ctx context.Context, owner, project, token string, jobID int) (int, error) {

	git, err := gitlab.NewClient(token)
	if err != nil {
		return 0, fmt.Errorf("failed to create client: %v", err)
	}

	job, resp, err := git.Jobs.RetryJob(fmt.Sprintf("%s/%s", owner, project), jobID, gitlab.WithContext(ctx))
	if err != nil {
		return 0, fmt.Errorf("error retrying job: %v", err)
	}
	if resp.StatusCode >= http.StatusBadRequest && resp.StatusCode <= http.StatusNetworkAuthenticationRequired {
		bodyBytes, err := io.ReadAll(resp.Body)
		if err != nil {
			return 0, fmt.Errorf("error Status: %d, failed to read response body: %v", resp.StatusCode, err)
		}
		return 0, fmt.Errorf("error Status: %d\n body: %s", resp.StatusCode, string(bodyBytes))
	}
	return job.ID, nil
}

// GetLastJobStatus returns the status of the latest executed job
func (g GL) GetLastJobStatus(t testing.TB, ctx context.Context, owner, project, token string) (string, int, error) {
	git, err := gitlab.NewClient(token)
	if err != nil {
		return "", 0, fmt.Errorf("failed to create client: %v", err)
	}

	includeRetried := true
	opts := &gitlab.ListJobsOptions{
		ListOptions: gitlab.ListOptions{
			PerPage: 1,
			Page:    1,
			OrderBy: "id",
			Sort:    "desc",
		},
		IncludeRetried: &includeRetried,
	}

	jobs, _, err := git.Jobs.ListProjectJobs(fmt.Sprintf("%s/%s", owner, project), opts, gitlab.WithContext(ctx))
	if err != nil {
		return "", 0, fmt.Errorf("error listing project jobs: %v", err)
	}

	if len(jobs) == 0 {
		return "", 0, fmt.Errorf("no jobs found for project: %s/%s", owner, project)
	}

	return jobs[0].Status, jobs[0].ID, nil
}

// GetJobLogs returns the execution logs of a given job
func (g GL) GetJobLogs(t testing.TB, ctx context.Context, owner, project, token string, jobID int) (string, error) {
	git, err := gitlab.NewClient(token)
	if err != nil {
		return "", fmt.Errorf("failed to create client: %v", err)
	}

	reader, resp, err := git.Jobs.GetTraceFile(fmt.Sprintf("%s/%s", owner, project), jobID)
	if err != nil {
		return "", fmt.Errorf("error getting job trace file: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("expected status 200 OK, but got %s for job %d trace", resp.Status, jobID)
	}

	logBytes, err := io.ReadAll(reader)
	if err != nil {
		return "", fmt.Errorf("failed to read job %d trace from bytes.Reader: %v", jobID, err)
	}

	return string(logBytes), nil
}

// GetJobStatus returns the status of a given gob
func (g GL) GetJobStatus(t testing.TB, ctx context.Context, owner, project, token string, jobID int) (string, error) {
	git, err := gitlab.NewClient(token)
	if err != nil {
		return "", fmt.Errorf("failed to create client: %v", err)
	}

	job, _, err := git.Jobs.GetJob(fmt.Sprintf("%s/%s", owner, project), jobID, gitlab.WithContext(ctx))
	if err != nil {
		return "", fmt.Errorf("error retrying job: %v", err)
	}

	return job.Status, nil
}

// GetFinalJobStatus return the final state of a running job
func (g GL) GetFinalJobStatus(t testing.TB, ctx context.Context, owner, project, token string, jobID int, maxBuildRetry int) (string, error) {
	var status string
	var err error
	count := 0
	fmt.Printf("waiting for job %d execution.\n", jobID)

	status, err = g.GetJobStatus(t, ctx, owner, project, token, jobID)
	if err != nil {
		return "", err
	}
	fmt.Printf("job status is %s\n", status)
	for status != StatusSuccess && status != StatusFailed && status != StatusCancelled {
		fmt.Printf("job status is %s\n", status)
		if count >= maxBuildRetry {
			return "", fmt.Errorf("timeout waiting for job '%d' execution", jobID)
		}
		count = count + 1
		time.Sleep(g.sleepTime * time.Second)
		status, err = g.GetJobStatus(t, ctx, owner, project, token, jobID)
		if err != nil {
			return "", err
		}
	}
	fmt.Printf("final job state is %s\n", status)
	return status, nil
}

// WaitBuildSuccess waits for the current job in a project to finish.
func (g GL) WaitBuildSuccess(t testing.TB, owner, project, token, failureMsg string, maxBuildRetry, maxErrorRetries int, timeBetweenErrorRetries time.Duration) error {
	var status string
	var jobID int
	var err error

	ctx := context.Background()
	// wait job creation
	time.Sleep(30 * time.Second)

	status, jobID, err = g.GetLastJobStatus(t, ctx, owner, project, token)
	if err != nil {
		return err
	}
	for i := 0; i < maxErrorRetries; i++ {
		if status != StatusSuccess && status != StatusFailed && status != StatusCancelled {
			status, err = g.GetFinalJobStatus(t, ctx, owner, project, token, jobID, maxBuildRetry)
			if err != nil {
				return err
			}
		}

		if status != StatusSuccess {
			logs, err := g.GetJobLogs(t, ctx, owner, project, token, jobID)
			if err != nil {
				return err
			}
			if utils.IsRetryableError(t, logs) {
				return fmt.Errorf("%s\nSee:\nhttps://gitlab.com/%s/%s/-/jobs/%d\nfor details", failureMsg, owner, project, jobID)
			}
			fmt.Println("job failed with retryable error. a new job will be triggered.")
		} else {
			return nil // job succeeded
		}

		// Trigger a new build
		jobID, err = g.TriggerNewBuild(t, ctx, owner, project, token, jobID)
		if err != nil {
			return fmt.Errorf("failed to trigger new job (attempt %d/%d): %w", i+1, maxErrorRetries, err)
		}
		fmt.Printf("triggered new job with ID: %d (attempt %d/%d)\n", jobID, i+1, maxErrorRetries)
		if i < maxErrorRetries-1 {
			time.Sleep(timeBetweenErrorRetries) // Wait before retrying
		}
	}
	return fmt.Errorf("%s job failed after %d retries", failureMsg, maxErrorRetries)
}

// AddProjectsToJobTokenScope adds a list of projects to the token scope of a project that host the runner image
func (g GL) AddProjectsToJobTokenScope(t testing.TB, owner, cicdProject, token string, repos []string) error {
	ctx := context.Background()
	git, err := gitlab.NewClient(token)
	if err != nil {
		return fmt.Errorf("failed to create client: %v", err)
	}
	runnerProjectPath := fmt.Sprintf("%s/%s", owner, cicdProject)

	projectsToAdd := make([]string, len(repos))
	for i, repo := range repos {
		projectsToAdd[i] = fmt.Sprintf("%s/%s", owner, repo)
	}

	runnerProjectID, err := getProjectIDByPath(git, ctx, runnerProjectPath)
	if err != nil {
		return fmt.Errorf("could not get the project ID for the runner repository. Aborting. Error: %v", err)
	}
	for _, targetProjectPath := range projectsToAdd {

		targetProjectID, err := getProjectIDByPath(git, ctx, targetProjectPath)
		if err != nil {
			return fmt.Errorf("could not find project ID. Error: %v", err)
		}

		opts := &gitlab.JobTokenInboundAllowOptions{
			TargetProjectID: &targetProjectID,
		}

		_, resp, err := git.JobTokenScope.AddProjectToJobScopeAllowList(runnerProjectID, opts, gitlab.WithContext(ctx))
		if err != nil {
			// GitLab often returns a 409 Conflict if the project is already in the list.
			if resp != nil && resp.StatusCode != http.StatusConflict {
				return fmt.Errorf("failed to add project. Status: %s. Error: %v", resp.Status, err)
			}
			continue
		}

		if resp.StatusCode != http.StatusCreated {
			return fmt.Errorf("done (Status: %s)", resp.Status)
		}
	}

	return nil
}

// getProjectIDByPath returns the ID or a project given its path
func getProjectIDByPath(git *gitlab.Client, ctx context.Context, projectPath string) (int, error) {
	project, _, err := git.Projects.GetProject(projectPath, nil, gitlab.WithContext(ctx))
	if err != nil {
		return 0, fmt.Errorf("failed to get project '%s': %w", projectPath, err)
	}
	return project.ID, nil
}
