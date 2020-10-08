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
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs_1 = require("fs");
const glob = __importStar(require("glob"));
const kpt_functions_1 = require("kpt-functions");
const path = __importStar(require("path"));
const _ = __importStar(require("lodash"));
const types_1 = require("./types");
exports.BUNDLE_ANNOTATION_PREFIX = 'bundles.validator.forsetisecurity.org';
exports.BUNDLE_ANNOTATION_REGEX = new RegExp(`${exports.BUNDLE_ANNOTATION_PREFIX}\/(.+)`);
exports.CT_KIND = "ConstraintTemplate";
exports.SUPPORTED_API_VERSIONS = /^(constraints|templates).gatekeeper.sh\/v1(.+)$/;
class PolicyLibrary {
    constructor(configs) {
        this.bundles = new Map();
        this.configs = new Array();
        configs
            .filter(o => {
            return PolicyConfig.isPolicyObject(o);
        })
            .forEach(o => {
            const annotations = o.metadata.annotations || {};
            Object.keys(annotations).forEach(annotation => {
                const result = annotation.match(exports.BUNDLE_ANNOTATION_REGEX);
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
    getAll() {
        return this.configs;
    }
    getTemplates() {
        return this.getOfKind(exports.CT_KIND);
    }
    getTemplate(kind) {
        const matches = this.getTemplates().filter(o => {
            return o.spec.crd.spec.names.kind === kind;
        });
        return matches[0] || undefined;
    }
    getOfKind(kind) {
        return this.configs.filter(o => {
            return o.kind === kind;
        });
    }
    bundlePolicy(bundleKey, control, policy) {
        let bundle = this.bundles.get(bundleKey);
        if (bundle === undefined) {
            bundle = new PolicyBundle(bundleKey);
            this.bundles.set(bundleKey, bundle);
        }
        bundle.addPolicy(policy);
    }
}
exports.PolicyLibrary = PolicyLibrary;
class PolicyBundle {
    constructor(annotation) {
        this.key = annotation;
        this.configs = new Array();
    }
    getName() {
        const matches = this.key.match(exports.BUNDLE_ANNOTATION_REGEX);
        return matches ? matches[1] : "Unknown";
    }
    getKey() {
        return this.getName();
    }
    addPolicy(policy) {
        this.configs.push(policy);
    }
    getConfigs() {
        return this.configs;
    }
    getControl(policy) {
        return kpt_functions_1.getAnnotation(policy, this.key) || "";
    }
}
exports.PolicyBundle = PolicyBundle;
class PolicyConfig {
    static compare(a, b) {
        return PolicyConfig.getName(a) > PolicyConfig.getName(b) ? 1 : -1;
    }
    static getDescription(o) {
        return kpt_functions_1.getAnnotation(o, "description") || "";
    }
    static getName(o) {
        if (o.kind === exports.CT_KIND) {
            return o.spec.crd.spec.names.kind;
        }
        return o.metadata.name;
    }
    static getPath(o, root = "../") {
        let targetPath = path.join(root, "samples");
        if (o.kind === exports.CT_KIND) {
            targetPath = path.join(root, "policies");
        }
        return path.join(targetPath, kpt_functions_1.getAnnotation(o, "config.kubernetes.io/path") || "");
    }
    static isPolicyObject(o) {
        return (o && o.apiVersion !== "" && exports.SUPPORTED_API_VERSIONS.test(o.apiVersion));
    }
    static getParams(o) {
        var _a, _b, _c, _d, _e, _f, _g;
        const result = new PolicyParams();
        if (!types_1.isConstraintTemplate(o) || ((_c = (_b = (_a = o.spec.crd) === null || _a === void 0 ? void 0 : _a.spec) === null || _b === void 0 ? void 0 : _b.validation) === null || _c === void 0 ? void 0 : _c.openAPIV3Schema) === undefined) {
            return result;
        }
        _.each((_g = (_f = (_e = (_d = o.spec.crd) === null || _d === void 0 ? void 0 : _d.spec) === null || _e === void 0 ? void 0 : _e.validation) === null || _f === void 0 ? void 0 : _f.openAPIV3Schema) === null || _g === void 0 ? void 0 : _g.properties, (prop, key) => {
            result[key] = prop.type || "unknown";
        });
        return result;
    }
}
exports.PolicyConfig = PolicyConfig;
class PolicyParams {
}
class FileWriter {
    constructor(sinkDir, overwrite, filePattern = "/**/*", create = true, prune = false) {
        if (create && !fs_1.existsSync(sinkDir)) {
            fs_1.mkdirSync(sinkDir, { recursive: true });
        }
        // If sink diretory is not empty, require 'overwrite' parameter to be set.
        const files = this.listFiles(sinkDir, filePattern);
        if (!overwrite && files.length > 0) {
            throw new Error(`sink dir contains files and overwrite is not set to string 'true'.`);
        }
        this.filesToDelete = new Set(files.map((file) => path.resolve(file)));
        this.prune = prune;
    }
    finish() {
        if (this.prune) {
            // Delete files that are missing from the new configs.
            this.filesToDelete.forEach((file) => {
                fs_1.unlinkSync(file);
            });
        }
    }
    listFiles(dir, filePattern) {
        return glob.sync(dir + filePattern);
    }
    write(file, contents) {
        const dir = path.dirname(file);
        if (!fs_1.existsSync(dir)) {
            fs_1.mkdirSync(dir, { recursive: true });
        }
        if (fs_1.existsSync(file)) {
            const currentContents = fs_1.readFileSync(file).toString();
            if (contents === currentContents) {
                // No changes to make.
                return;
            }
        }
        this.filesToDelete.delete(path.resolve(file));
        fs_1.writeFileSync(file, contents, "utf8");
    }
}
exports.FileWriter = FileWriter;
//# sourceMappingURL=common.js.map