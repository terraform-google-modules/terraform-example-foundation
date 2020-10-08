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

import * as fs from "fs-extra";
import * as kpt from "kpt-functions";
import * as os from "os";
import * as path from "path";
import { ConfigMap } from "./gen/io.k8s.api.core.v1";
import { generateDocs, BUNDLE_DIR, OVERWRITE, SINK_DIR } from "./generate_docs";

const SOURCE_DIR = path.resolve(
  __dirname,
  "..",
  "test-data",
  "generate-docs",
  "source"
);

const SOURCE_SAMPLES_FILE = path.resolve(SOURCE_DIR, "samples_templates.yaml");

describe("generateDocs", () => {
  let tmpDir = "";
  const functionConfig = ConfigMap.named("config");
  let sinkDir = "";

  beforeEach(() => {
    // Ensures tmpDir is unset before testing. Detects incorrectly running tests in parallel, or
    // tests not cleaning up properly.
    expect(tmpDir).toEqual("");
    tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "generate-docs-test"));
    functionConfig.data = {};

    // Get sample configs
    sinkDir = path.resolve(tmpDir, "foo");
    functionConfig.data![OVERWRITE] = "true";
    functionConfig.data![SINK_DIR] = sinkDir;
  });

  afterEach(() => {
    // Remove tmpDir so no other tests can have access to the data.
    fs.removeSync(tmpDir);
    // Reset tmpDir value to confirm test finished normally.
    tmpDir = "";
  });

  it("generates index.md", async () => {
    const input = await getSampleConfigs();
    const configs = new kpt.Configs(input.getAll(), functionConfig);
    const expectedFile = path.resolve(sinkDir, "index.md");

    await generateDocs(configs);

    expect(fs.existsSync(expectedFile)).toEqual(true);
  });

  it("generates cis-v1.0 bundle docs", async () => {
    const input = await getSampleConfigs();
    const configs = new kpt.Configs(input.getAll(), functionConfig);
    const expectedFile = path.resolve(sinkDir, BUNDLE_DIR, "cis-v1.0.md");

    await generateDocs(configs);

    expect(fs.existsSync(expectedFile)).toEqual(true);
  });

  it("generates cis-v1.1 bundle docs", async () => {
    const input = await getSampleConfigs();
    const configs = new kpt.Configs(input.getAll(), functionConfig);
    const expectedFile = path.resolve(sinkDir, BUNDLE_DIR, "cis-v1.1.md");

    await generateDocs(configs);

    expect(fs.existsSync(expectedFile)).toEqual(true);
  });
});

function getSampleConfigs(): Promise<kpt.Configs> {
  return kpt.readConfigs(SOURCE_SAMPLES_FILE, kpt.FileFormat.YAML);
}
