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
// DEPRECATED - This group version of ControllerRevision is deprecated by apps/v1beta2/ControllerRevision. See the release notes for more information. ControllerRevision implements an immutable snapshot of state data. Clients are responsible for serializing and deserializing the objects that contain their internal state. Once a ControllerRevision has been successfully created, it can not be updated. The API Server will fail validation of all requests that attempt to mutate the Data field. ControllerRevisions may, however, be deleted. Note that, due to its use by both the DaemonSet and StatefulSet controllers for update and rollback, this object is beta. However, it may be subject to name and representation changes in future releases, and clients should not depend on its stability. It is primarily for internal use by controllers.
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
    ControllerRevision.apiVersion = "apps/v1beta1";
    ControllerRevision.group = "apps";
    ControllerRevision.version = "v1beta1";
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
    ControllerRevisionList.apiVersion = "apps/v1beta1";
    ControllerRevisionList.group = "apps";
    ControllerRevisionList.version = "v1beta1";
    ControllerRevisionList.kind = "ControllerRevisionList";
})(ControllerRevisionList = exports.ControllerRevisionList || (exports.ControllerRevisionList = {}));
// DEPRECATED - This group version of Deployment is deprecated by apps/v1beta2/Deployment. See the release notes for more information. Deployment enables declarative updates for Pods and ReplicaSets.
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
    Deployment.apiVersion = "apps/v1beta1";
    Deployment.group = "apps";
    Deployment.version = "v1beta1";
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
    DeploymentList.apiVersion = "apps/v1beta1";
    DeploymentList.group = "apps";
    DeploymentList.version = "v1beta1";
    DeploymentList.kind = "DeploymentList";
})(DeploymentList = exports.DeploymentList || (exports.DeploymentList = {}));
// DEPRECATED. DeploymentRollback stores the information required to rollback a deployment.
class DeploymentRollback {
    constructor(desc) {
        this.apiVersion = DeploymentRollback.apiVersion;
        this.kind = DeploymentRollback.kind;
        this.name = desc.name;
        this.rollbackTo = desc.rollbackTo;
        this.updatedAnnotations = desc.updatedAnnotations;
    }
}
exports.DeploymentRollback = DeploymentRollback;
function isDeploymentRollback(o) {
    return (o &&
        o.apiVersion === DeploymentRollback.apiVersion &&
        o.kind === DeploymentRollback.kind);
}
exports.isDeploymentRollback = isDeploymentRollback;
(function (DeploymentRollback) {
    DeploymentRollback.apiVersion = "apps/v1beta1";
    DeploymentRollback.group = "apps";
    DeploymentRollback.version = "v1beta1";
    DeploymentRollback.kind = "DeploymentRollback";
})(DeploymentRollback = exports.DeploymentRollback || (exports.DeploymentRollback = {}));
// DeploymentSpec is the specification of the desired behavior of the Deployment.
class DeploymentSpec {
    constructor(desc) {
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
exports.DeploymentSpec = DeploymentSpec;
// DeploymentStatus is the most recently observed status of the Deployment.
class DeploymentStatus {
}
exports.DeploymentStatus = DeploymentStatus;
// DeploymentStrategy describes how to replace existing pods with new ones.
class DeploymentStrategy {
}
exports.DeploymentStrategy = DeploymentStrategy;
// DEPRECATED.
class RollbackConfig {
}
exports.RollbackConfig = RollbackConfig;
// Spec to control the desired behavior of rolling update.
class RollingUpdateDeployment {
}
exports.RollingUpdateDeployment = RollingUpdateDeployment;
// RollingUpdateStatefulSetStrategy is used to communicate parameter for RollingUpdateStatefulSetStrategyType.
class RollingUpdateStatefulSetStrategy {
}
exports.RollingUpdateStatefulSetStrategy = RollingUpdateStatefulSetStrategy;
// Scale represents a scaling request for a resource.
class Scale {
    constructor(desc) {
        this.apiVersion = Scale.apiVersion;
        this.kind = Scale.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Scale = Scale;
function isScale(o) {
    return o && o.apiVersion === Scale.apiVersion && o.kind === Scale.kind;
}
exports.isScale = isScale;
(function (Scale) {
    Scale.apiVersion = "apps/v1beta1";
    Scale.group = "apps";
    Scale.version = "v1beta1";
    Scale.kind = "Scale";
    // named constructs a Scale with metadata.name set to name.
    function named(name) {
        return new Scale({ metadata: { name } });
    }
    Scale.named = named;
})(Scale = exports.Scale || (exports.Scale = {}));
// ScaleSpec describes the attributes of a scale subresource
class ScaleSpec {
}
exports.ScaleSpec = ScaleSpec;
// ScaleStatus represents the current status of a scale subresource.
class ScaleStatus {
    constructor(desc) {
        this.replicas = desc.replicas;
        this.selector = desc.selector;
        this.targetSelector = desc.targetSelector;
    }
}
exports.ScaleStatus = ScaleStatus;
// DEPRECATED - This group version of StatefulSet is deprecated by apps/v1beta2/StatefulSet. See the release notes for more information. StatefulSet represents a set of pods with consistent identities. Identities are defined as:
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
    StatefulSet.apiVersion = "apps/v1beta1";
    StatefulSet.group = "apps";
    StatefulSet.version = "v1beta1";
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
    StatefulSetList.apiVersion = "apps/v1beta1";
    StatefulSetList.group = "apps";
    StatefulSetList.version = "v1beta1";
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
//# sourceMappingURL=io.k8s.api.apps.v1beta1.js.map