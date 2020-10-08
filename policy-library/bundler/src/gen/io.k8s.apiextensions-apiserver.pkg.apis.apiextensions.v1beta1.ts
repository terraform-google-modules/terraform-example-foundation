import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// CustomResourceColumnDefinition specifies a column for server side printing.
export class CustomResourceColumnDefinition {
  // JSONPath is a simple JSON path, i.e. with array notation.
  public JSONPath: string;

  // description is a human readable description of this column.
  public description?: string;

  // format is an optional OpenAPI type definition for this column. The 'name' format is applied to the primary identifier column to assist in clients identifying column is the resource name. See https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#data-types for more.
  public format?: string;

  // name is a human readable name for the column.
  public name: string;

  // priority is an integer defining the relative importance of this column compared to others. Lower numbers are considered higher priority. Columns that may be omitted in limited space scenarios should be given a higher priority.
  public priority?: number;

  // type is an OpenAPI type definition for this column. See https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#data-types for more.
  public type: string;

  constructor(desc: CustomResourceColumnDefinition) {
    this.JSONPath = desc.JSONPath;
    this.description = desc.description;
    this.format = desc.format;
    this.name = desc.name;
    this.priority = desc.priority;
    this.type = desc.type;
  }
}

// CustomResourceConversion describes how to convert different versions of a CR.
export class CustomResourceConversion {
  // ConversionReviewVersions is an ordered list of preferred `ConversionReview` versions the Webhook expects. API server will try to use first version in the list which it supports. If none of the versions specified in this list supported by API server, conversion will fail for this object. If a persisted Webhook configuration specifies allowed versions and does not include any versions known to the API Server, calls to the webhook will fail. Default to `['v1beta1']`.
  public conversionReviewVersions?: string[];

  // `strategy` specifies the conversion strategy. Allowed values are: - `None`: The converter only change the apiVersion and would not touch any other field in the CR. - `Webhook`: API Server will call to an external webhook to do the conversion. Additional information is needed for this option.
  public strategy: string;

  // `webhookClientConfig` is the instructions for how to call the webhook if strategy is `Webhook`. This field is alpha-level and is only honored by servers that enable the CustomResourceWebhookConversion feature.
  public webhookClientConfig?: WebhookClientConfig;

  constructor(desc: CustomResourceConversion) {
    this.conversionReviewVersions = desc.conversionReviewVersions;
    this.strategy = desc.strategy;
    this.webhookClientConfig = desc.webhookClientConfig;
  }
}

// CustomResourceDefinition represents a resource that should be exposed on the API server.  Its name MUST be in the format <.spec.name>.<.spec.group>.
export class CustomResourceDefinition implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Spec describes how the user wants the resources to appear
  public spec: CustomResourceDefinitionSpec;

  // Status indicates the actual state of the CustomResourceDefinition
  public status?: CustomResourceDefinitionStatus;

  constructor(desc: CustomResourceDefinition.Interface) {
    this.apiVersion = CustomResourceDefinition.apiVersion;
    this.kind = CustomResourceDefinition.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isCustomResourceDefinition(
  o: any
): o is CustomResourceDefinition {
  return (
    o &&
    o.apiVersion === CustomResourceDefinition.apiVersion &&
    o.kind === CustomResourceDefinition.kind
  );
}

export namespace CustomResourceDefinition {
  export const apiVersion = "apiextensions.k8s.io/v1beta1";
  export const group = "apiextensions.k8s.io";
  export const version = "v1beta1";
  export const kind = "CustomResourceDefinition";

  // CustomResourceDefinition represents a resource that should be exposed on the API server.  Its name MUST be in the format <.spec.name>.<.spec.group>.
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Spec describes how the user wants the resources to appear
    spec: CustomResourceDefinitionSpec;

    // Status indicates the actual state of the CustomResourceDefinition
    status?: CustomResourceDefinitionStatus;
  }
}

// CustomResourceDefinitionCondition contains details for the current condition of this pod.
export class CustomResourceDefinitionCondition {
  // Last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // Human-readable message indicating details about last transition.
  public message?: string;

  // Unique, one-word, CamelCase reason for the condition's last transition.
  public reason?: string;

  // Status is the status of the condition. Can be True, False, Unknown.
  public status: string;

  // Type is the type of the condition.
  public type: string;

