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

// AllowedFlexVolume represents a single Flexvolume that is allowed to be used.
export class AllowedFlexVolume {
  // driver is the name of the Flexvolume driver.
  public driver: string;

  constructor(desc: AllowedFlexVolume) {
    this.driver = desc.driver;
  }
}

// AllowedHostPath defines the host volume conditions that will be enabled by a policy for pods to use. It requires the path prefix to be defined.
export class AllowedHostPath {
  // pathPrefix is the path prefix that the host volume must match. It does not support `*`. Trailing slashes are trimmed when validating the path prefix with a host path.
  //
  // Examples: `/foo` would allow `/foo`, `/foo/` and `/foo/bar` `/foo` would not allow `/food` or `/etc/foo`
  public pathPrefix?: string;

  // when set to true, will allow host volumes matching the pathPrefix only if all volume mounts are readOnly.
  public readOnly?: boolean;
}

// Eviction evicts a pod from its node subject to certain policies and safety constraints. This is a subresource of Pod.  A request to cause such an eviction is created by POSTing to .../pods/<pod name>/evictions.
export class Eviction implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // DeleteOptions may be provided
  public deleteOptions?: apisMetaV1.DeleteOptions;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // ObjectMeta describes the pod that is being evicted.
  public metadata: apisMetaV1.ObjectMeta;

  constructor(desc: Eviction.Interface) {
    this.apiVersion = Eviction.apiVersion;
    this.deleteOptions = desc.deleteOptions;
    this.kind = Eviction.kind;
    this.metadata = desc.metadata;
  }
}

export function isEviction(o: any): o is Eviction {
  return o && o.apiVersion === Eviction.apiVersion && o.kind === Eviction.kind;
}

export namespace Eviction {
  export const apiVersion = "policy/v1beta1";
  export const group = "policy";
  export const version = "v1beta1";
  export const kind = "Eviction";

  // named constructs a Eviction with metadata.name set to name.
  export function named(name: string): Eviction {
    return new Eviction({ metadata: { name } });
  }
  // Eviction evicts a pod from its node subject to certain policies and safety constraints. This is a subresource of Pod.  A request to cause such an eviction is created by POSTing to .../pods/<pod name>/evictions.
  export interface Interface {
    // DeleteOptions may be provided
    deleteOptions?: apisMetaV1.DeleteOptions;

    // ObjectMeta describes the pod that is being evicted.
    metadata: apisMetaV1.ObjectMeta;
  }
}

// FSGroupStrategyOptions defines the strategy type and options used to create the strategy.
export class FSGroupStrategyOptions {
  // ranges are the allowed ranges of fs groups.  If you would like to force a single fs group then supply a single range with the same start and end. Required for MustRunAs.
  public ranges?: IDRange[];

  // rule is the strategy that will dictate what FSGroup is used in the SecurityContext.
  public rule?: string;
}

// HostPortRange defines a range of host ports that will be enabled by a policy for pods to use.  It requires both the start and end to be defined.
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

// IDRange provides a min/max of an allowed range of IDs.
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

// PodDisruptionBudget is an object to define the max disruption that can be caused to a collection of pods
export class PodDisruptionBudget implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior of the PodDisruptionBudget.
  public spec?: PodDisruptionBudgetSpec;

  // Most recently observed status of the PodDisruptionBudget.
  public status?: PodDisruptionBudgetStatus;

  constructor(desc: PodDisruptionBudget.Interface) {
    this.apiVersion = PodDisruptionBudget.apiVersion;
    this.kind = PodDisruptionBudget.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isPodDisruptionBudget(o: any): o is PodDisruptionBudget {
  return (
    o &&
    o.apiVersion === PodDisruptionBudget.apiVersion &&
    o.kind === PodDisruptionBudget.kind
  );
}

export namespace PodDisruptionBudget {
  export const apiVersion = "policy/v1beta1";
  export const group = "policy";
  export const version = "v1beta1";
  export const kind = "PodDisruptionBudget";

  // named constructs a PodDisruptionBudget with metadata.name set to name.
  export function named(name: string): PodDisruptionBudget {
    return new PodDisruptionBudget({ metadata: { name } });
  }
  // PodDisruptionBudget is an object to define the max disruption that can be caused to a collection of pods
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the desired behavior of the PodDisruptionBudget.
    spec?: PodDisruptionBudgetSpec;

    // Most recently observed status of the PodDisruptionBudget.
    status?: PodDisruptionBudgetStatus;
  }
}

// PodDisruptionBudgetList is a collection of PodDisruptionBudgets.
export class PodDisruptionBudgetList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  public items: PodDisruptionBudget[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: PodDisruptionBudgetList) {
    this.apiVersion = PodDisruptionBudgetList.apiVersion;
    this.items = desc.items.map(i => new PodDisruptionBudget(i));
    this.kind = PodDisruptionBudgetList.kind;
    this.metadata = desc.metadata;
  }
}

export function isPodDisruptionBudgetList(
  o: any
): o is PodDisruptionBudgetList {
  return (
    o &&
    o.apiVersion === PodDisruptionBudgetList.apiVersion &&
    o.kind === PodDisruptionBudgetList.kind
  );
}

