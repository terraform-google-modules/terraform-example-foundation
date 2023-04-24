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
	"strings"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/mitchellh/go-testing-interface"
	"github.com/tidwall/gjson"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

const (
	StatusQueued    = "QUEUED"
	StatusWorking   = "WORKING"
	StatusSuccess   = "SUCCESS"
	StatusFailure   = "FAILURE"
	StatusCancelled = "CANCELLED"
)

type GCP struct {
	Runf      func(t testing.TB, cmd string, args ...interface{}) gjson.Result
	sleepTime time.Duration
}

// NewGCP creates a new wrapper for Google Cloud Platform CLI.
func NewGCP() GCP {
	return GCP{
		Runf:      gcloud.Runf,
		sleepTime: 20,
	}
}

// GetBuilds gets all Cloud Build builds form a project and region that satisfy the given filter.
func (g GCP) GetBuilds(t testing.TB, projectID, region, filter string) map[string]string {
	var result = map[string]string{}
	builds := g.Runf(t, "builds list --project %s --region %s --filter %s", projectID, region, filter).Array()
	if len(builds) > 0 {
		for _, b := range builds {
			result[b.Get("id").String()] = b.Get("status").String()
		}
	}
	return result
}

// GetLastBuildStatus gets the status of the last build form a project and region that satisfy the given filter.
func (g GCP) GetLastBuildStatus(t testing.TB, projectID, region, filter string) string {
	return g.Runf(t, "builds list --project %s --region %s --limit 1 --sort-by ~createTime --filter %s", projectID, region, filter).Array()[0].Get("status").String()
}

// GetBuildStatus gets the status of the given build
func (g GCP) GetBuildStatus(t testing.TB, projectID, region, buildID string) string {
	return g.Runf(t, "builds describe %s  --project %s --region %s", buildID, projectID, region).Get("status").String()
}

// GetRunningBuildID gets the current build running for the given project, region, and filter
func (g GCP) GetRunningBuildID(t testing.TB, projectID, region, filter string) string {
	time.Sleep(g.sleepTime * time.Second)
	builds := g.GetBuilds(t, projectID, region, filter)
	for id, status := range builds {
		if status == StatusQueued || status == StatusWorking {
			return id
		}
	}
	return ""
}

// GetFinalBuildState gets the terminal status of the given build. It will wait if build is not finished.
func (g GCP) GetFinalBuildState(t testing.TB, projectID, region, buildID string, maxRetry int) (string, error) {
	var status string
	count := 0
	fmt.Printf("waiting for build %s execution.\n", buildID)
	status = g.GetBuildStatus(t, projectID, region, buildID)
	fmt.Printf("build status is %s\n", status)
	for status != StatusSuccess && status != StatusFailure && status != StatusCancelled {
		fmt.Printf("build status is %s\n", status)
		if count >= maxRetry {
			return "", fmt.Errorf("timeout waiting for build '%s' execution", buildID)
		}
		count = count + 1
		time.Sleep(g.sleepTime * time.Second)
		status = g.GetBuildStatus(t, projectID, region, buildID)
	}
	fmt.Printf("final build status is %s\n", status)
	return status, nil
}

// WaitBuildSuccess waits for the current build in a repo to finish.
func (g GCP) WaitBuildSuccess(t testing.TB, project, region, repo, commitSha, failureMsg string, maxRetry int) error {
	var filter string
	if commitSha == "" {
		filter = fmt.Sprintf("source.repoSource.repoName:%s", repo)
	} else {
		filter = fmt.Sprintf("source.repoSource.commitSha:%s", commitSha)
	}
	build := g.GetRunningBuildID(t, project, region, filter)
	if build != "" {
		status, err := g.GetFinalBuildState(t, project, region, build, maxRetry)
		if err != nil {
			return err
		}
		if status != StatusSuccess {
			return fmt.Errorf("%s\nSee:\nhttps://console.cloud.google.com/cloud-build/builds;region=%s/%s?project=%s\nfor details.\n", failureMsg, region, build, project)
		}
	} else {
		status := g.GetLastBuildStatus(t, project, region, filter)
		if status != StatusSuccess {
			return fmt.Errorf("%s\nSee:\nhttps://console.cloud.google.com/cloud-build/builds;region=%s/%s?project=%s\nfor details.\n", failureMsg, region, build, project)
		}
	}
	return nil
}

// HasSccNotification checks if a Security Command Center notification exists
func (g GCP) HasSccNotification(t testing.TB, orgID, sccName string) bool {
	filter := fmt.Sprintf("name=organizations/%s/notificationConfigs/%s", orgID, sccName)
	scc := g.Runf(t, "scc notifications list organizations/%s --filter %s --quiet", orgID, filter).Array()
	if len(scc) == 0 {
		return false
	}
	return testutils.GetLastSplitElement(scc[0].Get("name").String(), "/") == sccName
}

// HasTagKey  checks if a Tag Key exists
func (g GCP) HasTagKey(t testing.TB, orgID, tag string) bool {
	filter := fmt.Sprintf("shortName=%s", tag)
	tags := g.Runf(t, "resource-manager tags keys list --parent organizations/%s --filter %s ", orgID, filter).Array()
	if len(tags) == 0 {
		return false
	}
	return tags[0].Get("shortName").String() == tag
}

// EnableApis enables the apis in the given project
func (g GCP) EnableApis(t testing.TB, project string, apis []string) {
	g.Runf(t, "services enable %s --project %s", strings.Join(apis, " "), project)
}

// IsApiEnabled checks if the api is enabled in the given project
func (g GCP) IsApiEnabled(t testing.TB, project, api string) bool {
	filter := fmt.Sprintf("config.name=%s", api)
	return len(g.Runf(t, "services list --enabled --project %s --filter %s", project, filter).Array()) > 0
}
