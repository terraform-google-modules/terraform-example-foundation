"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// CSIDriver captures information about a Container Storage Interface (CSI) volume driver deployed on the cluster. CSI drivers do not need to create the CSIDriver object directly. Instead they may use the cluster-driver-registrar sidecar container. When deployed with a CSI driver it automatically creates a CSIDriver object representing the driver. Kubernetes attach detach controller uses this object to determine whether attach is required. Kubelet uses this object to determine whether pod information needs to be passed on mount. CSIDriver objects are non-namespaced.
class CSIDriver {
    constructor(desc) {
        this.apiVersion = CSIDriver.apiVersion;
        this.kind = CSIDriver.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
    }
}
exports.CSIDriver = CSIDriver;
function isCSIDriver(o) {
    return (o && o.apiVersion === CSIDriver.apiVersion && o.kind === CSIDriver.kind);
}
exports.isCSIDriver = isCSIDriver;
(function (CSIDriver) {
    CSIDriver.apiVersion = "storage.k8s.io/v1beta1";
    CSIDriver.group = "storage.k8s.io";
    CSIDriver.version = "v1beta1";
    CSIDriver.kind = "CSIDriver";
})(CSIDriver = exports.CSIDriver || (exports.CSIDriver = {}));
// CSIDriverList is a collection of CSIDriver objects.
class CSIDriverList {
    constructor(desc) {
        this.apiVersion = CSIDriverList.apiVersion;
        this.items = desc.items.map(i => new CSIDriver(i));
        this.kind = CSIDriverList.kind;
        this.metadata = desc.metadata;
    }
}
exports.CSIDriverList = CSIDriverList;
function isCSIDriverList(o) {
    return (o &&
        o.apiVersion === CSIDriverList.apiVersion &&
        o.kind === CSIDriverList.kind);
}
exports.isCSIDriverList = isCSIDriverList;
(function (CSIDriverList) {
    CSIDriverList.apiVersion = "storage.k8s.io/v1beta1";
    CSIDriverList.group = "storage.k8s.io";
    CSIDriverList.version = "v1beta1";
    CSIDriverList.kind = "CSIDriverList";
})(CSIDriverList = exports.CSIDriverList || (exports.CSIDriverList = {}));
// CSIDriverSpec is the specification of a CSIDriver.
class CSIDriverSpec {
}
exports.CSIDriverSpec = CSIDriverSpec;
// CSINode holds information about all CSI drivers installed on a node. CSI drivers do not need to create the CSINode object directly. As long as they use the node-driver-registrar sidecar container, the kubelet will automatically populate the CSINode object for the CSI driver as part of kubelet plugin registration. CSINode has the same name as a node. If the object is missing, it means either there are no CSI Drivers available on the node, or the Kubelet version is low enough that it doesn't create this object. CSINode has an OwnerReference that points to the corresponding node object.
class CSINode {
    constructor(desc) {
        this.apiVersion = CSINode.apiVersion;
        this.kind = CSINode.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
    }
}
exports.CSINode = CSINode;
function isCSINode(o) {
    return o && o.apiVersion === CSINode.apiVersion && o.kind === CSINode.kind;
}
exports.isCSINode = isCSINode;
(function (CSINode) {
    CSINode.apiVersion = "storage.k8s.io/v1beta1";
    CSINode.group = "storage.k8s.io";
    CSINode.version = "v1beta1";
    CSINode.kind = "CSINode";
})(CSINode = exports.CSINode || (exports.CSINode = {}));
// CSINodeDriver holds information about the specification of one CSI driver installed on a node
class CSINodeDriver {
    constructor(desc) {
        this.name = desc.name;
        this.nodeID = desc.nodeID;
        this.topologyKeys = desc.topologyKeys;
    }
}
exports.CSINodeDriver = CSINodeDriver;
// CSINodeList is a collection of CSINode objects.
class CSINodeList {
    constructor(desc) {
        this.apiVersion = CSINodeList.apiVersion;
        this.items = desc.items.map(i => new CSINode(i));
        this.kind = CSINodeList.kind;
        this.metadata = desc.metadata;
    }
}
exports.CSINodeList = CSINodeList;
function isCSINodeList(o) {
    return (o && o.apiVersion === CSINodeList.apiVersion && o.kind === CSINodeList.kind);
}
exports.isCSINodeList = isCSINodeList;
(function (CSINodeList) {
    CSINodeList.apiVersion = "storage.k8s.io/v1beta1";
    CSINodeList.group = "storage.k8s.io";
    CSINodeList.version = "v1beta1";
    CSINodeList.kind = "CSINodeList";
})(CSINodeList = exports.CSINodeList || (exports.CSINodeList = {}));
// CSINodeSpec holds information about the specification of all CSI drivers installed on a node
class CSINodeSpec {
    constructor(desc) {
        this.drivers = desc.drivers;
    }
}
exports.CSINodeSpec = CSINodeSpec;
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
    StorageClass.apiVersion = "storage.k8s.io/v1beta1";
    StorageClass.group = "storage.k8s.io";
    StorageClass.version = "v1beta1";
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
    StorageClassList.apiVersion = "storage.k8s.io/v1beta1";
    StorageClassList.group = "storage.k8s.io";
    StorageClassList.version = "v1beta1";
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
    VolumeAttachment.apiVersion = "storage.k8s.io/v1beta1";
    VolumeAttachment.group = "storage.k8s.io";
    VolumeAttachment.version = "v1beta1";
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
    VolumeAttachmentList.apiVersion = "storage.k8s.io/v1beta1";
    VolumeAttachmentList.group = "storage.k8s.io";
    VolumeAttachmentList.version = "v1beta1";
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
//# sourceMappingURL=io.k8s.api.storage.v1beta1.js.map