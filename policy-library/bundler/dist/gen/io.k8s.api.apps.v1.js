"use strict";
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const apiCoreV1 = __importStar(require("./io.k8s.api.core.v1"));
// ControllerRevision implements an immutable snapshot of state data. Clients are responsible for serializing and deserializing the objects that contain their internal state. Once a ControllerRevision has been successfully created, it can not be updated. The API Server will fail validation of all requests that attempt to mutate the Data field. ControllerRevisions may, however, be deleted. Note that, due to its use by both the DaemonSet and StatefulSet controllers for update and rollback, this object is beta. However, it may be subject to name and representation changes in future releases, and clients should not depend on its stability. It is primarily for internal use by controllers.
class ControllerRevision {
    constructor(desc) {
        this.apiVersion = ControllerRevision.apiVersion;
        this.data = desc.data;
        this.kind = ControllerRevision.kind;
        this.metadata = desc.metadata;
        this.revision = desc.revision;
    }
}
exports.ControllerRevision = ControllerRevision;
function isControllerRevision(o) {
    return (o &&
        o.apiVersion === ControllerRevision.apiVersion &&
        o.kind === ControllerRevision.kind);
}
exports.isControllerRevision = isControllerRevision;
(function (ControllerRevision) {
    ControllerRevision.apiVersion = "apps/v1";
    ControllerRevision.group = "apps";
    ControllerRevision.version = "v1";
    ControllerRevision.kind = "ControllerRevision";
})(ControllerRevision = exports.ControllerRevision || (exports.ControllerRevision = {}));
// ControllerRevisionList is a resource containing a list of ControllerRevision objects.
class ControllerRevisionList {
    constructor(desc) {
        this.apiVersion = ControllerRevisionList.apiVersion;
        this.items = desc.items.map(i => new ControllerRevision(i));
        this.kind = ControllerRevisionList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ControllerRevisionList = ControllerRevisionList;
function isControllerRevisionList(o) {
    return (o &&
        o.apiVersion === ControllerRevisionList.apiVersion &&
        o.kind === ControllerRevisionList.kind);
}
exports.isControllerRevisionList = isControllerRevisionList;
(function (ControllerRevisionList) {
    ControllerRevisionList.apiVersion = "apps/v1";
    ControllerRevisionList.group = "apps";
    ControllerRevisionList.version = "v1";
    ControllerRevisionList.kind = "ControllerRevisionList";
})(ControllerRevisionList = exports.ControllerRevisionList || (exports.ControllerRevisionList = {}));
// DaemonSet represents the configuration of a daemon set.
class DaemonSet {
    constructor(desc) {
        this.apiVersion = DaemonSet.apiVersion;
        this.kind = DaemonSet.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.DaemonSet = DaemonSet;
function isDaemonSet(o) {
    return (o && o.apiVersion === DaemonSet.apiVersion && o.kind === DaemonSet.kind);
}
exports.isDaemonSet = isDaemonSet;
(function (DaemonSet) {
    DaemonSet.apiVersion = "apps/v1";
    DaemonSet.group = "apps";
    DaemonSet.version = "v1";
    DaemonSet.kind = "DaemonSet";
    // named constructs a DaemonSet with metadata.name set to name.
    function named(name) {
        return new DaemonSet({ metadata: { name } });
    }
    DaemonSet.named = named;
})(DaemonSet = exports.DaemonSet || (exports.DaemonSet = {}));
// DaemonSetCondition describes the state of a DaemonSet at a certain point.
class DaemonSetCondition {
    constructor(desc) {
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.DaemonSetCondition = DaemonSetCondition;
// DaemonSetList is a collection of daemon sets.
class DaemonSetList {
    constructor(desc) {
        this.apiVersion = DaemonSetList.apiVersion;
        this.items = desc.items.map(i => new DaemonSet(i));
        this.kind = DaemonSetList.kind;
        this.metadata = desc.metadata;
    }
}
exports.DaemonSetList = DaemonSetList;
function isDaemonSetList(o) {
    return (o &&
        o.apiVersion === DaemonSetList.apiVersion &&
        o.kind === DaemonSetList.kind);
}
exports.isDaemonSetList = isDaemonSetList;
(function (DaemonSetList) {
    DaemonSetList.apiVersion = "apps/v1";
    DaemonSetList.group = "apps";
    DaemonSetList.version = "v1";
    DaemonSetList.kind = "DaemonSetList";
})(DaemonSetList = exports.DaemonSetList || (exports.DaemonSetList = {}));
// DaemonSetSpec is the specification of a daemon set.
class DaemonSetSpec {
    constructor(desc) {
        this.minReadySeconds = desc.minReadySeconds;
        this.revisionHistoryLimit = desc.revisionHistoryLimit;
        this.selector = desc.selector;
        this.template = desc.template;
        this.updateStrategy = desc.updateStrategy;
    }
}
exports.DaemonSetSpec = DaemonSetSpec;
// DaemonSetStatus represents the current status of a daemon set.
class DaemonSetStatus {
    constructor(desc) {
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
exports.DaemonSetStatus = DaemonSetStatus;
// DaemonSetUpdateStrategy is a struct used to control the update strategy for a DaemonSet.
class DaemonSetUpdateStrategy {
}
exports.DaemonSetUpdateStrategy = DaemonSetUpdateStrategy;
// Deployment enables declarative updates for Pods and ReplicaSets.
class Deployment {
    constructor(desc) {
        this.apiVersion = Deployment.apiVersion;
        this.kind = Deployment.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Deployment = Deployment;
function isDeployment(o) {
    return (o && o.apiVersion === Deployment.apiVersion && o.kind === Deployment.kind);
}
exports.isDeployment = isDeployment;
(function (Deployment) {
    Deployment.apiVersion = "apps/v1";
    Deployment.group = "apps";
    Deployment.version = "v1";
    Deployment.kind = "Deployment";
    // named constructs a Deployment with metadata.name set to name.
    function named(name) {
        return new Deployment({ metadata: { name } });
    }
    Deployment.named = named;
})(Deployment = exports.Deployment || (exports.Deployment = {}));
// DeploymentCondition describes the state of a deployment at a certain point.
class DeploymentCondition {
    constructor(desc) {
        this.lastTransitionTime = desc.lastTransitionTime;
        this.lastUpdateTime = desc.lastUpdateTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.DeploymentCondition = DeploymentCondition;
// DeploymentList is a list of Deployments.
class DeploymentList {
    constructor(desc) {
        this.apiVersion = DeploymentList.apiVersion;
        this.items = desc.items.map(i => new Deployment(i));
        this.kind = DeploymentList.kind;
        this.metadata = desc.metadata;
    }
}
exports.DeploymentList = DeploymentList;
function isDeploymentList(o) {
    return (o &&
        o.apiVersion === DeploymentList.apiVersion &&
        o.kind === DeploymentList.kind);
}
exports.isDeploymentList = isDeploymentList;
(function (DeploymentList) {
    DeploymentList.apiVersion = "apps/v1";
    DeploymentList.group = "apps";
    DeploymentList.version = "v1";
    DeploymentList.kind = "DeploymentList";
})(DeploymentList = exports.DeploymentList || (exports.DeploymentList = {}));
// DeploymentSpec is the specification of the desired behavior of the Deployment.
class DeploymentSpec {
    constructor(desc) {
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
exports.DeploymentSpec = DeploymentSpec;
// DeploymentStatus is the most recently observed status of the Deployment.
class DeploymentStatus {
}
exports.DeploymentStatus = DeploymentStatus;
// DeploymentStrategy describes how to replace existing pods with new ones.
class DeploymentStrategy {
}
exports.DeploymentStrategy = DeploymentStrategy;
// ReplicaSet ensures that a specified number of pod replicas are running at any given time.
class ReplicaSet {
    constructor(desc) {
        this.apiVersion = ReplicaSet.apiVersion;
        this.kind = ReplicaSet.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.ReplicaSet = ReplicaSet;
function isReplicaSet(o) {
    return (o && o.apiVersion === ReplicaSet.apiVersion && o.kind === ReplicaSet.kind);
}
exports.isReplicaSet = isReplicaSet;
(function (ReplicaSet) {
    ReplicaSet.apiVersion = "apps/v1";
    ReplicaSet.group = "apps";
    ReplicaSet.version = "v1";
    ReplicaSet.kind = "ReplicaSet";
    // named constructs a ReplicaSet with metadata.name set to name.
    function named(name) {
        return new ReplicaSet({ metadata: { name } });
    }
    ReplicaSet.named = named;
})(ReplicaSet = exports.ReplicaSet || (exports.ReplicaSet = {}));
// ReplicaSetCondition describes the state of a replica set at a certain point.
class ReplicaSetCondition {
    constructor(desc) {
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.ReplicaSetCondition = ReplicaSetCondition;
// ReplicaSetList is a collection of ReplicaSets.
class ReplicaSetList {
    constructor(desc) {
        this.apiVersion = ReplicaSetList.apiVersion;
        this.items = desc.items.map(i => new ReplicaSet(i));
        this.kind = ReplicaSetList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ReplicaSetList = ReplicaSetList;
function isReplicaSetList(o) {
    return (o &&
        o.apiVersion === ReplicaSetList.apiVersion &&
        o.kind === ReplicaSetList.kind);
}
exports.isReplicaSetList = isReplicaSetList;
(function (ReplicaSetList) {
    ReplicaSetList.apiVersion = "apps/v1";
    ReplicaSetList.group = "apps";
    ReplicaSetList.version = "v1";
    ReplicaSetList.kind = "ReplicaSetList";
})(ReplicaSetList = exports.ReplicaSetList || (exports.ReplicaSetList = {}));
// ReplicaSetSpec is the specification of a ReplicaSet.
class ReplicaSetSpec {
    constructor(desc) {
        this.minReadySeconds = desc.minReadySeconds;
        this.replicas = desc.replicas;
        this.selector = desc.selector;
        this.template = desc.template;
    }
}
exports.ReplicaSetSpec = ReplicaSetSpec;
// ReplicaSetStatus represents the current status of a ReplicaSet.
class ReplicaSetStatus {
    constructor(desc) {
        this.availableReplicas = desc.availableReplicas;
        this.conditions = desc.conditions;
        this.fullyLabeledReplicas = desc.fullyLabeledReplicas;
        this.observedGeneration = desc.observedGeneration;
        this.readyReplicas = desc.readyReplicas;
        this.replicas = desc.replicas;
    }
}
exports.ReplicaSetStatus = ReplicaSetStatus;
// Spec to control the desired behavior of daemon set rolling update.
class RollingUpdateDaemonSet {
}
exports.RollingUpdateDaemonSet = RollingUpdateDaemonSet;
// Spec to control the desired behavior of rolling update.
class RollingUpdateDeployment {
}
exports.RollingUpdateDeployment = RollingUpdateDeployment;
// RollingUpdateStatefulSetStrategy is used to communicate parameter for RollingUpdateStatefulSetStrategyType.
class RollingUpdateStatefulSetStrategy {
}
exports.RollingUpdateStatefulSetStrategy = RollingUpdateStatefulSetStrategy;
// StatefulSet represents a set of pods with consistent identities. Identities are defined as:
//  - Network: A single stable DNS and hostname.
//  - Storage: As many VolumeClaims as requested.
// The StatefulSet guarantees that a given network identity will always map to the same storage identity.
class StatefulSet {
    constructor(desc) {
        this.apiVersion = StatefulSet.apiVersion;
        this.kind = StatefulSet.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.StatefulSet = StatefulSet;
function isStatefulSet(o) {
    return (o && o.apiVersion === StatefulSet.apiVersion && o.kind === StatefulSet.kind);
}
exports.isStatefulSet = isStatefulSet;
(function (StatefulSet) {
    StatefulSet.apiVersion = "apps/v1";
    StatefulSet.group = "apps";
    StatefulSet.version = "v1";
    StatefulSet.kind = "StatefulSet";
    // named constructs a StatefulSet with metadata.name set to name.
    function named(name) {
        return new StatefulSet({ metadata: { name } });
    }
    StatefulSet.named = named;
})(StatefulSet = exports.StatefulSet || (exports.StatefulSet = {}));
// StatefulSetCondition describes the state of a statefulset at a certain point.
class StatefulSetCondition {
    constructor(desc) {
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.StatefulSetCondition = StatefulSetCondition;
// StatefulSetList is a collection of StatefulSets.
class StatefulSetList {
    constructor(desc) {
        this.apiVersion = StatefulSetList.apiVersion;
        this.items = desc.items.map(i => new StatefulSet(i));
        this.kind = StatefulSetList.kind;
        this.metadata = desc.metadata;
    }
}
exports.StatefulSetList = StatefulSetList;
function isStatefulSetList(o) {
    return (o &&
        o.apiVersion === StatefulSetList.apiVersion &&
        o.kind === StatefulSetList.kind);
}
exports.isStatefulSetList = isStatefulSetList;
(function (StatefulSetList) {
    StatefulSetList.apiVersion = "apps/v1";
    StatefulSetList.group = "apps";
    StatefulSetList.version = "v1";
    StatefulSetList.kind = "StatefulSetList";
})(StatefulSetList = exports.StatefulSetList || (exports.StatefulSetList = {}));
// A StatefulSetSpec is the specification of a StatefulSet.
class StatefulSetSpec {
    constructor(desc) {
        this.podManagementPolicy = desc.podManagementPolicy;
        this.replicas = desc.replicas;
        this.revisionHistoryLimit = desc.revisionHistoryLimit;
        this.selector = desc.selector;
        this.serviceName = desc.serviceName;
        this.template = desc.template;
        this.updateStrategy = desc.updateStrategy;
        this.volumeClaimTemplates =
            desc.volumeClaimTemplates !== undefined
                ? desc.volumeClaimTemplates.map(i => new apiCoreV1.PersistentVolumeClaim(i))
                : undefined;
    }
}
exports.StatefulSetSpec = StatefulSetSpec;
// StatefulSetStatus represents the current state of a StatefulSet.
class StatefulSetStatus {
    constructor(desc) {
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
exports.StatefulSetStatus = StatefulSetStatus;
// StatefulSetUpdateStrategy indicates the strategy that the StatefulSet controller will use to perform updates. It includes any additional parameters necessary to perform the update for the indicated strategy.
class StatefulSetUpdateStrategy {
}
exports.StatefulSetUpdateStrategy = StatefulSetUpdateStrategy;
//# sourceMappingURL=io.k8s.api.apps.v1.js.map