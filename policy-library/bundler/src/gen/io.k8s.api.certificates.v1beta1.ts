import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// Describes a certificate signing request
export class CertificateSigningRequest implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // The certificate request itself and any additional information.
  public spec?: CertificateSigningRequestSpec;

  // Derived information about the request.
  public status?: CertificateSigningRequestStatus;

  constructor(desc: CertificateSigningRequest.Interface) {
    this.apiVersion = CertificateSigningRequest.apiVersion;
    this.kind = CertificateSigningRequest.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isCertificateSigningRequest(
  o: any
): o is CertificateSigningRequest {
  return (
    o &&
    o.apiVersion === CertificateSigningRequest.apiVersion &&
    o.kind === CertificateSigningRequest.kind
  );
}

export namespace CertificateSigningRequest {
  export const apiVersion = "certificates.k8s.io/v1beta1";
  export const group = "certificates.k8s.io";
  export const version = "v1beta1";
  export const kind = "CertificateSigningRequest";

  // named constructs a CertificateSigningRequest with metadata.name set to name.
  export function named(name: string): CertificateSigningRequest {
    return new CertificateSigningRequest({ metadata: { name } });
  }
  // Describes a certificate signing request
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // The certificate request itself and any additional information.
    spec?: CertificateSigningRequestSpec;

    // Derived information about the request.
    status?: CertificateSigningRequestStatus;
  }
}

export class CertificateSigningRequestCondition {
  // timestamp for the last update to this condition
  public lastUpdateTime?: apisMetaV1.Time;

  // human readable message with details about the request state
  public message?: string;

  // brief reason for the request state
  public reason?: string;

  // request approval state, currently Approved or Denied.
  public type: string;

  constructor(desc: CertificateSigningRequestCondition) {
    this.lastUpdateTime = desc.lastUpdateTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.type = desc.type;
  }
}

export class CertificateSigningRequestList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  public items: CertificateSigningRequest[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: CertificateSigningRequestList) {
    this.apiVersion = CertificateSigningRequestList.apiVersion;
    this.items = desc.items.map(i => new CertificateSigningRequest(i));
    this.kind = CertificateSigningRequestList.kind;
    this.metadata = desc.metadata;
  }
}

export function isCertificateSigningRequestList(
  o: any
): o is CertificateSigningRequestList {
  return (
    o &&
    o.apiVersion === CertificateSigningRequestList.apiVersion &&
    o.kind === CertificateSigningRequestList.kind
  );
}

export namespace CertificateSigningRequestList {
  export const apiVersion = "certificates.k8s.io/v1beta1";
  export const group = "certificates.k8s.io";
  export const version = "v1beta1";
  export const kind = "CertificateSigningRequestList";

  export interface Interface {
    items: CertificateSigningRequest[];

    metadata?: apisMetaV1.ListMeta;
  }
}

// This information is immutable after the request is created. Only the Request and Usages fields can be set on creation, other fields are derived by Kubernetes and cannot be modified by users.
export class CertificateSigningRequestSpec {
  // Extra information about the requesting user. See user.Info interface for details.
  public extra?: { [key: string]: string[] };

  // Group information about the requesting user. See user.Info interface for details.
  public groups?: string[];

  // Base64-encoded PKCS#10 CSR data
  public request: string;

  // UID information about the requesting user. See user.Info interface for details.
  public uid?: string;

  // allowedUsages specifies a set of usage contexts the key will be valid for. See: https://tools.ietf.org/html/rfc5280#section-4.2.1.3
  //      https://tools.ietf.org/html/rfc5280#section-4.2.1.12
  public usages?: string[];

  // Information about the requesting user. See user.Info interface for details.
  public username?: string;

  constructor(desc: CertificateSigningRequestSpec) {
    this.extra = desc.extra;
    this.groups = desc.groups;
    this.request = desc.request;
    this.uid = desc.uid;
    this.usages = desc.usages;
    this.username = desc.username;
  }
}

export class CertificateSigningRequestStatus {
  // If request was approved, the controller will place the issued certificate here.
  public certificate?: string;

  // Conditions applied to the request, such as approval or denial.
  public conditions?: CertificateSigningRequestCondition[];
}
