import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";
import * as pkgUtilIntstr from "./io.k8s.apimachinery.pkg.util.intstr";

// IPBlock describes a particular CIDR (Ex. "192.168.1.1/24") that is allowed to the pods matched by a NetworkPolicySpec's podSelector. The except entry describes CIDRs that should not be included within this rule.
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

// NetworkPolicy describes what network traffic is allowed for a set of Pods
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
  export const apiVersion = "networking.k8s.io/v1";
  export const group = "networking.k8s.io";
  export const version = "v1";
  export const kind = "NetworkPolicy";

  // named constructs a NetworkPolicy with metadata.name set to name.
  export function named(name: string): NetworkPolicy {
    return new NetworkPolicy({ metadata: { name } });
  }
  // NetworkPolicy describes what network traffic is allowed for a set of Pods
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the desired behavior for this NetworkPolicy.
    spec?: NetworkPolicySpec;
  }
}

// NetworkPolicyEgressRule describes a particular set of traffic that is allowed out of pods matched by a NetworkPolicySpec's podSelector. The traffic must match both ports and to. This type is beta-level in 1.8
export class NetworkPolicyEgressRule {
  // List of destination ports for outgoing traffic. Each item in this list is combined using a logical OR. If this field is empty or missing, this rule matches all ports (traffic not restricted by port). If this field is present and contains at least one item, then this rule allows traffic only if the traffic matches at least one port in the list.
  public ports?: NetworkPolicyPort[];

  // List of destinations for outgoing traffic of pods selected for this rule. Items in this list are combined using a logical OR operation. If this field is empty or missing, this rule matches all destinations (traffic not restricted by destination). If this field is present and contains at least one item, this rule allows traffic only if the traffic matches at least one item in the to list.
  public to?: NetworkPolicyPeer[];
}

// NetworkPolicyIngressRule describes a particular set of traffic that is allowed to the pods matched by a NetworkPolicySpec's podSelector. The traffic must match both ports and from.
export class NetworkPolicyIngressRule {
  // List of sources which should be able to access the pods selected for this rule. Items in this list are combined using a logical OR operation. If this field is empty or missing, this rule matches all sources (traffic not restricted by source). If this field is present and contains at least on item, this rule allows traffic only if the traffic matches at least one item in the from list.
  public from?: NetworkPolicyPeer[];

  // List of ports which should be made accessible on the pods selected for this rule. Each item in this list is combined using a logical OR. If this field is empty or missing, this rule matches all ports (traffic not restricted by port). If this field is present and contains at least one item, then this rule allows traffic only if the traffic matches at least one port in the list.
  public ports?: NetworkPolicyPort[];
}

// NetworkPolicyList is a list of NetworkPolicy objects.
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
  export const apiVersion = "networking.k8s.io/v1";
  export const group = "networking.k8s.io";
  export const version = "v1";
  export const kind = "NetworkPolicyList";

  // NetworkPolicyList is a list of NetworkPolicy objects.
  export interface Interface {
    // Items is a list of schema objects.
    items: NetworkPolicy[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// NetworkPolicyPeer describes a peer to allow traffic from. Only certain combinations of fields are allowed
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

// NetworkPolicyPort describes a port to allow traffic on
export class NetworkPolicyPort {
  // The port on the given protocol. This can either be a numerical or named port on a pod. If this field is not provided, this matches all port names and numbers.
  public port?: pkgUtilIntstr.IntOrString;

  // The protocol (TCP, UDP, or SCTP) which traffic must match. If not specified, this field defaults to TCP.
  public protocol?: string;
}

// NetworkPolicySpec provides the specification of a NetworkPolicy
export class NetworkPolicySpec {
  // List of egress rules to be applied to the selected pods. Outgoing traffic is allowed if there are no NetworkPolicies selecting the pod (and cluster policy otherwise allows the traffic), OR if the traffic matches at least one egress rule across all of the NetworkPolicy objects whose podSelector matches the pod. If this field is empty then this NetworkPolicy limits all outgoing traffic (and serves solely to ensure that the pods it selects are isolated by default). This field is beta-level in 1.8
  public egress?: NetworkPolicyEgressRule[];

  // List of ingress rules to be applied to the selected pods. Traffic is allowed to a pod if there are no NetworkPolicies selecting the pod (and cluster policy otherwise allows the traffic), OR if the traffic source is the pod's local node, OR if the traffic matches at least one ingress rule across all of the NetworkPolicy objects whose podSelector matches the pod. If this field is empty then this NetworkPolicy does not allow any traffic (and serves solely to ensure that the pods it selects are isolated by default)
  public ingress?: NetworkPolicyIngressRule[];

  // Selects the pods to which this NetworkPolicy object applies. The array of ingress rules is applied to any pods selected by this field. Multiple network policies can select the same set of pods. In this case, the ingress rules for each are combined additively. This field is NOT optional and follows standard label selector semantics. An empty podSelector matches all pods in this namespace.
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
