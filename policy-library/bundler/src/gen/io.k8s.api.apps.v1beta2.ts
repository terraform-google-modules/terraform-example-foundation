import { KubernetesObject } from "kpt-functions";
import * as apiCoreV1 from "./io.k8s.api.core.v1";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";
import * as apimachineryPkgRuntime from "./io.k8s.apimachinery.pkg.runtime";
import * as pkgUtilIntstr from "./io.k8s.apimachinery.pkg.util.intstr";

// DEPRECATED - This group version of ControllerRevision is deprecated by apps/v1/ControllerRevision. See the release notes for more information. ControllerRevision implements an immutable snapshot of state data. Clients are responsible for serializing and deserializing the objects that contain their internal state. Once a ControllerRevision has been successfully created, it can not be updated. The API Server will fail validation of all requests that attempt to mutate the Data field. ControllerRevisions may, however, be deleted. Note that, due to its use by both the DaemonSet and StatefulSet controllers for update and rollback, this object is beta. However, it may be subject to name and representation changes in future releases, and clients should not depend on its stability. It is primarily for internal use by controllers.
export class ControllerRevision implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Data is the serialized representation of the state.
  public data?: apimachineryPkgRuntime.RawExtension;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Revision indicates the revision of the state represented by Data.
  public revision: number;

  constructor(desc: ControllerRevision.Interface) {
    this.apiVersion = ControllerRevision.apiVersion;
    this.data = desc.data;
    this.kind = ControllerRevision.kind;
    this.metadata = desc.metadata;
    this.revision = desc.revision;
  }
}

export function isControllerRevision(o: any): o is ControllerRevision {
  return (
    o &&
    o.apiVersion === ControllerRevision.apiVersion &&
    o.kind === ControllerRevision.kind
  );
}

export namespace ControllerRevision {
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "ControllerRevision";

  // DEPRECATED - This group version of ControllerRevision is deprecated by apps/v1/ControllerRevision. See the release notes for more information. ControllerRevision implements an immutable snapshot of state data. Clients are responsible for serializing and deserializing the objects that contain their internal state. Once a ControllerRevision has been successfully created, it can not be updated. The API Server will fail validation of all requests that attempt to mutate the Data field. ControllerRevisions may, however, be deleted. Note that, due to its use by both the DaemonSet and StatefulSet controllers for update and rollback, this object is beta. However, it may be subject to name and representation changes in future releases, and clients should not depend on its stability. It is primarily for internal use by controllers.
  export interface Interface {
    // Data is the serialized representation of the state.
    data?: apimachineryPkgRuntime.RawExtension;

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Revision indicates the revision of the state represented by Data.
    revision: number;
  }
}

// ControllerRevisionList is a resource containing a list of ControllerRevision objects.
export class ControllerRevisionList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is the list of ControllerRevisions
  public items: ControllerRevision[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ControllerRevisionList) {
    this.apiVersion = ControllerRevisionList.apiVersion;
    this.items = desc.items.map(i => new ControllerRevision(i));
    this.kind = ControllerRevisionList.kind;
    this.metadata = desc.metadata;
  }
}

export function isControllerRevisionList(o: any): o is ControllerRevisionList {
  return (
    o &&
    o.apiVersion === ControllerRevisionList.apiVersion &&
    o.kind === ControllerRevisionList.kind
  );
}

export namespace ControllerRevisionList {
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "ControllerRevisionList";

  // ControllerRevisionList is a resource containing a list of ControllerRevision objects.
  export interface Interface {
    // Items is the list of ControllerRevisions
    items: ControllerRevision[];

    // More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// DEPRECATED - This group version of DaemonSet is deprecated by apps/v1/DaemonSet. See the release notes for more information. DaemonSet represents the configuration of a daemon set.
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
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "DaemonSet";

