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

/* tslint:disable:member-access */

import { KubernetesObject } from "kpt-functions";
// import * as apiCoreV1 from "./gen/io.k8s.api.core.v1";
import * as apisMetaV1 from "./gen/io.k8s.apimachinery.pkg.apis.meta.v1";
import { JSONSchemaProps } from "./gen/io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1beta1";

export class ConstraintTemplate implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec
  public spec: ConstraintTemplateSpec;

  constructor(desc: ConstraintTemplateInterface) {
    this.apiVersion = ConstraintTemplateNamespace.apiVersion;
    this.kind = ConstraintTemplateNamespace.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
  }
}

export function isConstraintTemplate(o: any): o is ConstraintTemplate {
  return (
    o &&
    o.apiVersion === ConstraintTemplateNamespace.apiVersion &&
    o.kind === ConstraintTemplateNamespace.kind
  );
}

interface ConstraintTemplateInterface {
  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  metadata: apisMetaV1.ObjectMeta;

  spec: ConstraintTemplateSpec;
}

export class ConstraintTemplateNamespace {
  public static apiVersion = "templates.gatekeeper.sh/v1beta1";
  public static group = "templates.gatekeeper.sh";
  public static version = "v1beta1";
  public static kind = "ConstraintTemplate";
}

export class ConstraintTemplateSpec {
  public crd?: ConstraintTemplateCRD;
}

export class ConstraintTemplateCRD {
  public spec?: ConstraintTemplateCRDSpec;
}

export class ConstraintTemplateCRDSpec {
  public validation?: ConstraintTemplateValidation;
}

export class ConstraintTemplateValidation {
  public openAPIV3Schema?: JSONSchemaProps;
}