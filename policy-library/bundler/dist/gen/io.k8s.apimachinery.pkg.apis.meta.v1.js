"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// APIGroup contains the name, the supported versions, and the preferred version of a group.
class APIGroup {
    constructor(desc) {
        this.apiVersion = APIGroup.apiVersion;
        this.kind = APIGroup.kind;
        this.name = desc.name;
        this.preferredVersion = desc.preferredVersion;
        this.serverAddressByClientCIDRs = desc.serverAddressByClientCIDRs;
        this.versions = desc.versions;
    }
}
exports.APIGroup = APIGroup;
function isAPIGroup(o) {
    return o && o.apiVersion === APIGroup.apiVersion && o.kind === APIGroup.kind;
}
exports.isAPIGroup = isAPIGroup;
(function (APIGroup) {
    APIGroup.apiVersion = "v1";
    APIGroup.group = "";
    APIGroup.version = "v1";
    APIGroup.kind = "APIGroup";
})(APIGroup = exports.APIGroup || (exports.APIGroup = {}));
// APIGroupList is a list of APIGroup, to allow clients to discover the API at /apis.
class APIGroupList {
    constructor(desc) {
        this.apiVersion = APIGroupList.apiVersion;
        this.groups = desc.groups;
        this.kind = APIGroupList.kind;
    }
}
exports.APIGroupList = APIGroupList;
function isAPIGroupList(o) {
    return (o &&
        o.apiVersion === APIGroupList.apiVersion &&
        o.kind === APIGroupList.kind);
}
exports.isAPIGroupList = isAPIGroupList;
(function (APIGroupList) {
    APIGroupList.apiVersion = "v1";
    APIGroupList.group = "";
    APIGroupList.version = "v1";
    APIGroupList.kind = "APIGroupList";
})(APIGroupList = exports.APIGroupList || (exports.APIGroupList = {}));
// APIResource specifies the name of a resource and whether it is namespaced.
class APIResource {
    constructor(desc) {
        this.categories = desc.categories;
        this.group = desc.group;
        this.kind = desc.kind;
        this.name = desc.name;
        this.namespaced = desc.namespaced;
        this.shortNames = desc.shortNames;
        this.singularName = desc.singularName;
        this.storageVersionHash = desc.storageVersionHash;
        this.verbs = desc.verbs;
        this.version = desc.version;
    }
}
exports.APIResource = APIResource;
// APIResourceList is a list of APIResource, it is used to expose the name of the resources supported in a specific group and version, and if the resource is namespaced.
class APIResourceList {
    constructor(desc) {
        this.apiVersion = APIResourceList.apiVersion;
        this.groupVersion = desc.groupVersion;
        this.kind = APIResourceList.kind;
        this.resources = desc.resources;
    }
}
exports.APIResourceList = APIResourceList;
function isAPIResourceList(o) {
    return (o &&
        o.apiVersion === APIResourceList.apiVersion &&
        o.kind === APIResourceList.kind);
}
exports.isAPIResourceList = isAPIResourceList;
(function (APIResourceList) {
    APIResourceList.apiVersion = "v1";
    APIResourceList.group = "";
    APIResourceList.version = "v1";
    APIResourceList.kind = "APIResourceList";
})(APIResourceList = exports.APIResourceList || (exports.APIResourceList = {}));
// APIVersions lists the versions that are available, to allow clients to discover the API at /api, which is the root path of the legacy v1 API.
class APIVersions {
    constructor(desc) {
        this.apiVersion = APIVersions.apiVersion;
        this.kind = APIVersions.kind;
        this.serverAddressByClientCIDRs = desc.serverAddressByClientCIDRs;
        this.versions = desc.versions;
    }
}
exports.APIVersions = APIVersions;
function isAPIVersions(o) {
    return (o && o.apiVersion === APIVersions.apiVersion && o.kind === APIVersions.kind);
}
exports.isAPIVersions = isAPIVersions;
(function (APIVersions) {
    APIVersions.apiVersion = "v1";
    APIVersions.group = "";
    APIVersions.version = "v1";
    APIVersions.kind = "APIVersions";
})(APIVersions = exports.APIVersions || (exports.APIVersions = {}));
// DeleteOptions may be provided when deleting an API object.
class DeleteOptions {
    constructor(desc) {
        this.apiVersion = DeleteOptions.apiVersion;
        this.dryRun = desc.dryRun;
        this.gracePeriodSeconds = desc.gracePeriodSeconds;
        this.kind = DeleteOptions.kind;
        this.orphanDependents = desc.orphanDependents;
        this.preconditions = desc.preconditions;
        this.propagationPolicy = desc.propagationPolicy;
    }
}
exports.DeleteOptions = DeleteOptions;
function isDeleteOptions(o) {
    return (o &&
        o.apiVersion === DeleteOptions.apiVersion &&
        o.kind === DeleteOptions.kind);
}
exports.isDeleteOptions = isDeleteOptions;
(function (DeleteOptions) {
    DeleteOptions.apiVersion = "v1";
    DeleteOptions.group = "";
    DeleteOptions.version = "v1";
    DeleteOptions.kind = "DeleteOptions";
})(DeleteOptions = exports.DeleteOptions || (exports.DeleteOptions = {}));
// GroupVersion contains the "group/version" and "version" string of a version. It is made a struct to keep extensibility.
class GroupVersionForDiscovery {
    constructor(desc) {
        this.groupVersion = desc.groupVersion;
        this.version = desc.version;
    }
}
exports.GroupVersionForDiscovery = GroupVersionForDiscovery;
// Initializer is information about an initializer that has not yet completed.
class Initializer {
    constructor(desc) {
        this.name = desc.name;
    }
}
exports.Initializer = Initializer;
// Initializers tracks the progress of initialization.
class Initializers {
    constructor(desc) {
        this.pending = desc.pending;
        this.result = desc.result;
    }
}
exports.Initializers = Initializers;
// A label selector is a label query over a set of resources. The result of matchLabels and matchExpressions are ANDed. An empty label selector matches all objects. A null label selector matches no objects.
class LabelSelector {
}
exports.LabelSelector = LabelSelector;
// A label selector requirement is a selector that contains values, a key, and an operator that relates the key and values.
class LabelSelectorRequirement {
    constructor(desc) {
        this.key = desc.key;
        this.operator = desc.operator;
        this.values = desc.values;
    }
}
exports.LabelSelectorRequirement = LabelSelectorRequirement;
// ListMeta describes metadata that synthetic resources must have, including lists and various status objects. A resource may have only one of {ObjectMeta, ListMeta}.
class ListMeta {
}
exports.ListMeta = ListMeta;
// ManagedFieldsEntry is a workflow-id, a FieldSet and the group version of the resource that the fieldset applies to.
class ManagedFieldsEntry {
}
exports.ManagedFieldsEntry = ManagedFieldsEntry;
// ObjectMeta is metadata that all persisted resources must have, which includes all objects users must create.
class ObjectMeta {
    constructor(desc) {
        this.annotations = desc.annotations;
        this.clusterName = desc.clusterName;
        this.creationTimestamp = desc.creationTimestamp;
        this.deletionGracePeriodSeconds = desc.deletionGracePeriodSeconds;
        this.deletionTimestamp = desc.deletionTimestamp;
        this.finalizers = desc.finalizers;
        this.generateName = desc.generateName;
        this.generation = desc.generation;
        this.initializers = desc.initializers;
        this.labels = desc.labels;
        this.managedFields = desc.managedFields;
        this.name = desc.name;
        this.namespace = desc.namespace;
        this.ownerReferences = desc.ownerReferences;
        this.resourceVersion = desc.resourceVersion;
        this.selfLink = desc.selfLink;
        this.uid = desc.uid;
    }
}
exports.ObjectMeta = ObjectMeta;
// OwnerReference contains enough information to let you identify an owning object. An owning object must be in the same namespace as the dependent, or be cluster-scoped, so there is no namespace field.
class OwnerReference {
    constructor(desc) {
        this.apiVersion = desc.apiVersion;
        this.blockOwnerDeletion = desc.blockOwnerDeletion;
        this.controller = desc.controller;
        this.kind = desc.kind;
        this.name = desc.name;
        this.uid = desc.uid;
    }
}
exports.OwnerReference = OwnerReference;
// Preconditions must be fulfilled before an operation (update, delete, etc.) is carried out.
class Preconditions {
}
exports.Preconditions = Preconditions;
// ServerAddressByClientCIDR helps the client to determine the server address that they should use, depending on the clientCIDR that they match.
class ServerAddressByClientCIDR {
    constructor(desc) {
        this.clientCIDR = desc.clientCIDR;
        this.serverAddress = desc.serverAddress;
    }
}
exports.ServerAddressByClientCIDR = ServerAddressByClientCIDR;
// Status is a return value for calls that don't return other objects.
class Status {
    constructor(desc) {
        this.apiVersion = Status.apiVersion;
        this.code = desc.code;
        this.details = desc.details;
        this.kind = Status.kind;
        this.message = desc.message;
        this.metadata = desc.metadata;
        this.reason = desc.reason;
        this.status = desc.status;
    }
}
exports.Status = Status;
function isStatus(o) {
    return o && o.apiVersion === Status.apiVersion && o.kind === Status.kind;
}
exports.isStatus = isStatus;
(function (Status) {
    Status.apiVersion = "v1";
    Status.group = "";
    Status.version = "v1";
    Status.kind = "Status";
})(Status = exports.Status || (exports.Status = {}));
// StatusCause provides more information about an api.Status failure, including cases when multiple errors are encountered.
class StatusCause {
}
exports.StatusCause = StatusCause;
// StatusDetails is a set of additional properties that MAY be set by the server to provide additional information about a response. The Reason field of a Status object defines what attributes will be set. Clients must ignore fields that do not match the defined type of each attribute, and should assume that any attribute may be empty, invalid, or under defined.
class StatusDetails {
}
exports.StatusDetails = StatusDetails;
// Event represents a single event to a watched resource.
class WatchEvent {
    constructor(desc) {
        this.apiVersion = WatchEvent.apiVersion;
        this.kind = WatchEvent.kind;
        this.object = desc.object;
        this.type = desc.type;
    }
}
exports.WatchEvent = WatchEvent;
function isWatchEvent(o) {
    return (o && o.apiVersion === WatchEvent.apiVersion && o.kind === WatchEvent.kind);
}
exports.isWatchEvent = isWatchEvent;
(function (WatchEvent) {
    WatchEvent.apiVersion = "v1";
    WatchEvent.group = "";
    WatchEvent.version = "v1";
    WatchEvent.kind = "WatchEvent";
})(WatchEvent = exports.WatchEvent || (exports.WatchEvent = {}));
//# sourceMappingURL=io.k8s.apimachinery.pkg.apis.meta.v1.js.map