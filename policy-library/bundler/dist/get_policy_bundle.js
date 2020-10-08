"use strict";
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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
exports.ANNOTATION_NAME = "bundle";
function getPolicyBundle(configs) {
    return __awaiter(this, void 0, void 0, function* () {
        // Get the paramters
        const bundleName = configs.getFunctionConfigValueOrThrow(exports.ANNOTATION_NAME);
        // Build the policy library
        const library = new common_1.PolicyLibrary(configs.getAll());
        // Get bundle
        const annotationName = `${common_1.BUNDLE_ANNOTATION_PREFIX}/${bundleName}`;
        const bundle = library.bundles.get(annotationName);
        if (bundle === undefined) {
            throw new Error(`bundle does not exist: ` + annotationName + `.`);
        }
        // Return the bundle
        configs.deleteAll();
        configs.insert(...bundle.configs);
    });
}
exports.getPolicyBundle = getPolicyBundle;
getPolicyBundle.usage = `
Get policy bundle of constraints based on annoation.

Configured using a ConfigMap with the following keys:
${exports.ANNOTATION_NAME}: Name of the policy bundle.
Example:
apiVersion: v1
kind: ConfigMap
data:
  ${exports.ANNOTATION_NAME}: 'bundles.validator.forsetisecurity.org/cis-v1.1'
metadata:
  name: my-config
`;
//# sourceMappingURL=get_policy_bundle.js.map