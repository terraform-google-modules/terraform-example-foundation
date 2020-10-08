import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// CrossVersionObjectReference contains enough information to let you identify the referred resource.
export class CrossVersionObjectReference {
  // API version of the referent
  public apiVersion?: string;

  // Kind of the referent; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds"
  public kind: string;

  // Name of the referent; More info: http://kubernetes.io/docs/user-guide/identifiers#names
  public name: string;

  constructor(desc: CrossVersionObjectReference) {
    this.apiVersion = desc.apiVersion;
    this.kind = desc.kind;
    this.name = desc.name;
  }
}

// configuration of a horizontal pod autoscaler.
export class HorizontalPodAutoscaler implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // behaviour of autoscaler. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.
  public spec?: HorizontalPodAutoscalerSpec;

  // current information about the autoscaler.
  public status?: HorizontalPodAutoscalerStatus;

  constructor(desc: HorizontalPodAutoscaler.Interface) {
    this.apiVersion = HorizontalPodAutoscaler.apiVersion;
    this.kind = HorizontalPodAutoscaler.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isHorizontalPodAutoscaler(
  o: any
): o is HorizontalPodAutoscaler {
  return (
    o &&
    o.apiVersion === HorizontalPodAutoscaler.apiVersion &&
    o.kind === HorizontalPodAutoscaler.kind
  );
}

export namespace HorizontalPodAutoscaler {
  export const apiVersion = "autoscaling/v1";
  export const group = "autoscaling";
  export const version = "v1";
  export const kind = "HorizontalPodAutoscaler";

  // named constructs a HorizontalPodAutoscaler with metadata.name set to name.
  export function named(name: string): HorizontalPodAutoscaler {
    return new HorizontalPodAutoscaler({ metadata: { name } });
  }
  // configuration of a horizontal pod autoscaler.
  export interface Interface {
    // Standard object metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // behaviour of autoscaler. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.
    spec?: HorizontalPodAutoscalerSpec;

    // current information about the autoscaler.
    status?: HorizontalPodAutoscalerStatus;
  }
}

// list of horizontal pod autoscaler objects.
export class HorizontalPodAutoscalerList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // list of horizontal pod autoscaler objects.
  public items: HorizontalPodAutoscaler[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata.
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: HorizontalPodAutoscalerList) {
    this.apiVersion = HorizontalPodAutoscalerList.apiVersion;
    this.items = desc.items.map(i => new HorizontalPodAutoscaler(i));
    this.kind = HorizontalPodAutoscalerList.kind;
    this.metadata = desc.metadata;
  }
}

export function isHorizontalPodAutoscalerList(
  o: any
): o is HorizontalPodAutoscalerList {
  return (
    o &&
    o.apiVersion === HorizontalPodAutoscalerList.apiVersion &&
    o.kind === HorizontalPodAutoscalerList.kind
  );
}

export namespace HorizontalPodAutoscalerList {
  export const apiVersion = "autoscaling/v1";
  export const group = "autoscaling";
  export const version = "v1";
  export const kind = "HorizontalPodAutoscalerList";

  // list of horizontal pod autoscaler objects.
  export interface Interface {
    // list of horizontal pod autoscaler objects.
    items: HorizontalPodAutoscaler[];

    // Standard list metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}

// specification of a horizontal pod autoscaler.
export class HorizontalPodAutoscalerSpec {
  // upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than MinReplicas.
  public maxReplicas: number;

  // lower limit for the number of pods that can be set by the autoscaler, default 1.
  public minReplicas?: number;

  // reference to scaled resource; horizontal pod autoscaler will learn the current resource consumption and will set the desired number of pods by using its Scale subresource.
  public scaleTargetRef: CrossVersionObjectReference;

  // target average CPU utilization (represented as a percentage of requested CPU) over all the pods; if not specified the default autoscaling policy will be used.
  public targetCPUUtilizationPercentage?: number;

  constructor(desc: HorizontalPodAutoscalerSpec) {
    this.maxReplicas = desc.maxReplicas;
    this.minReplicas = desc.minReplicas;
    this.scaleTargetRef = desc.scaleTargetRef;
    this.targetCPUUtilizationPercentage = desc.targetCPUUtilizationPercentage;
  }
}

// current status of a horizontal pod autoscaler
export class HorizontalPodAutoscalerStatus {
  // current average CPU utilization over all pods, represented as a percentage of requested CPU, e.g. 70 means that an average pod is using now 70% of its requested CPU.
  public currentCPUUtilizationPercentage?: number;

  // current number of replicas of pods managed by this autoscaler.
  public currentReplicas: number;

  // desired number of replicas of pods managed by this autoscaler.
  public desiredReplicas: number;

  // last time the HorizontalPodAutoscaler scaled the number of pods; used by the autoscaler to control how often the number of pods is changed.
  public lastScaleTime?: apisMetaV1.Time;

  // most recent generation observed by this autoscaler.
  public observedGeneration?: number;

  constructor(desc: HorizontalPodAutoscalerStatus) {
    this.currentCPUUtilizationPercentage = desc.currentCPUUtilizationPercentage;
    this.currentReplicas = desc.currentReplicas;
    this.desiredReplicas = desc.desiredReplicas;
    this.lastScaleTime = desc.lastScaleTime;
    this.observedGeneration = desc.observedGeneration;
  }
}

// Scale represents a scaling request for a resource.
export class Scale implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.
  public spec?: ScaleSpec;

  // current status of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status. Read-only.
  public status?: ScaleStatus;

  constructor(desc: Scale.Interface) {
    this.apiVersion = Scale.apiVersion;
    this.kind = Scale.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isScale(o: any): o is Scale {
  return o && o.apiVersion === Scale.apiVersion && o.kind === Scale.kind;
}

export namespace Scale {
  export const apiVersion = "autoscaling/v1";
  export const group = "autoscaling";
  export const version = "v1";
  export const kind = "Scale";

  // named constructs a Scale with metadata.name set to name.
  export function named(name: string): Scale {
    return new Scale({ metadata: { name } });
  }
  // Scale represents a scaling request for a resource.
  export interface Interface {
    // Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.
    metadata: apisMetaV1.ObjectMeta;

    // defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.
    spec?: ScaleSpec;

    // current status of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status. Read-only.
    status?: ScaleStatus;
  }
}

// ScaleSpec describes the attributes of a scale subresource.
export class ScaleSpec {
  // desired number of instances for the scaled object.
  public replicas?: number;
}

// ScaleStatus represents the current status of a scale subresource.
export class ScaleStatus {
  // actual number of observed instances of the scaled object.
  public replicas: number;

  // label query over pods that should match the replicas count. This is same as the label selector but in the string format to avoid introspection by clients. The string will be in the same format as the query-param syntax. More info about label selectors: http://kubernetes.io/docs/user-guide/labels#label-selectors
  public selector?: string;

  constructor(desc: ScaleStatus) {
    this.replicas = desc.replicas;
    this.selector = desc.selector;
  }
}
