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
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const kpt = __importStar(require("kpt-functions"));
const path = __importStar(require("path"));
const io_k8s_api_core_v1_1 = require("./gen/io.k8s.api.core.v1");
const get_policy_bundle_1 = require("./get_policy_bundle");
const kpt_functions_1 = require("kpt-functions");
const FORSETI_BUNDLE = "forseti-security";
const RUNNER = new kpt_functions_1.TestRunner(get_policy_bundle_1.getPolicyBundle);
const SOURCE_SAMPLES_FILE = path.resolve(__dirname, "..", "test-data", "policy-bundle", "source", "samples.yaml");
const SINK_SAMPLES_FILE = path.resolve(__dirname, "..", "test-data", "policy-bundle", "sink", "samples.yaml");
describe("getPolicyBundle", () => {
    const functionConfig = io_k8s_api_core_v1_1.ConfigMap.named("config");
    beforeEach(() => {
        functionConfig.data = {};
    });
    it("replicates test dir", () => __awaiter(void 0, void 0, void 0, function* () {
        const input = yield readTestConfigs(SOURCE_SAMPLES_FILE);
        functionConfig.data[get_policy_bundle_1.ANNOTATION_NAME] = FORSETI_BUNDLE;
        const configs = new kpt.Configs(input.getAll(), functionConfig);
        const expectedConfigs = yield readTestConfigs(SINK_SAMPLES_FILE);
        yield get_policy_bundle_1.getPolicyBundle(configs);
        yield RUNNER.assert(configs, expectedConfigs);
    }));
});
function readTestConfigs(file) {
    return kpt.readConfigs(file, kpt.FileFormat.YAML);
}
//# sourceMappingURL=get_policy_bundle_test.js.map