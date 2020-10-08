"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// AllowedCSIDriver represents a single inline CSI Driver that is allowed to be used.
class AllowedCSIDriver {
    constructor(desc) {
        this.name = desc.name;
    }
}
exports.AllowedCSIDriver = AllowedCSIDriver;
// AllowedFlexVolume represents a single Flexvolume that is allowed to be used.
class AllowedFlexVolume {
    constructor(desc) {
        this.driver = desc.driver;
    }
}
exports.AllowedFlexVolume = AllowedFlexVolume;
// AllowedHostPath defines the host volume conditions that will be enabled by a policy for pods to use. It requires the path prefix to be defined.
class AllowedHostPath {
}
exports.AllowedHostPath = AllowedHostPath;
// Eviction evicts a pod from its node subject to certain policies and safety constraints. This is a subresource of Pod.  A request to cause such an eviction is created by POSTing to .../pods/<pod name>/evictions.
class Eviction {
    constructor(desc) {
        this.apiVersion = Eviction.apiVersion;
        this.deleteOptions = desc.deleteOptions;
        this.kind = Eviction.kind;
        this.metadata = desc.metadata;
    }
}
exports.Eviction = Eviction;
function isEviction(o) {
    return o && o.apiVersion === Eviction.apiVersion && o.kind === Eviction.kind;
}
exports.isEviction = isEviction;
(function (Eviction) {
    Eviction.apiVersion = "policy/v1beta1";
    Eviction.group = "policy";
    Eviction.version = "v1beta1";
    Eviction.kind = "Eviction";
    // named constructs a Eviction with metadata.name set to name.
    function named(name) {
        return new Eviction({ metadata: { name } });
    }
    Eviction.named = named;
})(Eviction = exports.Eviction || (exports.Eviction = {}));
// FSGroupStrategyOptions defines the strategy type and options used to create the strategy.
class FSGroupStrategyOptions {
}
exports.FSGroupStrategyOptions = FSGroupStrategyOptions;
// HostPortRange defines a range of host ports that will be enabled by a policy for pods to use.  It requires both the start and end to be defined.
class HostPortRange {
    constructor(desc) {
        this.max = desc.max;
        this.min = desc.min;
    }
}
exports.HostPortRange = HostPortRange;
// IDRange provides a min/max of an allowed range of IDs.
class IDRange {
    constructor(desc) {
        this.max = desc.max;
        this.min = desc.min;
    }
}
exports.IDRange = IDRange;
// PodDisruptionBudget is an object to define the max disruption that can be caused to a collection of pods
class PodDisruptionBudget {
    constructor(desc) {
        this.apiVersion = PodDisruptionBudget.apiVersion;
        this.kind = PodDisruptionBudget.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.PodDisruptionBudget = PodDisruptionBudget;
function isPodDisruptionBudget(o) {
    return (o &&
        o.apiVersion === PodDisruptionBudget.apiVersion &&
        o.kind === PodDisruptionBudget.kind);
}
exports.isPodDisruptionBudget = isPodDisruptionBudget;
(function (PodDisruptionBudget) {
    PodDisruptionBudget.apiVersion = "policy/v1beta1";
    PodDisruptionBudget.group = "policy";
    PodDisruptionBudget.version = "v1beta1";
    PodDisruptionBudget.kind = "PodDisruptionBudget";
    // named constructs a PodDisruptionBudget with metadata.name set to name.
    function named(name) {
        return new PodDisruptionBudget({ metadata: { name } });
    }
    PodDisruptionBudget.named = named;
})(PodDisruptionBudget = exports.PodDisruptionBudget || (exports.PodDisruptionBudget = {}));
// PodDisruptionBudgetList is a collection of PodDisruptionBudgets.
class PodDisruptionBudgetList {
    constructor(desc) {
        this.apiVersion = PodDisruptionBudgetList.apiVersion;
        this.items = desc.items.map(i => new PodDisruptionBudget(i));
        this.kind = PodDisruptionBudgetList.kind;
        this.metadata = desc.metadata;
    }
}
exports.PodDisruptionBudgetList = PodDisruptionBudgetList;
function isPodDisruptionBudgetList(o) {
    return (o &&
        o.apiVersion === PodDisruptionBudgetList.apiVersion &&
        o.kind === PodDisruptionBudgetList.kind);
}
exports.isPodDisruptionBudgetList = isPodDisruptionBudgetList;
(function (PodDisruptionBudgetList) {
    PodDisruptionBudgetList.apiVersion = "policy/v1beta1";
    PodDisruptionBudgetList.group = "policy";
    PodDisruptionBudgetList.version = "v1beta1";
    PodDisruptionBudgetList.kind = "PodDisruptionBudgetList";
})(PodDisruptionBudgetList = exports.PodDisruptionBudgetList || (exports.PodDisruptionBudgetList = {}));
// PodDisruptionBudgetSpec is a description of a PodDisruptionBudget.
class PodDisruptionBudgetSpec {
}
exports.PodDisruptionBudgetSpec = PodDisruptionBudgetSpec;
// PodDisruptionBudgetStatus represents information about the status of a PodDisruptionBudget. Status may trail the actual state of a system.
class PodDisruptionBudgetStatus {
    constructor(desc) {
        this.currentHealthy = desc.currentHealthy;
        this.desiredHealthy = desc.desiredHealthy;
        this.disruptedPods = desc.disruptedPods;
        this.disruptionsAllowed = desc.disruptionsAllowed;
        this.expectedPods = desc.expectedPods;
        this.observedGeneration = desc.observedGeneration;
    }
}
exports.PodDisruptionBudgetStatus = PodDisruptionBudgetStatus;
// PodSecurityPolicy governs the ability to make requests that affect the Security Context that will be applied to a pod and container.
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
    PodSecurityPolicy.apiVersion = "policy/v1beta1";
    PodSecurityPolicy.group = "policy";
    PodSecurityPolicy.version = "v1beta1";
    PodSecurityPolicy.kind = "PodSecurityPolicy";
    // named constructs a PodSecurityPolicy with metadata.name set to name.
    function named(name) {
        return new PodSecurityPolicy({ metadata: { name } });
    }
    PodSecurityPolicy.named = named;
})(PodSecurityPolicy = exports.PodSecurityPolicy || (exports.PodSecurityPolicy = {}));
// PodSecurityPolicyList is a list of PodSecurityPolicy objects.
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
    PodSecurityPolicyList.apiVersion = "policy/v1beta1";
    PodSecurityPolicyList.group = "policy";
    PodSecurityPolicyList.version = "v1beta1";
    PodSecurityPolicyList.kind = "PodSecurityPolicyList";
})(PodSecurityPolicyList = exports.PodSecurityPolicyList || (exports.PodSecurityPolicyList = {}));
// PodSecurityPolicySpec defines the policy enforced.
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
// RunAsGroupStrategyOptions defines the strategy type and any options used to create the strategy.
class RunAsGroupStrategyOptions {
    constructor(desc) {
        this.ranges = desc.ranges;
        this.rule = desc.rule;
    }
}
exports.RunAsGroupStrategyOptions = RunAsGroupStrategyOptions;
// RunAsUserStrategyOptions defines the strategy type and any options used to create the strategy.
class RunAsUserStrategyOptions {
    constructor(desc) {
        this.ranges = desc.ranges;
        this.rule = desc.rule;
    }
}
exports.RunAsUserStrategyOptions = RunAsUserStrategyOptions;
// SELinuxStrategyOptions defines the strategy type and any options used to create the strategy.
class SELinuxStrategyOptions {
    constructor(desc) {
        this.rule = desc.rule;
        this.seLinuxOptions = desc.seLinuxOptions;
    }
}
exports.SELinuxStrategyOptions = SELinuxStrategyOptions;
// SupplementalGroupsStrategyOptions defines the strategy type and options used to create the strategy.
class SupplementalGroupsStrategyOptions {
}
exports.SupplementalGroupsStrategyOptions = SupplementalGroupsStrategyOptions;
//# sourceMappingURL=io.k8s.api.policy.v1beta1.js.map