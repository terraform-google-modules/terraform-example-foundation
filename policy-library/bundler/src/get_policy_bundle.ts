/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Configs } from "kpt-functions";
import { PolicyLibrary, BUNDLE_ANNOTATION_PREFIX } from "./common";

export const ANNOTATION_NAME = "bundle";

export async function getPolicyBundle(configs: Configs) {
  // Get the paramters
  const bundleName = configs.getFunctionConfigValueOrThrow(ANNOTATION_NAME);

  // Build the policy library
  const library = new PolicyLibrary(configs.getAll());

  // Get bundle
  const annotationName = `${BUNDLE_ANNOTATION_PREFIX}/${bundleName}`;
  const bundle = library.bundles.get(annotationName);
  if (bundle === undefined) {
    throw new Error(`bundle does not exist: ` + annotationName + `.`);
  }

  // Return the bundle
  configs.deleteAll();
  configs.insert(...bundle.configs);
}

getPolicyBundle.usage = `
Get policy bundle of constraints based on annoation.

Configured using a ConfigMap with the following keys:
${ANNOTATION_NAME}: Name of the policy bundle.
Example:
apiVersion: v1
kind: ConfigMap
data:
  ${ANNOTATION_NAME}: 'bundles.validator.forsetisecurity.org/cis-v1.1'
metadata:
  name: my-config
`;
