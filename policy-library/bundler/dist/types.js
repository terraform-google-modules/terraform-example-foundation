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
Object.defineProperty(exports, "__esModule", { value: true });
class ConstraintTemplate {
    constructor(desc) {
        this.apiVersion = ConstraintTemplateNamespace.apiVersion;
        this.kind = ConstraintTemplateNamespace.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
    }
}
exports.ConstraintTemplate = ConstraintTemplate;
function isConstraintTemplate(o) {
    return (o &&
        o.apiVersion === ConstraintTemplateNamespace.apiVersion &&
        o.kind === ConstraintTemplateNamespace.kind);
}
exports.isConstraintTemplate = isConstraintTemplate;
class ConstraintTemplateNamespace {
}
exports.ConstraintTemplateNamespace = ConstraintTemplateNamespace;
ConstraintTemplateNamespace.apiVersion = "templates.gatekeeper.sh/v1beta1";
ConstraintTemplateNamespace.group = "templates.gatekeeper.sh";
ConstraintTemplateNamespace.version = "v1beta1";
ConstraintTemplateNamespace.kind = "ConstraintTemplate";
class ConstraintTemplateSpec {
}
exports.ConstraintTemplateSpec = ConstraintTemplateSpec;
class ConstraintTemplateCRD {
}
exports.ConstraintTemplateCRD = ConstraintTemplateCRD;
class ConstraintTemplateCRDSpec {
}
exports.ConstraintTemplateCRDSpec = ConstraintTemplateCRDSpec;
class ConstraintTemplateValidation {
}
exports.ConstraintTemplateValidation = ConstraintTemplateValidation;
//# sourceMappingURL=types.js.map