  constructor(desc: CustomResourceDefinitionCondition) {
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// CustomResourceDefinitionList is a list of CustomResourceDefinition objects.
export class CustomResourceDefinitionList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items individual CustomResourceDefinitions
  public items: CustomResourceDefinition[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: CustomResourceDefinitionList) {
    this.apiVersion = CustomResourceDefinitionList.apiVersion;
    this.items = desc.items.map(i => new CustomResourceDefinition(i));
    this.kind = CustomResourceDefinitionList.kind;
    this.metadata = desc.metadata;
  }
}

export function isCustomResourceDefinitionList(
  o: any
): o is CustomResourceDefinitionList {
  return (
    o &&
    o.apiVersion === CustomResourceDefinitionList.apiVersion &&
    o.kind === CustomResourceDefinitionList.kind
  );
}

export namespace CustomResourceDefinitionList {
  export const apiVersion = "apiextensions.k8s.io/v1beta1";
  export const group = "apiextensions.k8s.io";
  export const version = "v1beta1";
  export const kind = "CustomResourceDefinitionList";

  // CustomResourceDefinitionList is a list of CustomResourceDefinition objects.
  export interface Interface {
    // Items individual CustomResourceDefinitions
    items: CustomResourceDefinition[];

    metadata?: apisMetaV1.ListMeta;
  }
}

// CustomResourceDefinitionNames indicates the names to serve this CustomResourceDefinition
export class CustomResourceDefinitionNames {
  // Categories is a list of grouped resources custom resources belong to (e.g. 'all')
  public categories?: string[];

  // Kind is the serialized kind of the resource.  It is normally CamelCase and singular.
  public kind: string;

  // ListKind is the serialized kind of the list for this resource.  Defaults to <kind>List.
  public listKind?: string;

  // Plural is the plural name of the resource to serve.  It must match the name of the CustomResourceDefinition-registration too: plural.group and it must be all lowercase.
  public plural: string;

  // ShortNames are short names for the resource.  It must be all lowercase.
  public shortNames?: string[];

  // Singular is the singular name of the resource.  It must be all lowercase  Defaults to lowercased <kind>
  public singular?: string;

  constructor(desc: CustomResourceDefinitionNames) {
    this.categories = desc.categories;
    this.kind = desc.kind;
    this.listKind = desc.listKind;
    this.plural = desc.plural;
    this.shortNames = desc.shortNames;
    this.singular = desc.singular;
  }
}

// CustomResourceDefinitionSpec describes how a user wants their resource to appear
export class CustomResourceDefinitionSpec {
  // AdditionalPrinterColumns are additional columns shown e.g. in kubectl next to the name. Defaults to a created-at column. Optional, the global columns for all versions. Top-level and per-version columns are mutually exclusive.
  public additionalPrinterColumns?: CustomResourceColumnDefinition[];

  // `conversion` defines conversion settings for the CRD.
  public conversion?: CustomResourceConversion;

  // Group is the group this resource belongs in
  public group: string;

  // Names are the names used to describe this custom resource
  public names: CustomResourceDefinitionNames;

  // Scope indicates whether this resource is cluster or namespace scoped.  Default is namespaced
  public scope: string;

  // Subresources describes the subresources for CustomResource Optional, the global subresources for all versions. Top-level and per-version subresources are mutually exclusive.
  public subresources?: CustomResourceSubresources;

  // Validation describes the validation methods for CustomResources Optional, the global validation schema for all versions. Top-level and per-version schemas are mutually exclusive.
  public validation?: CustomResourceValidation;

  // Version is the version this resource belongs in Should be always first item in Versions field if provided. Optional, but at least one of Version or Versions must be set. Deprecated: Please use `Versions`.
  public version?: string;

  // Versions is the list of all supported versions for this resource. If Version field is provided, this field is optional. Validation: All versions must use the same validation schema for now. i.e., top level Validation field is applied to all of these versions. Order: The version name will be used to compute the order. If the version string is "kube-like", it will sort above non "kube-like" version strings, which are ordered lexicographically. "Kube-like" versions start with a "v", then are followed by a number (the major version), then optionally the string "alpha" or "beta" and another number (the minor version). These are sorted first by GA > beta > alpha (where GA is a version with no suffix such as beta or alpha), and then by comparing major version, then minor version. An example sorted list of versions: v10, v2, v1, v11beta2, v10beta3, v3beta1, v12alpha1, v11alpha2, foo1, foo10.
  public versions?: CustomResourceDefinitionVersion[];

  constructor(desc: CustomResourceDefinitionSpec) {
    this.additionalPrinterColumns = desc.additionalPrinterColumns;
    this.conversion = desc.conversion;
    this.group = desc.group;
    this.names = desc.names;
    this.scope = desc.scope;
    this.subresources = desc.subresources;
    this.validation = desc.validation;
    this.version = desc.version;
    this.versions = desc.versions;
  }
}

// CustomResourceDefinitionStatus indicates the state of the CustomResourceDefinition
export class CustomResourceDefinitionStatus {
  // AcceptedNames are the names that are actually being used to serve discovery They may be different than the names in spec.
  public acceptedNames: CustomResourceDefinitionNames;

