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
const fs = __importStar(require("fs-extra"));
const kpt = __importStar(require("kpt-functions"));
const os = __importStar(require("os"));
const path = __importStar(require("path"));
const io_k8s_api_core_v1_1 = require("./gen/io.k8s.api.core.v1");
const generate_docs_1 = require("./generate_docs");
const SOURCE_DIR = path.resolve(__dirname, "..", "test-data", "generate-docs", "source");
const SOURCE_SAMPLES_FILE = path.resolve(SOURCE_DIR, "samples_templates.yaml");
describe("generateDocs", () => {
    let tmpDir = "";
    const functionConfig = io_k8s_api_core_v1_1.ConfigMap.named("config");
    let sinkDir = "";
    beforeEach(() => {
        // Ensures tmpDir is unset before testing. Detects incorrectly running tests in parallel, or
        // tests not cleaning up properly.
        expect(tmpDir).toEqual("");
        tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "generate-docs-test"));
        functionConfig.data = {};
        // Get sample configs
        sinkDir = path.resolve(tmpDir, "foo");
        functionConfig.data[generate_docs_1.OVERWRITE] = "true";
        functionConfig.data[generate_docs_1.SINK_DIR] = sinkDir;
    });
    afterEach(() => {
        // Remove tmpDir so no other tests can have access to the data.
        fs.removeSync(tmpDir);
        // Reset tmpDir value to confirm test finished normally.
        tmpDir = "";
    });
    it("generates index.md", () => __awaiter(void 0, void 0, void 0, function* () {
        const input = yield getSampleConfigs();
        const configs = new kpt.Configs(input.getAll(), functionConfig);
        const expectedFile = path.resolve(sinkDir, "index.md");
        yield generate_docs_1.generateDocs(configs);
        expect(fs.existsSync(expectedFile)).toEqual(true);
    }));
    it("generates cis-v1.0 bundle docs", () => __awaiter(void 0, void 0, void 0, function* () {
        const input = yield getSampleConfigs();
        const configs = new kpt.Configs(input.getAll(), functionConfig);
        const expectedFile = path.resolve(sinkDir, generate_docs_1.BUNDLE_DIR, "cis-v1.0.md");
        yield generate_docs_1.generateDocs(configs);
        expect(fs.existsSync(expectedFile)).toEqual(true);
    }));
    it("generates cis-v1.1 bundle docs", () => __awaiter(void 0, void 0, void 0, function* () {
        const input = yield getSampleConfigs();
        const configs = new kpt.Configs(input.getAll(), functionConfig);
        const expectedFile = path.resolve(sinkDir, generate_docs_1.BUNDLE_DIR, "cis-v1.1.md");
        yield generate_docs_1.generateDocs(configs);
        expect(fs.existsSync(expectedFile)).toEqual(true);
    }));
});
function getSampleConfigs() {
    return kpt.readConfigs(SOURCE_SAMPLES_FILE, kpt.FileFormat.YAML);
}
//# sourceMappingURL=generate_docs_test.js.map