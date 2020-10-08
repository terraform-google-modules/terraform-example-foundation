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

import * as kpt from "kpt-functions";
import * as path from "path";
import { ConfigMap } from "./gen/io.k8s.api.core.v1";
import { getPolicyBundle, ANNOTATION_NAME } from "./get_policy_bundle";
import { TestRunner } from "kpt-functions";

const FORSETI_BUNDLE = "forseti-security";
const RUNNER = new TestRunner(getPolicyBundle);

const SOURCE_SAMPLES_FILE = path.resolve(
  __dirname,
  "..",
  "test-data",
  "policy-bundle",
  "source",
  "samples.yaml"
);

const SINK_SAMPLES_FILE = path.resolve(
  __dirname,
  "..",
  "test-data",
  "policy-bundle",
  "sink",
  "samples.yaml"
);

describe("getPolicyBundle", () => {
  const functionConfig = ConfigMap.named("config");

  beforeEach(() => {
    functionConfig.data = {};
  });

  it("replicates test dir", async () => {
    const input = await readTestConfigs(SOURCE_SAMPLES_FILE);
    functionConfig.data![ANNOTATION_NAME] = FORSETI_BUNDLE;
    const configs = new kpt.Configs(input.getAll(), functionConfig);
    const expectedConfigs = await readTestConfigs(SINK_SAMPLES_FILE);

    await getPolicyBundle(configs);

    await RUNNER.assert(configs, expectedConfigs);
  });
});

function readTestConfigs(file: string): Promise<kpt.Configs> {
  return kpt.readConfigs(file, kpt.FileFormat.YAML);
}