  // Conditions indicate state for particular aspects of a CustomResourceDefinition
  public conditions: CustomResourceDefinitionCondition[];

  // StoredVersions are all versions of CustomResources that were ever persisted. Tracking these versions allows a migration path for stored versions in etcd. The field is mutable so the migration controller can first finish a migration to another version (i.e. that no old objects are left in the storage), and then remove the rest of the versions from this list. None of the versions in this list can be removed from the spec.Versions field.
  public storedVersions: string[];

  constructor(desc: CustomResourceDefinitionStatus) {
    this.acceptedNames = desc.acceptedNames;
    this.conditions = desc.conditions;
    this.storedVersions = desc.storedVersions;
  }
}

// CustomResourceDefinitionVersion describes a version for CRD.
export class CustomResourceDefinitionVersion {
  // AdditionalPrinterColumns are additional columns shown e.g. in kubectl next to the name. Defaults to a created-at column. Top-level and per-version columns are mutually exclusive. Per-version columns must not all be set to identical values (top-level columns should be used instead) This field is alpha-level and is only honored by servers that enable the CustomResourceWebhookConversion feature. NOTE: CRDs created prior to 1.13 populated the top-level additionalPrinterColumns field by default. To apply an update that changes to per-version additionalPrinterColumns, the top-level additionalPrinterColumns field must be explicitly set to null
  public additionalPrinterColumns?: CustomResourceColumnDefinition[];

  // Name is the version name, e.g. “v1”, “v2beta1”, etc.
  public name: string;

  // Schema describes the schema for CustomResource used in validation, pruning, and defaulting. Top-level and per-version schemas are mutually exclusive. Per-version schemas must not all be set to identical values (top-level validation schema should be used instead) This field is alpha-level and is only honored by servers that enable the CustomResourceWebhookConversion feature.
  public schema?: CustomResourceValidation;

  // Served is a flag enabling/disabling this version from being served via REST APIs
  public served: boolean;

  // Storage flags the version as storage version. There must be exactly one flagged as storage version.
  public storage: boolean;

  // Subresources describes the subresources for CustomResource Top-level and per-version subresources are mutually exclusive. Per-version subresources must not all be set to identical values (top-level subresources should be used instead) This field is alpha-level and is only honored by servers that enable the CustomResourceWebhookConversion feature.
  public subresources?: CustomResourceSubresources;

  constructor(desc: CustomResourceDefinitionVersion) {
    this.additionalPrinterColumns = desc.additionalPrinterColumns;
    this.name = desc.name;
    this.schema = desc.schema;
    this.served = desc.served;
    this.storage = desc.storage;
    this.subresources = desc.subresources;
  }
}

// CustomResourceSubresourceScale defines how to serve the scale subresource for CustomResources.
export class CustomResourceSubresourceScale {
  // LabelSelectorPath defines the JSON path inside of a CustomResource that corresponds to Scale.Status.Selector. Only JSON paths without the array notation are allowed. Must be a JSON Path under .status. Must be set to work with HPA. If there is no value under the given path in the CustomResource, the status label selector value in the /scale subresource will default to the empty string.
  public labelSelectorPath?: string;

  // SpecReplicasPath defines the JSON path inside of a CustomResource that corresponds to Scale.Spec.Replicas. Only JSON paths without the array notation are allowed. Must be a JSON Path under .spec. If there is no value under the given path in the CustomResource, the /scale subresource will return an error on GET.
  public specReplicasPath: string;

  // StatusReplicasPath defines the JSON path inside of a CustomResource that corresponds to Scale.Status.Replicas. Only JSON paths without the array notation are allowed. Must be a JSON Path under .status. If there is no value under the given path in the CustomResource, the status replica value in the /scale subresource will default to 0.
  public statusReplicasPath: string;

  constructor(desc: CustomResourceSubresourceScale) {
    this.labelSelectorPath = desc.labelSelectorPath;
    this.specReplicasPath = desc.specReplicasPath;
    this.statusReplicasPath = desc.statusReplicasPath;
  }
}

// CustomResourceSubresourceStatus defines how to serve the status subresource for CustomResources. Status is represented by the `.status` JSON path inside of a CustomResource. When set, * exposes a /status subresource for the custom resource * PUT requests to the /status subresource take a custom resource object, and ignore changes to anything except the status stanza * PUT/POST/PATCH requests to the custom resource ignore changes to the status stanza
export type CustomResourceSubresourceStatus = object;

// CustomResourceSubresources defines the status and scale subresources for CustomResources.
export class CustomResourceSubresources {
  // Scale denotes the scale subresource for CustomResources
  public scale?: CustomResourceSubresourceScale;

