// Copyright 2024 Google LLC
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

package stages

var (
	DefaultDeployEnvironments  = []string{"production", "nonproduction", "development"}
	DefaultDestroyEnvironments = []string{"development", "nonproduction", "production"}
	SingleDeployEnvironments   = []string{"production"}
)

// GetEnvironments returns the target environments for apply or destroy lifecycles.
// When productionOnlyDeploy is true, it returns SingleDeployEnvironments (production).
// Otherwise, it returns DefaultDestroyEnvironments in reverse order when isDestroy is true,
// or DefaultDeployEnvironments when isDestroy is false.
func GetEnvironments(productionOnlyDeploy bool, isDestroy bool) []string {
	if productionOnlyDeploy {
		return SingleDeployEnvironments
	}
	if isDestroy {
		return DefaultDestroyEnvironments
	}
	return DefaultDeployEnvironments
}

func getEnvironments(tfvars GlobalTFVars) []string {
	isProdOnly := tfvars.ProductionOnlyDeploy != nil && *tfvars.ProductionOnlyDeploy
	return GetEnvironments(isProdOnly, false)
}

func getDestroyEnvironments(c CommonConf) []string {
	return GetEnvironments(c.ProductionOnlyDeploy, true)
}
