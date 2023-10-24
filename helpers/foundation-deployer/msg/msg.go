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

package msg

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

const (
	size            = 70
	readmeURL       = "https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/%s/README.md"
	cloudBuildURL   = "https://console.cloud.google.com/cloud-build/builds;region=%s?project=%s"
	buildErrorURL   = "https://console.cloud.google.com/cloud-build/builds;region=%s/%s?project=%s"
	quotaURL        = "https://support.google.com/code/contact/billing_quota_increase"
	troubleQuotaURL = "https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/TROUBLESHOOTING.md#billing-quota-exceeded"
	groupAdminURL   = "https://cloud.google.com/identity/docs/how-to/setup#assigning_an_admin_role_to_the_service_account"
)

var (
	bar = strings.Repeat("#", size)
)

func PressEnter(msg string) {
	reader := bufio.NewReader(os.Stdin)
	t := "# Press Enter to continue"
	if msg != "" {
		t = msg
	}
	fmt.Print(t)
	_, err := reader.ReadString('\n')
	if err != nil {
		fmt.Printf("# Failed to read string. Error: %s\n", err.Error())
		os.Exit(3)
	}
}

func pad(msg string, size int) string {
	return fmt.Sprintf("%*s", ((size + len(msg)) / 2), msg)
}

func CloudBuildURL(project, region string) string {
	return fmt.Sprintf(cloudBuildURL, region, project)
}

func BuildErrorURL(project, region, build string) string {
	return fmt.Sprintf(buildErrorURL, region, build, project)
}

func PrintStageMsg(msg string) {
	fmt.Println("")
	fmt.Println(bar)
	fmt.Println(pad(msg, size))
	fmt.Println(bar)
	fmt.Println("")
}

func PrintBuildMsg(project, region string, disablePrompt bool) {
	fmt.Println("")
	fmt.Println("# Follow build execution and check build results in the Google console:")
	fmt.Printf("# %s\n", CloudBuildURL(project, region))
	if !disablePrompt {
		PressEnter("# Press Enter to continue at any time")
		fmt.Println("")
	}
}

func PrintQuotaMsg(sa string, disablePrompt bool) {
	fmt.Println("")
	fmt.Println("# Request a billing quota increase for the service account of stage 4-projects")
	fmt.Printf("# %s \n", sa)
	fmt.Printf("# Link: %s\n", quotaURL)
	fmt.Println("")
	fmt.Printf("# See: %s\n", troubleQuotaURL)
	fmt.Println("# for additional information")
	fmt.Println("")
	if !disablePrompt {
		PressEnter("")
		fmt.Println("")
	}
}

func PrintAdminGroupPermissionMsg(sa string, disablePrompt bool) {
	fmt.Println("")
	fmt.Println("# Request a Super Admin to Grant 'Group Admin' role in the")
	fmt.Println("# Admin Console of the Google Workspace to the Bootstrap service account:")
	fmt.Printf("# %s \n", sa)
	fmt.Println("")
	fmt.Printf("# See: %s\n", groupAdminURL)
	fmt.Println("# for additional information")
	fmt.Println("")
	if !disablePrompt {
		PressEnter("")
		fmt.Println("")
	}
}

func ConfirmQuota(sa string, disablePrompt bool) {
	fmt.Println("")
	fmt.Println("# Proceed if you received confirmation of billing quota increase for the service account of stage 4-projects")
	fmt.Printf("# %s \n", sa)
	fmt.Printf("# Quota increase link is: %s\n", quotaURL)
	fmt.Println("")
	if !disablePrompt {
		PressEnter("")
		fmt.Println("")
	}
}
