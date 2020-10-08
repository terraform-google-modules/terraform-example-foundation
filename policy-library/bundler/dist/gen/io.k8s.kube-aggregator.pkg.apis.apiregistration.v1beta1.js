"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// APIService represents a server for a particular GroupVersion. Name must be "version.group".
class APIService {
    constructor(desc) {
        this.apiVersion = APIService.apiVersion;
        this.kind = APIService.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.APIService = APIService;
function isAPIService(o) {
    return (o && o.apiVersion === APIService.apiVersion && o.kind === APIService.kind);
}
exports.isAPIService = isAPIService;
(function (APIService) {
    APIService.apiVersion = "apiregistration.k8s.io/v1beta1";
    APIService.group = "apiregistration.k8s.io";
    APIService.version = "v1beta1";
    APIService.kind = "APIService";
    // named constructs a APIService with metadata.name set to name.
    function named(name) {
        return new APIService({ metadata: { name } });
    }
    APIService.named = named;
})(APIService = exports.APIService || (exports.APIService = {}));
// APIServiceCondition describes the state of an APIService at a particular point
class APIServiceCondition {
    constructor(desc) {
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.APIServiceCondition = APIServiceCondition;
// APIServiceList is a list of APIService objects.
class APIServiceList {
    constructor(desc) {
        this.apiVersion = APIServiceList.apiVersion;
        this.items = desc.items.map(i => new APIService(i));
        this.kind = APIServiceList.kind;
        this.metadata = desc.metadata;
    }
}
exports.APIServiceList = APIServiceList;
function isAPIServiceList(o) {
    return (o &&
        o.apiVersion === APIServiceList.apiVersion &&
        o.kind === APIServiceList.kind);
}
exports.isAPIServiceList = isAPIServiceList;
(function (APIServiceList) {
    APIServiceList.apiVersion = "apiregistration.k8s.io/v1beta1";
    APIServiceList.group = "apiregistration.k8s.io";
    APIServiceList.version = "v1beta1";
    APIServiceList.kind = "APIServiceList";
})(APIServiceList = exports.APIServiceList || (exports.APIServiceList = {}));
// APIServiceSpec contains information for locating and communicating with a server. Only https is supported, though you are able to disable certificate verification.
class APIServiceSpec {
    constructor(desc) {
        this.caBundle = desc.caBundle;
        this.group = desc.group;
        this.groupPriorityMinimum = desc.groupPriorityMinimum;
        this.insecureSkipTLSVerify = desc.insecureSkipTLSVerify;
        this.service = desc.service;
        this.version = desc.version;
        this.versionPriority = desc.versionPriority;
    }
}
exports.APIServiceSpec = APIServiceSpec;
// APIServiceStatus contains derived information about an API server
class APIServiceStatus {
}
exports.APIServiceStatus = APIServiceStatus;
// ServiceReference holds a reference to Service.legacy.k8s.io
class ServiceReference {
}
exports.ServiceReference = ServiceReference;
//# sourceMappingURL=io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.js.map