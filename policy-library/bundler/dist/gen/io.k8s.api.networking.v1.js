"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// IPBlock describes a particular CIDR (Ex. "192.168.1.1/24") that is allowed to the pods matched by a NetworkPolicySpec's podSelector. The except entry describes CIDRs that should not be included within this rule.
class IPBlock {
    constructor(desc) {
        this.cidr = desc.cidr;
        this.except = desc.except;
    }
}
exports.IPBlock = IPBlock;
// NetworkPolicy describes what network traffic is allowed for a set of Pods
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
    NetworkPolicy.apiVersion = "networking.k8s.io/v1";
    NetworkPolicy.group = "networking.k8s.io";
    NetworkPolicy.version = "v1";
    NetworkPolicy.kind = "NetworkPolicy";
    // named constructs a NetworkPolicy with metadata.name set to name.
    function named(name) {
        return new NetworkPolicy({ metadata: { name } });
    }
    NetworkPolicy.named = named;
})(NetworkPolicy = exports.NetworkPolicy || (exports.NetworkPolicy = {}));
// NetworkPolicyEgressRule describes a particular set of traffic that is allowed out of pods matched by a NetworkPolicySpec's podSelector. The traffic must match both ports and to. This type is beta-level in 1.8
class NetworkPolicyEgressRule {
}
exports.NetworkPolicyEgressRule = NetworkPolicyEgressRule;
// NetworkPolicyIngressRule describes a particular set of traffic that is allowed to the pods matched by a NetworkPolicySpec's podSelector. The traffic must match both ports and from.
class NetworkPolicyIngressRule {
}
exports.NetworkPolicyIngressRule = NetworkPolicyIngressRule;
// NetworkPolicyList is a list of NetworkPolicy objects.
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
    NetworkPolicyList.apiVersion = "networking.k8s.io/v1";
    NetworkPolicyList.group = "networking.k8s.io";
    NetworkPolicyList.version = "v1";
    NetworkPolicyList.kind = "NetworkPolicyList";
})(NetworkPolicyList = exports.NetworkPolicyList || (exports.NetworkPolicyList = {}));
// NetworkPolicyPeer describes a peer to allow traffic from. Only certain combinations of fields are allowed
class NetworkPolicyPeer {
}
exports.NetworkPolicyPeer = NetworkPolicyPeer;
// NetworkPolicyPort describes a port to allow traffic on
class NetworkPolicyPort {
}
exports.NetworkPolicyPort = NetworkPolicyPort;
// NetworkPolicySpec provides the specification of a NetworkPolicy
class NetworkPolicySpec {
    constructor(desc) {
        this.egress = desc.egress;
        this.ingress = desc.ingress;
        this.podSelector = desc.podSelector;
        this.policyTypes = desc.policyTypes;
    }
}
exports.NetworkPolicySpec = NetworkPolicySpec;
//# sourceMappingURL=io.k8s.api.networking.v1.js.map