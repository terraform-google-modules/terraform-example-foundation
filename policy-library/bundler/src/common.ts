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

import {
  existsSync,
  mkdirSync,
  readFileSync,
  unlinkSync,
  writeFileSync
} from "fs";
import * as glob from "glob";
import { KubernetesObject, getAnnotation } from "kpt-functions";
import * as path from "path";
import * as _ from "lodash";
import { isConstraintTemplate } from "./types";

export const BUNDLE_ANNOTATION_PREFIX = 'bundles.validator.forsetisecurity.org';
export const BUNDLE_ANNOTATION_REGEX = new RegExp(`${BUNDLE_ANNOTATION_PREFIX}\/(.+)`);
export const CT_KIND = "ConstraintTemplate";
export const SUPPORTED_API_VERSIONS = /^(constraints|templates).gatekeeper.sh\/v1(.+)$/;

class PolicyLibrary {
  bundles: Map<string, PolicyBundle>;
  configs: KubernetesObject[];

  constructor(configs: KubernetesObject[]) {
    this.bundles = new Map();
    this.configs = new Array();

    configs
      .filter(o => {
        return PolicyConfig.isPolicyObject(o);
      })
      .forEach(o => {
        const annotations = o.metadata.annotations || {};
        Object.keys(annotations).forEach(annotation => {
          const result = annotation.match(BUNDLE_ANNOTATION_REGEX);
          if (!result) {
            return;
          }
          const bundle = result[0];
          const control = annotations[annotation];
          this.bundlePolicy(bundle, control, o);
        });
        this.configs.push(o);
      });
  }

  getAll(): KubernetesObject[] {
    return this.configs;
  }

  getTemplates(): KubernetesObject[] {
    return this.getOfKind(CT_KIND);
  }

  getTemplate(kind: string): KubernetesObject {
    const matches = this.getTemplates().filter(o => {
      return (o as any).spec.crd.spec.names.kind === kind;
    });
    return matches[0] || undefined;
  }

  getOfKind(kind: string): KubernetesObject[] {
    return this.configs.filter(o => {
      return o.kind === kind;
    });
  }

  bundlePolicy(bundleKey: string, control: string, policy: KubernetesObject) {
    let bundle = this.bundles.get(bundleKey);
    if (bundle === undefined) {
      bundle = new PolicyBundle(bundleKey);
      this.bundles.set(bundleKey, bundle);
    }

    bundle.addPolicy(policy);
  }
}

class PolicyBundle {
  key: string;
  configs: KubernetesObject[];

  constructor(annotation: string) {
    this.key = annotation;
    this.configs = new Array();
  }

  getName() {
    const matches = this.key.match(BUNDLE_ANNOTATION_REGEX);
    return matches ? matches[1] : "Unknown";
  }

  getKey() {
    return this.getName();
  }

  addPolicy(policy: KubernetesObject) {
    this.configs.push(policy);
  }

  getConfigs() {
    return this.configs;
  }

  getControl(policy: KubernetesObject): string {
    return getAnnotation(policy, this.key) || "";
  }
}

class PolicyConfig {
  static compare(a: any, b: any) {
    return PolicyConfig.getName(a) > PolicyConfig.getName(b) ? 1 : -1;
  }

  static getDescription(o: any): string {
    return getAnnotation(o, "description") || "";
  }

  static getName(o: any): string {
    if (o.kind === CT_KIND) {
      return o.spec.crd.spec.names.kind;
    }
    return o.metadata.name;
  }

  static getPath(o: any, root = "../"): string {
    let targetPath = path.join(root, "samples");
    if (o.kind === CT_KIND) {
      targetPath = path.join(root, "policies");
    }
    return path.join(
      targetPath,
      getAnnotation(o, "config.kubernetes.io/path") || ""
    );
  }

  static isPolicyObject(o: any): boolean {
    return (
      o && o.apiVersion !== "" && SUPPORTED_API_VERSIONS.test(o.apiVersion)
    );
  }

  static getParams(o: any): PolicyParams {
    const result = new PolicyParams();
    if (!isConstraintTemplate(o) || o.spec.crd?.spec?.validation?.openAPIV3Schema === undefined) {
      return result;
    }

    _.each(o.spec.crd?.spec?.validation?.openAPIV3Schema?.properties, (prop, key) => {
      result[key] = prop.type || "unknown";
    });

    return result;
  }
}

class PolicyParams {
  [index: string]: string;
}

class FileWriter {
  filesToDelete: Set<string>;
  prune: boolean;

  constructor(
    sinkDir: string,
    overwrite: boolean,
    filePattern = "/**/*",
    create = true,
    prune = false
  ) {
    if (create && !existsSync(sinkDir)) {
      mkdirSync(sinkDir, { recursive: true });
    }

    // If sink diretory is not empty, require 'overwrite' parameter to be set.
    const files = this.listFiles(sinkDir, filePattern);
    if (!overwrite && files.length > 0) {
      throw new Error(
        `sink dir contains files and overwrite is not set to string 'true'.`
      );
    }

    this.filesToDelete = new Set(files.map((file) => path.resolve(file)));
    this.prune = prune;
  }

  finish() {
    if (this.prune) {
      // Delete files that are missing from the new configs.
      this.filesToDelete.forEach((file: any) => {
        unlinkSync(file);
      });
    }
  }

  listFiles(dir: string, filePattern: string): string[] {
    return glob.sync(dir + filePattern);
  }

  write(file: any, contents: string) {
    const dir = path.dirname(file);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }

    if (existsSync(file)) {
      const currentContents = readFileSync(file).toString();
      if (contents === currentContents) {
        // No changes to make.
        return;
      }
    }

    this.filesToDelete.delete(path.resolve(file));
    writeFileSync(file, contents, "utf8");
  }
}

export { FileWriter, PolicyBundle, PolicyConfig, PolicyLibrary };
