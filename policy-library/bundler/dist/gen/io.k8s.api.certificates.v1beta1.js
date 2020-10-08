"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Describes a certificate signing request
class CertificateSigningRequest {
    constructor(desc) {
        this.apiVersion = CertificateSigningRequest.apiVersion;
        this.kind = CertificateSigningRequest.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.CertificateSigningRequest = CertificateSigningRequest;
function isCertificateSigningRequest(o) {
    return (o &&
        o.apiVersion === CertificateSigningRequest.apiVersion &&
        o.kind === CertificateSigningRequest.kind);
}
exports.isCertificateSigningRequest = isCertificateSigningRequest;
(function (CertificateSigningRequest) {
    CertificateSigningRequest.apiVersion = "certificates.k8s.io/v1beta1";
    CertificateSigningRequest.group = "certificates.k8s.io";
    CertificateSigningRequest.version = "v1beta1";
    CertificateSigningRequest.kind = "CertificateSigningRequest";
    // named constructs a CertificateSigningRequest with metadata.name set to name.
    function named(name) {
        return new CertificateSigningRequest({ metadata: { name } });
    }
    CertificateSigningRequest.named = named;
})(CertificateSigningRequest = exports.CertificateSigningRequest || (exports.CertificateSigningRequest = {}));
class CertificateSigningRequestCondition {
    constructor(desc) {
        this.lastUpdateTime = desc.lastUpdateTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.type = desc.type;
    }
}
exports.CertificateSigningRequestCondition = CertificateSigningRequestCondition;
class CertificateSigningRequestList {
    constructor(desc) {
        this.apiVersion = CertificateSigningRequestList.apiVersion;
        this.items = desc.items.map(i => new CertificateSigningRequest(i));
        this.kind = CertificateSigningRequestList.kind;
        this.metadata = desc.metadata;
    }
}
exports.CertificateSigningRequestList = CertificateSigningRequestList;
function isCertificateSigningRequestList(o) {
    return (o &&
        o.apiVersion === CertificateSigningRequestList.apiVersion &&
        o.kind === CertificateSigningRequestList.kind);
}
exports.isCertificateSigningRequestList = isCertificateSigningRequestList;
(function (CertificateSigningRequestList) {
    CertificateSigningRequestList.apiVersion = "certificates.k8s.io/v1beta1";
    CertificateSigningRequestList.group = "certificates.k8s.io";
    CertificateSigningRequestList.version = "v1beta1";
    CertificateSigningRequestList.kind = "CertificateSigningRequestList";
})(CertificateSigningRequestList = exports.CertificateSigningRequestList || (exports.CertificateSigningRequestList = {}));
// This information is immutable after the request is created. Only the Request and Usages fields can be set on creation, other fields are derived by Kubernetes and cannot be modified by users.
class CertificateSigningRequestSpec {
    constructor(desc) {
        this.extra = desc.extra;
        this.groups = desc.groups;
        this.request = desc.request;
        this.uid = desc.uid;
        this.usages = desc.usages;
        this.username = desc.username;
    }
}
exports.CertificateSigningRequestSpec = CertificateSigningRequestSpec;
class CertificateSigningRequestStatus {
}
exports.CertificateSigningRequestStatus = CertificateSigningRequestStatus;
//# sourceMappingURL=io.k8s.api.certificates.v1beta1.js.map