  // named constructs a DaemonSet with metadata.name set to name.
  export function named(name: string): DaemonSet {
    return new DaemonSet({ metadata: { name } });
  }
  // DEPRECATED - This group version of DaemonSet is deprecated by apps/v1/DaemonSet. See the release notes for more information. DaemonSet represents the configuration of a daemon set.
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
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
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

  // A label query over pods that are managed by the daemon set. Must match in order to be controlled. It must match the pod template's labels. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public selector: apisMetaV1.LabelSelector;

  // An object that describes the pod that will be created. The DaemonSet will create exactly one copy of this pod on every node that matches the template's node selector (or on every node if no node selector is specified). More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template
  public template: apiCoreV1.PodTemplateSpec;

  // An update strategy to replace existing DaemonSet pods with new pods.
  public updateStrategy?: DaemonSetUpdateStrategy;

  constructor(desc: DaemonSetSpec) {
    this.minReadySeconds = desc.minReadySeconds;
    this.revisionHistoryLimit = desc.revisionHistoryLimit;
    this.selector = desc.selector;
    this.template = desc.template;
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

// DaemonSetUpdateStrategy is a struct used to control the update strategy for a DaemonSet.
export class DaemonSetUpdateStrategy {
  // Rolling update config params. Present only if type = "RollingUpdate".
  public rollingUpdate?: RollingUpdateDaemonSet;

  // Type of daemon set update. Can be "RollingUpdate" or "OnDelete". Default is RollingUpdate.
  public type?: string;
}

// DEPRECATED - This group version of Deployment is deprecated by apps/v1/Deployment. See the release notes for more information. Deployment enables declarative updates for Pods and ReplicaSets.
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
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "Deployment";

  // named constructs a Deployment with metadata.name set to name.
  export function named(name: string): Deployment {
    return new Deployment({ metadata: { name } });
  }
  // DEPRECATED - This group version of Deployment is deprecated by apps/v1/Deployment. See the release notes for more information. Deployment enables declarative updates for Pods and ReplicaSets.
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
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "DeploymentList";

  // DeploymentList is a list of Deployments.
  export interface Interface {
    // Items is the list of Deployments.
    items: Deployment[];

    // Standard list metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}

// DeploymentSpec is the specification of the desired behavior of the Deployment.
export class DeploymentSpec {
  // Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)
  public minReadySeconds?: number;

  // Indicates that the deployment is paused.
  public paused?: boolean;

  // The maximum time in seconds for a deployment to make progress before it is considered to be failed. The deployment controller will continue to process failed deployments and a condition with a ProgressDeadlineExceeded reason will be surfaced in the deployment status. Note that progress will not be estimated during the time a deployment is paused. Defaults to 600s.
  public progressDeadlineSeconds?: number;

  // Number of desired pods. This is a pointer to distinguish between explicit zero and not specified. Defaults to 1.
  public replicas?: number;

  // The number of old ReplicaSets to retain to allow rollback. This is a pointer to distinguish between explicit zero and not specified. Defaults to 10.
  public revisionHistoryLimit?: number;

  // Label selector for pods. Existing ReplicaSets whose pods are selected by this will be the ones affected by this deployment. It must match the pod template's labels.
  public selector: apisMetaV1.LabelSelector;

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

// DEPRECATED - This group version of ReplicaSet is deprecated by apps/v1/ReplicaSet. See the release notes for more information. ReplicaSet ensures that a specified number of pod replicas are running at any given time.
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
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "ReplicaSet";

  // named constructs a ReplicaSet with metadata.name set to name.
  export function named(name: string): ReplicaSet {
    return new ReplicaSet({ metadata: { name } });
  }
  // DEPRECATED - This group version of ReplicaSet is deprecated by apps/v1/ReplicaSet. See the release notes for more information. ReplicaSet ensures that a specified number of pod replicas are running at any given time.
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
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
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

  // Selector is a label query over pods that should match the replica count. Label keys and values that must match in order to be controlled by this replica set. It must match the pod template's labels. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public selector: apisMetaV1.LabelSelector;

  // Template is the object that describes the pod that will be created if insufficient replicas are detected. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template
  public template?: apiCoreV1.PodTemplateSpec;

  constructor(desc: ReplicaSetSpec) {
    this.minReadySeconds = desc.minReadySeconds;
    this.replicas = desc.replicas;
    this.selector = desc.selector;
    this.template = desc.template;
  }
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

// Spec to control the desired behavior of daemon set rolling update.
export class RollingUpdateDaemonSet {
  // The maximum number of DaemonSet pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of total number of DaemonSet pods at the start of the update (ex: 10%). Absolute number is calculated from percentage by rounding up. This cannot be 0. Default value is 1. Example: when this is set to 30%, at most 30% of the total number of nodes that should be running the daemon pod (i.e. status.desiredNumberScheduled) can have their pods stopped for an update at any given time. The update starts by stopping at most 30% of those DaemonSet pods and then brings up new DaemonSet pods in their place. Once the new pods are available, it then proceeds onto other DaemonSet pods, thus ensuring that at least 70% of original number of DaemonSet pods are available at all times during the update.
  public maxUnavailable?: pkgUtilIntstr.IntOrString;
}

// Spec to control the desired behavior of rolling update.
export class RollingUpdateDeployment {
  // The maximum number of pods that can be scheduled above the desired number of pods. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). This can not be 0 if MaxUnavailable is 0. Absolute number is calculated from percentage by rounding up. Defaults to 25%. Example: when this is set to 30%, the new ReplicaSet can be scaled up immediately when the rolling update starts, such that the total number of old and new pods do not exceed 130% of desired pods. Once old pods have been killed, new ReplicaSet can be scaled up further, ensuring that total number of pods running at any time during the update is at most 130% of desired pods.
  public maxSurge?: pkgUtilIntstr.IntOrString;

  // The maximum number of pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). Absolute number is calculated from percentage by rounding down. This can not be 0 if MaxSurge is 0. Defaults to 25%. Example: when this is set to 30%, the old ReplicaSet can be scaled down to 70% of desired pods immediately when the rolling update starts. Once new pods are ready, old ReplicaSet can be scaled down further, followed by scaling up the new ReplicaSet, ensuring that the total number of pods available at all times during the update is at least 70% of desired pods.
  public maxUnavailable?: pkgUtilIntstr.IntOrString;
}

// RollingUpdateStatefulSetStrategy is used to communicate parameter for RollingUpdateStatefulSetStrategyType.
export class RollingUpdateStatefulSetStrategy {
  // Partition indicates the ordinal at which the StatefulSet should be partitioned. Default value is 0.
  public partition?: number;
}

// Scale represents a scaling request for a resource.
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
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "Scale";

  // named constructs a Scale with metadata.name set to name.
  export function named(name: string): Scale {
    return new Scale({ metadata: { name } });
  }
  // Scale represents a scaling request for a resource.
  export interface Interface {
    // Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata.
    metadata: apisMetaV1.ObjectMeta;

    // defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status.
    spec?: ScaleSpec;

    // current status of the scale. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status. Read-only.
    status?: ScaleStatus;
  }
}

// ScaleSpec describes the attributes of a scale subresource
export class ScaleSpec {
  // desired number of instances for the scaled object.
  public replicas?: number;
}

// ScaleStatus represents the current status of a scale subresource.
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

// DEPRECATED - This group version of StatefulSet is deprecated by apps/v1/StatefulSet. See the release notes for more information. StatefulSet represents a set of pods with consistent identities. Identities are defined as:
//  - Network: A single stable DNS and hostname.
//  - Storage: As many VolumeClaims as requested.
// The StatefulSet guarantees that a given network identity will always map to the same storage identity.
export class StatefulSet implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the desired identities of pods in this set.
  public spec?: StatefulSetSpec;

  // Status is the current status of Pods in this StatefulSet. This data may be out of date by some window of time.
  public status?: StatefulSetStatus;

  constructor(desc: StatefulSet.Interface) {
    this.apiVersion = StatefulSet.apiVersion;
    this.kind = StatefulSet.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isStatefulSet(o: any): o is StatefulSet {
  return (
    o && o.apiVersion === StatefulSet.apiVersion && o.kind === StatefulSet.kind
  );
}

export namespace StatefulSet {
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "StatefulSet";

  // named constructs a StatefulSet with metadata.name set to name.
  export function named(name: string): StatefulSet {
    return new StatefulSet({ metadata: { name } });
  }
  // DEPRECATED - This group version of StatefulSet is deprecated by apps/v1/StatefulSet. See the release notes for more information. StatefulSet represents a set of pods with consistent identities. Identities are defined as:
  //  - Network: A single stable DNS and hostname.
  //  - Storage: As many VolumeClaims as requested.
  // The StatefulSet guarantees that a given network identity will always map to the same storage identity.
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the desired identities of pods in this set.
    spec?: StatefulSetSpec;

    // Status is the current status of Pods in this StatefulSet. This data may be out of date by some window of time.
    status?: StatefulSetStatus;
  }
}

// StatefulSetCondition describes the state of a statefulset at a certain point.
export class StatefulSetCondition {
  // Last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // A human readable message indicating details about the transition.
  public message?: string;

  // The reason for the condition's last transition.
  public reason?: string;

  // Status of the condition, one of True, False, Unknown.
  public status: string;

  // Type of statefulset condition.
  public type: string;

  constructor(desc: StatefulSetCondition) {
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// StatefulSetList is a collection of StatefulSets.
export class StatefulSetList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  public items: StatefulSet[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: StatefulSetList) {
    this.apiVersion = StatefulSetList.apiVersion;
    this.items = desc.items.map(i => new StatefulSet(i));
    this.kind = StatefulSetList.kind;
    this.metadata = desc.metadata;
  }
}

export function isStatefulSetList(o: any): o is StatefulSetList {
  return (
    o &&
    o.apiVersion === StatefulSetList.apiVersion &&
    o.kind === StatefulSetList.kind
  );
}

export namespace StatefulSetList {
  export const apiVersion = "apps/v1beta2";
  export const group = "apps";
  export const version = "v1beta2";
  export const kind = "StatefulSetList";

  // StatefulSetList is a collection of StatefulSets.
  export interface Interface {
    items: StatefulSet[];

    metadata?: apisMetaV1.ListMeta;
  }
}

// A StatefulSetSpec is the specification of a StatefulSet.
export class StatefulSetSpec {
  // podManagementPolicy controls how pods are created during initial scale up, when replacing pods on nodes, or when scaling down. The default policy is `OrderedReady`, where pods are created in increasing order (pod-0, then pod-1, etc) and the controller will wait until each pod is ready before continuing. When scaling down, the pods are removed in the opposite order. The alternative policy is `Parallel` which will create pods in parallel to match the desired scale without waiting, and on scale down will delete all pods at once.
  public podManagementPolicy?: string;

  // replicas is the desired number of replicas of the given Template. These are replicas in the sense that they are instantiations of the same Template, but individual replicas also have a consistent identity. If unspecified, defaults to 1.
  public replicas?: number;

  // revisionHistoryLimit is the maximum number of revisions that will be maintained in the StatefulSet's revision history. The revision history consists of all revisions not represented by a currently applied StatefulSetSpec version. The default value is 10.
  public revisionHistoryLimit?: number;

  // selector is a label query over pods that should match the replica count. It must match the pod template's labels. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public selector: apisMetaV1.LabelSelector;

  // serviceName is the name of the service that governs this StatefulSet. This service must exist before the StatefulSet, and is responsible for the network identity of the set. Pods get DNS/hostnames that follow the pattern: pod-specific-string.serviceName.default.svc.cluster.local where "pod-specific-string" is managed by the StatefulSet controller.
  public serviceName: string;

  // template is the object that describes the pod that will be created if insufficient replicas are detected. Each pod stamped out by the StatefulSet will fulfill this Template, but have a unique identity from the rest of the StatefulSet.
  public template: apiCoreV1.PodTemplateSpec;

  // updateStrategy indicates the StatefulSetUpdateStrategy that will be employed to update Pods in the StatefulSet when a revision is made to Template.
  public updateStrategy?: StatefulSetUpdateStrategy;

  // volumeClaimTemplates is a list of claims that pods are allowed to reference. The StatefulSet controller is responsible for mapping network identities to claims in a way that maintains the identity of a pod. Every claim in this list must have at least one matching (by name) volumeMount in one container in the template. A claim in this list takes precedence over any volumes in the template, with the same name.
  public volumeClaimTemplates?: apiCoreV1.PersistentVolumeClaim[];

  constructor(desc: StatefulSetSpec) {
    this.podManagementPolicy = desc.podManagementPolicy;
    this.replicas = desc.replicas;
    this.revisionHistoryLimit = desc.revisionHistoryLimit;
    this.selector = desc.selector;
    this.serviceName = desc.serviceName;
    this.template = desc.template;
    this.updateStrategy = desc.updateStrategy;
    this.volumeClaimTemplates =
      desc.volumeClaimTemplates !== undefined
        ? desc.volumeClaimTemplates.map(
            i => new apiCoreV1.PersistentVolumeClaim(i)
          )
        : undefined;
  }
}

// StatefulSetStatus represents the current state of a StatefulSet.
export class StatefulSetStatus {
  // collisionCount is the count of hash collisions for the StatefulSet. The StatefulSet controller uses this field as a collision avoidance mechanism when it needs to create the name for the newest ControllerRevision.
  public collisionCount?: number;

  // Represents the latest available observations of a statefulset's current state.
  public conditions?: StatefulSetCondition[];

  // currentReplicas is the number of Pods created by the StatefulSet controller from the StatefulSet version indicated by currentRevision.
  public currentReplicas?: number;

  // currentRevision, if not empty, indicates the version of the StatefulSet used to generate Pods in the sequence [0,currentReplicas).
  public currentRevision?: string;

  // observedGeneration is the most recent generation observed for this StatefulSet. It corresponds to the StatefulSet's generation, which is updated on mutation by the API Server.
  public observedGeneration?: number;

  // readyReplicas is the number of Pods created by the StatefulSet controller that have a Ready Condition.
  public readyReplicas?: number;

  // replicas is the number of Pods created by the StatefulSet controller.
  public replicas: number;

  // updateRevision, if not empty, indicates the version of the StatefulSet used to generate Pods in the sequence [replicas-updatedReplicas,replicas)
  public updateRevision?: string;

  // updatedReplicas is the number of Pods created by the StatefulSet controller from the StatefulSet version indicated by updateRevision.
  public updatedReplicas?: number;

  constructor(desc: StatefulSetStatus) {
    this.collisionCount = desc.collisionCount;
    this.conditions = desc.conditions;
    this.currentReplicas = desc.currentReplicas;
    this.currentRevision = desc.currentRevision;
    this.observedGeneration = desc.observedGeneration;
    this.readyReplicas = desc.readyReplicas;
    this.replicas = desc.replicas;
    this.updateRevision = desc.updateRevision;
    this.updatedReplicas = desc.updatedReplicas;
  }
}

// StatefulSetUpdateStrategy indicates the strategy that the StatefulSet controller will use to perform updates. It includes any additional parameters necessary to perform the update for the indicated strategy.
export class StatefulSetUpdateStrategy {
  // RollingUpdate is used to communicate parameters when Type is RollingUpdateStatefulSetStrategyType.
  public rollingUpdate?: RollingUpdateStatefulSetStrategy;

  // Type indicates the type of the StatefulSetUpdateStrategy. Default is RollingUpdate.
  public type?: string;
}
