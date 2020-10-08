import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// DEPRECATED - This group version of PriorityClass is deprecated by scheduling.k8s.io/v1/PriorityClass. PriorityClass defines mapping from a priority class name to the priority integer value. The value can be any valid integer.
export class PriorityClass implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // description is an arbitrary string that usually provides guidelines on when this priority class should be used.
  public description?: string;

  // globalDefault specifies whether this PriorityClass should be considered as the default priority for pods that do not have any priority class. Only one PriorityClass can be marked as `globalDefault`. However, if more than one PriorityClasses exists with their `globalDefault` field set to true, the smallest value of such global default PriorityClasses will be used as the default priority.
  public globalDefault?: boolean;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // The value of this priority class. This is the actual priority that pods receive when they have the name of this class in their pod spec.
  public value: number;

  constructor(desc: PriorityClass.Interface) {
    this.apiVersion = PriorityClass.apiVersion;
    this.description = desc.description;
    this.globalDefault = desc.globalDefault;
    this.kind = PriorityClass.kind;
    this.metadata = desc.metadata;
    this.value = desc.value;
  }
}

export function isPriorityClass(o: any): o is PriorityClass {
  return (
    o &&
    o.apiVersion === PriorityClass.apiVersion &&
    o.kind === PriorityClass.kind
  );
}

export namespace PriorityClass {
  export const apiVersion = "scheduling.k8s.io/v1beta1";
  export const group = "scheduling.k8s.io";
  export const version = "v1beta1";
  export const kind = "PriorityClass";

  // DEPRECATED - This group version of PriorityClass is deprecated by scheduling.k8s.io/v1/PriorityClass. PriorityClass defines mapping from a priority class name to the priority integer value. The value can be any valid integer.
  export interface Interface {
    // description is an arbitrary string that usually provides guidelines on when this priority class should be used.
    description?: string;

    // globalDefault specifies whether this PriorityClass should be considered as the default priority for pods that do not have any priority class. Only one PriorityClass can be marked as `globalDefault`. However, if more than one PriorityClasses exists with their `globalDefault` field set to true, the smallest value of such global default PriorityClasses will be used as the default priority.
    globalDefault?: boolean;

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // The value of this priority class. This is the actual priority that pods receive when they have the name of this class in their pod spec.
    value: number;
  }
}

// PriorityClassList is a collection of priority classes.
export class PriorityClassList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // items is the list of PriorityClasses
  public items: PriorityClass[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: PriorityClassList) {
    this.apiVersion = PriorityClassList.apiVersion;
    this.items = desc.items.map(i => new PriorityClass(i));
    this.kind = PriorityClassList.kind;
    this.metadata = desc.metadata;
  }
}

export function isPriorityClassList(o: any): o is PriorityClassList {
  return (
    o &&
    o.apiVersion === PriorityClassList.apiVersion &&
    o.kind === PriorityClassList.kind
  );
}

export namespace PriorityClassList {
  export const apiVersion = "scheduling.k8s.io/v1beta1";
  export const group = "scheduling.k8s.io";
  export const version = "v1beta1";
  export const kind = "PriorityClassList";

  // PriorityClassList is a collection of priority classes.
  export interface Interface {
    // items is the list of PriorityClasses
    items: PriorityClass[];

    // Standard list metadata More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}
