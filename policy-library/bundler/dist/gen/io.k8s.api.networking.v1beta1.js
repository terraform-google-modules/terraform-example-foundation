"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
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
// Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc.
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
    Ingress.apiVersion = "networking.k8s.io/v1beta1";
    Ingress.group = "networking.k8s.io";
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
    IngressList.apiVersion = "networking.k8s.io/v1beta1";
    IngressList.group = "networking.k8s.io";
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
//# sourceMappingURL=io.k8s.api.networking.v1beta1.js.map