import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// APIService represents a server for a particular GroupVersion. Name must be "version.group".
export class APIService implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Spec contains information for locating and communicating with a server
  public spec?: APIServiceSpec;

  // Status contains derived information about an API server
  public status?: APIServiceStatus;

  constructor(desc: APIService.Interface) {
    this.apiVersion = APIService.apiVersion;
    this.kind = APIService.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isAPIService(o: any): o is APIService {
  return (
    o && o.apiVersion === APIService.apiVersion && o.kind === APIService.kind
  );
}

export namespace APIService {
  export const apiVersion = "apiregistration.k8s.io/v1beta1";
  export const group = "apiregistration.k8s.io";
  export const version = "v1beta1";
  export const kind = "APIService";

  // named constructs a APIService with metadata.name set to name.
  export function named(name: string): APIService {
    return new APIService({ metadata: { name } });
  }
  // APIService represents a server for a particular GroupVersion. Name must be "version.group".
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Spec contains information for locating and communicating with a server
    spec?: APIServiceSpec;

    // Status contains derived information about an API server
    status?: APIServiceStatus;
  }
}

// APIServiceCondition describes the state of an APIService at a particular point
export class APIServiceCondition {
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

  constructor(desc: APIServiceCondition) {
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// APIServiceList is a list of APIService objects.
export class APIServiceList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  public items: APIService[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: APIServiceList) {
    this.apiVersion = APIServiceList.apiVersion;
    this.items = desc.items.map(i => new APIService(i));
    this.kind = APIServiceList.kind;
    this.metadata = desc.metadata;
  }
}

export function isAPIServiceList(o: any): o is APIServiceList {
  return (
    o &&
    o.apiVersion === APIServiceList.apiVersion &&
    o.kind === APIServiceList.kind
  );
}

export namespace APIServiceList {
  export const apiVersion = "apiregistration.k8s.io/v1beta1";
  export const group = "apiregistration.k8s.io";
  export const version = "v1beta1";
  export const kind = "APIServiceList";

  // APIServiceList is a list of APIService objects.
  export interface Interface {
    items: APIService[];

    metadata?: apisMetaV1.ListMeta;
  }
}

// APIServiceSpec contains information for locating and communicating with a server. Only https is supported, though you are able to disable certificate verification.
export class APIServiceSpec {
  // CABundle is a PEM encoded CA bundle which will be used to validate an API server's serving certificate. If unspecified, system trust roots on the apiserver are used.
  public caBundle?: string;

  // Group is the API group name this server hosts
  public group?: string;

  // GroupPriorityMininum is the priority this group should have at least. Higher priority means that the group is preferred by clients over lower priority ones. Note that other versions of this group might specify even higher GroupPriorityMininum values such that the whole group gets a higher priority. The primary sort is based on GroupPriorityMinimum, ordered highest number to lowest (20 before 10). The secondary sort is based on the alphabetical comparison of the name of the object.  (v1.bar before v1.foo) We'd recommend something like: *.k8s.io (except extensions) at 18000 and PaaSes (OpenShift, Deis) are recommended to be in the 2000s
  public groupPriorityMinimum: number;

  // InsecureSkipTLSVerify disables TLS certificate verification when communicating with this server. This is strongly discouraged.  You should use the CABundle instead.
  public insecureSkipTLSVerify?: boolean;

  // Service is a reference to the service for this API server.  It must communicate on port 443 If the Service is nil, that means the handling for the API groupversion is handled locally on this server. The call will simply delegate to the normal handler chain to be fulfilled.
  public service: ServiceReference;

  // Version is the API version this server hosts.  For example, "v1"
  public version?: string;

  // VersionPriority controls the ordering of this API version inside of its group.  Must be greater than zero. The primary sort is based on VersionPriority, ordered highest to lowest (20 before 10). Since it's inside of a group, the number can be small, probably in the 10s. In case of equal version priorities, the version string will be used to compute the order inside a group. If the version string is "kube-like", it will sort above non "kube-like" version strings, which are ordered lexicographically. "Kube-like" versions start with a "v", then are followed by a number (the major version), then optionally the string "alpha" or "beta" and another number (the minor version). These are sorted first by GA > beta > alpha (where GA is a version with no suffix such as beta or alpha), and then by comparing major version, then minor version. An example sorted list of versions: v10, v2, v1, v11beta2, v10beta3, v3beta1, v12alpha1, v11alpha2, foo1, foo10.
  public versionPriority: number;

  constructor(desc: APIServiceSpec) {
    this.caBundle = desc.caBundle;
    this.group = desc.group;
    this.groupPriorityMinimum = desc.groupPriorityMinimum;
    this.insecureSkipTLSVerify = desc.insecureSkipTLSVerify;
    this.service = desc.service;
    this.version = desc.version;
    this.versionPriority = desc.versionPriority;
  }
}

// APIServiceStatus contains derived information about an API server
export class APIServiceStatus {
  // Current service state of apiService.
  public conditions?: APIServiceCondition[];
}

// ServiceReference holds a reference to Service.legacy.k8s.io
export class ServiceReference {
  // Name is the name of the service
  public name?: string;

  // Namespace is the namespace of the service
  public namespace?: string;
}
