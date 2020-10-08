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
const common_1 = require("./common");
const FORSETI_BUNDLE = 'bundles.validator.forsetisecurity.org/forseti-security';
const SOURCE_DIR = path.resolve(__dirname, '..', 'test-data', 'common', 'source');
const SOURCE_INVALID_FILE = path.resolve(SOURCE_DIR, 'invalid.yaml');
const SOURCE_BUNDLE_FILE = path.resolve(SOURCE_DIR, 'bundle.yaml');
const SINK_DIR = path.resolve(__dirname, '..', 'test-data', 'common', 'sink');
const SINK_BUNDLE_FILE = path.resolve(SINK_DIR, 'bundle.yaml');
const INVALID_CONSTRAINT_NAME = 'invalid-constraint-no-api-version';
const CONSTRAINT_WITHOUT_BUNDLE_NAME = 'constraint-without-bundle';
describe('PolicyLibrary', () => {
    it('filters out invalid policy objects', () => __awaiter(void 0, void 0, void 0, function* () {
        const configs = yield readTestConfigs(SOURCE_INVALID_FILE);
        const library = new common_1.PolicyLibrary(configs.getAll());
        library.configs.forEach((config) => {
            const configName = config.metadata.name || '';
            expect(configName).not.toEqual(INVALID_CONSTRAINT_NAME);
        });
    }));
    it("filters out policy objects without an annotation", () => __awaiter(void 0, void 0, void 0, function* () {
        const configs = yield readTestConfigs(SOURCE_INVALID_FILE);
        const library = new common_1.PolicyLibrary(configs.getAll());
        library.configs.forEach((config) => {
            const configName = config.metadata.name || '';
            expect(configName).not.toEqual(CONSTRAINT_WITHOUT_BUNDLE_NAME);
        });
    }));
    it("builds policy bundles", () => __awaiter(void 0, void 0, void 0, function* () {
        const configs = yield readTestConfigs(SOURCE_BUNDLE_FILE);
        const expectedConfigs = yield readTestConfigs(SINK_BUNDLE_FILE);
        const library = new common_1.PolicyLibrary(configs.getAll());
        const bundle = library.bundles.get(FORSETI_BUNDLE);
        const actualConfigs = bundle ? new kpt.Configs(bundle.configs) : new kpt.Configs();
        expect(valueOf(actualConfigs)).toEqual(valueOf(expectedConfigs));
    }));
});
describe('FileWriter', () => {
    let tmpDir = '';
    beforeEach(() => {
        // Ensures tmpDir is unset before testing. Detects incorrectly running tests in parallel, or
        // tests not cleaning up properly.
        expect(tmpDir).toEqual('');
        tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'file-writer-test'));
    });
    afterEach(() => {
        // Remove tmpDir so no other tests can have access to the data.
        fs.removeSync(tmpDir);
        // Reset tmpDir value to confirm test finished normally.
        tmpDir = '';
    });
    it("throws if --overwrite isn't passed for non-empty directory", () => __awaiter(void 0, void 0, void 0, function* () {
        const fileWriter = () => { new common_1.FileWriter(SINK_DIR, false); };
        expect(fileWriter).toThrowError(/sink dir contains files/);
    }));
    it("silently makes output directory if it doesn't exist", () => __awaiter(void 0, void 0, void 0, function* () {
        const sinkDir = path.resolve(tmpDir, 'foo');
        new common_1.FileWriter(sinkDir, false);
        expect(fs.existsSync(sinkDir)).toEqual(true);
    }));
    it('overwrites if --overwrite is passed for non-empty directory', () => __awaiter(void 0, void 0, void 0, function* () {
        const sinkDir = path.resolve(tmpDir, 'foo');
        const fileToDelete = path.resolve(sinkDir, 'delete_me.yaml');
        fs.createFileSync(fileToDelete);
        const fileWriter = new common_1.FileWriter(sinkDir, true, undefined, undefined, true);
        fileWriter.finish();
        expect(fs.existsSync(fileToDelete)).toEqual(false);
    }));
    it('writes files to sink dir', () => __awaiter(void 0, void 0, void 0, function* () {
        const sinkDir = path.resolve(tmpDir, 'foo');
        const file = path.resolve(sinkDir + 'test.yaml');
        const fileContents = fs.readFileSync(SOURCE_BUNDLE_FILE).toString();
        const fileWriter = new common_1.FileWriter(sinkDir, true);
        fileWriter.write(file, fileContents);
        const actualFileContents = fs.readFileSync(file).toString();
        expect(JSON.parse(JSON.stringify(fileContents))).toEqual(JSON.parse(JSON.stringify(actualFileContents)));
    }));
});
function readTestConfigs(file) {
    return kpt.readConfigs(file, kpt.FileFormat.YAML);
}
function valueOf(configs) {
    return configs && JSON.parse(JSON.stringify(configs.getAll()));
}
//# sourceMappingURL=common_test.js.map