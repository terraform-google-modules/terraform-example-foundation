import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// Lease defines a lease concept.
export class Lease implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Specification of the Lease. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: LeaseSpec;

  constructor(desc: Lease.Interface) {
    this.apiVersion = Lease.apiVersion;
    this.kind = Lease.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
  }
}

export function isLease(o: any): o is Lease {
  return o && o.apiVersion === Lease.apiVersion && o.kind === Lease.kind;
}

export namespace Lease {
  export const apiVersion = "coordination.k8s.io/v1";
  export const group = "coordination.k8s.io";
  export const version = "v1";
  export const kind = "Lease";

  // named constructs a Lease with metadata.name set to name.
  export function named(name: string): Lease {
    return new Lease({ metadata: { name } });
  }
  // Lease defines a lease concept.
  export interface Interface {
    // More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the Lease. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: LeaseSpec;
  }
}

// LeaseList is a list of Lease objects.
export class LeaseList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of schema objects.
  public items: Lease[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: LeaseList) {
    this.apiVersion = LeaseList.apiVersion;
    this.items = desc.items.map(i => new Lease(i));
    this.kind = LeaseList.kind;
    this.metadata = desc.metadata;
  }
}

export function isLeaseList(o: any): o is LeaseList {
  return (
    o && o.apiVersion === LeaseList.apiVersion && o.kind === LeaseList.kind
  );
}

export namespace LeaseList {
  export const apiVersion = "coordination.k8s.io/v1";
  export const group = "coordination.k8s.io";
  export const version = "v1";
  export const kind = "LeaseList";

  // LeaseList is a list of Lease objects.
  export interface Interface {
    // Items is a list of schema objects.
    items: Lease[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// LeaseSpec is a specification of a Lease.
export class LeaseSpec {
  // acquireTime is a time when the current lease was acquired.
  public acquireTime?: apisMetaV1.MicroTime;

  // holderIdentity contains the identity of the holder of a current lease.
  public holderIdentity?: string;

  // leaseDurationSeconds is a duration that candidates for a lease need to wait to force acquire it. This is measure against time of last observed RenewTime.
  public leaseDurationSeconds?: number;

  // leaseTransitions is the number of transitions of a lease between holders.
  public leaseTransitions?: number;

  // renewTime is a time when the current holder of a lease has last updated the lease.
  public renewTime?: apisMetaV1.MicroTime;
}