  // Status denotes the status subresource for CustomResources
  public status?: CustomResourceSubresourceStatus;
}

// CustomResourceValidation is a list of validation methods for CustomResources.
export class CustomResourceValidation {
  // OpenAPIV3Schema is the OpenAPI v3 schema to be validated against.
  public openAPIV3Schema?: JSONSchemaProps;
}

// ExternalDocumentation allows referencing an external resource for extended documentation.
export class ExternalDocumentation {
  public description?: string;

  public url?: string;
}

// JSON represents any valid JSON value. These types are supported: bool, int64, float64, string, []interface{}, map[string]interface{} and nil.
export type JSON = object;

// JSONSchemaProps is a JSON-Schema following Specification Draft 4 (http://json-schema.org/).
export class JSONSchemaProps {
  public $ref?: string;

  public $schema?: string;

  public additionalItems?: JSONSchemaPropsOrBool;

  public additionalProperties?: JSONSchemaPropsOrBool;

  public allOf?: JSONSchemaProps[];

  public anyOf?: JSONSchemaProps[];

  public default?: JSON;

  public definitions?: { [key: string]: JSONSchemaProps };

  public dependencies?: { [key: string]: JSONSchemaPropsOrStringArray };

  public description?: string;

  public enum?: JSON[];

  public example?: JSON;

  public exclusiveMaximum?: boolean;

  public exclusiveMinimum?: boolean;

  public externalDocs?: ExternalDocumentation;

  public format?: string;

  public id?: string;

  public items?: JSONSchemaPropsOrArray;

  public maxItems?: number;

  public maxLength?: number;

  public maxProperties?: number;

  public maximum?: number;

  public minItems?: number;

  public minLength?: number;

  public minProperties?: number;

  public minimum?: number;

  public multipleOf?: number;

  public not?: JSONSchemaProps;

  public nullable?: boolean;

  public oneOf?: JSONSchemaProps[];

  public pattern?: string;

  public patternProperties?: { [key: string]: JSONSchemaProps };

  public properties?: { [key: string]: JSONSchemaProps };

  public required?: string[];

  public title?: string;

  public type?: string;

  public uniqueItems?: boolean;
}

// JSONSchemaPropsOrArray represents a value that can either be a JSONSchemaProps or an array of JSONSchemaProps. Mainly here for serialization purposes.
export type JSONSchemaPropsOrArray = object;

// JSONSchemaPropsOrBool represents JSONSchemaProps or a boolean value. Defaults to true for the boolean property.
export type JSONSchemaPropsOrBool = object;

// JSONSchemaPropsOrStringArray represents a JSONSchemaProps or a string array.
export type JSONSchemaPropsOrStringArray = object;

// ServiceReference holds a reference to Service.legacy.k8s.io
export class ServiceReference {
  // `name` is the name of the service. Required
  public name: string;

  // `namespace` is the namespace of the service. Required
  public namespace: string;

  // `path` is an optional URL path which will be sent in any request to this service.
  public path?: string;

  constructor(desc: ServiceReference) {
    this.name = desc.name;
    this.namespace = desc.namespace;
    this.path = desc.path;
  }
}

// WebhookClientConfig contains the information to make a TLS connection with the webhook. It has the same field as admissionregistration.v1beta1.WebhookClientConfig.
export class WebhookClientConfig {
  // `caBundle` is a PEM encoded CA bundle which will be used to validate the webhook's server certificate. If unspecified, system trust roots on the apiserver are used.
  public caBundle?: string;

  // `service` is a reference to the service for this webhook. Either `service` or `url` must be specified.
  //
  // If the webhook is running within the cluster, then you should use `service`.
  //
  // Port 443 will be used if it is open, otherwise it is an error.
  public service?: ServiceReference;

  // `url` gives the location of the webhook, in standard URL form (`scheme://host:port/path`). Exactly one of `url` or `service` must be specified.
  //
  // The `host` should not refer to a service running in the cluster; use the `service` field instead. The host might be resolved via external DNS in some apiservers (e.g., `kube-apiserver` cannot resolve in-cluster DNS as that would be a layering violation). `host` may also be an IP address.
  //
  // Please note that using `localhost` or `127.0.0.1` as a `host` is risky unless you take great care to run this webhook on all hosts which run an apiserver which might need to make calls to this webhook. Such installs are likely to be non-portable, i.e., not easy to turn up in a new cluster.
  //
  // The scheme must be "https"; the URL must begin with "https://".
  //
  // A path is optional, and if present may be any string permissible in a URL. You may use the path to pass an arbitrary string to the webhook, for example, a cluster identifier.
  //
  // Attempting to use a user or basic auth e.g. "user:password@" is not allowed. Fragments ("#...") and query parameters ("?...") are not allowed, either.
  public url?: string;
}