export namespace PodDisruptionBudgetList {
  export const apiVersion = "policy/v1beta1";
  export const group = "policy";
  export const version = "v1beta1";
  export const kind = "PodDisruptionBudgetList";

  // PodDisruptionBudgetList is a collection of PodDisruptionBudgets.
  export interface Interface {
    items: PodDisruptionBudget[];

    metadata?: apisMetaV1.ListMeta;
  }
}

// PodDisruptionBudgetSpec is a description of a PodDisruptionBudget.
export class PodDisruptionBudgetSpec {
  // An eviction is allowed if at most "maxUnavailable" pods selected by "selector" are unavailable after the eviction, i.e. even in absence of the evicted pod. For example, one can prevent all voluntary evictions by specifying 0. This is a mutually exclusive setting with "minAvailable".
  public maxUnavailable?: pkgUtilIntstr.IntOrString;

  // An eviction is allowed if at least "minAvailable" pods selected by "selector" will still be available after the eviction, i.e. even in the absence of the evicted pod.  So for example you can prevent all voluntary evictions by specifying "100%".
  public minAvailable?: pkgUtilIntstr.IntOrString;

  // Label query over pods whose evictions are managed by the disruption budget.
  public selector?: apisMetaV1.LabelSelector;
}

// PodDisruptionBudgetStatus represents information about the status of a PodDisruptionBudget. Status may trail the actual state of a system.
export class PodDisruptionBudgetStatus {
  // current number of healthy pods
  public currentHealthy: number;

  // minimum desired number of healthy pods
  public desiredHealthy: number;

  // DisruptedPods contains information about pods whose eviction was processed by the API server eviction subresource handler but has not yet been observed by the PodDisruptionBudget controller. A pod will be in this map from the time when the API server processed the eviction request to the time when the pod is seen by PDB controller as having been marked for deletion (or after a timeout). The key in the map is the name of the pod and the value is the time when the API server processed the eviction request. If the deletion didn't occur and a pod is still there it will be removed from the list automatically by PodDisruptionBudget controller after some time. If everything goes smooth this map should be empty for the most of the time. Large number of entries in the map may indicate problems with pod deletions.
  public disruptedPods?: { [key: string]: apisMetaV1.Time };

  // Number of pod disruptions that are currently allowed.
  public disruptionsAllowed: number;

  // total number of pods counted by this disruption budget
  public expectedPods: number;

  // Most recent generation observed when updating this PDB status. PodDisruptionsAllowed and other status informatio is valid only if observedGeneration equals to PDB's object generation.
  public observedGeneration?: number;

  constructor(desc: PodDisruptionBudgetStatus) {
    this.currentHealthy = desc.currentHealthy;
    this.desiredHealthy = desc.desiredHealthy;
    this.disruptedPods = desc.disruptedPods;
    this.disruptionsAllowed = desc.disruptionsAllowed;
    this.expectedPods = desc.expectedPods;
    this.observedGeneration = desc.observedGeneration;
  }
}

// PodSecurityPolicy governs the ability to make requests that affect the Security Context that will be applied to a pod and container.
export class PodSecurityPolicy implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
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
  export const apiVersion = "policy/v1beta1";
  export const group = "policy";
  export const version = "v1beta1";
  export const kind = "PodSecurityPolicy";

  // named constructs a PodSecurityPolicy with metadata.name set to name.
  export function named(name: string): PodSecurityPolicy {
    return new PodSecurityPolicy({ metadata: { name } });
  }
  // PodSecurityPolicy governs the ability to make requests that affect the Security Context that will be applied to a pod and container.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // spec defines the policy enforced.
    spec?: PodSecurityPolicySpec;
  }
}

// PodSecurityPolicyList is a list of PodSecurityPolicy objects.
export class PodSecurityPolicyList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // items is a list of schema objects.
  public items: PodSecurityPolicy[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
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
  export const apiVersion = "policy/v1beta1";
  export const group = "policy";
  export const version = "v1beta1";
  export const kind = "PodSecurityPolicyList";

  // PodSecurityPolicyList is a list of PodSecurityPolicy objects.
  export interface Interface {
    // items is a list of schema objects.
    items: PodSecurityPolicy[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// PodSecurityPolicySpec defines the policy enforced.
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

// RunAsGroupStrategyOptions defines the strategy type and any options used to create the strategy.
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

// RunAsUserStrategyOptions defines the strategy type and any options used to create the strategy.
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

// SELinuxStrategyOptions defines the strategy type and any options used to create the strategy.
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

// SupplementalGroupsStrategyOptions defines the strategy type and options used to create the strategy.
export class SupplementalGroupsStrategyOptions {
  // ranges are the allowed ranges of supplemental groups.  If you would like to force a single supplemental group then supply a single range with the same start and end. Required for MustRunAs.
  public ranges?: IDRange[];

  // rule is the strategy that will dictate what supplemental groups is used in the SecurityContext.
  public rule?: string;
}
