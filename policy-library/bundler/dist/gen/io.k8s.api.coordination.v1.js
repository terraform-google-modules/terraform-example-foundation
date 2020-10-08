"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Lease defines a lease concept.
class Lease {
    constructor(desc) {
        this.apiVersion = Lease.apiVersion;
        this.kind = Lease.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
    }
}
exports.Lease = Lease;
function isLease(o) {
    return o && o.apiVersion === Lease.apiVersion && o.kind === Lease.kind;
}
exports.isLease = isLease;
(function (Lease) {
    Lease.apiVersion = "coordination.k8s.io/v1";
    Lease.group = "coordination.k8s.io";
    Lease.version = "v1";
    Lease.kind = "Lease";
    // named constructs a Lease with metadata.name set to name.
    function named(name) {
        return new Lease({ metadata: { name } });
    }
    Lease.named = named;
})(Lease = exports.Lease || (exports.Lease = {}));
// LeaseList is a list of Lease objects.
class LeaseList {
    constructor(desc) {
        this.apiVersion = LeaseList.apiVersion;
        this.items = desc.items.map(i => new Lease(i));
        this.kind = LeaseList.kind;
        this.metadata = desc.metadata;
    }
}
exports.LeaseList = LeaseList;
function isLeaseList(o) {
    return (o && o.apiVersion === LeaseList.apiVersion && o.kind === LeaseList.kind);
}
exports.isLeaseList = isLeaseList;
(function (LeaseList) {
    LeaseList.apiVersion = "coordination.k8s.io/v1";
    LeaseList.group = "coordination.k8s.io";
    LeaseList.version = "v1";
    LeaseList.kind = "LeaseList";
})(LeaseList = exports.LeaseList || (exports.LeaseList = {}));
// LeaseSpec is a specification of a Lease.
class LeaseSpec {
}
exports.LeaseSpec = LeaseSpec;
//# sourceMappingURL=io.k8s.api.coordination.v1.js.map