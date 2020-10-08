import { KubernetesObject } from "kpt-functions";
import * as apiCoreV1 from "./io.k8s.api.core.v1";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";
import * as pkgUtilIntstr from "./io.k8s.apimachinery.pkg.util.intstr";

// AllowedCSIDriver represents a single inline CSI Driver that is allowed to be used.
export class AllowedCSIDriver {
  // Name is the registered name of the CSI driver
  public name: string;

  constructor(desc: AllowedCSIDriver) {
    this.name = desc.name;
  }
}

// AllowedFlexVolume represents a single Flexvolume that is allowed to be used. Deprecated: use AllowedFlexVolume from policy API Group instead.
export class AllowedFlexVolume {
  // driver is the name of the Flexvolume driver.
  public driver: string;

  constructor(desc: AllowedFlexVolume) {
    this.driver = desc.driver;
  }
}

// AllowedHostPath defines the host volume conditions that will be enabled by a policy for pods to use. It requires the path prefix to be defined. Deprecated: use AllowedHostPath from policy API Group instead.
export class AllowedHostPath {
  // pathPrefix is the path prefix that the host volume must match. It does not support `*`. Trailing slashes are trimmed when validating the path prefix with a host path.
  //
  // Examples: `/foo` would allow `/foo`, `/foo/` and `/foo/bar` `/foo` would not allow `/food` or `/etc/foo`
  public pathPrefix?: string;

  // when set to true, will allow host volumes matching the pathPrefix only if all volume mounts are readOnly.
  public readOnly?: boolean;
}

// DEPRECATED - This group version of DaemonSet is deprecated by apps/v1beta2/DaemonSet. See the release notes for more information. DaemonSet represents the configuration of a daemon set.
export class DaemonSet implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // The desired behavior of this daemon set. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
  public spec?: DaemonSetSpec;

  // The current status of this daemon set. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
  public status?: DaemonSetStatus;

  constructor(desc: DaemonSet.Interface) {
    this.apiVersion = DaemonSet.apiVersion;
    this.kind = DaemonSet.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isDaemonSet(o: any): o is DaemonSet {
  return (
    o && o.apiVersion === DaemonSet.apiVersion && o.kind === DaemonSet.kind
  );
}

export namespace DaemonSet {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "DaemonSet";

  // named constructs a DaemonSet with metadata.name set to name.
  export function named(name: string): DaemonSet {
    return new DaemonSet({ metadata: { name } });
  }
  // DEPRECATED - This group version of DaemonSet is deprecated by apps/v1beta2/DaemonSet. See the release notes for more information. DaemonSet represents the configuration of a daemon set.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // The desired behavior of this daemon set. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
    spec?: DaemonSetSpec;

    // The current status of this daemon set. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
    status?: DaemonSetStatus;
  }
}

// DaemonSetCondition describes the state of a DaemonSet at a certain point.
export class DaemonSetCondition {
  // Last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // A human readable message indicating details about the transition.
  public message?: string;

  // The reason for the condition's last transition.
  public reason?: string;

  // Status of the condition, one of True, False, Unknown.
  public status: string;

  // Type of DaemonSet condition.
  public type: string;

  constructor(desc: DaemonSetCondition) {
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// DaemonSetList is a collection of daemon sets.
export class DaemonSetList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // A list of daemon sets.
  public items: DaemonSet[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: DaemonSetList) {
    this.apiVersion = DaemonSetList.apiVersion;
    this.items = desc.items.map(i => new DaemonSet(i));
    this.kind = DaemonSetList.kind;
    this.metadata = desc.metadata;
  }
}

export function isDaemonSetList(o: any): o is DaemonSetList {
  return (
    o &&
    o.apiVersion === DaemonSetList.apiVersion &&
    o.kind === DaemonSetList.kind
  );
}

export namespace DaemonSetList {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "DaemonSetList";

