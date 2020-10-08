"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// StorageClass describes the parameters for a class of storage for which PersistentVolumes can be dynamically provisioned.
//
// StorageClasses are non-namespaced; the name of the storage class according to etcd is in ObjectMeta.Name.
class StorageClass {
    constructor(desc) {
        this.allowVolumeExpansion = desc.allowVolumeExpansion;
        this.allowedTopologies = desc.allowedTopologies;
        this.apiVersion = StorageClass.apiVersion;
        this.kind = StorageClass.kind;
        this.metadata = desc.metadata;
        this.mountOptions = desc.mountOptions;
        this.parameters = desc.parameters;
        this.provisioner = desc.provisioner;
        this.reclaimPolicy = desc.reclaimPolicy;
        this.volumeBindingMode = desc.volumeBindingMode;
    }
}
exports.StorageClass = StorageClass;
function isStorageClass(o) {
    return (o &&
        o.apiVersion === StorageClass.apiVersion &&
        o.kind === StorageClass.kind);
}
exports.isStorageClass = isStorageClass;
(function (StorageClass) {
    StorageClass.apiVersion = "storage.k8s.io/v1";
    StorageClass.group = "storage.k8s.io";
    StorageClass.version = "v1";
    StorageClass.kind = "StorageClass";
})(StorageClass = exports.StorageClass || (exports.StorageClass = {}));
// StorageClassList is a collection of storage classes.
class StorageClassList {
    constructor(desc) {
        this.apiVersion = StorageClassList.apiVersion;
        this.items = desc.items.map(i => new StorageClass(i));
        this.kind = StorageClassList.kind;
        this.metadata = desc.metadata;
    }
}
exports.StorageClassList = StorageClassList;
function isStorageClassList(o) {
    return (o &&
        o.apiVersion === StorageClassList.apiVersion &&
        o.kind === StorageClassList.kind);
}
exports.isStorageClassList = isStorageClassList;
(function (StorageClassList) {
    StorageClassList.apiVersion = "storage.k8s.io/v1";
    StorageClassList.group = "storage.k8s.io";
    StorageClassList.version = "v1";
    StorageClassList.kind = "StorageClassList";
})(StorageClassList = exports.StorageClassList || (exports.StorageClassList = {}));
// VolumeAttachment captures the intent to attach or detach the specified volume to/from the specified node.
//
// VolumeAttachment objects are non-namespaced.
class VolumeAttachment {
    constructor(desc) {
        this.apiVersion = VolumeAttachment.apiVersion;
        this.kind = VolumeAttachment.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.VolumeAttachment = VolumeAttachment;
function isVolumeAttachment(o) {
    return (o &&
        o.apiVersion === VolumeAttachment.apiVersion &&
        o.kind === VolumeAttachment.kind);
}
exports.isVolumeAttachment = isVolumeAttachment;
(function (VolumeAttachment) {
    VolumeAttachment.apiVersion = "storage.k8s.io/v1";
    VolumeAttachment.group = "storage.k8s.io";
    VolumeAttachment.version = "v1";
    VolumeAttachment.kind = "VolumeAttachment";
})(VolumeAttachment = exports.VolumeAttachment || (exports.VolumeAttachment = {}));
// VolumeAttachmentList is a collection of VolumeAttachment objects.
class VolumeAttachmentList {
    constructor(desc) {
        this.apiVersion = VolumeAttachmentList.apiVersion;
        this.items = desc.items.map(i => new VolumeAttachment(i));
        this.kind = VolumeAttachmentList.kind;
        this.metadata = desc.metadata;
    }
}
exports.VolumeAttachmentList = VolumeAttachmentList;
function isVolumeAttachmentList(o) {
    return (o &&
        o.apiVersion === VolumeAttachmentList.apiVersion &&
        o.kind === VolumeAttachmentList.kind);
}
exports.isVolumeAttachmentList = isVolumeAttachmentList;
(function (VolumeAttachmentList) {
    VolumeAttachmentList.apiVersion = "storage.k8s.io/v1";
    VolumeAttachmentList.group = "storage.k8s.io";
    VolumeAttachmentList.version = "v1";
    VolumeAttachmentList.kind = "VolumeAttachmentList";
})(VolumeAttachmentList = exports.VolumeAttachmentList || (exports.VolumeAttachmentList = {}));
// VolumeAttachmentSource represents a volume that should be attached. Right now only PersistenVolumes can be attached via external attacher, in future we may allow also inline volumes in pods. Exactly one member can be set.
class VolumeAttachmentSource {
}
exports.VolumeAttachmentSource = VolumeAttachmentSource;
// VolumeAttachmentSpec is the specification of a VolumeAttachment request.
class VolumeAttachmentSpec {
    constructor(desc) {
        this.attacher = desc.attacher;
        this.nodeName = desc.nodeName;
        this.source = desc.source;
    }
}
exports.VolumeAttachmentSpec = VolumeAttachmentSpec;
// VolumeAttachmentStatus is the status of a VolumeAttachment request.
class VolumeAttachmentStatus {
    constructor(desc) {
        this.attachError = desc.attachError;
        this.attached = desc.attached;
        this.attachmentMetadata = desc.attachmentMetadata;
        this.detachError = desc.detachError;
    }
}
exports.VolumeAttachmentStatus = VolumeAttachmentStatus;
// VolumeError captures an error encountered during a volume operation.
class VolumeError {
}
exports.VolumeError = VolumeError;
//# sourceMappingURL=io.k8s.api.storage.v1.js.map