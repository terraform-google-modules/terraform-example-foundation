"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Endpoint represents a single logical "backend" implementing a service.
class Endpoint {
    constructor(desc) {
        this.addresses = desc.addresses;
        this.conditions = desc.conditions;
        this.hostname = desc.hostname;
        this.targetRef = desc.targetRef;
        this.topology = desc.topology;
    }
}
exports.Endpoint = Endpoint;
// EndpointConditions represents the current condition of an endpoint.
class EndpointConditions {
}
exports.EndpointConditions = EndpointConditions;
// EndpointPort represents a Port used by an EndpointSlice
class EndpointPort {
}
exports.EndpointPort = EndpointPort;
// EndpointSlice represents a subset of the endpoints that implement a service. For a given service there may be multiple EndpointSlice objects, selected by labels, which must be joined to produce the full set of endpoints.
class EndpointSlice {
    constructor(desc) {
        this.addressType = desc.addressType;
        this.apiVersion = EndpointSlice.apiVersion;
        this.endpoints = desc.endpoints;
        this.kind = EndpointSlice.kind;
        this.metadata = desc.metadata;
        this.ports = desc.ports;
    }
}
exports.EndpointSlice = EndpointSlice;
function isEndpointSlice(o) {
    return o && o.apiVersion === EndpointSlice.apiVersion && o.kind === EndpointSlice.kind;
}
exports.isEndpointSlice = isEndpointSlice;
(function (EndpointSlice) {
    EndpointSlice.apiVersion = "discovery.k8s.io/v1beta1";
    EndpointSlice.group = "discovery.k8s.io";
    EndpointSlice.version = "v1beta1";
    EndpointSlice.kind = "EndpointSlice";
})(EndpointSlice = exports.EndpointSlice || (exports.EndpointSlice = {}));
// EndpointSliceList represents a list of endpoint slices
class EndpointSliceList {
    constructor(desc) {
        this.apiVersion = EndpointSliceList.apiVersion;
        this.items = desc.items.map((i) => new EndpointSlice(i));
        this.kind = EndpointSliceList.kind;
        this.metadata = desc.metadata;
    }
}
exports.EndpointSliceList = EndpointSliceList;
function isEndpointSliceList(o) {
    return o && o.apiVersion === EndpointSliceList.apiVersion && o.kind === EndpointSliceList.kind;
}
exports.isEndpointSliceList = isEndpointSliceList;
(function (EndpointSliceList) {
    EndpointSliceList.apiVersion = "discovery.k8s.io/v1beta1";
    EndpointSliceList.group = "discovery.k8s.io";
    EndpointSliceList.version = "v1beta1";
    EndpointSliceList.kind = "EndpointSliceList";
})(EndpointSliceList = exports.EndpointSliceList || (exports.EndpointSliceList = {}));
//# sourceMappingURL=io.k8s.api.discovery.v1beta1.js.map