  // DaemonSetList is a collection of daemon sets.
  export interface Interface {
    // A list of daemon sets.
    items: DaemonSet[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// DaemonSetSpec is the specification of a daemon set.
export class DaemonSetSpec {
  // The minimum number of seconds for which a newly created DaemonSet pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready).
  public minReadySeconds?: number;

  // The number of old history to retain to allow rollback. This is a pointer to distinguish between explicit zero and not specified. Defaults to 10.
  public revisionHistoryLimit?: number;

  // A label query over pods that are managed by the daemon set. Must match in order to be controlled. If empty, defaulted to labels on Pod template. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public selector?: apisMetaV1.LabelSelector;

  // An object that describes the pod that will be created. The DaemonSet will create exactly one copy of this pod on every node that matches the template's node selector (or on every node if no node selector is specified). More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template
  public template: apiCoreV1.PodTemplateSpec;

  // DEPRECATED. A sequence number representing a specific generation of the template. Populated by the system. It can be set only during the creation.
  public templateGeneration?: number;

  // An update strategy to replace existing DaemonSet pods with new pods.
  public updateStrategy?: DaemonSetUpdateStrategy;

  constructor(desc: DaemonSetSpec) {
    this.minReadySeconds = desc.minReadySeconds;
    this.revisionHistoryLimit = desc.revisionHistoryLimit;
    this.selector = desc.selector;
    this.template = desc.template;
    this.templateGeneration = desc.templateGeneration;
    this.updateStrategy = desc.updateStrategy;
  }
}

// DaemonSetStatus represents the current status of a daemon set.
export class DaemonSetStatus {
  // Count of hash collisions for the DaemonSet. The DaemonSet controller uses this field as a collision avoidance mechanism when it needs to create the name for the newest ControllerRevision.
  public collisionCount?: number;

  // Represents the latest available observations of a DaemonSet's current state.
  public conditions?: DaemonSetCondition[];

  // The number of nodes that are running at least 1 daemon pod and are supposed to run the daemon pod. More info: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
  public currentNumberScheduled: number;

  // The total number of nodes that should be running the daemon pod (including nodes correctly running the daemon pod). More info: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
  public desiredNumberScheduled: number;

  // The number of nodes that should be running the daemon pod and have one or more of the daemon pod running and available (ready for at least spec.minReadySeconds)
  public numberAvailable?: number;

  // The number of nodes that are running the daemon pod, but are not supposed to run the daemon pod. More info: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
  public numberMisscheduled: number;

  // The number of nodes that should be running the daemon pod and have one or more of the daemon pod running and ready.
  public numberReady: number;

  // The number of nodes that should be running the daemon pod and have none of the daemon pod running and available (ready for at least spec.minReadySeconds)
  public numberUnavailable?: number;

  // The most recent generation observed by the daemon set controller.
  public observedGeneration?: number;

  // The total number of nodes that are running updated daemon pod
  public updatedNumberScheduled?: number;

  constructor(desc: DaemonSetStatus) {
    this.collisionCount = desc.collisionCount;
    this.conditions = desc.conditions;
    this.currentNumberScheduled = desc.currentNumberScheduled;
    this.desiredNumberScheduled = desc.desiredNumberScheduled;
    this.numberAvailable = desc.numberAvailable;
    this.numberMisscheduled = desc.numberMisscheduled;
    this.numberReady = desc.numberReady;
    this.numberUnavailable = desc.numberUnavailable;
    this.observedGeneration = desc.observedGeneration;
    this.updatedNumberScheduled = desc.updatedNumberScheduled;
  }
}

export class DaemonSetUpdateStrategy {
  // Rolling update config params. Present only if type = "RollingUpdate".
  public rollingUpdate?: RollingUpdateDaemonSet;

  // Type of daemon set update. Can be "RollingUpdate" or "OnDelete". Default is OnDelete.
  public type?: string;
}

// DEPRECATED - This group version of Deployment is deprecated by apps/v1beta2/Deployment. See the release notes for more information. Deployment enables declarative updates for Pods and ReplicaSets.
export class Deployment implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior of the Deployment.
  public spec?: DeploymentSpec;

  // Most recently observed status of the Deployment.
  public status?: DeploymentStatus;

  constructor(desc: Deployment.Interface) {
    this.apiVersion = Deployment.apiVersion;
    this.kind = Deployment.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isDeployment(o: any): o is Deployment {
  return (
    o && o.apiVersion === Deployment.apiVersion && o.kind === Deployment.kind
  );
}

export namespace Deployment {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "Deployment";

  // named constructs a Deployment with metadata.name set to name.
  export function named(name: string): Deployment {
    return new Deployment({ metadata: { name } });
  }
  // DEPRECATED - This group version of Deployment is deprecated by apps/v1beta2/Deployment. See the release notes for more information. Deployment enables declarative updates for Pods and ReplicaSets.
  export interface Interface {
    // Standard object metadata.
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the desired behavior of the Deployment.
    spec?: DeploymentSpec;

    // Most recently observed status of the Deployment.
    status?: DeploymentStatus;
  }
}

// DeploymentCondition describes the state of a deployment at a certain point.
export class DeploymentCondition {
  // Last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // The last time this condition was updated.
  public lastUpdateTime?: apisMetaV1.Time;

  // A human readable message indicating details about the transition.
  public message?: string;

  // The reason for the condition's last transition.
  public reason?: string;

  // Status of the condition, one of True, False, Unknown.
  public status: string;

  // Type of deployment condition.
  public type: string;

  constructor(desc: DeploymentCondition) {
    this.lastTransitionTime = desc.lastTransitionTime;
    this.lastUpdateTime = desc.lastUpdateTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// DeploymentList is a list of Deployments.
export class DeploymentList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is the list of Deployments.
  public items: Deployment[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata.
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: DeploymentList) {
    this.apiVersion = DeploymentList.apiVersion;
    this.items = desc.items.map(i => new Deployment(i));
    this.kind = DeploymentList.kind;
    this.metadata = desc.metadata;
  }
}

export function isDeploymentList(o: any): o is DeploymentList {
  return (
    o &&
    o.apiVersion === DeploymentList.apiVersion &&
    o.kind === DeploymentList.kind
  );
}

export namespace DeploymentList {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "DeploymentList";

  // DeploymentList is a list of Deployments.
  export interface Interface {
    // Items is the list of Deployments.
    items: Deployment[];

    // Standard list metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}

// DEPRECATED. DeploymentRollback stores the information required to rollback a deployment.
export class DeploymentRollback {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Required: This must match the Name of a deployment.
  public name: string;

  // The config of this deployment rollback.
  public rollbackTo: RollbackConfig;

  // The annotations to be updated to a deployment
  public updatedAnnotations?: { [key: string]: string };

  constructor(desc: DeploymentRollback) {
    this.apiVersion = DeploymentRollback.apiVersion;
    this.kind = DeploymentRollback.kind;
    this.name = desc.name;
    this.rollbackTo = desc.rollbackTo;
    this.updatedAnnotations = desc.updatedAnnotations;
  }
}

export function isDeploymentRollback(o: any): o is DeploymentRollback {
  return (
    o &&
    o.apiVersion === DeploymentRollback.apiVersion &&
    o.kind === DeploymentRollback.kind
  );
}

export namespace DeploymentRollback {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "DeploymentRollback";

  // DEPRECATED. DeploymentRollback stores the information required to rollback a deployment.
  export interface Interface {
    // Required: This must match the Name of a deployment.
    name: string;

    // The config of this deployment rollback.
    rollbackTo: RollbackConfig;

    // The annotations to be updated to a deployment
    updatedAnnotations?: { [key: string]: string };
  }
}

// DeploymentSpec is the specification of the desired behavior of the Deployment.
export class DeploymentSpec {
  // Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)
  public minReadySeconds?: number;

  // Indicates that the deployment is paused and will not be processed by the deployment controller.
  public paused?: boolean;

  // The maximum time in seconds for a deployment to make progress before it is considered to be failed. The deployment controller will continue to process failed deployments and a condition with a ProgressDeadlineExceeded reason will be surfaced in the deployment status. Note that progress will not be estimated during the time a deployment is paused. This is set to the max value of int32 (i.e. 2147483647) by default, which means "no deadline".
  public progressDeadlineSeconds?: number;

  // Number of desired pods. This is a pointer to distinguish between explicit zero and not specified. Defaults to 1.
  public replicas?: number;

  // The number of old ReplicaSets to retain to allow rollback. This is a pointer to distinguish between explicit zero and not specified. This is set to the max value of int32 (i.e. 2147483647) by default, which means "retaining all old RelicaSets".
  public revisionHistoryLimit?: number;

  // DEPRECATED. The config this deployment is rolling back to. Will be cleared after rollback is done.
  public rollbackTo?: RollbackConfig;

  // Label selector for pods. Existing ReplicaSets whose pods are selected by this will be the ones affected by this deployment.
  public selector?: apisMetaV1.LabelSelector;

  // The deployment strategy to use to replace existing pods with new ones.
  public strategy?: DeploymentStrategy;

  // Template describes the pods that will be created.
  public template: apiCoreV1.PodTemplateSpec;

  constructor(desc: DeploymentSpec) {
    this.minReadySeconds = desc.minReadySeconds;
    this.paused = desc.paused;
    this.progressDeadlineSeconds = desc.progressDeadlineSeconds;
    this.replicas = desc.replicas;
    this.revisionHistoryLimit = desc.revisionHistoryLimit;
    this.rollbackTo = desc.rollbackTo;
    this.selector = desc.selector;
    this.strategy = desc.strategy;
    this.template = desc.template;
  }
}

// DeploymentStatus is the most recently observed status of the Deployment.
export class DeploymentStatus {
  // Total number of available pods (ready for at least minReadySeconds) targeted by this deployment.
  public availableReplicas?: number;

  // Count of hash collisions for the Deployment. The Deployment controller uses this field as a collision avoidance mechanism when it needs to create the name for the newest ReplicaSet.
  public collisionCount?: number;

  // Represents the latest available observations of a deployment's current state.
  public conditions?: DeploymentCondition[];

  // The generation observed by the deployment controller.
  public observedGeneration?: number;

  // Total number of ready pods targeted by this deployment.
  public readyReplicas?: number;

  // Total number of non-terminated pods targeted by this deployment (their labels match the selector).
  public replicas?: number;

  // Total number of unavailable pods targeted by this deployment. This is the total number of pods that are still required for the deployment to have 100% available capacity. They may either be pods that are running but not yet available or pods that still have not been created.
  public unavailableReplicas?: number;

  // Total number of non-terminated pods targeted by this deployment that have the desired template spec.
  public updatedReplicas?: number;
}

// DeploymentStrategy describes how to replace existing pods with new ones.
export class DeploymentStrategy {
  // Rolling update config params. Present only if DeploymentStrategyType = RollingUpdate.
  public rollingUpdate?: RollingUpdateDeployment;

  // Type of deployment. Can be "Recreate" or "RollingUpdate". Default is RollingUpdate.
  public type?: string;
}

// FSGroupStrategyOptions defines the strategy type and options used to create the strategy. Deprecated: use FSGroupStrategyOptions from policy API Group instead.
export class FSGroupStrategyOptions {
  // ranges are the allowed ranges of fs groups.  If you would like to force a single fs group then supply a single range with the same start and end. Required for MustRunAs.
  public ranges?: IDRange[];

  // rule is the strategy that will dictate what FSGroup is used in the SecurityContext.
  public rule?: string;
}

// HTTPIngressPath associates a path regex with a backend. Incoming urls matching the path are forwarded to the backend.
export class HTTPIngressPath {
  // Backend defines the referenced service endpoint to which the traffic will be forwarded to.
  public backend: IngressBackend;

  // Path is an extended POSIX regex as defined by IEEE Std 1003.1, (i.e this follows the egrep/unix syntax, not the perl syntax) matched against the path of an incoming request. Currently it can contain characters disallowed from the conventional "path" part of a URL as defined by RFC 3986. Paths must begin with a '/'. If unspecified, the path defaults to a catch all sending traffic to the backend.
  public path?: string;

  constructor(desc: HTTPIngressPath) {
    this.backend = desc.backend;
    this.path = desc.path;
  }
}

// HTTPIngressRuleValue is a list of http selectors pointing to backends. In the example: http://<host>/<path>?<searchpart> -> backend where where parts of the url correspond to RFC 3986, this resource will be used to match against everything after the last '/' and before the first '?' or '#'.
export class HTTPIngressRuleValue {
  // A collection of paths that map requests to backends.
  public paths: HTTPIngressPath[];

  constructor(desc: HTTPIngressRuleValue) {
    this.paths = desc.paths;
  }
}

// HostPortRange defines a range of host ports that will be enabled by a policy for pods to use.  It requires both the start and end to be defined. Deprecated: use HostPortRange from policy API Group instead.
export class HostPortRange {
  // max is the end of the range, inclusive.
  public max: number;

  // min is the start of the range, inclusive.
  public min: number;

  constructor(desc: HostPortRange) {
    this.max = desc.max;
    this.min = desc.min;
  }
}

// IDRange provides a min/max of an allowed range of IDs. Deprecated: use IDRange from policy API Group instead.
export class IDRange {
  // max is the end of the range, inclusive.
  public max: number;

  // min is the start of the range, inclusive.
  public min: number;

  constructor(desc: IDRange) {
    this.max = desc.max;
    this.min = desc.min;
  }
}

// DEPRECATED 1.9 - This group version of IPBlock is deprecated by networking/v1/IPBlock. IPBlock describes a particular CIDR (Ex. "192.168.1.1/24") that is allowed to the pods matched by a NetworkPolicySpec's podSelector. The except entry describes CIDRs that should not be included within this rule.
export class IPBlock {
  // CIDR is a string representing the IP Block Valid examples are "192.168.1.1/24"
  public cidr: string;

  // Except is a slice of CIDRs that should not be included within an IP Block Valid examples are "192.168.1.1/24" Except values will be rejected if they are outside the CIDR range
  public except?: string[];

  constructor(desc: IPBlock) {
    this.cidr = desc.cidr;
    this.except = desc.except;
  }
}

// Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc. DEPRECATED - This group version of Ingress is deprecated by networking.k8s.io/v1beta1 Ingress. See the release notes for more information.
export class Ingress implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec is the desired state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
  public spec?: IngressSpec;

  // Status is the current state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
  public status?: IngressStatus;

  constructor(desc: Ingress.Interface) {
    this.apiVersion = Ingress.apiVersion;
    this.kind = Ingress.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isIngress(o: any): o is Ingress {
  return o && o.apiVersion === Ingress.apiVersion && o.kind === Ingress.kind;
}

export namespace Ingress {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "Ingress";

  // named constructs a Ingress with metadata.name set to name.
  export function named(name: string): Ingress {
    return new Ingress({ metadata: { name } });
  }
  // Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc. DEPRECATED - This group version of Ingress is deprecated by networking.k8s.io/v1beta1 Ingress. See the release notes for more information.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec is the desired state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
    spec?: IngressSpec;

    // Status is the current state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
    status?: IngressStatus;
  }
}

// IngressBackend describes all endpoints for a given service and port.
export class IngressBackend {
  // Specifies the name of the referenced service.
  public serviceName: string;

  // Specifies the port of the referenced service.
  public servicePort: pkgUtilIntstr.IntOrString;

  constructor(desc: IngressBackend) {
    this.serviceName = desc.serviceName;
    this.servicePort = desc.servicePort;
  }
}

// IngressList is a collection of Ingress.
export class IngressList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is the list of Ingress.
  public items: Ingress[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: IngressList) {
    this.apiVersion = IngressList.apiVersion;
    this.items = desc.items.map(i => new Ingress(i));
    this.kind = IngressList.kind;
    this.metadata = desc.metadata;
  }
}

export function isIngressList(o: any): o is IngressList {
  return (
    o && o.apiVersion === IngressList.apiVersion && o.kind === IngressList.kind
  );
}

export namespace IngressList {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "IngressList";

  // IngressList is a collection of Ingress.
  export interface Interface {
    // Items is the list of Ingress.
    items: Ingress[];

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// IngressRule represents the rules mapping the paths under a specified host to the related backend services. Incoming requests are first evaluated for a host match, then routed to the backend associated with the matching IngressRuleValue.
export class IngressRule {
  // Host is the fully qualified domain name of a network host, as defined by RFC 3986. Note the following deviations from the "host" part of the URI as defined in the RFC: 1. IPs are not allowed. Currently an IngressRuleValue can only apply to the
  // 	  IP in the Spec of the parent Ingress.
  // 2. The `:` delimiter is not respected because ports are not allowed.
  // 	  Currently the port of an Ingress is implicitly :80 for http and
  // 	  :443 for https.
  // Both these may change in the future. Incoming requests are matched against the host before the IngressRuleValue. If the host is unspecified, the Ingress routes all traffic based on the specified IngressRuleValue.
  public host?: string;

  public http?: HTTPIngressRuleValue;
}

// IngressSpec describes the Ingress the user wishes to exist.
export class IngressSpec {
  // A default backend capable of servicing requests that don't match any rule. At least one of 'backend' or 'rules' must be specified. This field is optional to allow the loadbalancer controller or defaulting logic to specify a global default.
  public backend?: IngressBackend;

  // A list of host rules used to configure the Ingress. If unspecified, or no rule matches, all traffic is sent to the default backend.
  public rules?: IngressRule[];

  // TLS configuration. Currently the Ingress only supports a single TLS port, 443. If multiple members of this list specify different hosts, they will be multiplexed on the same port according to the hostname specified through the SNI TLS extension, if the ingress controller fulfilling the ingress supports SNI.
  public tls?: IngressTLS[];
}

// IngressStatus describe the current state of the Ingress.
export class IngressStatus {
  // LoadBalancer contains the current status of the load-balancer.
  public loadBalancer?: apiCoreV1.LoadBalancerStatus;
}

// IngressTLS describes the transport layer security associated with an Ingress.
export class IngressTLS {
  // Hosts are a list of hosts included in the TLS certificate. The values in this list must match the name/s used in the tlsSecret. Defaults to the wildcard host setting for the loadbalancer controller fulfilling this Ingress, if left unspecified.
  public hosts?: string[];

  // SecretName is the name of the secret used to terminate SSL traffic on 443. Field is left optional to allow SSL routing based on SNI hostname alone. If the SNI host in a listener conflicts with the "Host" header field used by an IngressRule, the SNI host is used for termination and value of the Host header is used for routing.
  public secretName?: string;
}

// DEPRECATED 1.9 - This group version of NetworkPolicy is deprecated by networking/v1/NetworkPolicy. NetworkPolicy describes what network traffic is allowed for a set of Pods
export class NetworkPolicy implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior for this NetworkPolicy.
  public spec?: NetworkPolicySpec;

  constructor(desc: NetworkPolicy.Interface) {
    this.apiVersion = NetworkPolicy.apiVersion;
    this.kind = NetworkPolicy.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
  }
}

export function isNetworkPolicy(o: any): o is NetworkPolicy {
  return (
    o &&
    o.apiVersion === NetworkPolicy.apiVersion &&
    o.kind === NetworkPolicy.kind
  );
}

export namespace NetworkPolicy {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "NetworkPolicy";

  // named constructs a NetworkPolicy with metadata.name set to name.
  export function named(name: string): NetworkPolicy {
    return new NetworkPolicy({ metadata: { name } });
  }
  // DEPRECATED 1.9 - This group version of NetworkPolicy is deprecated by networking/v1/NetworkPolicy. NetworkPolicy describes what network traffic is allowed for a set of Pods
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the desired behavior for this NetworkPolicy.
    spec?: NetworkPolicySpec;
  }
}

// DEPRECATED 1.9 - This group version of NetworkPolicyEgressRule is deprecated by networking/v1/NetworkPolicyEgressRule. NetworkPolicyEgressRule describes a particular set of traffic that is allowed out of pods matched by a NetworkPolicySpec's podSelector. The traffic must match both ports and to. This type is beta-level in 1.8
export class NetworkPolicyEgressRule {
  // List of destination ports for outgoing traffic. Each item in this list is combined using a logical OR. If this field is empty or missing, this rule matches all ports (traffic not restricted by port). If this field is present and contains at least one item, then this rule allows traffic only if the traffic matches at least one port in the list.
  public ports?: NetworkPolicyPort[];

  // List of destinations for outgoing traffic of pods selected for this rule. Items in this list are combined using a logical OR operation. If this field is empty or missing, this rule matches all destinations (traffic not restricted by destination). If this field is present and contains at least one item, this rule allows traffic only if the traffic matches at least one item in the to list.
  public to?: NetworkPolicyPeer[];
}

// DEPRECATED 1.9 - This group version of NetworkPolicyIngressRule is deprecated by networking/v1/NetworkPolicyIngressRule. This NetworkPolicyIngressRule matches traffic if and only if the traffic matches both ports AND from.
export class NetworkPolicyIngressRule {
  // List of sources which should be able to access the pods selected for this rule. Items in this list are combined using a logical OR operation. If this field is empty or missing, this rule matches all sources (traffic not restricted by source). If this field is present and contains at least on item, this rule allows traffic only if the traffic matches at least one item in the from list.
  public from?: NetworkPolicyPeer[];

  // List of ports which should be made accessible on the pods selected for this rule. Each item in this list is combined using a logical OR. If this field is empty or missing, this rule matches all ports (traffic not restricted by port). If this field is present and contains at least one item, then this rule allows traffic only if the traffic matches at least one port in the list.
  public ports?: NetworkPolicyPort[];
}

// DEPRECATED 1.9 - This group version of NetworkPolicyList is deprecated by networking/v1/NetworkPolicyList. Network Policy List is a list of NetworkPolicy objects.
export class NetworkPolicyList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of schema objects.
  public items: NetworkPolicy[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: NetworkPolicyList) {
    this.apiVersion = NetworkPolicyList.apiVersion;
    this.items = desc.items.map(i => new NetworkPolicy(i));
    this.kind = NetworkPolicyList.kind;
    this.metadata = desc.metadata;
  }
}

export function isNetworkPolicyList(o: any): o is NetworkPolicyList {
  return (
    o &&
    o.apiVersion === NetworkPolicyList.apiVersion &&
    o.kind === NetworkPolicyList.kind
  );
}

export namespace NetworkPolicyList {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "NetworkPolicyList";

  // DEPRECATED 1.9 - This group version of NetworkPolicyList is deprecated by networking/v1/NetworkPolicyList. Network Policy List is a list of NetworkPolicy objects.
  export interface Interface {
    // Items is a list of schema objects.
    items: NetworkPolicy[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// DEPRECATED 1.9 - This group version of NetworkPolicyPeer is deprecated by networking/v1/NetworkPolicyPeer.
export class NetworkPolicyPeer {
  // IPBlock defines policy on a particular IPBlock. If this field is set then neither of the other fields can be.
  public ipBlock?: IPBlock;

  // Selects Namespaces using cluster-scoped labels. This field follows standard label selector semantics; if present but empty, it selects all namespaces.
  //
  // If PodSelector is also set, then the NetworkPolicyPeer as a whole selects the Pods matching PodSelector in the Namespaces selected by NamespaceSelector. Otherwise it selects all Pods in the Namespaces selected by NamespaceSelector.
  public namespaceSelector?: apisMetaV1.LabelSelector;

  // This is a label selector which selects Pods. This field follows standard label selector semantics; if present but empty, it selects all pods.
  //
  // If NamespaceSelector is also set, then the NetworkPolicyPeer as a whole selects the Pods matching PodSelector in the Namespaces selected by NamespaceSelector. Otherwise it selects the Pods matching PodSelector in the policy's own Namespace.
  public podSelector?: apisMetaV1.LabelSelector;
}

// DEPRECATED 1.9 - This group version of NetworkPolicyPort is deprecated by networking/v1/NetworkPolicyPort.
export class NetworkPolicyPort {
  // If specified, the port on the given protocol.  This can either be a numerical or named port on a pod.  If this field is not provided, this matches all port names and numbers. If present, only traffic on the specified protocol AND port will be matched.
  public port?: pkgUtilIntstr.IntOrString;

  // Optional.  The protocol (TCP, UDP, or SCTP) which traffic must match. If not specified, this field defaults to TCP.
  public protocol?: string;
}

// DEPRECATED 1.9 - This group version of NetworkPolicySpec is deprecated by networking/v1/NetworkPolicySpec.
export class NetworkPolicySpec {
  // List of egress rules to be applied to the selected pods. Outgoing traffic is allowed if there are no NetworkPolicies selecting the pod (and cluster policy otherwise allows the traffic), OR if the traffic matches at least one egress rule across all of the NetworkPolicy objects whose podSelector matches the pod. If this field is empty then this NetworkPolicy limits all outgoing traffic (and serves solely to ensure that the pods it selects are isolated by default). This field is beta-level in 1.8
  public egress?: NetworkPolicyEgressRule[];

  // List of ingress rules to be applied to the selected pods. Traffic is allowed to a pod if there are no NetworkPolicies selecting the pod OR if the traffic source is the pod's local node, OR if the traffic matches at least one ingress rule across all of the NetworkPolicy objects whose podSelector matches the pod. If this field is empty then this NetworkPolicy does not allow any traffic (and serves solely to ensure that the pods it selects are isolated by default).
  public ingress?: NetworkPolicyIngressRule[];

  // Selects the pods to which this NetworkPolicy object applies.  The array of ingress rules is applied to any pods selected by this field. Multiple network policies can select the same set of pods.  In this case, the ingress rules for each are combined additively. This field is NOT optional and follows standard label selector semantics. An empty podSelector matches all pods in this namespace.
  public podSelector: apisMetaV1.LabelSelector;

  // List of rule types that the NetworkPolicy relates to. Valid options are "Ingress", "Egress", or "Ingress,Egress". If this field is not specified, it will default based on the existence of Ingress or Egress rules; policies that contain an Egress section are assumed to affect Egress, and all policies (whether or not they contain an Ingress section) are assumed to affect Ingress. If you want to write an egress-only policy, you must explicitly specify policyTypes [ "Egress" ]. Likewise, if you want to write a policy that specifies that no egress is allowed, you must specify a policyTypes value that include "Egress" (since such a policy would not include an Egress section and would otherwise default to just [ "Ingress" ]). This field is beta-level in 1.8
  public policyTypes?: string[];

  constructor(desc: NetworkPolicySpec) {
    this.egress = desc.egress;
    this.ingress = desc.ingress;
    this.podSelector = desc.podSelector;
    this.policyTypes = desc.policyTypes;
  }
}

// PodSecurityPolicy governs the ability to make requests that affect the Security Context that will be applied to a pod and container. Deprecated: use PodSecurityPolicy from policy API Group instead.
export class PodSecurityPolicy implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // spec defines the policy enforced.
  public spec?: PodSecurityPolicySpec;

  constructor(desc: PodSecurityPolicy.Interface) {
    this.apiVersion = PodSecurityPolicy.apiVersion;
    this.kind = PodSecurityPolicy.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
  }
}

export function isPodSecurityPolicy(o: any): o is PodSecurityPolicy {
  return (
    o &&
    o.apiVersion === PodSecurityPolicy.apiVersion &&
    o.kind === PodSecurityPolicy.kind
  );
}

export namespace PodSecurityPolicy {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "PodSecurityPolicy";

  // named constructs a PodSecurityPolicy with metadata.name set to name.
  export function named(name: string): PodSecurityPolicy {
    return new PodSecurityPolicy({ metadata: { name } });
  }
  // PodSecurityPolicy governs the ability to make requests that affect the Security Context that will be applied to a pod and container. Deprecated: use PodSecurityPolicy from policy API Group instead.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // spec defines the policy enforced.
    spec?: PodSecurityPolicySpec;
  }
}

// PodSecurityPolicyList is a list of PodSecurityPolicy objects. Deprecated: use PodSecurityPolicyList from policy API Group instead.
export class PodSecurityPolicyList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // items is a list of schema objects.
  public items: PodSecurityPolicy[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: PodSecurityPolicyList) {
    this.apiVersion = PodSecurityPolicyList.apiVersion;
    this.items = desc.items.map(i => new PodSecurityPolicy(i));
    this.kind = PodSecurityPolicyList.kind;
    this.metadata = desc.metadata;
  }
}

export function isPodSecurityPolicyList(o: any): o is PodSecurityPolicyList {
  return (
    o &&
    o.apiVersion === PodSecurityPolicyList.apiVersion &&
    o.kind === PodSecurityPolicyList.kind
  );
}

export namespace PodSecurityPolicyList {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "PodSecurityPolicyList";

  // PodSecurityPolicyList is a list of PodSecurityPolicy objects. Deprecated: use PodSecurityPolicyList from policy API Group instead.
  export interface Interface {
    // items is a list of schema objects.
    items: PodSecurityPolicy[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// PodSecurityPolicySpec defines the policy enforced. Deprecated: use PodSecurityPolicySpec from policy API Group instead.
export class PodSecurityPolicySpec {
  // allowPrivilegeEscalation determines if a pod can request to allow privilege escalation. If unspecified, defaults to true.
  public allowPrivilegeEscalation?: boolean;

  // AllowedCSIDrivers is a whitelist of inline CSI drivers that must be explicitly set to be embedded within a pod spec. An empty value means no CSI drivers can run inline within a pod spec.
  public allowedCSIDrivers?: AllowedCSIDriver[];

  // allowedCapabilities is a list of capabilities that can be requested to add to the container. Capabilities in this field may be added at the pod author's discretion. You must not list a capability in both allowedCapabilities and requiredDropCapabilities.
  public allowedCapabilities?: string[];

  // allowedFlexVolumes is a whitelist of allowed Flexvolumes.  Empty or nil indicates that all Flexvolumes may be used.  This parameter is effective only when the usage of the Flexvolumes is allowed in the "volumes" field.
  public allowedFlexVolumes?: AllowedFlexVolume[];

  // allowedHostPaths is a white list of allowed host paths. Empty indicates that all host paths may be used.
  public allowedHostPaths?: AllowedHostPath[];

  // AllowedProcMountTypes is a whitelist of allowed ProcMountTypes. Empty or nil indicates that only the DefaultProcMountType may be used. This requires the ProcMountType feature flag to be enabled.
  public allowedProcMountTypes?: string[];

  // allowedUnsafeSysctls is a list of explicitly allowed unsafe sysctls, defaults to none. Each entry is either a plain sysctl name or ends in "*" in which case it is considered as a prefix of allowed sysctls. Single * means all unsafe sysctls are allowed. Kubelet has to whitelist all allowed unsafe sysctls explicitly to avoid rejection.
  //
  // Examples: e.g. "foo/*" allows "foo/bar", "foo/baz", etc. e.g. "foo.*" allows "foo.bar", "foo.baz", etc.
  public allowedUnsafeSysctls?: string[];

  // defaultAddCapabilities is the default set of capabilities that will be added to the container unless the pod spec specifically drops the capability.  You may not list a capability in both defaultAddCapabilities and requiredDropCapabilities. Capabilities added here are implicitly allowed, and need not be included in the allowedCapabilities list.
  public defaultAddCapabilities?: string[];

  // defaultAllowPrivilegeEscalation controls the default setting for whether a process can gain more privileges than its parent process.
  public defaultAllowPrivilegeEscalation?: boolean;

  // forbiddenSysctls is a list of explicitly forbidden sysctls, defaults to none. Each entry is either a plain sysctl name or ends in "*" in which case it is considered as a prefix of forbidden sysctls. Single * means all sysctls are forbidden.
  //
  // Examples: e.g. "foo/*" forbids "foo/bar", "foo/baz", etc. e.g. "foo.*" forbids "foo.bar", "foo.baz", etc.
  public forbiddenSysctls?: string[];

  // fsGroup is the strategy that will dictate what fs group is used by the SecurityContext.
  public fsGroup: FSGroupStrategyOptions;

  // hostIPC determines if the policy allows the use of HostIPC in the pod spec.
  public hostIPC?: boolean;

  // hostNetwork determines if the policy allows the use of HostNetwork in the pod spec.
  public hostNetwork?: boolean;

  // hostPID determines if the policy allows the use of HostPID in the pod spec.
  public hostPID?: boolean;

  // hostPorts determines which host port ranges are allowed to be exposed.
  public hostPorts?: HostPortRange[];

  // privileged determines if a pod can request to be run as privileged.
  public privileged?: boolean;

  // readOnlyRootFilesystem when set to true will force containers to run with a read only root file system.  If the container specifically requests to run with a non-read only root file system the PSP should deny the pod. If set to false the container may run with a read only root file system if it wishes but it will not be forced to.
  public readOnlyRootFilesystem?: boolean;

  // requiredDropCapabilities are the capabilities that will be dropped from the container.  These are required to be dropped and cannot be added.
  public requiredDropCapabilities?: string[];

  // RunAsGroup is the strategy that will dictate the allowable RunAsGroup values that may be set. If this field is omitted, the pod's RunAsGroup can take any value. This field requires the RunAsGroup feature gate to be enabled.
  public runAsGroup?: RunAsGroupStrategyOptions;

  // runAsUser is the strategy that will dictate the allowable RunAsUser values that may be set.
  public runAsUser: RunAsUserStrategyOptions;

  // seLinux is the strategy that will dictate the allowable labels that may be set.
  public seLinux: SELinuxStrategyOptions;

  // supplementalGroups is the strategy that will dictate what supplemental groups are used by the SecurityContext.
  public supplementalGroups: SupplementalGroupsStrategyOptions;

  // volumes is a white list of allowed volume plugins. Empty indicates that no volumes may be used. To allow all volumes you may use '*'.
  public volumes?: string[];

  constructor(desc: PodSecurityPolicySpec) {
    this.allowPrivilegeEscalation = desc.allowPrivilegeEscalation;
    this.allowedCSIDrivers = desc.allowedCSIDrivers;
    this.allowedCapabilities = desc.allowedCapabilities;
    this.allowedFlexVolumes = desc.allowedFlexVolumes;
    this.allowedHostPaths = desc.allowedHostPaths;
    this.allowedProcMountTypes = desc.allowedProcMountTypes;
    this.allowedUnsafeSysctls = desc.allowedUnsafeSysctls;
    this.defaultAddCapabilities = desc.defaultAddCapabilities;
    this.defaultAllowPrivilegeEscalation = desc.defaultAllowPrivilegeEscalation;
    this.forbiddenSysctls = desc.forbiddenSysctls;
    this.fsGroup = desc.fsGroup;
    this.hostIPC = desc.hostIPC;
    this.hostNetwork = desc.hostNetwork;
    this.hostPID = desc.hostPID;
    this.hostPorts = desc.hostPorts;
    this.privileged = desc.privileged;
    this.readOnlyRootFilesystem = desc.readOnlyRootFilesystem;
    this.requiredDropCapabilities = desc.requiredDropCapabilities;
    this.runAsGroup = desc.runAsGroup;
    this.runAsUser = desc.runAsUser;
    this.seLinux = desc.seLinux;
    this.supplementalGroups = desc.supplementalGroups;
    this.volumes = desc.volumes;
  }
}

// DEPRECATED - This group version of ReplicaSet is deprecated by apps/v1beta2/ReplicaSet. See the release notes for more information. ReplicaSet ensures that a specified number of pod replicas are running at any given time.
export class ReplicaSet implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // If the Labels of a ReplicaSet are empty, they are defaulted to be the same as the Pod(s) that the ReplicaSet manages. Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the specification of the desired behavior of the ReplicaSet. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
  public spec?: ReplicaSetSpec;

  // Status is the most recently observed status of the ReplicaSet. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
  public status?: ReplicaSetStatus;

  constructor(desc: ReplicaSet.Interface) {
    this.apiVersion = ReplicaSet.apiVersion;
    this.kind = ReplicaSet.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isReplicaSet(o: any): o is ReplicaSet {
  return (
    o && o.apiVersion === ReplicaSet.apiVersion && o.kind === ReplicaSet.kind
  );
}

export namespace ReplicaSet {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "ReplicaSet";

  // named constructs a ReplicaSet with metadata.name set to name.
  export function named(name: string): ReplicaSet {
    return new ReplicaSet({ metadata: { name } });
  }
  // DEPRECATED - This group version of ReplicaSet is deprecated by apps/v1beta2/ReplicaSet. See the release notes for more information. ReplicaSet ensures that a specified number of pod replicas are running at any given time.
  export interface Interface {
    // If the Labels of a ReplicaSet are empty, they are defaulted to be the same as the Pod(s) that the ReplicaSet manages. Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the specification of the desired behavior of the ReplicaSet. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
    spec?: ReplicaSetSpec;

    // Status is the most recently observed status of the ReplicaSet. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
    status?: ReplicaSetStatus;
  }
}

// ReplicaSetCondition describes the state of a replica set at a certain point.
export class ReplicaSetCondition {
  // The last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // A human readable message indicating details about the transition.
  public message?: string;

  // The reason for the condition's last transition.
  public reason?: string;

  // Status of the condition, one of True, False, Unknown.
  public status: string;

  // Type of replica set condition.
  public type: string;

  constructor(desc: ReplicaSetCondition) {
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// ReplicaSetList is a collection of ReplicaSets.
export class ReplicaSetList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of ReplicaSets. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller
  public items: ReplicaSet[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ReplicaSetList) {
    this.apiVersion = ReplicaSetList.apiVersion;
    this.items = desc.items.map(i => new ReplicaSet(i));
    this.kind = ReplicaSetList.kind;
    this.metadata = desc.metadata;
  }
}

export function isReplicaSetList(o: any): o is ReplicaSetList {
  return (
    o &&
    o.apiVersion === ReplicaSetList.apiVersion &&
    o.kind === ReplicaSetList.kind
  );
}

export namespace ReplicaSetList {
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "ReplicaSetList";

  // ReplicaSetList is a collection of ReplicaSets.
  export interface Interface {
    // List of ReplicaSets. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller
    items: ReplicaSet[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// ReplicaSetSpec is the specification of a ReplicaSet.
export class ReplicaSetSpec {
  // Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)
  public minReadySeconds?: number;

  // Replicas is the number of desired replicas. This is a pointer to distinguish between explicit zero and unspecified. Defaults to 1. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/#what-is-a-replicationcontroller
  public replicas?: number;

  // Selector is a label query over pods that should match the replica count. If the selector is empty, it is defaulted to the labels present on the pod template. Label keys and values that must match in order to be controlled by this replica set. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public selector?: apisMetaV1.LabelSelector;

  // Template is the object that describes the pod that will be created if insufficient replicas are detected. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template
  public template?: apiCoreV1.PodTemplateSpec;
}

// ReplicaSetStatus represents the current status of a ReplicaSet.
export class ReplicaSetStatus {
  // The number of available replicas (ready for at least minReadySeconds) for this replica set.
  public availableReplicas?: number;

  // Represents the latest available observations of a replica set's current state.
  public conditions?: ReplicaSetCondition[];

  // The number of pods that have labels matching the labels of the pod template of the replicaset.
  public fullyLabeledReplicas?: number;

  // ObservedGeneration reflects the generation of the most recently observed ReplicaSet.
  public observedGeneration?: number;

  // The number of ready replicas for this replica set.
  public readyReplicas?: number;

  // Replicas is the most recently oberved number of replicas. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/#what-is-a-replicationcontroller
  public replicas: number;

  constructor(desc: ReplicaSetStatus) {
    this.availableReplicas = desc.availableReplicas;
    this.conditions = desc.conditions;
    this.fullyLabeledReplicas = desc.fullyLabeledReplicas;
    this.observedGeneration = desc.observedGeneration;
    this.readyReplicas = desc.readyReplicas;
    this.replicas = desc.replicas;
  }
}

// DEPRECATED.
export class RollbackConfig {
  // The revision to rollback to. If set to 0, rollback to the last revision.
  public revision?: number;
}

// Spec to control the desired behavior of daemon set rolling update.
export class RollingUpdateDaemonSet {
  // The maximum number of DaemonSet pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of total number of DaemonSet pods at the start of the update (ex: 10%). Absolute number is calculated from percentage by rounding up. This cannot be 0. Default value is 1. Example: when this is set to 30%, at most 30% of the total number of nodes that should be running the daemon pod (i.e. status.desiredNumberScheduled) can have their pods stopped for an update at any given time. The update starts by stopping at most 30% of those DaemonSet pods and then brings up new DaemonSet pods in their place. Once the new pods are available, it then proceeds onto other DaemonSet pods, thus ensuring that at least 70% of original number of DaemonSet pods are available at all times during the update.
  public maxUnavailable?: pkgUtilIntstr.IntOrString;
}

// Spec to control the desired behavior of rolling update.
export class RollingUpdateDeployment {
  // The maximum number of pods that can be scheduled above the desired number of pods. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). This can not be 0 if MaxUnavailable is 0. Absolute number is calculated from percentage by rounding up. By default, a value of 1 is used. Example: when this is set to 30%, the new RC can be scaled up immediately when the rolling update starts, such that the total number of old and new pods do not exceed 130% of desired pods. Once old pods have been killed, new RC can be scaled up further, ensuring that total number of pods running at any time during the update is at most 130% of desired pods.
  public maxSurge?: pkgUtilIntstr.IntOrString;

  // The maximum number of pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). Absolute number is calculated from percentage by rounding down. This can not be 0 if MaxSurge is 0. By default, a fixed value of 1 is used. Example: when this is set to 30%, the old RC can be scaled down to 70% of desired pods immediately when the rolling update starts. Once new pods are ready, old RC can be scaled down further, followed by scaling up the new RC, ensuring that the total number of pods available at all times during the update is at least 70% of desired pods.
  public maxUnavailable?: pkgUtilIntstr.IntOrString;
}

// RunAsGroupStrategyOptions defines the strategy type and any options used to create the strategy. Deprecated: use RunAsGroupStrategyOptions from policy API Group instead.
export class RunAsGroupStrategyOptions {
  // ranges are the allowed ranges of gids that may be used. If you would like to force a single gid then supply a single range with the same start and end. Required for MustRunAs.
  public ranges?: IDRange[];

  // rule is the strategy that will dictate the allowable RunAsGroup values that may be set.
  public rule: string;

  constructor(desc: RunAsGroupStrategyOptions) {
    this.ranges = desc.ranges;
    this.rule = desc.rule;
  }
}

// RunAsUserStrategyOptions defines the strategy type and any options used to create the strategy. Deprecated: use RunAsUserStrategyOptions from policy API Group instead.
export class RunAsUserStrategyOptions {
  // ranges are the allowed ranges of uids that may be used. If you would like to force a single uid then supply a single range with the same start and end. Required for MustRunAs.
  public ranges?: IDRange[];

  // rule is the strategy that will dictate the allowable RunAsUser values that may be set.
  public rule: string;

  constructor(desc: RunAsUserStrategyOptions) {
    this.ranges = desc.ranges;
    this.rule = desc.rule;
  }
}

// SELinuxStrategyOptions defines the strategy type and any options used to create the strategy. Deprecated: use SELinuxStrategyOptions from policy API Group instead.
export class SELinuxStrategyOptions {
  // rule is the strategy that will dictate the allowable labels that may be set.
  public rule: string;

  // seLinuxOptions required to run as; required for MustRunAs More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  public seLinuxOptions?: apiCoreV1.SELinuxOptions;

  constructor(desc: SELinuxStrategyOptions) {
    this.rule = desc.rule;
    this.seLinuxOptions = desc.seLinuxOptions;
  }
}

// represents a scaling request for a resource.
export class Scale implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status.
  public spec?: ScaleSpec;

  // current status of the scale. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status. Read-only.
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
  export const apiVersion = "extensions/v1beta1";
  export const group = "extensions";
  export const version = "v1beta1";
  export const kind = "Scale";

  // named constructs a Scale with metadata.name set to name.
  export function named(name: string): Scale {
    return new Scale({ metadata: { name } });
  }
  // represents a scaling request for a resource.
  export interface Interface {
    // Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata.
    metadata: apisMetaV1.ObjectMeta;

    // defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status.
    spec?: ScaleSpec;

    // current status of the scale. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status. Read-only.
    status?: ScaleStatus;
  }
}

// describes the attributes of a scale subresource
export class ScaleSpec {
  // desired number of instances for the scaled object.
  public replicas?: number;
}

// represents the current status of a scale subresource.
export class ScaleStatus {
  // actual number of observed instances of the scaled object.
  public replicas: number;

  // label query over pods that should match the replicas count. More info: http://kubernetes.io/docs/user-guide/labels#label-selectors
  public selector?: { [key: string]: string };

  // label selector for pods that should match the replicas count. This is a serializated version of both map-based and more expressive set-based selectors. This is done to avoid introspection in the clients. The string will be in the same format as the query-param syntax. If the target type only supports map-based selectors, both this field and map-based selector field are populated. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public targetSelector?: string;

  constructor(desc: ScaleStatus) {
    this.replicas = desc.replicas;
    this.selector = desc.selector;
    this.targetSelector = desc.targetSelector;
  }
}

// SupplementalGroupsStrategyOptions defines the strategy type and options used to create the strategy. Deprecated: use SupplementalGroupsStrategyOptions from policy API Group instead.
export class SupplementalGroupsStrategyOptions {
  // ranges are the allowed ranges of supplemental groups.  If you would like to force a single supplemental group then supply a single range with the same start and end. Required for MustRunAs.
  public ranges?: IDRange[];

  // rule is the strategy that will dictate what supplemental groups is used in the SecurityContext.
  public rule?: string;
}
