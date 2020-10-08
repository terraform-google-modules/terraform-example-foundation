"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// AllowedCSIDriver represents a single inline CSI Driver that is allowed to be used.
class AllowedCSIDriver {
    constructor(desc) {
        this.name = desc.name;
    }
}
exports.AllowedCSIDriver = AllowedCSIDriver;
// AllowedFlexVolume represents a single Flexvolume that is allowed to be used. Deprecated: use AllowedFlexVolume from policy API Group instead.
class AllowedFlexVolume {
    constructor(desc) {
        this.driver = desc.driver;
    }
}
exports.AllowedFlexVolume = AllowedFlexVolume;
// AllowedHostPath defines the host volume conditions that will be enabled by a policy for pods to use. It requires the path prefix to be defined. Deprecated: use AllowedHostPath from policy API Group instead.
class AllowedHostPath {
}
exports.AllowedHostPath = AllowedHostPath;
// DEPRECATED - This group version of DaemonSet is deprecated by apps/v1beta2/DaemonSet. See the release notes for more information. DaemonSet represents the configuration of a daemon set.
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
    DaemonSet.apiVersion = "extensions/v1beta1";
    DaemonSet.group = "extensions";
    DaemonSet.version = "v1beta1";
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
    DaemonSetList.apiVersion = "extensions/v1beta1";
    DaemonSetList.group = "extensions";
    DaemonSetList.version = "v1beta1";
    DaemonSetList.kind = "DaemonSetList";
})(DaemonSetList = exports.DaemonSetList || (exports.DaemonSetList = {}));
// DaemonSetSpec is the specification of a daemon set.
class DaemonSetSpec {
    constructor(desc) {
        this.minReadySeconds = desc.minReadySeconds;
        this.revisionHistoryLimit = desc.revisionHistoryLimit;
        this.selector = desc.selector;
        this.template = desc.template;
        this.templateGeneration = desc.templateGeneration;
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
class DaemonSetUpdateStrategy {
}
exports.DaemonSetUpdateStrategy = DaemonSetUpdateStrategy;
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
    Deployment.apiVersion = "extensions/v1beta1";
    Deployment.group = "extensions";
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
    DeploymentList.apiVersion = "extensions/v1beta1";
    DeploymentList.group = "extensions";
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
    DeploymentRollback.apiVersion = "extensions/v1beta1";
    DeploymentRollback.group = "extensions";
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
// FSGroupStrategyOptions defines the strategy type and options used to create the strategy. Deprecated: use FSGroupStrategyOptions from policy API Group instead.
class FSGroupStrategyOptions {
}
exports.FSGroupStrategyOptions = FSGroupStrategyOptions;
// HTTPIngressPath associates a path regex with a backend. Incoming urls matching the path are forwarded to the backend.
class HTTPIngressPath {
    constructor(desc) {
        this.backend = desc.backend;
        this.path = desc.path;
    }
}
exports.HTTPIngressPath = HTTPIngressPath;
// HTTPIngressRuleValue is a list of http selectors pointing to backends. In the example: http://<host>/<path>?<searchpart> -> backend where where parts of the url correspond to RFC 3986, this resource will be used to match against everything after the last '/' and before the first '?' or '#'.
class HTTPIngressRuleValue {
    constructor(desc) {
        this.paths = desc.paths;
    }
}
exports.HTTPIngressRuleValue = HTTPIngressRuleValue;
// HostPortRange defines a range of host ports that will be enabled by a policy for pods to use.  It requires both the start and end to be defined. Deprecated: use HostPortRange from policy API Group instead.
class HostPortRange {
    constructor(desc) {
        this.max = desc.max;
        this.min = desc.min;
    }
}
exports.HostPortRange = HostPortRange;
// IDRange provides a min/max of an allowed range of IDs. Deprecated: use IDRange from policy API Group instead.
class IDRange {
    constructor(desc) {
        this.max = desc.max;
        this.min = desc.min;
    }
}
exports.IDRange = IDRange;
// DEPRECATED 1.9 - This group version of IPBlock is deprecated by networking/v1/IPBlock. IPBlock describes a particular CIDR (Ex. "192.168.1.1/24") that is allowed to the pods matched by a NetworkPolicySpec's podSelector. The except entry describes CIDRs that should not be included within this rule.
class IPBlock {
    constructor(desc) {
        this.cidr = desc.cidr;
        this.except = desc.except;
    }
}
exports.IPBlock = IPBlock;
// Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc. DEPRECATED - This group version of Ingress is deprecated by networking.k8s.io/v1beta1 Ingress. See the release notes for more information.
class Ingress {
    constructor(desc) {
        this.apiVersion = Ingress.apiVersion;
        this.kind = Ingress.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Ingress = Ingress;
function isIngress(o) {
    return o && o.apiVersion === Ingress.apiVersion && o.kind === Ingress.kind;
}
exports.isIngress = isIngress;
(function (Ingress) {
    Ingress.apiVersion = "extensions/v1beta1";
    Ingress.group = "extensions";
    Ingress.version = "v1beta1";
    Ingress.kind = "Ingress";
    // named constructs a Ingress with metadata.name set to name.
    function named(name) {
        return new Ingress({ metadata: { name } });
    }
    Ingress.named = named;
})(Ingress = exports.Ingress || (exports.Ingress = {}));
// IngressBackend describes all endpoints for a given service and port.
class IngressBackend {
    constructor(desc) {
        this.serviceName = desc.serviceName;
        this.servicePort = desc.servicePort;
    }
}
exports.IngressBackend = IngressBackend;
// IngressList is a collection of Ingress.
class IngressList {
    constructor(desc) {
        this.apiVersion = IngressList.apiVersion;
        this.items = desc.items.map(i => new Ingress(i));
        this.kind = IngressList.kind;
        this.metadata = desc.metadata;
    }
}
exports.IngressList = IngressList;
function isIngressList(o) {
    return (o && o.apiVersion === IngressList.apiVersion && o.kind === IngressList.kind);
}
exports.isIngressList = isIngressList;
(function (IngressList) {
    IngressList.apiVersion = "extensions/v1beta1";
    IngressList.group = "extensions";
    IngressList.version = "v1beta1";
    IngressList.kind = "IngressList";
})(IngressList = exports.IngressList || (exports.IngressList = {}));
// IngressRule represents the rules mapping the paths under a specified host to the related backend services. Incoming requests are first evaluated for a host match, then routed to the backend associated with the matching IngressRuleValue.
class IngressRule {
}
exports.IngressRule = IngressRule;
// IngressSpec describes the Ingress the user wishes to exist.
class IngressSpec {
}
exports.IngressSpec = IngressSpec;
// IngressStatus describe the current state of the Ingress.
class IngressStatus {
}
exports.IngressStatus = IngressStatus;
// IngressTLS describes the transport layer security associated with an Ingress.
class IngressTLS {
}
exports.IngressTLS = IngressTLS;
// DEPRECATED 1.9 - This group version of NetworkPolicy is deprecated by networking/v1/NetworkPolicy. NetworkPolicy describes what network traffic is allowed for a set of Pods
class NetworkPolicy {
    constructor(desc) {
        this.apiVersion = NetworkPolicy.apiVersion;
        this.kind = NetworkPolicy.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
    }
}
exports.NetworkPolicy = NetworkPolicy;
function isNetworkPolicy(o) {
    return (o &&
        o.apiVersion === NetworkPolicy.apiVersion &&
        o.kind === NetworkPolicy.kind);
}
exports.isNetworkPolicy = isNetworkPolicy;
(function (NetworkPolicy) {
    NetworkPolicy.apiVersion = "extensions/v1beta1";
    NetworkPolicy.group = "extensions";
    NetworkPolicy.version = "v1beta1";
    NetworkPolicy.kind = "NetworkPolicy";
    // named constructs a NetworkPolicy with metadata.name set to name.
    function named(name) {
        return new NetworkPolicy({ metadata: { name } });
    }
    NetworkPolicy.named = named;
})(NetworkPolicy = exports.NetworkPolicy || (exports.NetworkPolicy = {}));
// DEPRECATED 1.9 - This group version of NetworkPolicyEgressRule is deprecated by networking/v1/NetworkPolicyEgressRule. NetworkPolicyEgressRule describes a particular set of traffic that is allowed out of pods matched by a NetworkPolicySpec's podSelector. The traffic must match both ports and to. This type is beta-level in 1.8
class NetworkPolicyEgressRule {
}
exports.NetworkPolicyEgressRule = NetworkPolicyEgressRule;
// DEPRECATED 1.9 - This group version of NetworkPolicyIngressRule is deprecated by networking/v1/NetworkPolicyIngressRule. This NetworkPolicyIngressRule matches traffic if and only if the traffic matches both ports AND from.
class NetworkPolicyIngressRule {
}
exports.NetworkPolicyIngressRule = NetworkPolicyIngressRule;
// DEPRECATED 1.9 - This group version of NetworkPolicyList is deprecated by networking/v1/NetworkPolicyList. Network Policy List is a list of NetworkPolicy objects.
class NetworkPolicyList {
    constructor(desc) {
        this.apiVersion = NetworkPolicyList.apiVersion;
        this.items = desc.items.map(i => new NetworkPolicy(i));
        this.kind = NetworkPolicyList.kind;
        this.metadata = desc.metadata;
    }
}
exports.NetworkPolicyList = NetworkPolicyList;
function isNetworkPolicyList(o) {
    return (o &&
        o.apiVersion === NetworkPolicyList.apiVersion &&
        o.kind === NetworkPolicyList.kind);
}
exports.isNetworkPolicyList = isNetworkPolicyList;
(function (NetworkPolicyList) {
    NetworkPolicyList.apiVersion = "extensions/v1beta1";
    NetworkPolicyList.group = "extensions";
    NetworkPolicyList.version = "v1beta1";
    NetworkPolicyList.kind = "NetworkPolicyList";
})(NetworkPolicyList = exports.NetworkPolicyList || (exports.NetworkPolicyList = {}));
// DEPRECATED 1.9 - This group version of NetworkPolicyPeer is deprecated by networking/v1/NetworkPolicyPeer.
class NetworkPolicyPeer {
}
exports.NetworkPolicyPeer = NetworkPolicyPeer;
// DEPRECATED 1.9 - This group version of NetworkPolicyPort is deprecated by networking/v1/NetworkPolicyPort.
class NetworkPolicyPort {
}
exports.NetworkPolicyPort = NetworkPolicyPort;
// DEPRECATED 1.9 - This group version of NetworkPolicySpec is deprecated by networking/v1/NetworkPolicySpec.
class NetworkPolicySpec {
    constructor(desc) {
        this.egress = desc.egress;
        this.ingress = desc.ingress;
        this.podSelector = desc.podSelector;
        this.policyTypes = desc.policyTypes;
    }
}
exports.NetworkPolicySpec = NetworkPolicySpec;
// PodSecurityPolicy governs the ability to make requests that affect the Security Context that will be applied to a pod and container. Deprecated: use PodSecurityPolicy from policy API Group instead.
class PodSecurityPolicy {
    constructor(desc) {
        this.apiVersion = PodSecurityPolicy.apiVersion;
        this.kind = PodSecurityPolicy.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
    }
}
exports.PodSecurityPolicy = PodSecurityPolicy;
function isPodSecurityPolicy(o) {
    return (o &&
        o.apiVersion === PodSecurityPolicy.apiVersion &&
        o.kind === PodSecurityPolicy.kind);
}
exports.isPodSecurityPolicy = isPodSecurityPolicy;
(function (PodSecurityPolicy) {
    PodSecurityPolicy.apiVersion = "extensions/v1beta1";
    PodSecurityPolicy.group = "extensions";
    PodSecurityPolicy.version = "v1beta1";
    PodSecurityPolicy.kind = "PodSecurityPolicy";
    // named constructs a PodSecurityPolicy with metadata.name set to name.
    function named(name) {
        return new PodSecurityPolicy({ metadata: { name } });
    }
    PodSecurityPolicy.named = named;
})(PodSecurityPolicy = exports.PodSecurityPolicy || (exports.PodSecurityPolicy = {}));
// PodSecurityPolicyList is a list of PodSecurityPolicy objects. Deprecated: use PodSecurityPolicyList from policy API Group instead.
class PodSecurityPolicyList {
    constructor(desc) {
        this.apiVersion = PodSecurityPolicyList.apiVersion;
        this.items = desc.items.map(i => new PodSecurityPolicy(i));
        this.kind = PodSecurityPolicyList.kind;
        this.metadata = desc.metadata;
    }
}
exports.PodSecurityPolicyList = PodSecurityPolicyList;
function isPodSecurityPolicyList(o) {
    return (o &&
        o.apiVersion === PodSecurityPolicyList.apiVersion &&
        o.kind === PodSecurityPolicyList.kind);
}
exports.isPodSecurityPolicyList = isPodSecurityPolicyList;
(function (PodSecurityPolicyList) {
    PodSecurityPolicyList.apiVersion = "extensions/v1beta1";
    PodSecurityPolicyList.group = "extensions";
    PodSecurityPolicyList.version = "v1beta1";
    PodSecurityPolicyList.kind = "PodSecurityPolicyList";
})(PodSecurityPolicyList = exports.PodSecurityPolicyList || (exports.PodSecurityPolicyList = {}));
// PodSecurityPolicySpec defines the policy enforced. Deprecated: use PodSecurityPolicySpec from policy API Group instead.
class PodSecurityPolicySpec {
    constructor(desc) {
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
exports.PodSecurityPolicySpec = PodSecurityPolicySpec;
// DEPRECATED - This group version of ReplicaSet is deprecated by apps/v1beta2/ReplicaSet. See the release notes for more information. ReplicaSet ensures that a specified number of pod replicas are running at any given time.
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
    ReplicaSet.apiVersion = "extensions/v1beta1";
    ReplicaSet.group = "extensions";
    ReplicaSet.version = "v1beta1";
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
    ReplicaSetList.apiVersion = "extensions/v1beta1";
    ReplicaSetList.group = "extensions";
    ReplicaSetList.version = "v1beta1";
    ReplicaSetList.kind = "ReplicaSetList";
})(ReplicaSetList = exports.ReplicaSetList || (exports.ReplicaSetList = {}));
// ReplicaSetSpec is the specification of a ReplicaSet.
class ReplicaSetSpec {
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
// DEPRECATED.
class RollbackConfig {
}
exports.RollbackConfig = RollbackConfig;
// Spec to control the desired behavior of daemon set rolling update.
class RollingUpdateDaemonSet {
}
exports.RollingUpdateDaemonSet = RollingUpdateDaemonSet;
// Spec to control the desired behavior of rolling update.
class RollingUpdateDeployment {
}
exports.RollingUpdateDeployment = RollingUpdateDeployment;
// RunAsGroupStrategyOptions defines the strategy type and any options used to create the strategy. Deprecated: use RunAsGroupStrategyOptions from policy API Group instead.
class RunAsGroupStrategyOptions {
    constructor(desc) {
        this.ranges = desc.ranges;
        this.rule = desc.rule;
    }
}
exports.RunAsGroupStrategyOptions = RunAsGroupStrategyOptions;
// RunAsUserStrategyOptions defines the strategy type and any options used to create the strategy. Deprecated: use RunAsUserStrategyOptions from policy API Group instead.
class RunAsUserStrategyOptions {
    constructor(desc) {
        this.ranges = desc.ranges;
        this.rule = desc.rule;
    }
}
exports.RunAsUserStrategyOptions = RunAsUserStrategyOptions;
// SELinuxStrategyOptions defines the strategy type and any options used to create the strategy. Deprecated: use SELinuxStrategyOptions from policy API Group instead.
class SELinuxStrategyOptions {
    constructor(desc) {
        this.rule = desc.rule;
        this.seLinuxOptions = desc.seLinuxOptions;
    }
}
exports.SELinuxStrategyOptions = SELinuxStrategyOptions;
// represents a scaling request for a resource.
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
    Scale.apiVersion = "extensions/v1beta1";
    Scale.group = "extensions";
    Scale.version = "v1beta1";
    Scale.kind = "Scale";
    // named constructs a Scale with metadata.name set to name.
    function named(name) {
        return new Scale({ metadata: { name } });
    }
    Scale.named = named;
})(Scale = exports.Scale || (exports.Scale = {}));
// describes the attributes of a scale subresource
class ScaleSpec {
}
exports.ScaleSpec = ScaleSpec;
// represents the current status of a scale subresource.
class ScaleStatus {
    constructor(desc) {
        this.replicas = desc.replicas;
        this.selector = desc.selector;
        this.targetSelector = desc.targetSelector;
    }
}
exports.ScaleStatus = ScaleStatus;
// SupplementalGroupsStrategyOptions defines the strategy type and options used to create the strategy. Deprecated: use SupplementalGroupsStrategyOptions from policy API Group instead.
class SupplementalGroupsStrategyOptions {
}
exports.SupplementalGroupsStrategyOptions = SupplementalGroupsStrategyOptions;
//# sourceMappingURL=io.k8s.api.extensions.v1beta1.js.map