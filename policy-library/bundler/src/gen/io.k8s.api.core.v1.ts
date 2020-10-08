import { KubernetesObject } from "kpt-functions";
import * as pkgApiResource from "./io.k8s.apimachinery.pkg.api.resource";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";
import * as pkgUtilIntstr from "./io.k8s.apimachinery.pkg.util.intstr";

// Represents a Persistent Disk resource in AWS.
//
// An AWS EBS disk must exist before mounting to a container. The disk must also be in the same AWS zone as the kubelet. An AWS EBS disk can only be mounted as read/write once. AWS EBS volumes support ownership management and SELinux relabeling.
export class AWSElasticBlockStoreVolumeSource {
  // Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
  public fsType?: string;

  // The partition in the volume that you want to mount. If omitted, the default is to mount by volume name. Examples: For volume /dev/sda1, you specify the partition as "1". Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty).
  public partition?: number;

  // Specify "true" to force and set the ReadOnly property in VolumeMounts to "true". If omitted, the default is "false". More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
  public readOnly?: boolean;

  // Unique ID of the persistent disk resource in AWS (Amazon EBS volume). More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
  public volumeID: string;

  constructor(desc: AWSElasticBlockStoreVolumeSource) {
    this.fsType = desc.fsType;
    this.partition = desc.partition;
    this.readOnly = desc.readOnly;
    this.volumeID = desc.volumeID;
  }
}

// Affinity is a group of affinity scheduling rules.
export class Affinity {
  // Describes node affinity scheduling rules for the pod.
  public nodeAffinity?: NodeAffinity;

  // Describes pod affinity scheduling rules (e.g. co-locate this pod in the same node, zone, etc. as some other pod(s)).
  public podAffinity?: PodAffinity;

  // Describes pod anti-affinity scheduling rules (e.g. avoid putting this pod in the same node, zone, etc. as some other pod(s)).
  public podAntiAffinity?: PodAntiAffinity;
}

// AttachedVolume describes a volume attached to a node
export class AttachedVolume {
  // DevicePath represents the device path where the volume should be available
  public devicePath: string;

  // Name of the attached volume
  public name: string;

  constructor(desc: AttachedVolume) {
    this.devicePath = desc.devicePath;
    this.name = desc.name;
  }
}

// AzureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
export class AzureDiskVolumeSource {
  // Host Caching mode: None, Read Only, Read Write.
  public cachingMode?: string;

  // The Name of the data disk in the blob storage
  public diskName: string;

  // The URI the data disk in the blob storage
  public diskURI: string;

  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
  public fsType?: string;

  // Expected values Shared: multiple blob disks per storage account  Dedicated: single blob disk per storage account  Managed: azure managed data disk (only in managed availability set). defaults to shared
  public kind?: string;

  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  constructor(desc: AzureDiskVolumeSource) {
    this.cachingMode = desc.cachingMode;
    this.diskName = desc.diskName;
    this.diskURI = desc.diskURI;
    this.fsType = desc.fsType;
    this.kind = desc.kind;
    this.readOnly = desc.readOnly;
  }
}

// AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
export class AzureFilePersistentVolumeSource {
  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // the name of secret that contains Azure Storage Account Name and Key
  public secretName: string;

  // the namespace of the secret that contains Azure Storage Account Name and Key default is the same as the Pod
  public secretNamespace?: string;

  // Share Name
  public shareName: string;

  constructor(desc: AzureFilePersistentVolumeSource) {
    this.readOnly = desc.readOnly;
    this.secretName = desc.secretName;
    this.secretNamespace = desc.secretNamespace;
    this.shareName = desc.shareName;
  }
}

// AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
export class AzureFileVolumeSource {
  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // the name of secret that contains Azure Storage Account Name and Key
  public secretName: string;

  // Share Name
  public shareName: string;

  constructor(desc: AzureFileVolumeSource) {
    this.readOnly = desc.readOnly;
    this.secretName = desc.secretName;
    this.shareName = desc.shareName;
  }
}

// Binding ties one object to another; for example, a pod is bound to a node by a scheduler. Deprecated in 1.7, please use the bindings subresource of pods instead.
export class Binding implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // The target object that you want to bind to the standard object.
  public target: ObjectReference;

  constructor(desc: Binding.Interface) {
    this.apiVersion = Binding.apiVersion;
    this.kind = Binding.kind;
    this.metadata = desc.metadata;
    this.target = desc.target;
  }
}

export function isBinding(o: any): o is Binding {
  return o && o.apiVersion === Binding.apiVersion && o.kind === Binding.kind;
}

export namespace Binding {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Binding";

  // Binding ties one object to another; for example, a pod is bound to a node by a scheduler. Deprecated in 1.7, please use the bindings subresource of pods instead.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // The target object that you want to bind to the standard object.
    target: ObjectReference;
  }
}

// Represents storage that is managed by an external CSI volume driver (Beta feature)
export class CSIPersistentVolumeSource {
  // ControllerPublishSecretRef is a reference to the secret object containing sensitive information to pass to the CSI driver to complete the CSI ControllerPublishVolume and ControllerUnpublishVolume calls. This field is optional, and may be empty if no secret is required. If the secret object contains more than one secret, all secrets are passed.
  public controllerPublishSecretRef?: SecretReference;

  // Driver is the name of the driver to use for this volume. Required.
  public driver: string;

  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs".
  public fsType?: string;

  // NodePublishSecretRef is a reference to the secret object containing sensitive information to pass to the CSI driver to complete the CSI NodePublishVolume and NodeUnpublishVolume calls. This field is optional, and may be empty if no secret is required. If the secret object contains more than one secret, all secrets are passed.
  public nodePublishSecretRef?: SecretReference;

  // NodeStageSecretRef is a reference to the secret object containing sensitive information to pass to the CSI driver to complete the CSI NodeStageVolume and NodeStageVolume and NodeUnstageVolume calls. This field is optional, and may be empty if no secret is required. If the secret object contains more than one secret, all secrets are passed.
  public nodeStageSecretRef?: SecretReference;

  // Optional: The value to pass to ControllerPublishVolumeRequest. Defaults to false (read/write).
  public readOnly?: boolean;

  // Attributes of the volume to publish.
  public volumeAttributes?: { [key: string]: string };

  // VolumeHandle is the unique volume name returned by the CSI volume plugin’s CreateVolume to refer to the volume on all subsequent calls. Required.
  public volumeHandle: string;

  constructor(desc: CSIPersistentVolumeSource) {
    this.controllerPublishSecretRef = desc.controllerPublishSecretRef;
    this.driver = desc.driver;
    this.fsType = desc.fsType;
    this.nodePublishSecretRef = desc.nodePublishSecretRef;
    this.nodeStageSecretRef = desc.nodeStageSecretRef;
    this.readOnly = desc.readOnly;
    this.volumeAttributes = desc.volumeAttributes;
    this.volumeHandle = desc.volumeHandle;
  }
}

// Represents a source location of a volume to mount, managed by an external CSI driver
export class CSIVolumeSource {
  // Driver is the name of the CSI driver that handles this volume. Consult with your admin for the correct name as registered in the cluster.
  public driver: string;

  // Filesystem type to mount. Ex. "ext4", "xfs", "ntfs". If not provided, the empty value is passed to the associated CSI driver which will determine the default filesystem to apply.
  public fsType?: string;

  // NodePublishSecretRef is a reference to the secret object containing sensitive information to pass to the CSI driver to complete the CSI NodePublishVolume and NodeUnpublishVolume calls. This field is optional, and  may be empty if no secret is required. If the secret object contains more than one secret, all secret references are passed.
  public nodePublishSecretRef?: LocalObjectReference;

  // Specifies a read-only configuration for the volume. Defaults to false (read/write).
  public readOnly?: boolean;

  // VolumeAttributes stores driver-specific properties that are passed to the CSI driver. Consult your driver's documentation for supported values.
  public volumeAttributes?: { [key: string]: string };

  constructor(desc: CSIVolumeSource) {
    this.driver = desc.driver;
    this.fsType = desc.fsType;
    this.nodePublishSecretRef = desc.nodePublishSecretRef;
    this.readOnly = desc.readOnly;
    this.volumeAttributes = desc.volumeAttributes;
  }
}

// Adds and removes POSIX capabilities from running containers.
export class Capabilities {
  // Added capabilities
  public add?: string[];

  // Removed capabilities
  public drop?: string[];
}

// Represents a Ceph Filesystem mount that lasts the lifetime of a pod Cephfs volumes do not support ownership management or SELinux relabeling.
export class CephFSPersistentVolumeSource {
  // Required: Monitors is a collection of Ceph monitors More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public monitors: string[];

  // Optional: Used as the mounted root, rather than the full Ceph tree, default is /
  public path?: string;

  // Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts. More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public readOnly?: boolean;

  // Optional: SecretFile is the path to key ring for User, default is /etc/ceph/user.secret More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public secretFile?: string;

  // Optional: SecretRef is reference to the authentication secret for User, default is empty. More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public secretRef?: SecretReference;

  // Optional: User is the rados user name, default is admin More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public user?: string;

  constructor(desc: CephFSPersistentVolumeSource) {
    this.monitors = desc.monitors;
    this.path = desc.path;
    this.readOnly = desc.readOnly;
    this.secretFile = desc.secretFile;
    this.secretRef = desc.secretRef;
    this.user = desc.user;
  }
}

// Represents a Ceph Filesystem mount that lasts the lifetime of a pod Cephfs volumes do not support ownership management or SELinux relabeling.
export class CephFSVolumeSource {
  // Required: Monitors is a collection of Ceph monitors More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public monitors: string[];

  // Optional: Used as the mounted root, rather than the full Ceph tree, default is /
  public path?: string;

  // Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts. More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public readOnly?: boolean;

  // Optional: SecretFile is the path to key ring for User, default is /etc/ceph/user.secret More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public secretFile?: string;

  // Optional: SecretRef is reference to the authentication secret for User, default is empty. More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public secretRef?: LocalObjectReference;

  // Optional: User is the rados user name, default is admin More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it
  public user?: string;

  constructor(desc: CephFSVolumeSource) {
    this.monitors = desc.monitors;
    this.path = desc.path;
    this.readOnly = desc.readOnly;
    this.secretFile = desc.secretFile;
    this.secretRef = desc.secretRef;
    this.user = desc.user;
  }
}

// Represents a cinder volume resource in Openstack. A Cinder volume must exist before mounting to a container. The volume must also be in the same region as the kubelet. Cinder volumes support ownership management and SELinux relabeling.
export class CinderPersistentVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public fsType?: string;

  // Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts. More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public readOnly?: boolean;

  // Optional: points to a secret object containing parameters used to connect to OpenStack.
  public secretRef?: SecretReference;

  // volume id used to identify the volume in cinder More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public volumeID: string;

  constructor(desc: CinderPersistentVolumeSource) {
    this.fsType = desc.fsType;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.volumeID = desc.volumeID;
  }
}

// Represents a cinder volume resource in Openstack. A Cinder volume must exist before mounting to a container. The volume must also be in the same region as the kubelet. Cinder volumes support ownership management and SELinux relabeling.
export class CinderVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public fsType?: string;

  // Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts. More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public readOnly?: boolean;

  // Optional: points to a secret object containing parameters used to connect to OpenStack.
  public secretRef?: LocalObjectReference;

  // volume id used to identify the volume in cinder More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public volumeID: string;

  constructor(desc: CinderVolumeSource) {
    this.fsType = desc.fsType;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.volumeID = desc.volumeID;
  }
}

// ClientIPConfig represents the configurations of Client IP based session affinity.
export class ClientIPConfig {
  // timeoutSeconds specifies the seconds of ClientIP type session sticky time. The value must be >0 && <=86400(for 1 day) if ServiceAffinity == "ClientIP". Default value is 10800(for 3 hours).
  public timeoutSeconds?: number;
}

// Information about the condition of a component.
export class ComponentCondition {
  // Condition error code for a component. For example, a health check error code.
  public error?: string;

  // Message about the condition for a component. For example, information about a health check.
  public message?: string;

  // Status of the condition for a component. Valid values for "Healthy": "True", "False", or "Unknown".
  public status: string;

  // Type of condition for a component. Valid value: "Healthy"
  public type: string;

  constructor(desc: ComponentCondition) {
    this.error = desc.error;
    this.message = desc.message;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// ComponentStatus (and ComponentStatusList) holds the cluster validation info.
export class ComponentStatus implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of component conditions observed
  public conditions?: ComponentCondition[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  constructor(desc: ComponentStatus.Interface) {
    this.apiVersion = ComponentStatus.apiVersion;
    this.conditions = desc.conditions;
    this.kind = ComponentStatus.kind;
    this.metadata = desc.metadata;
  }
}

export function isComponentStatus(o: any): o is ComponentStatus {
  return (
    o &&
    o.apiVersion === ComponentStatus.apiVersion &&
    o.kind === ComponentStatus.kind
  );
}

export namespace ComponentStatus {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ComponentStatus";

  // named constructs a ComponentStatus with metadata.name set to name.
  export function named(name: string): ComponentStatus {
    return new ComponentStatus({ metadata: { name } });
  }
  // ComponentStatus (and ComponentStatusList) holds the cluster validation info.
  export interface Interface {
    // List of component conditions observed
    conditions?: ComponentCondition[];

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;
  }
}

// Status of all the conditions for the component as a list of ComponentStatus objects.
export class ComponentStatusList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of ComponentStatus objects.
  public items: ComponentStatus[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ComponentStatusList) {
    this.apiVersion = ComponentStatusList.apiVersion;
    this.items = desc.items.map(i => new ComponentStatus(i));
    this.kind = ComponentStatusList.kind;
    this.metadata = desc.metadata;
  }
}

export function isComponentStatusList(o: any): o is ComponentStatusList {
  return (
    o &&
    o.apiVersion === ComponentStatusList.apiVersion &&
    o.kind === ComponentStatusList.kind
  );
}

export namespace ComponentStatusList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ComponentStatusList";

  // Status of all the conditions for the component as a list of ComponentStatus objects.
  export interface Interface {
    // List of ComponentStatus objects.
    items: ComponentStatus[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// ConfigMap holds configuration data for pods to consume.
export class ConfigMap implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // BinaryData contains the binary data. Each key must consist of alphanumeric characters, '-', '_' or '.'. BinaryData can contain byte sequences that are not in the UTF-8 range. The keys stored in BinaryData must not overlap with the ones in the Data field, this is enforced during validation process. Using this field will require 1.10+ apiserver and kubelet.
  public binaryData?: { [key: string]: string };

  // Data contains the configuration data. Each key must consist of alphanumeric characters, '-', '_' or '.'. Values with non-UTF-8 byte sequences must use the BinaryData field. The keys stored in Data must not overlap with the keys in the BinaryData field, this is enforced during validation process.
  public data?: { [key: string]: string };

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  constructor(desc: ConfigMap.Interface) {
    this.apiVersion = ConfigMap.apiVersion;
    this.binaryData = desc.binaryData;
    this.data = desc.data;
    this.kind = ConfigMap.kind;
    this.metadata = desc.metadata;
  }
}

export function isConfigMap(o: any): o is ConfigMap {
  return (
    o && o.apiVersion === ConfigMap.apiVersion && o.kind === ConfigMap.kind
  );
}

export namespace ConfigMap {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ConfigMap";

  // named constructs a ConfigMap with metadata.name set to name.
  export function named(name: string): ConfigMap {
    return new ConfigMap({ metadata: { name } });
  }
  // ConfigMap holds configuration data for pods to consume.
  export interface Interface {
    // BinaryData contains the binary data. Each key must consist of alphanumeric characters, '-', '_' or '.'. BinaryData can contain byte sequences that are not in the UTF-8 range. The keys stored in BinaryData must not overlap with the ones in the Data field, this is enforced during validation process. Using this field will require 1.10+ apiserver and kubelet.
    binaryData?: { [key: string]: string };

    // Data contains the configuration data. Each key must consist of alphanumeric characters, '-', '_' or '.'. Values with non-UTF-8 byte sequences must use the BinaryData field. The keys stored in Data must not overlap with the keys in the BinaryData field, this is enforced during validation process.
    data?: { [key: string]: string };

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;
  }
}

// ConfigMapEnvSource selects a ConfigMap to populate the environment variables with.
//
// The contents of the target ConfigMap's Data field will represent the key-value pairs as environment variables.
export class ConfigMapEnvSource {
  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Specify whether the ConfigMap must be defined
  public optional?: boolean;
}

// Selects a key from a ConfigMap.
export class ConfigMapKeySelector {
  // The key to select.
  public key: string;

  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Specify whether the ConfigMap or it's key must be defined
  public optional?: boolean;

  constructor(desc: ConfigMapKeySelector) {
    this.key = desc.key;
    this.name = desc.name;
    this.optional = desc.optional;
  }
}

// ConfigMapList is a resource containing a list of ConfigMap objects.
export class ConfigMapList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is the list of ConfigMaps.
  public items: ConfigMap[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ConfigMapList) {
    this.apiVersion = ConfigMapList.apiVersion;
    this.items = desc.items.map(i => new ConfigMap(i));
    this.kind = ConfigMapList.kind;
    this.metadata = desc.metadata;
  }
}

export function isConfigMapList(o: any): o is ConfigMapList {
  return (
    o &&
    o.apiVersion === ConfigMapList.apiVersion &&
    o.kind === ConfigMapList.kind
  );
}

export namespace ConfigMapList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ConfigMapList";

  // ConfigMapList is a resource containing a list of ConfigMap objects.
  export interface Interface {
    // Items is the list of ConfigMaps.
    items: ConfigMap[];

    // More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// ConfigMapNodeConfigSource contains the information to reference a ConfigMap as a config source for the Node.
export class ConfigMapNodeConfigSource {
  // KubeletConfigKey declares which key of the referenced ConfigMap corresponds to the KubeletConfiguration structure This field is required in all cases.
  public kubeletConfigKey: string;

  // Name is the metadata.name of the referenced ConfigMap. This field is required in all cases.
  public name: string;

  // Namespace is the metadata.namespace of the referenced ConfigMap. This field is required in all cases.
  public namespace: string;

  // ResourceVersion is the metadata.ResourceVersion of the referenced ConfigMap. This field is forbidden in Node.Spec, and required in Node.Status.
  public resourceVersion?: string;

  // UID is the metadata.UID of the referenced ConfigMap. This field is forbidden in Node.Spec, and required in Node.Status.
  public uid?: string;

  constructor(desc: ConfigMapNodeConfigSource) {
    this.kubeletConfigKey = desc.kubeletConfigKey;
    this.name = desc.name;
    this.namespace = desc.namespace;
    this.resourceVersion = desc.resourceVersion;
    this.uid = desc.uid;
  }
}

// Adapts a ConfigMap into a projected volume.
//
// The contents of the target ConfigMap's Data field will be presented in a projected volume as files using the keys in the Data field as the file names, unless the items element is populated with specific mappings of keys to paths. Note that this is identical to a configmap volume source without the default mode.
export class ConfigMapProjection {
  // If unspecified, each key-value pair in the Data field of the referenced ConfigMap will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the ConfigMap, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.
  public items?: KeyToPath[];

  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Specify whether the ConfigMap or it's keys must be defined
  public optional?: boolean;
}

// Adapts a ConfigMap into a volume.
//
// The contents of the target ConfigMap's Data field will be presented in a volume as files using the keys in the Data field as the file names, unless the items element is populated with specific mappings of keys to paths. ConfigMap volumes support ownership management and SELinux relabeling.
export class ConfigMapVolumeSource {
  // Optional: mode bits to use on created files by default. Must be a value between 0 and 0777. Defaults to 0644. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.
  public defaultMode?: number;

  // If unspecified, each key-value pair in the Data field of the referenced ConfigMap will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the ConfigMap, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.
  public items?: KeyToPath[];

  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Specify whether the ConfigMap or it's keys must be defined
  public optional?: boolean;
}

// A single application container that you want to run within a pod.
export class Container {
  // Arguments to the entrypoint. The docker image's CMD is used if this is not provided. Variable references $(VAR_NAME) are expanded using the container's environment. If a variable cannot be resolved, the reference in the input string will be unchanged. The $(VAR_NAME) syntax can be escaped with a double $$, ie: $$(VAR_NAME). Escaped references will never be expanded, regardless of whether the variable exists or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
  public args?: string[];

  // Entrypoint array. Not executed within a shell. The docker image's ENTRYPOINT is used if this is not provided. Variable references $(VAR_NAME) are expanded using the container's environment. If a variable cannot be resolved, the reference in the input string will be unchanged. The $(VAR_NAME) syntax can be escaped with a double $$, ie: $$(VAR_NAME). Escaped references will never be expanded, regardless of whether the variable exists or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
  public command?: string[];

  // List of environment variables to set in the container. Cannot be updated.
  public env?: EnvVar[];

  // List of sources to populate environment variables in the container. The keys defined within a source must be a C_IDENTIFIER. All invalid keys will be reported as an event when the container is starting. When a key exists in multiple sources, the value associated with the last source will take precedence. Values defined by an Env with a duplicate key will take precedence. Cannot be updated.
  public envFrom?: EnvFromSource[];

  // Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images This field is optional to allow higher level config management to default or override container images in workload controllers like Deployments and StatefulSets.
  public image?: string;

  // Image pull policy. One of Always, Never, IfNotPresent. Defaults to Always if :latest tag is specified, or IfNotPresent otherwise. Cannot be updated. More info: https://kubernetes.io/docs/concepts/containers/images#updating-images
  public imagePullPolicy?: string;

  // Actions that the management system should take in response to container lifecycle events. Cannot be updated.
  public lifecycle?: Lifecycle;

  // Periodic probe of container liveness. Container will be restarted if the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
  public livenessProbe?: Probe;

  // Name of the container specified as a DNS_LABEL. Each container in a pod must have a unique name (DNS_LABEL). Cannot be updated.
  public name: string;

  // List of ports to expose from the container. Exposing a port here gives the system additional information about the network connections a container uses, but is primarily informational. Not specifying a port here DOES NOT prevent that port from being exposed. Any port which is listening on the default "0.0.0.0" address inside a container will be accessible from the network. Cannot be updated.
  public ports?: ContainerPort[];

  // Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
  public readinessProbe?: Probe;

  // Compute Resources required by this container. Cannot be updated. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  public resources?: ResourceRequirements;

  // Security options the pod should run with. More info: https://kubernetes.io/docs/concepts/policy/security-context/ More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  public securityContext?: SecurityContext;

  // Whether this container should allocate a buffer for stdin in the container runtime. If this is not set, reads from stdin in the container will always result in EOF. Default is false.
  public stdin?: boolean;

  // Whether the container runtime should close the stdin channel after it has been opened by a single attach. When stdin is true the stdin stream will remain open across multiple attach sessions. If stdinOnce is set to true, stdin is opened on container start, is empty until the first client attaches to stdin, and then remains open and accepts data until the client disconnects, at which time stdin is closed and remains closed until the container is restarted. If this flag is false, a container processes that reads from stdin will never receive an EOF. Default is false
  public stdinOnce?: boolean;

  // Optional: Path at which the file to which the container's termination message will be written is mounted into the container's filesystem. Message written is intended to be brief final status, such as an assertion failure message. Will be truncated by the node if greater than 4096 bytes. The total message length across all containers will be limited to 12kb. Defaults to /dev/termination-log. Cannot be updated.
  public terminationMessagePath?: string;

  // Indicate how the termination message should be populated. File will use the contents of terminationMessagePath to populate the container status message on both success and failure. FallbackToLogsOnError will use the last chunk of container log output if the termination message file is empty and the container exited with an error. The log output is limited to 2048 bytes or 80 lines, whichever is smaller. Defaults to File. Cannot be updated.
  public terminationMessagePolicy?: string;

  // Whether this container should allocate a TTY for itself, also requires 'stdin' to be true. Default is false.
  public tty?: boolean;

  // volumeDevices is the list of block devices to be used by the container. This is a beta feature.
  public volumeDevices?: VolumeDevice[];

  // Pod volumes to mount into the container's filesystem. Cannot be updated.
  public volumeMounts?: VolumeMount[];

  // Container's working directory. If not specified, the container runtime's default will be used, which might be configured in the container image. Cannot be updated.
  public workingDir?: string;

  constructor(desc: Container) {
    this.args = desc.args;
    this.command = desc.command;
    this.env = desc.env;
    this.envFrom = desc.envFrom;
    this.image = desc.image;
    this.imagePullPolicy = desc.imagePullPolicy;
    this.lifecycle = desc.lifecycle;
    this.livenessProbe = desc.livenessProbe;
    this.name = desc.name;
    this.ports = desc.ports;
    this.readinessProbe = desc.readinessProbe;
    this.resources = desc.resources;
    this.securityContext = desc.securityContext;
    this.stdin = desc.stdin;
    this.stdinOnce = desc.stdinOnce;
    this.terminationMessagePath = desc.terminationMessagePath;
    this.terminationMessagePolicy = desc.terminationMessagePolicy;
    this.tty = desc.tty;
    this.volumeDevices = desc.volumeDevices;
    this.volumeMounts = desc.volumeMounts;
    this.workingDir = desc.workingDir;
  }
}

// Describe a container image
export class ContainerImage {
  // Names by which this image is known. e.g. ["k8s.gcr.io/hyperkube:v1.0.7", "dockerhub.io/google_containers/hyperkube:v1.0.7"]
  public names: string[];

  // The size of the image in bytes.
  public sizeBytes?: number;

  constructor(desc: ContainerImage) {
    this.names = desc.names;
    this.sizeBytes = desc.sizeBytes;
  }
}

// ContainerPort represents a network port in a single container.
export class ContainerPort {
  // Number of port to expose on the pod's IP address. This must be a valid port number, 0 < x < 65536.
  public containerPort: number;

  // What host IP to bind the external port to.
  public hostIP?: string;

  // Number of port to expose on the host. If specified, this must be a valid port number, 0 < x < 65536. If HostNetwork is specified, this must match ContainerPort. Most containers do not need this.
  public hostPort?: number;

  // If specified, this must be an IANA_SVC_NAME and unique within the pod. Each named port in a pod must have a unique name. Name for the port that can be referred to by services.
  public name?: string;

  // Protocol for port. Must be UDP, TCP, or SCTP. Defaults to "TCP".
  public protocol?: string;

  constructor(desc: ContainerPort) {
    this.containerPort = desc.containerPort;
    this.hostIP = desc.hostIP;
    this.hostPort = desc.hostPort;
    this.name = desc.name;
    this.protocol = desc.protocol;
  }
}

// ContainerState holds a possible state of container. Only one of its members may be specified. If none of them is specified, the default one is ContainerStateWaiting.
export class ContainerState {
  // Details about a running container
  public running?: ContainerStateRunning;

  // Details about a terminated container
  public terminated?: ContainerStateTerminated;

  // Details about a waiting container
  public waiting?: ContainerStateWaiting;
}

// ContainerStateRunning is a running state of a container.
export class ContainerStateRunning {
  // Time at which the container was last (re-)started
  public startedAt?: apisMetaV1.Time;
}

// ContainerStateTerminated is a terminated state of a container.
export class ContainerStateTerminated {
  // Container's ID in the format 'docker://<container_id>'
  public containerID?: string;

  // Exit status from the last termination of the container
  public exitCode: number;

  // Time at which the container last terminated
  public finishedAt?: apisMetaV1.Time;

  // Message regarding the last termination of the container
  public message?: string;

  // (brief) reason from the last termination of the container
  public reason?: string;

  // Signal from the last termination of the container
  public signal?: number;

  // Time at which previous execution of the container started
  public startedAt?: apisMetaV1.Time;

  constructor(desc: ContainerStateTerminated) {
    this.containerID = desc.containerID;
    this.exitCode = desc.exitCode;
    this.finishedAt = desc.finishedAt;
    this.message = desc.message;
    this.reason = desc.reason;
    this.signal = desc.signal;
    this.startedAt = desc.startedAt;
  }
}

// ContainerStateWaiting is a waiting state of a container.
export class ContainerStateWaiting {
  // Message regarding why the container is not yet running.
  public message?: string;

  // (brief) reason the container is not yet running.
  public reason?: string;
}

// ContainerStatus contains details for the current status of this container.
export class ContainerStatus {
  // Container's ID in the format 'docker://<container_id>'.
  public containerID?: string;

  // The image the container is running. More info: https://kubernetes.io/docs/concepts/containers/images
  public image: string;

  // ImageID of the container's image.
  public imageID: string;

  // Details about the container's last termination condition.
  public lastState?: ContainerState;

  // This must be a DNS_LABEL. Each container in a pod must have a unique name. Cannot be updated.
  public name: string;

  // Specifies whether the container has passed its readiness probe.
  public ready: boolean;

  // The number of times the container has been restarted, currently based on the number of dead containers that have not yet been removed. Note that this is calculated from dead containers. But those containers are subject to garbage collection. This value will get capped at 5 by GC.
  public restartCount: number;

  // Details about the container's current condition.
  public state?: ContainerState;

  constructor(desc: ContainerStatus) {
    this.containerID = desc.containerID;
    this.image = desc.image;
    this.imageID = desc.imageID;
    this.lastState = desc.lastState;
    this.name = desc.name;
    this.ready = desc.ready;
    this.restartCount = desc.restartCount;
    this.state = desc.state;
  }
}

// DaemonEndpoint contains information about a single Daemon endpoint.
export class DaemonEndpoint {
  // Port number of the given endpoint.
  public Port: number;

  constructor(desc: DaemonEndpoint) {
    this.Port = desc.Port;
  }
}

// Represents downward API info for projecting into a projected volume. Note that this is identical to a downwardAPI volume source without the default mode.
export class DownwardAPIProjection {
  // Items is a list of DownwardAPIVolume file
  public items?: DownwardAPIVolumeFile[];
}

// DownwardAPIVolumeFile represents information to create the file containing the pod field
export class DownwardAPIVolumeFile {
  // Required: Selects a field of the pod: only annotations, labels, name and namespace are supported.
  public fieldRef?: ObjectFieldSelector;

  // Optional: mode bits to use on this file, must be a value between 0 and 0777. If not specified, the volume defaultMode will be used. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.
  public mode?: number;

  // Required: Path is  the relative path name of the file to be created. Must not be absolute or contain the '..' path. Must be utf-8 encoded. The first item of the relative path must not start with '..'
  public path: string;

  // Selects a resource of the container: only resources limits and requests (limits.cpu, limits.memory, requests.cpu and requests.memory) are currently supported.
  public resourceFieldRef?: ResourceFieldSelector;

  constructor(desc: DownwardAPIVolumeFile) {
    this.fieldRef = desc.fieldRef;
    this.mode = desc.mode;
    this.path = desc.path;
    this.resourceFieldRef = desc.resourceFieldRef;
  }
}

// DownwardAPIVolumeSource represents a volume containing downward API info. Downward API volumes support ownership management and SELinux relabeling.
export class DownwardAPIVolumeSource {
  // Optional: mode bits to use on created files by default. Must be a value between 0 and 0777. Defaults to 0644. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.
  public defaultMode?: number;

  // Items is a list of downward API volume file
  public items?: DownwardAPIVolumeFile[];
}

// Represents an empty directory for a pod. Empty directory volumes support ownership management and SELinux relabeling.
export class EmptyDirVolumeSource {
  // What type of storage medium should back this directory. The default is "" which means to use the node's default medium. Must be an empty string (default) or Memory. More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir
  public medium?: string;

  // Total amount of local storage required for this EmptyDir volume. The size limit is also applicable for memory medium. The maximum usage on memory medium EmptyDir would be the minimum value between the SizeLimit specified here and the sum of memory limits of all containers in a pod. The default is nil which means that the limit is undefined. More info: http://kubernetes.io/docs/user-guide/volumes#emptydir
  public sizeLimit?: pkgApiResource.Quantity;
}

// EndpointAddress is a tuple that describes single IP address.
export class EndpointAddress {
  // The Hostname of this endpoint
  public hostname?: string;

  // The IP of this endpoint. May not be loopback (127.0.0.0/8), link-local (169.254.0.0/16), or link-local multicast ((224.0.0.0/24). IPv6 is also accepted but not fully supported on all platforms. Also, certain kubernetes components, like kube-proxy, are not IPv6 ready.
  public ip: string;

  // Optional: Node hosting this endpoint. This can be used to determine endpoints local to a node.
  public nodeName?: string;

  // Reference to object providing the endpoint.
  public targetRef?: ObjectReference;

  constructor(desc: EndpointAddress) {
    this.hostname = desc.hostname;
    this.ip = desc.ip;
    this.nodeName = desc.nodeName;
    this.targetRef = desc.targetRef;
  }
}

// EndpointPort is a tuple that describes a single port.
export class EndpointPort {
  // The name of this port (corresponds to ServicePort.Name). Must be a DNS_LABEL. Optional only if one port is defined.
  public name?: string;

  // The port number of the endpoint.
  public port: number;

  // The IP protocol for this port. Must be UDP, TCP, or SCTP. Default is TCP.
  public protocol?: string;

  constructor(desc: EndpointPort) {
    this.name = desc.name;
    this.port = desc.port;
    this.protocol = desc.protocol;
  }
}

// EndpointSubset is a group of addresses with a common set of ports. The expanded set of endpoints is the Cartesian product of Addresses x Ports. For example, given:
//   {
//     Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
//     Ports:     [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
//   }
// The resulting set of endpoints can be viewed as:
//     a: [ 10.10.1.1:8675, 10.10.2.2:8675 ],
//     b: [ 10.10.1.1:309, 10.10.2.2:309 ]
export class EndpointSubset {
  // IP addresses which offer the related ports that are marked as ready. These endpoints should be considered safe for load balancers and clients to utilize.
  public addresses?: EndpointAddress[];

  // IP addresses which offer the related ports but are not currently marked as ready because they have not yet finished starting, have recently failed a readiness check, or have recently failed a liveness check.
  public notReadyAddresses?: EndpointAddress[];

  // Port numbers available on the related IP addresses.
  public ports?: EndpointPort[];
}

// Endpoints is a collection of endpoints that implement the actual service. Example:
//   Name: "mysvc",
//   Subsets: [
//     {
//       Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
//       Ports: [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
//     },
//     {
//       Addresses: [{"ip": "10.10.3.3"}],
//       Ports: [{"name": "a", "port": 93}, {"name": "b", "port": 76}]
//     },
//  ]
export class Endpoints implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // The set of all endpoints is the union of all subsets. Addresses are placed into subsets according to the IPs they share. A single address with multiple ports, some of which are ready and some of which are not (because they come from different containers) will result in the address being displayed in different subsets for the different ports. No address will appear in both Addresses and NotReadyAddresses in the same subset. Sets of addresses and ports that comprise a service.
  public subsets?: EndpointSubset[];

  constructor(desc: Endpoints.Interface) {
    this.apiVersion = Endpoints.apiVersion;
    this.kind = Endpoints.kind;
    this.metadata = desc.metadata;
    this.subsets = desc.subsets;
  }
}

export function isEndpoints(o: any): o is Endpoints {
  return (
    o && o.apiVersion === Endpoints.apiVersion && o.kind === Endpoints.kind
  );
}

export namespace Endpoints {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Endpoints";

  // named constructs a Endpoints with metadata.name set to name.
  export function named(name: string): Endpoints {
    return new Endpoints({ metadata: { name } });
  }
  // Endpoints is a collection of endpoints that implement the actual service. Example:
  //   Name: "mysvc",
  //   Subsets: [
  //     {
  //       Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
  //       Ports: [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
  //     },
  //     {
  //       Addresses: [{"ip": "10.10.3.3"}],
  //       Ports: [{"name": "a", "port": 93}, {"name": "b", "port": 76}]
  //     },
  //  ]
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // The set of all endpoints is the union of all subsets. Addresses are placed into subsets according to the IPs they share. A single address with multiple ports, some of which are ready and some of which are not (because they come from different containers) will result in the address being displayed in different subsets for the different ports. No address will appear in both Addresses and NotReadyAddresses in the same subset. Sets of addresses and ports that comprise a service.
    subsets?: EndpointSubset[];
  }
}

// EndpointsList is a list of endpoints.
export class EndpointsList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of endpoints.
  public items: Endpoints[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: EndpointsList) {
    this.apiVersion = EndpointsList.apiVersion;
    this.items = desc.items.map(i => new Endpoints(i));
    this.kind = EndpointsList.kind;
    this.metadata = desc.metadata;
  }
}

export function isEndpointsList(o: any): o is EndpointsList {
  return (
    o &&
    o.apiVersion === EndpointsList.apiVersion &&
    o.kind === EndpointsList.kind
  );
}

export namespace EndpointsList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "EndpointsList";

  // EndpointsList is a list of endpoints.
  export interface Interface {
    // List of endpoints.
    items: Endpoints[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// EnvFromSource represents the source of a set of ConfigMaps
export class EnvFromSource {
  // The ConfigMap to select from
  public configMapRef?: ConfigMapEnvSource;

  // An optional identifier to prepend to each key in the ConfigMap. Must be a C_IDENTIFIER.
  public prefix?: string;

  // The Secret to select from
  public secretRef?: SecretEnvSource;
}

// EnvVar represents an environment variable present in a Container.
export class EnvVar {
  // Name of the environment variable. Must be a C_IDENTIFIER.
  public name: string;

  // Variable references $(VAR_NAME) are expanded using the previous defined environment variables in the container and any service environment variables. If a variable cannot be resolved, the reference in the input string will be unchanged. The $(VAR_NAME) syntax can be escaped with a double $$, ie: $$(VAR_NAME). Escaped references will never be expanded, regardless of whether the variable exists or not. Defaults to "".
  public value?: string;

  // Source for the environment variable's value. Cannot be used if value is not empty.
  public valueFrom?: EnvVarSource;

  constructor(desc: EnvVar) {
    this.name = desc.name;
    this.value = desc.value;
    this.valueFrom = desc.valueFrom;
  }
}

// EnvVarSource represents a source for the value of an EnvVar.
export class EnvVarSource {
  // Selects a key of a ConfigMap.
  public configMapKeyRef?: ConfigMapKeySelector;

  // Selects a field of the pod: supports metadata.name, metadata.namespace, metadata.labels, metadata.annotations, spec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP.
  public fieldRef?: ObjectFieldSelector;

  // Selects a resource of the container: only resources limits and requests (limits.cpu, limits.memory, limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.
  public resourceFieldRef?: ResourceFieldSelector;

  // Selects a key of a secret in the pod's namespace
  public secretKeyRef?: SecretKeySelector;
}

// Event is a report of an event somewhere in the cluster.
export class Event implements KubernetesObject {
  // What action was taken/failed regarding to the Regarding object.
  public action?: string;

  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // The number of times this event has occurred.
  public count?: number;

  // Time when this Event was first observed.
  public eventTime?: apisMetaV1.MicroTime;

  // The time at which the event was first recorded. (Time of server receipt is in TypeMeta.)
  public firstTimestamp?: apisMetaV1.Time;

  // The object that this event is about.
  public involvedObject: ObjectReference;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // The time at which the most recent occurrence of this event was recorded.
  public lastTimestamp?: apisMetaV1.Time;

  // A human-readable description of the status of this operation.
  public message?: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // This should be a short, machine understandable string that gives the reason for the transition into the object's current status.
  public reason?: string;

  // Optional secondary object for more complex actions.
  public related?: ObjectReference;

  // Name of the controller that emitted this Event, e.g. `kubernetes.io/kubelet`.
  public reportingComponent?: string;

  // ID of the controller instance, e.g. `kubelet-xyzf`.
  public reportingInstance?: string;

  // Data about the Event series this event represents or nil if it's a singleton Event.
  public series?: EventSeries;

  // The component reporting this event. Should be a short machine understandable string.
  public source?: EventSource;

  // Type of this event (Normal, Warning), new types could be added in the future
  public type?: string;

  constructor(desc: Event.Interface) {
    this.action = desc.action;
    this.apiVersion = Event.apiVersion;
    this.count = desc.count;
    this.eventTime = desc.eventTime;
    this.firstTimestamp = desc.firstTimestamp;
    this.involvedObject = desc.involvedObject;
    this.kind = Event.kind;
    this.lastTimestamp = desc.lastTimestamp;
    this.message = desc.message;
    this.metadata = desc.metadata;
    this.reason = desc.reason;
    this.related = desc.related;
    this.reportingComponent = desc.reportingComponent;
    this.reportingInstance = desc.reportingInstance;
    this.series = desc.series;
    this.source = desc.source;
    this.type = desc.type;
  }
}

export function isEvent(o: any): o is Event {
  return o && o.apiVersion === Event.apiVersion && o.kind === Event.kind;
}

export namespace Event {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Event";

  // Event is a report of an event somewhere in the cluster.
  export interface Interface {
    // What action was taken/failed regarding to the Regarding object.
    action?: string;

    // The number of times this event has occurred.
    count?: number;

    // Time when this Event was first observed.
    eventTime?: apisMetaV1.MicroTime;

    // The time at which the event was first recorded. (Time of server receipt is in TypeMeta.)
    firstTimestamp?: apisMetaV1.Time;

    // The object that this event is about.
    involvedObject: ObjectReference;

    // The time at which the most recent occurrence of this event was recorded.
    lastTimestamp?: apisMetaV1.Time;

    // A human-readable description of the status of this operation.
    message?: string;

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // This should be a short, machine understandable string that gives the reason for the transition into the object's current status.
    reason?: string;

    // Optional secondary object for more complex actions.
    related?: ObjectReference;

    // Name of the controller that emitted this Event, e.g. `kubernetes.io/kubelet`.
    reportingComponent?: string;

    // ID of the controller instance, e.g. `kubelet-xyzf`.
    reportingInstance?: string;

    // Data about the Event series this event represents or nil if it's a singleton Event.
    series?: EventSeries;

    // The component reporting this event. Should be a short machine understandable string.
    source?: EventSource;

    // Type of this event (Normal, Warning), new types could be added in the future
    type?: string;
  }
}

// EventList is a list of events.
export class EventList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of events
  public items: Event[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: EventList) {
    this.apiVersion = EventList.apiVersion;
    this.items = desc.items.map(i => new Event(i));
    this.kind = EventList.kind;
    this.metadata = desc.metadata;
  }
}

export function isEventList(o: any): o is EventList {
  return (
    o && o.apiVersion === EventList.apiVersion && o.kind === EventList.kind
  );
}

export namespace EventList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "EventList";

  // EventList is a list of events.
  export interface Interface {
    // List of events
    items: Event[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// EventSeries contain information on series of events, i.e. thing that was/is happening continuously for some time.
export class EventSeries {
  // Number of occurrences in this series up to the last heartbeat time
  public count?: number;

  // Time of the last occurrence observed
  public lastObservedTime?: apisMetaV1.MicroTime;

  // State of this Series: Ongoing or Finished
  public state?: string;
}

// EventSource contains information for an event.
export class EventSource {
  // Component from which the event is generated.
  public component?: string;

  // Node name on which the event is generated.
  public host?: string;
}

// ExecAction describes a "run in container" action.
export class ExecAction {
  // Command is the command line to execute inside the container, the working directory for the command  is root ('/') in the container's filesystem. The command is simply exec'd, it is not run inside a shell, so traditional shell instructions ('|', etc) won't work. To use a shell, you need to explicitly call out to that shell. Exit status of 0 is treated as live/healthy and non-zero is unhealthy.
  public command?: string[];
}

// Represents a Fibre Channel volume. Fibre Channel volumes can only be mounted as read/write once. Fibre Channel volumes support ownership management and SELinux relabeling.
export class FCVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
  public fsType?: string;

  // Optional: FC target lun number
  public lun?: number;

  // Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // Optional: FC target worldwide names (WWNs)
  public targetWWNs?: string[];

  // Optional: FC volume world wide identifiers (wwids) Either wwids or combination of targetWWNs and lun must be set, but not both simultaneously.
  public wwids?: string[];
}

// FlexPersistentVolumeSource represents a generic persistent volume resource that is provisioned/attached using an exec based plugin.
export class FlexPersistentVolumeSource {
  // Driver is the name of the driver to use for this volume.
  public driver: string;

  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". The default filesystem depends on FlexVolume script.
  public fsType?: string;

  // Optional: Extra command options if any.
  public options?: { [key: string]: string };

  // Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // Optional: SecretRef is reference to the secret object containing sensitive information to pass to the plugin scripts. This may be empty if no secret object is specified. If the secret object contains more than one secret, all secrets are passed to the plugin scripts.
  public secretRef?: SecretReference;

  constructor(desc: FlexPersistentVolumeSource) {
    this.driver = desc.driver;
    this.fsType = desc.fsType;
    this.options = desc.options;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
  }
}

// FlexVolume represents a generic volume resource that is provisioned/attached using an exec based plugin.
export class FlexVolumeSource {
  // Driver is the name of the driver to use for this volume.
  public driver: string;

  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". The default filesystem depends on FlexVolume script.
  public fsType?: string;

  // Optional: Extra command options if any.
  public options?: { [key: string]: string };

  // Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // Optional: SecretRef is reference to the secret object containing sensitive information to pass to the plugin scripts. This may be empty if no secret object is specified. If the secret object contains more than one secret, all secrets are passed to the plugin scripts.
  public secretRef?: LocalObjectReference;

  constructor(desc: FlexVolumeSource) {
    this.driver = desc.driver;
    this.fsType = desc.fsType;
    this.options = desc.options;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
  }
}

// Represents a Flocker volume mounted by the Flocker agent. One and only one of datasetName and datasetUUID should be set. Flocker volumes do not support ownership management or SELinux relabeling.
export class FlockerVolumeSource {
  // Name of the dataset stored as metadata -> name on the dataset for Flocker should be considered as deprecated
  public datasetName?: string;

  // UUID of the dataset. This is unique identifier of a Flocker dataset
  public datasetUUID?: string;
}

// Represents a Persistent Disk resource in Google Compute Engine.
//
// A GCE PD must exist before mounting to a container. The disk must also be in the same GCE project and zone as the kubelet. A GCE PD can only be mounted as read/write once or read-only many times. GCE PDs support ownership management and SELinux relabeling.
export class GCEPersistentDiskVolumeSource {
  // Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
  public fsType?: string;

  // The partition in the volume that you want to mount. If omitted, the default is to mount by volume name. Examples: For volume /dev/sda1, you specify the partition as "1". Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty). More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
  public partition?: number;

  // Unique name of the PD resource in GCE. Used to identify the disk in GCE. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
  public pdName: string;

  // ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
  public readOnly?: boolean;

  constructor(desc: GCEPersistentDiskVolumeSource) {
    this.fsType = desc.fsType;
    this.partition = desc.partition;
    this.pdName = desc.pdName;
    this.readOnly = desc.readOnly;
  }
}

// Represents a volume that is populated with the contents of a git repository. Git repo volumes do not support ownership management. Git repo volumes support SELinux relabeling.
//
// DEPRECATED: GitRepo is deprecated. To provision a container with a git repo, mount an EmptyDir into an InitContainer that clones the repo using git, then mount the EmptyDir into the Pod's container.
export class GitRepoVolumeSource {
  // Target directory name. Must not contain or start with '..'.  If '.' is supplied, the volume directory will be the git repository.  Otherwise, if specified, the volume will contain the git repository in the subdirectory with the given name.
  public directory?: string;

  // Repository URL
  public repository: string;

  // Commit hash for the specified revision.
  public revision?: string;

  constructor(desc: GitRepoVolumeSource) {
    this.directory = desc.directory;
    this.repository = desc.repository;
    this.revision = desc.revision;
  }
}

// Represents a Glusterfs mount that lasts the lifetime of a pod. Glusterfs volumes do not support ownership management or SELinux relabeling.
export class GlusterfsPersistentVolumeSource {
  // EndpointsName is the endpoint name that details Glusterfs topology. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod
  public endpoints: string;

  // EndpointsNamespace is the namespace that contains Glusterfs endpoint. If this field is empty, the EndpointNamespace defaults to the same namespace as the bound PVC. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod
  public endpointsNamespace?: string;

  // Path is the Glusterfs volume path. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod
  public path: string;

  // ReadOnly here will force the Glusterfs volume to be mounted with read-only permissions. Defaults to false. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod
  public readOnly?: boolean;

  constructor(desc: GlusterfsPersistentVolumeSource) {
    this.endpoints = desc.endpoints;
    this.endpointsNamespace = desc.endpointsNamespace;
    this.path = desc.path;
    this.readOnly = desc.readOnly;
  }
}

// Represents a Glusterfs mount that lasts the lifetime of a pod. Glusterfs volumes do not support ownership management or SELinux relabeling.
export class GlusterfsVolumeSource {
  // EndpointsName is the endpoint name that details Glusterfs topology. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod
  public endpoints: string;

  // Path is the Glusterfs volume path. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod
  public path: string;

  // ReadOnly here will force the Glusterfs volume to be mounted with read-only permissions. Defaults to false. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod
  public readOnly?: boolean;

  constructor(desc: GlusterfsVolumeSource) {
    this.endpoints = desc.endpoints;
    this.path = desc.path;
    this.readOnly = desc.readOnly;
  }
}

// HTTPGetAction describes an action based on HTTP Get requests.
export class HTTPGetAction {
  // Host name to connect to, defaults to the pod IP. You probably want to set "Host" in httpHeaders instead.
  public host?: string;

  // Custom headers to set in the request. HTTP allows repeated headers.
  public httpHeaders?: HTTPHeader[];

  // Path to access on the HTTP server.
  public path?: string;

  // Name or number of the port to access on the container. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.
  public port: pkgUtilIntstr.IntOrString;

  // Scheme to use for connecting to the host. Defaults to HTTP.
  public scheme?: string;

  constructor(desc: HTTPGetAction) {
    this.host = desc.host;
    this.httpHeaders = desc.httpHeaders;
    this.path = desc.path;
    this.port = desc.port;
    this.scheme = desc.scheme;
  }
}

// HTTPHeader describes a custom header to be used in HTTP probes
export class HTTPHeader {
  // The header field name
  public name: string;

  // The header field value
  public value: string;

  constructor(desc: HTTPHeader) {
    this.name = desc.name;
    this.value = desc.value;
  }
}

// Handler defines a specific action that should be taken
export class Handler {
  // One and only one of the following should be specified. Exec specifies the action to take.
  public exec?: ExecAction;

  // HTTPGet specifies the http request to perform.
  public httpGet?: HTTPGetAction;

  // TCPSocket specifies an action involving a TCP port. TCP hooks not yet supported
  public tcpSocket?: TCPSocketAction;
}

// HostAlias holds the mapping between IP and hostnames that will be injected as an entry in the pod's hosts file.
export class HostAlias {
  // Hostnames for the above IP address.
  public hostnames?: string[];

  // IP address of the host file entry.
  public ip?: string;
}

// Represents a host path mapped into a pod. Host path volumes do not support ownership management or SELinux relabeling.
export class HostPathVolumeSource {
  // Path of the directory on the host. If the path is a symlink, it will follow the link to the real path. More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
  public path: string;

  // Type for HostPath Volume Defaults to "" More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
  public type?: string;

  constructor(desc: HostPathVolumeSource) {
    this.path = desc.path;
    this.type = desc.type;
  }
}

// ISCSIPersistentVolumeSource represents an ISCSI disk. ISCSI volumes can only be mounted as read/write once. ISCSI volumes support ownership management and SELinux relabeling.
export class ISCSIPersistentVolumeSource {
  // whether support iSCSI Discovery CHAP authentication
  public chapAuthDiscovery?: boolean;

  // whether support iSCSI Session CHAP authentication
  public chapAuthSession?: boolean;

  // Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi
  public fsType?: string;

  // Custom iSCSI Initiator Name. If initiatorName is specified with iscsiInterface simultaneously, new iSCSI interface <target portal>:<volume name> will be created for the connection.
  public initiatorName?: string;

  // Target iSCSI Qualified Name.
  public iqn: string;

  // iSCSI Interface Name that uses an iSCSI transport. Defaults to 'default' (tcp).
  public iscsiInterface?: string;

  // iSCSI Target Lun number.
  public lun: number;

  // iSCSI Target Portal List. The Portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260).
  public portals?: string[];

  // ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false.
  public readOnly?: boolean;

  // CHAP Secret for iSCSI target and initiator authentication
  public secretRef?: SecretReference;

  // iSCSI Target Portal. The Portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260).
  public targetPortal: string;

  constructor(desc: ISCSIPersistentVolumeSource) {
    this.chapAuthDiscovery = desc.chapAuthDiscovery;
    this.chapAuthSession = desc.chapAuthSession;
    this.fsType = desc.fsType;
    this.initiatorName = desc.initiatorName;
    this.iqn = desc.iqn;
    this.iscsiInterface = desc.iscsiInterface;
    this.lun = desc.lun;
    this.portals = desc.portals;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.targetPortal = desc.targetPortal;
  }
}

// Represents an ISCSI disk. ISCSI volumes can only be mounted as read/write once. ISCSI volumes support ownership management and SELinux relabeling.
export class ISCSIVolumeSource {
  // whether support iSCSI Discovery CHAP authentication
  public chapAuthDiscovery?: boolean;

  // whether support iSCSI Session CHAP authentication
  public chapAuthSession?: boolean;

  // Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi
  public fsType?: string;

  // Custom iSCSI Initiator Name. If initiatorName is specified with iscsiInterface simultaneously, new iSCSI interface <target portal>:<volume name> will be created for the connection.
  public initiatorName?: string;

  // Target iSCSI Qualified Name.
  public iqn: string;

  // iSCSI Interface Name that uses an iSCSI transport. Defaults to 'default' (tcp).
  public iscsiInterface?: string;

  // iSCSI Target Lun number.
  public lun: number;

  // iSCSI Target Portal List. The portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260).
  public portals?: string[];

  // ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false.
  public readOnly?: boolean;

  // CHAP Secret for iSCSI target and initiator authentication
  public secretRef?: LocalObjectReference;

  // iSCSI Target Portal. The Portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260).
  public targetPortal: string;

  constructor(desc: ISCSIVolumeSource) {
    this.chapAuthDiscovery = desc.chapAuthDiscovery;
    this.chapAuthSession = desc.chapAuthSession;
    this.fsType = desc.fsType;
    this.initiatorName = desc.initiatorName;
    this.iqn = desc.iqn;
    this.iscsiInterface = desc.iscsiInterface;
    this.lun = desc.lun;
    this.portals = desc.portals;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.targetPortal = desc.targetPortal;
  }
}

// Maps a string key to a path within a volume.
export class KeyToPath {
  // The key to project.
  public key: string;

  // Optional: mode bits to use on this file, must be a value between 0 and 0777. If not specified, the volume defaultMode will be used. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.
  public mode?: number;

  // The relative path of the file to map the key to. May not be an absolute path. May not contain the path element '..'. May not start with the string '..'.
  public path: string;

  constructor(desc: KeyToPath) {
    this.key = desc.key;
    this.mode = desc.mode;
    this.path = desc.path;
  }
}

// Lifecycle describes actions that the management system should take in response to container lifecycle events. For the PostStart and PreStop lifecycle handlers, management of the container blocks until the action is complete, unless the container process fails, in which case the handler is aborted.
export class Lifecycle {
  // PostStart is called immediately after a container is created. If the handler fails, the container is terminated and restarted according to its restart policy. Other management of the container blocks until the hook completes. More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks
  public postStart?: Handler;

  // PreStop is called immediately before a container is terminated due to an API request or management event such as liveness probe failure, preemption, resource contention, etc. The handler is not called if the container crashes or exits. The reason for termination is passed to the handler. The Pod's termination grace period countdown begins before the PreStop hooked is executed. Regardless of the outcome of the handler, the container will eventually terminate within the Pod's termination grace period. Other management of the container blocks until the hook completes or until the termination grace period is reached. More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks
  public preStop?: Handler;
}

// LimitRange sets resource usage limits for each kind of resource in a Namespace.
export class LimitRange implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the limits enforced. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: LimitRangeSpec;

  constructor(desc: LimitRange.Interface) {
    this.apiVersion = LimitRange.apiVersion;
    this.kind = LimitRange.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
  }
}

export function isLimitRange(o: any): o is LimitRange {
  return (
    o && o.apiVersion === LimitRange.apiVersion && o.kind === LimitRange.kind
  );
}

export namespace LimitRange {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "LimitRange";

  // named constructs a LimitRange with metadata.name set to name.
  export function named(name: string): LimitRange {
    return new LimitRange({ metadata: { name } });
  }
  // LimitRange sets resource usage limits for each kind of resource in a Namespace.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the limits enforced. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: LimitRangeSpec;
  }
}

// LimitRangeItem defines a min/max usage limit for any resource that matches on kind.
export class LimitRangeItem {
  // Default resource requirement limit value by resource name if resource limit is omitted.
  public default?: { [key: string]: pkgApiResource.Quantity };

  // DefaultRequest is the default resource requirement request value by resource name if resource request is omitted.
  public defaultRequest?: { [key: string]: pkgApiResource.Quantity };

  // Max usage constraints on this kind by resource name.
  public max?: { [key: string]: pkgApiResource.Quantity };

  // MaxLimitRequestRatio if specified, the named resource must have a request and limit that are both non-zero where limit divided by request is less than or equal to the enumerated value; this represents the max burst for the named resource.
  public maxLimitRequestRatio?: { [key: string]: pkgApiResource.Quantity };

  // Min usage constraints on this kind by resource name.
  public min?: { [key: string]: pkgApiResource.Quantity };

  // Type of resource that this limit applies to.
  public type?: string;
}

// LimitRangeList is a list of LimitRange items.
export class LimitRangeList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of LimitRange objects. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  public items: LimitRange[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: LimitRangeList) {
    this.apiVersion = LimitRangeList.apiVersion;
    this.items = desc.items.map(i => new LimitRange(i));
    this.kind = LimitRangeList.kind;
    this.metadata = desc.metadata;
  }
}

export function isLimitRangeList(o: any): o is LimitRangeList {
  return (
    o &&
    o.apiVersion === LimitRangeList.apiVersion &&
    o.kind === LimitRangeList.kind
  );
}

export namespace LimitRangeList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "LimitRangeList";

  // LimitRangeList is a list of LimitRange items.
  export interface Interface {
    // Items is a list of LimitRange objects. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
    items: LimitRange[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// LimitRangeSpec defines a min/max usage limit for resources that match on kind.
export class LimitRangeSpec {
  // Limits is the list of LimitRangeItem objects that are enforced.
  public limits: LimitRangeItem[];

  constructor(desc: LimitRangeSpec) {
    this.limits = desc.limits;
  }
}

// LoadBalancerIngress represents the status of a load-balancer ingress point: traffic intended for the service should be sent to an ingress point.
export class LoadBalancerIngress {
  // Hostname is set for load-balancer ingress points that are DNS based (typically AWS load-balancers)
  public hostname?: string;

  // IP is set for load-balancer ingress points that are IP based (typically GCE or OpenStack load-balancers)
  public ip?: string;
}

// LoadBalancerStatus represents the status of a load-balancer.
export class LoadBalancerStatus {
  // Ingress is a list containing ingress points for the load-balancer. Traffic intended for the service should be sent to these ingress points.
  public ingress?: LoadBalancerIngress[];
}

// LocalObjectReference contains enough information to let you locate the referenced object inside the same namespace.
export class LocalObjectReference {
  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;
}

// Local represents directly-attached storage with node affinity (Beta feature)
export class LocalVolumeSource {
  // Filesystem type to mount. It applies only when the Path is a block device. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". The default value is to auto-select a fileystem if unspecified.
  public fsType?: string;

  // The full path to the volume on the node. It can be either a directory or block device (disk, partition, ...).
  public path: string;

  constructor(desc: LocalVolumeSource) {
    this.fsType = desc.fsType;
    this.path = desc.path;
  }
}

// Represents an NFS mount that lasts the lifetime of a pod. NFS volumes do not support ownership management or SELinux relabeling.
export class NFSVolumeSource {
  // Path that is exported by the NFS server. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
  public path: string;

  // ReadOnly here will force the NFS export to be mounted with read-only permissions. Defaults to false. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
  public readOnly?: boolean;

  // Server is the hostname or IP address of the NFS server. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
  public server: string;

  constructor(desc: NFSVolumeSource) {
    this.path = desc.path;
    this.readOnly = desc.readOnly;
    this.server = desc.server;
  }
}

// Namespace provides a scope for Names. Use of multiple namespaces is optional.
export class Namespace implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the behavior of the Namespace. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: NamespaceSpec;

  // Status describes the current status of a Namespace. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: NamespaceStatus;

  constructor(desc: Namespace.Interface) {
    this.apiVersion = Namespace.apiVersion;
    this.kind = Namespace.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isNamespace(o: any): o is Namespace {
  return (
    o && o.apiVersion === Namespace.apiVersion && o.kind === Namespace.kind
  );
}

export namespace Namespace {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Namespace";

  // named constructs a Namespace with metadata.name set to name.
  export function named(name: string): Namespace {
    return new Namespace({ metadata: { name } });
  }
  // Namespace provides a scope for Names. Use of multiple namespaces is optional.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the behavior of the Namespace. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: NamespaceSpec;

    // Status describes the current status of a Namespace. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: NamespaceStatus;
  }
}

// NamespaceList is a list of Namespaces.
export class NamespaceList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is the list of Namespace objects in the list. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
  public items: Namespace[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: NamespaceList) {
    this.apiVersion = NamespaceList.apiVersion;
    this.items = desc.items.map(i => new Namespace(i));
    this.kind = NamespaceList.kind;
    this.metadata = desc.metadata;
  }
}

export function isNamespaceList(o: any): o is NamespaceList {
  return (
    o &&
    o.apiVersion === NamespaceList.apiVersion &&
    o.kind === NamespaceList.kind
  );
}

export namespace NamespaceList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "NamespaceList";

  // NamespaceList is a list of Namespaces.
  export interface Interface {
    // Items is the list of Namespace objects in the list. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
    items: Namespace[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// NamespaceSpec describes the attributes on a Namespace.
export class NamespaceSpec {
  // Finalizers is an opaque list of values that must be empty to permanently remove object from storage. More info: https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
  public finalizers?: string[];
}

// NamespaceStatus is information about the current status of a Namespace.
export class NamespaceStatus {
  // Phase is the current lifecycle phase of the namespace. More info: https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
  public phase?: string;
}

// Node is a worker node in Kubernetes. Each node will have a unique identifier in the cache (i.e. in etcd).
export class Node implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the behavior of a node. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: NodeSpec;

  // Most recently observed status of the node. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: NodeStatus;

  constructor(desc: Node.Interface) {
    this.apiVersion = Node.apiVersion;
    this.kind = Node.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isNode(o: any): o is Node {
  return o && o.apiVersion === Node.apiVersion && o.kind === Node.kind;
}

export namespace Node {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Node";

  // named constructs a Node with metadata.name set to name.
  export function named(name: string): Node {
    return new Node({ metadata: { name } });
  }
  // Node is a worker node in Kubernetes. Each node will have a unique identifier in the cache (i.e. in etcd).
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the behavior of a node. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: NodeSpec;

    // Most recently observed status of the node. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: NodeStatus;
  }
}

// NodeAddress contains information for the node's address.
export class NodeAddress {
  // The node address.
  public address: string;

  // Node address type, one of Hostname, ExternalIP or InternalIP.
  public type: string;

  constructor(desc: NodeAddress) {
    this.address = desc.address;
    this.type = desc.type;
  }
}

// Node affinity is a group of node affinity scheduling rules.
export class NodeAffinity {
  // The scheduler will prefer to schedule pods to nodes that satisfy the affinity expressions specified by this field, but it may choose a node that violates one or more of the expressions. The node that is most preferred is the one with the greatest sum of weights, i.e. for each node that meets all of the scheduling requirements (resource request, requiredDuringScheduling affinity expressions, etc.), compute a sum by iterating through the elements of this field and adding "weight" to the sum if the node matches the corresponding matchExpressions; the node(s) with the highest sum are the most preferred.
  public preferredDuringSchedulingIgnoredDuringExecution?: PreferredSchedulingTerm[];

  // If the affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to an update), the system may or may not try to eventually evict the pod from its node.
  public requiredDuringSchedulingIgnoredDuringExecution?: NodeSelector;
}

// NodeCondition contains condition information for a node.
export class NodeCondition {
  // Last time we got an update on a given condition.
  public lastHeartbeatTime?: apisMetaV1.Time;

  // Last time the condition transit from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // Human readable message indicating details about last transition.
  public message?: string;

  // (brief) reason for the condition's last transition.
  public reason?: string;

  // Status of the condition, one of True, False, Unknown.
  public status: string;

  // Type of node condition.
  public type: string;

  constructor(desc: NodeCondition) {
    this.lastHeartbeatTime = desc.lastHeartbeatTime;
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// NodeConfigSource specifies a source of node configuration. Exactly one subfield (excluding metadata) must be non-nil.
export class NodeConfigSource {
  // ConfigMap is a reference to a Node's ConfigMap
  public configMap?: ConfigMapNodeConfigSource;
}

// NodeConfigStatus describes the status of the config assigned by Node.Spec.ConfigSource.
export class NodeConfigStatus {
  // Active reports the checkpointed config the node is actively using. Active will represent either the current version of the Assigned config, or the current LastKnownGood config, depending on whether attempting to use the Assigned config results in an error.
  public active?: NodeConfigSource;

  // Assigned reports the checkpointed config the node will try to use. When Node.Spec.ConfigSource is updated, the node checkpoints the associated config payload to local disk, along with a record indicating intended config. The node refers to this record to choose its config checkpoint, and reports this record in Assigned. Assigned only updates in the status after the record has been checkpointed to disk. When the Kubelet is restarted, it tries to make the Assigned config the Active config by loading and validating the checkpointed payload identified by Assigned.
  public assigned?: NodeConfigSource;

  // Error describes any problems reconciling the Spec.ConfigSource to the Active config. Errors may occur, for example, attempting to checkpoint Spec.ConfigSource to the local Assigned record, attempting to checkpoint the payload associated with Spec.ConfigSource, attempting to load or validate the Assigned config, etc. Errors may occur at different points while syncing config. Earlier errors (e.g. download or checkpointing errors) will not result in a rollback to LastKnownGood, and may resolve across Kubelet retries. Later errors (e.g. loading or validating a checkpointed config) will result in a rollback to LastKnownGood. In the latter case, it is usually possible to resolve the error by fixing the config assigned in Spec.ConfigSource. You can find additional information for debugging by searching the error message in the Kubelet log. Error is a human-readable description of the error state; machines can check whether or not Error is empty, but should not rely on the stability of the Error text across Kubelet versions.
  public error?: string;

  // LastKnownGood reports the checkpointed config the node will fall back to when it encounters an error attempting to use the Assigned config. The Assigned config becomes the LastKnownGood config when the node determines that the Assigned config is stable and correct. This is currently implemented as a 10-minute soak period starting when the local record of Assigned config is updated. If the Assigned config is Active at the end of this period, it becomes the LastKnownGood. Note that if Spec.ConfigSource is reset to nil (use local defaults), the LastKnownGood is also immediately reset to nil, because the local default config is always assumed good. You should not make assumptions about the node's method of determining config stability and correctness, as this may change or become configurable in the future.
  public lastKnownGood?: NodeConfigSource;
}

// NodeDaemonEndpoints lists ports opened by daemons running on the Node.
export class NodeDaemonEndpoints {
  // Endpoint on which Kubelet is listening.
  public kubeletEndpoint?: DaemonEndpoint;
}

// NodeList is the whole list of all Nodes which have been registered with master.
export class NodeList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of nodes
  public items: Node[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: NodeList) {
    this.apiVersion = NodeList.apiVersion;
    this.items = desc.items.map(i => new Node(i));
    this.kind = NodeList.kind;
    this.metadata = desc.metadata;
  }
}

export function isNodeList(o: any): o is NodeList {
  return o && o.apiVersion === NodeList.apiVersion && o.kind === NodeList.kind;
}

export namespace NodeList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "NodeList";

  // NodeList is the whole list of all Nodes which have been registered with master.
  export interface Interface {
    // List of nodes
    items: Node[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// A node selector represents the union of the results of one or more label queries over a set of nodes; that is, it represents the OR of the selectors represented by the node selector terms.
export class NodeSelector {
  // Required. A list of node selector terms. The terms are ORed.
  public nodeSelectorTerms: NodeSelectorTerm[];

  constructor(desc: NodeSelector) {
    this.nodeSelectorTerms = desc.nodeSelectorTerms;
  }
}

// A node selector requirement is a selector that contains values, a key, and an operator that relates the key and values.
export class NodeSelectorRequirement {
  // The label key that the selector applies to.
  public key: string;

  // Represents a key's relationship to a set of values. Valid operators are In, NotIn, Exists, DoesNotExist. Gt, and Lt.
  public operator: string;

  // An array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty. If the operator is Gt or Lt, the values array must have a single element, which will be interpreted as an integer. This array is replaced during a strategic merge patch.
  public values?: string[];

  constructor(desc: NodeSelectorRequirement) {
    this.key = desc.key;
    this.operator = desc.operator;
    this.values = desc.values;
  }
}

// A null or empty node selector term matches no objects. The requirements of them are ANDed. The TopologySelectorTerm type implements a subset of the NodeSelectorTerm.
export class NodeSelectorTerm {
  // A list of node selector requirements by node's labels.
  public matchExpressions?: NodeSelectorRequirement[];

  // A list of node selector requirements by node's fields.
  public matchFields?: NodeSelectorRequirement[];
}

// NodeSpec describes the attributes that a node is created with.
export class NodeSpec {
  // If specified, the source to get node configuration from The DynamicKubeletConfig feature gate must be enabled for the Kubelet to use this field
  public configSource?: NodeConfigSource;

  // Deprecated. Not all kubelets will set this field. Remove field after 1.13. see: https://issues.k8s.io/61966
  public externalID?: string;

  // PodCIDR represents the pod IP range assigned to the node.
  public podCIDR?: string;

  // ID of the node assigned by the cloud provider in the format: <ProviderName>://<ProviderSpecificNodeID>
  public providerID?: string;

  // If specified, the node's taints.
  public taints?: Taint[];

  // Unschedulable controls node schedulability of new pods. By default, node is schedulable. More info: https://kubernetes.io/docs/concepts/nodes/node/#manual-node-administration
  public unschedulable?: boolean;
}

// NodeStatus is information about the current status of a node.
export class NodeStatus {
  // List of addresses reachable to the node. Queried from cloud provider, if available. More info: https://kubernetes.io/docs/concepts/nodes/node/#addresses
  public addresses?: NodeAddress[];

  // Allocatable represents the resources of a node that are available for scheduling. Defaults to Capacity.
  public allocatable?: { [key: string]: pkgApiResource.Quantity };

  // Capacity represents the total resources of a node. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#capacity
  public capacity?: { [key: string]: pkgApiResource.Quantity };

  // Conditions is an array of current observed node conditions. More info: https://kubernetes.io/docs/concepts/nodes/node/#condition
  public conditions?: NodeCondition[];

  // Status of the config assigned to the node via the dynamic Kubelet config feature.
  public config?: NodeConfigStatus;

  // Endpoints of daemons running on the Node.
  public daemonEndpoints?: NodeDaemonEndpoints;

  // List of container images on this node
  public images?: ContainerImage[];

  // Set of ids/uuids to uniquely identify the node. More info: https://kubernetes.io/docs/concepts/nodes/node/#info
  public nodeInfo?: NodeSystemInfo;

  // NodePhase is the recently observed lifecycle phase of the node. More info: https://kubernetes.io/docs/concepts/nodes/node/#phase The field is never populated, and now is deprecated.
  public phase?: string;

  // List of volumes that are attached to the node.
  public volumesAttached?: AttachedVolume[];

  // List of attachable volumes in use (mounted) by the node.
  public volumesInUse?: string[];
}

// NodeSystemInfo is a set of ids/uuids to uniquely identify the node.
export class NodeSystemInfo {
  // The Architecture reported by the node
  public architecture: string;

  // Boot ID reported by the node.
  public bootID: string;

  // ContainerRuntime Version reported by the node through runtime remote API (e.g. docker://1.5.0).
  public containerRuntimeVersion: string;

  // Kernel Version reported by the node from 'uname -r' (e.g. 3.16.0-0.bpo.4-amd64).
  public kernelVersion: string;

  // KubeProxy Version reported by the node.
  public kubeProxyVersion: string;

  // Kubelet Version reported by the node.
  public kubeletVersion: string;

  // MachineID reported by the node. For unique machine identification in the cluster this field is preferred. Learn more from man(5) machine-id: http://man7.org/linux/man-pages/man5/machine-id.5.html
  public machineID: string;

  // The Operating System reported by the node
  public operatingSystem: string;

  // OS Image reported by the node from /etc/os-release (e.g. Debian GNU/Linux 7 (wheezy)).
  public osImage: string;

  // SystemUUID reported by the node. For unique machine identification MachineID is preferred. This field is specific to Red Hat hosts https://access.redhat.com/documentation/en-US/Red_Hat_Subscription_Management/1/html/RHSM/getting-system-uuid.html
  public systemUUID: string;

  constructor(desc: NodeSystemInfo) {
    this.architecture = desc.architecture;
    this.bootID = desc.bootID;
    this.containerRuntimeVersion = desc.containerRuntimeVersion;
    this.kernelVersion = desc.kernelVersion;
    this.kubeProxyVersion = desc.kubeProxyVersion;
    this.kubeletVersion = desc.kubeletVersion;
    this.machineID = desc.machineID;
    this.operatingSystem = desc.operatingSystem;
    this.osImage = desc.osImage;
    this.systemUUID = desc.systemUUID;
  }
}

// ObjectFieldSelector selects an APIVersioned field of an object.
export class ObjectFieldSelector {
  // Version of the schema the FieldPath is written in terms of, defaults to "v1".
  public apiVersion?: string;

  // Path of the field to select in the specified API version.
  public fieldPath: string;

  constructor(desc: ObjectFieldSelector) {
    this.apiVersion = desc.apiVersion;
    this.fieldPath = desc.fieldPath;
  }
}

// ObjectReference contains enough information to let you inspect or modify the referred object.
export class ObjectReference {
  // API version of the referent.
  public apiVersion?: string;

  // If referring to a piece of an object instead of an entire object, this string should contain a valid JSON/Go field access statement, such as desiredState.manifest.containers[2]. For example, if the object reference is to a container within a pod, this would take on a value like: "spec.containers{name}" (where "name" refers to the name of the container that triggered the event) or if no container name is specified "spec.containers[2]" (container with index 2 in this pod). This syntax is chosen only to have some well-defined way of referencing a part of an object.
  public fieldPath?: string;

  // Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind?: string;

  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Namespace of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
  public namespace?: string;

  // Specific resourceVersion to which this reference is made, if any. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency
  public resourceVersion?: string;

  // UID of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#uids
  public uid?: string;
}

// PersistentVolume (PV) is a storage resource provisioned by an administrator. It is analogous to a node. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes
export class PersistentVolume implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines a specification of a persistent volume owned by the cluster. Provisioned by an administrator. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes
  public spec?: PersistentVolumeSpec;

  // Status represents the current information/status for the persistent volume. Populated by the system. Read-only. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes
  public status?: PersistentVolumeStatus;

  constructor(desc: PersistentVolume.Interface) {
    this.apiVersion = PersistentVolume.apiVersion;
    this.kind = PersistentVolume.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isPersistentVolume(o: any): o is PersistentVolume {
  return (
    o &&
    o.apiVersion === PersistentVolume.apiVersion &&
    o.kind === PersistentVolume.kind
  );
}

export namespace PersistentVolume {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "PersistentVolume";

  // named constructs a PersistentVolume with metadata.name set to name.
  export function named(name: string): PersistentVolume {
    return new PersistentVolume({ metadata: { name } });
  }
  // PersistentVolume (PV) is a storage resource provisioned by an administrator. It is analogous to a node. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines a specification of a persistent volume owned by the cluster. Provisioned by an administrator. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes
    spec?: PersistentVolumeSpec;

    // Status represents the current information/status for the persistent volume. Populated by the system. Read-only. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes
    status?: PersistentVolumeStatus;
  }
}

// PersistentVolumeClaim is a user's request for and claim to a persistent volume
export class PersistentVolumeClaim implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the desired characteristics of a volume requested by a pod author. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
  public spec?: PersistentVolumeClaimSpec;

  // Status represents the current information/status of a persistent volume claim. Read-only. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
  public status?: PersistentVolumeClaimStatus;

  constructor(desc: PersistentVolumeClaim.Interface) {
    this.apiVersion = PersistentVolumeClaim.apiVersion;
    this.kind = PersistentVolumeClaim.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isPersistentVolumeClaim(o: any): o is PersistentVolumeClaim {
  return (
    o &&
    o.apiVersion === PersistentVolumeClaim.apiVersion &&
    o.kind === PersistentVolumeClaim.kind
  );
}

export namespace PersistentVolumeClaim {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "PersistentVolumeClaim";

  // named constructs a PersistentVolumeClaim with metadata.name set to name.
  export function named(name: string): PersistentVolumeClaim {
    return new PersistentVolumeClaim({ metadata: { name } });
  }
  // PersistentVolumeClaim is a user's request for and claim to a persistent volume
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the desired characteristics of a volume requested by a pod author. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
    spec?: PersistentVolumeClaimSpec;

    // Status represents the current information/status of a persistent volume claim. Read-only. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
    status?: PersistentVolumeClaimStatus;
  }
}

// PersistentVolumeClaimCondition contails details about state of pvc
export class PersistentVolumeClaimCondition {
  // Last time we probed the condition.
  public lastProbeTime?: apisMetaV1.Time;

  // Last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // Human-readable message indicating details about last transition.
  public message?: string;

  // Unique, this should be a short, machine understandable string that gives the reason for condition's last transition. If it reports "ResizeStarted" that means the underlying persistent volume is being resized.
  public reason?: string;

  public status: string;

  public type: string;

  constructor(desc: PersistentVolumeClaimCondition) {
    this.lastProbeTime = desc.lastProbeTime;
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// PersistentVolumeClaimList is a list of PersistentVolumeClaim items.
export class PersistentVolumeClaimList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // A list of persistent volume claims. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
  public items: PersistentVolumeClaim[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: PersistentVolumeClaimList) {
    this.apiVersion = PersistentVolumeClaimList.apiVersion;
    this.items = desc.items.map(i => new PersistentVolumeClaim(i));
    this.kind = PersistentVolumeClaimList.kind;
    this.metadata = desc.metadata;
  }
}

export function isPersistentVolumeClaimList(
  o: any
): o is PersistentVolumeClaimList {
  return (
    o &&
    o.apiVersion === PersistentVolumeClaimList.apiVersion &&
    o.kind === PersistentVolumeClaimList.kind
  );
}

export namespace PersistentVolumeClaimList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "PersistentVolumeClaimList";

  // PersistentVolumeClaimList is a list of PersistentVolumeClaim items.
  export interface Interface {
    // A list of persistent volume claims. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
    items: PersistentVolumeClaim[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// PersistentVolumeClaimSpec describes the common attributes of storage devices and allows a Source for provider-specific attributes
export class PersistentVolumeClaimSpec {
  // AccessModes contains the desired access modes the volume should have. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1
  public accessModes?: string[];

  // This field requires the VolumeSnapshotDataSource alpha feature gate to be enabled and currently VolumeSnapshot is the only supported data source. If the provisioner can support VolumeSnapshot data source, it will create a new volume and data will be restored to the volume at the same time. If the provisioner does not support VolumeSnapshot data source, volume will not be created and the failure will be reported as an event. In the future, we plan to support more data source types and the behavior of the provisioner may change.
  public dataSource?: TypedLocalObjectReference;

  // Resources represents the minimum resources the volume should have. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources
  public resources?: ResourceRequirements;

  // A label query over volumes to consider for binding.
  public selector?: apisMetaV1.LabelSelector;

  // Name of the StorageClass required by the claim. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1
  public storageClassName?: string;

  // volumeMode defines what type of volume is required by the claim. Value of Filesystem is implied when not included in claim spec. This is a beta feature.
  public volumeMode?: string;

  // VolumeName is the binding reference to the PersistentVolume backing this claim.
  public volumeName?: string;
}

// PersistentVolumeClaimStatus is the current status of a persistent volume claim.
export class PersistentVolumeClaimStatus {
  // AccessModes contains the actual access modes the volume backing the PVC has. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1
  public accessModes?: string[];

  // Represents the actual resources of the underlying volume.
  public capacity?: { [key: string]: pkgApiResource.Quantity };

  // Current Condition of persistent volume claim. If underlying persistent volume is being resized then the Condition will be set to 'ResizeStarted'.
  public conditions?: PersistentVolumeClaimCondition[];

  // Phase represents the current phase of PersistentVolumeClaim.
  public phase?: string;
}

// PersistentVolumeClaimVolumeSource references the user's PVC in the same namespace. This volume finds the bound PV and mounts that volume for the pod. A PersistentVolumeClaimVolumeSource is, essentially, a wrapper around another type of volume that is owned by someone else (the system).
export class PersistentVolumeClaimVolumeSource {
  // ClaimName is the name of a PersistentVolumeClaim in the same namespace as the pod using this volume. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
  public claimName: string;

  // Will force the ReadOnly setting in VolumeMounts. Default false.
  public readOnly?: boolean;

  constructor(desc: PersistentVolumeClaimVolumeSource) {
    this.claimName = desc.claimName;
    this.readOnly = desc.readOnly;
  }
}

// PersistentVolumeList is a list of PersistentVolume items.
export class PersistentVolumeList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of persistent volumes. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes
  public items: PersistentVolume[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: PersistentVolumeList) {
    this.apiVersion = PersistentVolumeList.apiVersion;
    this.items = desc.items.map(i => new PersistentVolume(i));
    this.kind = PersistentVolumeList.kind;
    this.metadata = desc.metadata;
  }
}

export function isPersistentVolumeList(o: any): o is PersistentVolumeList {
  return (
    o &&
    o.apiVersion === PersistentVolumeList.apiVersion &&
    o.kind === PersistentVolumeList.kind
  );
}

export namespace PersistentVolumeList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "PersistentVolumeList";

  // PersistentVolumeList is a list of PersistentVolume items.
  export interface Interface {
    // List of persistent volumes. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes
    items: PersistentVolume[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// PersistentVolumeSpec is the specification of a persistent volume.
export class PersistentVolumeSpec {
  // AccessModes contains all ways the volume can be mounted. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes
  public accessModes?: string[];

  // AWSElasticBlockStore represents an AWS Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
  public awsElasticBlockStore?: AWSElasticBlockStoreVolumeSource;

  // AzureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
  public azureDisk?: AzureDiskVolumeSource;

  // AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
  public azureFile?: AzureFilePersistentVolumeSource;

  // A description of the persistent volume's resources and capacity. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#capacity
  public capacity?: { [key: string]: pkgApiResource.Quantity };

  // CephFS represents a Ceph FS mount on the host that shares a pod's lifetime
  public cephfs?: CephFSPersistentVolumeSource;

  // Cinder represents a cinder volume attached and mounted on kubelets host machine More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public cinder?: CinderPersistentVolumeSource;

  // ClaimRef is part of a bi-directional binding between PersistentVolume and PersistentVolumeClaim. Expected to be non-nil when bound. claim.VolumeName is the authoritative bind between PV and PVC. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#binding
  public claimRef?: ObjectReference;

  // CSI represents storage that is handled by an external CSI driver (Beta feature).
  public csi?: CSIPersistentVolumeSource;

  // FC represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod.
  public fc?: FCVolumeSource;

  // FlexVolume represents a generic volume resource that is provisioned/attached using an exec based plugin.
  public flexVolume?: FlexPersistentVolumeSource;

  // Flocker represents a Flocker volume attached to a kubelet's host machine and exposed to the pod for its usage. This depends on the Flocker control service being running
  public flocker?: FlockerVolumeSource;

  // GCEPersistentDisk represents a GCE Disk resource that is attached to a kubelet's host machine and then exposed to the pod. Provisioned by an admin. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
  public gcePersistentDisk?: GCEPersistentDiskVolumeSource;

  // Glusterfs represents a Glusterfs volume that is attached to a host and exposed to the pod. Provisioned by an admin. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md
  public glusterfs?: GlusterfsPersistentVolumeSource;

  // HostPath represents a directory on the host. Provisioned by a developer or tester. This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
  public hostPath?: HostPathVolumeSource;

  // ISCSI represents an ISCSI Disk resource that is attached to a kubelet's host machine and then exposed to the pod. Provisioned by an admin.
  public iscsi?: ISCSIPersistentVolumeSource;

  // Local represents directly-attached storage with node affinity
  public local?: LocalVolumeSource;

  // A list of mount options, e.g. ["ro", "soft"]. Not validated - mount will simply fail if one is invalid. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#mount-options
  public mountOptions?: string[];

  // NFS represents an NFS mount on the host. Provisioned by an admin. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
  public nfs?: NFSVolumeSource;

  // NodeAffinity defines constraints that limit what nodes this volume can be accessed from. This field influences the scheduling of pods that use this volume.
  public nodeAffinity?: VolumeNodeAffinity;

  // What happens to a persistent volume when released from its claim. Valid options are Retain (default for manually created PersistentVolumes), Delete (default for dynamically provisioned PersistentVolumes), and Recycle (deprecated). Recycle must be supported by the volume plugin underlying this PersistentVolume. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#reclaiming
  public persistentVolumeReclaimPolicy?: string;

  // PhotonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine
  public photonPersistentDisk?: PhotonPersistentDiskVolumeSource;

  // PortworxVolume represents a portworx volume attached and mounted on kubelets host machine
  public portworxVolume?: PortworxVolumeSource;

  // Quobyte represents a Quobyte mount on the host that shares a pod's lifetime
  public quobyte?: QuobyteVolumeSource;

  // RBD represents a Rados Block Device mount on the host that shares a pod's lifetime. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md
  public rbd?: RBDPersistentVolumeSource;

  // ScaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.
  public scaleIO?: ScaleIOPersistentVolumeSource;

  // Name of StorageClass to which this persistent volume belongs. Empty value means that this volume does not belong to any StorageClass.
  public storageClassName?: string;

  // StorageOS represents a StorageOS volume that is attached to the kubelet's host machine and mounted into the pod More info: https://releases.k8s.io/HEAD/examples/volumes/storageos/README.md
  public storageos?: StorageOSPersistentVolumeSource;

  // volumeMode defines if a volume is intended to be used with a formatted filesystem or to remain in raw block state. Value of Filesystem is implied when not included in spec. This is a beta feature.
  public volumeMode?: string;

  // VsphereVolume represents a vSphere volume attached and mounted on kubelets host machine
  public vsphereVolume?: VsphereVirtualDiskVolumeSource;
}

// PersistentVolumeStatus is the current status of a persistent volume.
export class PersistentVolumeStatus {
  // A human-readable message indicating details about why the volume is in this state.
  public message?: string;

  // Phase indicates if a volume is available, bound to a claim, or released by a claim. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#phase
  public phase?: string;

  // Reason is a brief CamelCase string that describes any failure and is meant for machine parsing and tidy display in the CLI.
  public reason?: string;
}

// Represents a Photon Controller persistent disk resource.
export class PhotonPersistentDiskVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
  public fsType?: string;

  // ID that identifies Photon Controller persistent disk
  public pdID: string;

  constructor(desc: PhotonPersistentDiskVolumeSource) {
    this.fsType = desc.fsType;
    this.pdID = desc.pdID;
  }
}

// Pod is a collection of containers that can run on a host. This resource is created by clients and scheduled onto hosts.
export class Pod implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior of the pod. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: PodSpec;

  // Most recently observed status of the pod. This data may not be up to date. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: PodStatus;

  constructor(desc: Pod.Interface) {
    this.apiVersion = Pod.apiVersion;
    this.kind = Pod.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isPod(o: any): o is Pod {
  return o && o.apiVersion === Pod.apiVersion && o.kind === Pod.kind;
}

export namespace Pod {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Pod";

  // named constructs a Pod with metadata.name set to name.
  export function named(name: string): Pod {
    return new Pod({ metadata: { name } });
  }
  // Pod is a collection of containers that can run on a host. This resource is created by clients and scheduled onto hosts.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the desired behavior of the pod. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: PodSpec;

    // Most recently observed status of the pod. This data may not be up to date. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: PodStatus;
  }
}

// Pod affinity is a group of inter pod affinity scheduling rules.
export class PodAffinity {
  // The scheduler will prefer to schedule pods to nodes that satisfy the affinity expressions specified by this field, but it may choose a node that violates one or more of the expressions. The node that is most preferred is the one with the greatest sum of weights, i.e. for each node that meets all of the scheduling requirements (resource request, requiredDuringScheduling affinity expressions, etc.), compute a sum by iterating through the elements of this field and adding "weight" to the sum if the node has pods which matches the corresponding podAffinityTerm; the node(s) with the highest sum are the most preferred.
  public preferredDuringSchedulingIgnoredDuringExecution?: WeightedPodAffinityTerm[];

  // If the affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to a pod label update), the system may or may not try to eventually evict the pod from its node. When there are multiple elements, the lists of nodes corresponding to each podAffinityTerm are intersected, i.e. all terms must be satisfied.
  public requiredDuringSchedulingIgnoredDuringExecution?: PodAffinityTerm[];
}

// Defines a set of pods (namely those matching the labelSelector relative to the given namespace(s)) that this pod should be co-located (affinity) or not co-located (anti-affinity) with, where co-located is defined as running on a node whose value of the label with key <topologyKey> matches that of any node on which a pod of the set of pods is running
export class PodAffinityTerm {
  // A label query over a set of resources, in this case pods.
  public labelSelector?: apisMetaV1.LabelSelector;

  // namespaces specifies which namespaces the labelSelector applies to (matches against); null or empty list means "this pod's namespace"
  public namespaces?: string[];

  // This pod should be co-located (affinity) or not co-located (anti-affinity) with the pods matching the labelSelector in the specified namespaces, where co-located is defined as running on a node whose value of the label with key topologyKey matches that of any node on which any of the selected pods is running. Empty topologyKey is not allowed.
  public topologyKey: string;

  constructor(desc: PodAffinityTerm) {
    this.labelSelector = desc.labelSelector;
    this.namespaces = desc.namespaces;
    this.topologyKey = desc.topologyKey;
  }
}

// Pod anti affinity is a group of inter pod anti affinity scheduling rules.
export class PodAntiAffinity {
  // The scheduler will prefer to schedule pods to nodes that satisfy the anti-affinity expressions specified by this field, but it may choose a node that violates one or more of the expressions. The node that is most preferred is the one with the greatest sum of weights, i.e. for each node that meets all of the scheduling requirements (resource request, requiredDuringScheduling anti-affinity expressions, etc.), compute a sum by iterating through the elements of this field and adding "weight" to the sum if the node has pods which matches the corresponding podAffinityTerm; the node(s) with the highest sum are the most preferred.
  public preferredDuringSchedulingIgnoredDuringExecution?: WeightedPodAffinityTerm[];

  // If the anti-affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the anti-affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to a pod label update), the system may or may not try to eventually evict the pod from its node. When there are multiple elements, the lists of nodes corresponding to each podAffinityTerm are intersected, i.e. all terms must be satisfied.
  public requiredDuringSchedulingIgnoredDuringExecution?: PodAffinityTerm[];
}

// PodCondition contains details for the current condition of this pod.
export class PodCondition {
  // Last time we probed the condition.
  public lastProbeTime?: apisMetaV1.Time;

  // Last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // Human-readable message indicating details about last transition.
  public message?: string;

  // Unique, one-word, CamelCase reason for the condition's last transition.
  public reason?: string;

  // Status is the status of the condition. Can be True, False, Unknown. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions
  public status: string;

  // Type is the type of the condition. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions
  public type: string;

  constructor(desc: PodCondition) {
    this.lastProbeTime = desc.lastProbeTime;
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// PodDNSConfig defines the DNS parameters of a pod in addition to those generated from DNSPolicy.
export class PodDNSConfig {
  // A list of DNS name server IP addresses. This will be appended to the base nameservers generated from DNSPolicy. Duplicated nameservers will be removed.
  public nameservers?: string[];

  // A list of DNS resolver options. This will be merged with the base options generated from DNSPolicy. Duplicated entries will be removed. Resolution options given in Options will override those that appear in the base DNSPolicy.
  public options?: PodDNSConfigOption[];

  // A list of DNS search domains for host-name lookup. This will be appended to the base search paths generated from DNSPolicy. Duplicated search paths will be removed.
  public searches?: string[];
}

// PodDNSConfigOption defines DNS resolver options of a pod.
export class PodDNSConfigOption {
  // Required.
  public name?: string;

  public value?: string;
}

// PodList is a list of Pods.
export class PodList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of pods. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md
  public items: Pod[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: PodList) {
    this.apiVersion = PodList.apiVersion;
    this.items = desc.items.map(i => new Pod(i));
    this.kind = PodList.kind;
    this.metadata = desc.metadata;
  }
}

export function isPodList(o: any): o is PodList {
  return o && o.apiVersion === PodList.apiVersion && o.kind === PodList.kind;
}

export namespace PodList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "PodList";

  // PodList is a list of Pods.
  export interface Interface {
    // List of pods. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md
    items: Pod[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// PodReadinessGate contains the reference to a pod condition
export class PodReadinessGate {
  // ConditionType refers to a condition in the pod's condition list with matching type.
  public conditionType: string;

  constructor(desc: PodReadinessGate) {
    this.conditionType = desc.conditionType;
  }
}

// PodSecurityContext holds pod-level security attributes and common container settings. Some fields are also present in container.securityContext.  Field values of container.securityContext take precedence over field values of PodSecurityContext.
export class PodSecurityContext {
  // A special supplemental group that applies to all containers in a pod. Some volume types allow the Kubelet to change the ownership of that volume to be owned by the pod:
  //
  // 1. The owning GID will be the FSGroup 2. The setgid bit is set (new files created in the volume will be owned by FSGroup) 3. The permission bits are OR'd with rw-rw----
  //
  // If unset, the Kubelet will not modify the ownership and permissions of any volume.
  public fsGroup?: number;

  // The GID to run the entrypoint of the container process. Uses runtime default if unset. May also be set in SecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence for that container.
  public runAsGroup?: number;

  // Indicates that the container must run as a non-root user. If true, the Kubelet will validate the image at runtime to ensure that it does not run as UID 0 (root) and fail to start the container if it does. If unset or false, no such validation will be performed. May also be set in SecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.
  public runAsNonRoot?: boolean;

  // The UID to run the entrypoint of the container process. Defaults to user specified in image metadata if unspecified. May also be set in SecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence for that container.
  public runAsUser?: number;

  // The SELinux context to be applied to all containers. If unspecified, the container runtime will allocate a random SELinux context for each container.  May also be set in SecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence for that container.
  public seLinuxOptions?: SELinuxOptions;

  // A list of groups applied to the first process run in each container, in addition to the container's primary GID.  If unspecified, no groups will be added to any container.
  public supplementalGroups?: number[];

  // Sysctls hold a list of namespaced sysctls used for the pod. Pods with unsupported sysctls (by the container runtime) might fail to launch.
  public sysctls?: Sysctl[];
}

// PodSpec is a description of a pod.
export class PodSpec {
  // Optional duration in seconds the pod may be active on the node relative to StartTime before the system will actively try to mark it failed and kill associated containers. Value must be a positive integer.
  public activeDeadlineSeconds?: number;

  // If specified, the pod's scheduling constraints
  public affinity?: Affinity;

  // AutomountServiceAccountToken indicates whether a service account token should be automatically mounted.
  public automountServiceAccountToken?: boolean;

  // List of containers belonging to the pod. Containers cannot currently be added or removed. There must be at least one container in a Pod. Cannot be updated.
  public containers: Container[];

  // Specifies the DNS parameters of a pod. Parameters specified here will be merged to the generated DNS configuration based on DNSPolicy.
  public dnsConfig?: PodDNSConfig;

  // Set DNS policy for the pod. Defaults to "ClusterFirst". Valid values are 'ClusterFirstWithHostNet', 'ClusterFirst', 'Default' or 'None'. DNS parameters given in DNSConfig will be merged with the policy selected with DNSPolicy. To have DNS options set along with hostNetwork, you have to specify DNS policy explicitly to 'ClusterFirstWithHostNet'.
  public dnsPolicy?: string;

  // EnableServiceLinks indicates whether information about services should be injected into pod's environment variables, matching the syntax of Docker links. Optional: Defaults to true.
  public enableServiceLinks?: boolean;

  // HostAliases is an optional list of hosts and IPs that will be injected into the pod's hosts file if specified. This is only valid for non-hostNetwork pods.
  public hostAliases?: HostAlias[];

  // Use the host's ipc namespace. Optional: Default to false.
  public hostIPC?: boolean;

  // Host networking requested for this pod. Use the host's network namespace. If this option is set, the ports that will be used must be specified. Default to false.
  public hostNetwork?: boolean;

  // Use the host's pid namespace. Optional: Default to false.
  public hostPID?: boolean;

  // Specifies the hostname of the Pod If not specified, the pod's hostname will be set to a system-defined value.
  public hostname?: string;

  // ImagePullSecrets is an optional list of references to secrets in the same namespace to use for pulling any of the images used by this PodSpec. If specified, these secrets will be passed to individual puller implementations for them to use. For example, in the case of docker, only DockerConfig type secrets are honored. More info: https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod
  public imagePullSecrets?: LocalObjectReference[];

  // List of initialization containers belonging to the pod. Init containers are executed in order prior to containers being started. If any init container fails, the pod is considered to have failed and is handled according to its restartPolicy. The name for an init container or normal container must be unique among all containers. Init containers may not have Lifecycle actions, Readiness probes, or Liveness probes. The resourceRequirements of an init container are taken into account during scheduling by finding the highest request/limit for each resource type, and then using the max of of that value or the sum of the normal containers. Limits are applied to init containers in a similar fashion. Init containers cannot currently be added or removed. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  public initContainers?: Container[];

  // NodeName is a request to schedule this pod onto a specific node. If it is non-empty, the scheduler simply schedules this pod onto that node, assuming that it fits resource requirements.
  public nodeName?: string;

  // NodeSelector is a selector which must be true for the pod to fit on a node. Selector which must match a node's labels for the pod to be scheduled on that node. More info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  public nodeSelector?: { [key: string]: string };

  // The priority value. Various system components use this field to find the priority of the pod. When Priority Admission Controller is enabled, it prevents users from setting this field. The admission controller populates this field from PriorityClassName. The higher the value, the higher the priority.
  public priority?: number;

  // If specified, indicates the pod's priority. "system-node-critical" and "system-cluster-critical" are two special keywords which indicate the highest priorities with the former being the highest priority. Any other name must be defined by creating a PriorityClass object with that name. If not specified, the pod priority will be default or zero if there is no default.
  public priorityClassName?: string;

  // If specified, all readiness gates will be evaluated for pod readiness. A pod is ready when all its containers are ready AND all conditions specified in the readiness gates have status equal to "True" More info: https://git.k8s.io/enhancements/keps/sig-network/0007-pod-ready%2B%2B.md
  public readinessGates?: PodReadinessGate[];

  // Restart policy for all containers within the pod. One of Always, OnFailure, Never. Default to Always. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy
  public restartPolicy?: string;

  // RuntimeClassName refers to a RuntimeClass object in the node.k8s.io group, which should be used to run this pod.  If no RuntimeClass resource matches the named class, the pod will not be run. If unset or empty, the "legacy" RuntimeClass will be used, which is an implicit class with an empty definition that uses the default runtime handler. More info: https://git.k8s.io/enhancements/keps/sig-node/runtime-class.md This is an alpha feature and may change in the future.
  public runtimeClassName?: string;

  // If specified, the pod will be dispatched by specified scheduler. If not specified, the pod will be dispatched by default scheduler.
  public schedulerName?: string;

  // SecurityContext holds pod-level security attributes and common container settings. Optional: Defaults to empty.  See type description for default values of each field.
  public securityContext?: PodSecurityContext;

  // DeprecatedServiceAccount is a depreciated alias for ServiceAccountName. Deprecated: Use serviceAccountName instead.
  public serviceAccount?: string;

  // ServiceAccountName is the name of the ServiceAccount to use to run this pod. More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  public serviceAccountName?: string;

  // Share a single process namespace between all of the containers in a pod. When this is set containers will be able to view and signal processes from other containers in the same pod, and the first process in each container will not be assigned PID 1. HostPID and ShareProcessNamespace cannot both be set. Optional: Default to false. This field is beta-level and may be disabled with the PodShareProcessNamespace feature.
  public shareProcessNamespace?: boolean;

  // If specified, the fully qualified Pod hostname will be "<hostname>.<subdomain>.<pod namespace>.svc.<cluster domain>". If not specified, the pod will not have a domainname at all.
  public subdomain?: string;

  // Optional duration in seconds the pod needs to terminate gracefully. May be decreased in delete request. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period will be used instead. The grace period is the duration in seconds after the processes running in the pod are sent a termination signal and the time when the processes are forcibly halted with a kill signal. Set this value longer than the expected cleanup time for your process. Defaults to 30 seconds.
  public terminationGracePeriodSeconds?: number;

  // If specified, the pod's tolerations.
  public tolerations?: Toleration[];

  // List of volumes that can be mounted by containers belonging to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes
  public volumes?: Volume[];

  constructor(desc: PodSpec) {
    this.activeDeadlineSeconds = desc.activeDeadlineSeconds;
    this.affinity = desc.affinity;
    this.automountServiceAccountToken = desc.automountServiceAccountToken;
    this.containers = desc.containers;
    this.dnsConfig = desc.dnsConfig;
    this.dnsPolicy = desc.dnsPolicy;
    this.enableServiceLinks = desc.enableServiceLinks;
    this.hostAliases = desc.hostAliases;
    this.hostIPC = desc.hostIPC;
    this.hostNetwork = desc.hostNetwork;
    this.hostPID = desc.hostPID;
    this.hostname = desc.hostname;
    this.imagePullSecrets = desc.imagePullSecrets;
    this.initContainers = desc.initContainers;
    this.nodeName = desc.nodeName;
    this.nodeSelector = desc.nodeSelector;
    this.priority = desc.priority;
    this.priorityClassName = desc.priorityClassName;
    this.readinessGates = desc.readinessGates;
    this.restartPolicy = desc.restartPolicy;
    this.runtimeClassName = desc.runtimeClassName;
    this.schedulerName = desc.schedulerName;
    this.securityContext = desc.securityContext;
    this.serviceAccount = desc.serviceAccount;
    this.serviceAccountName = desc.serviceAccountName;
    this.shareProcessNamespace = desc.shareProcessNamespace;
    this.subdomain = desc.subdomain;
    this.terminationGracePeriodSeconds = desc.terminationGracePeriodSeconds;
    this.tolerations = desc.tolerations;
    this.volumes = desc.volumes;
  }
}

// PodStatus represents information about the status of a pod. Status may trail the actual state of a system, especially if the node that hosts the pod cannot contact the control plane.
export class PodStatus {
  // Current service state of pod. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions
  public conditions?: PodCondition[];

  // The list has one entry per container in the manifest. Each entry is currently the output of `docker inspect`. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-and-container-status
  public containerStatuses?: ContainerStatus[];

  // IP address of the host to which the pod is assigned. Empty if not yet scheduled.
  public hostIP?: string;

  // The list has one entry per init container in the manifest. The most recent successful init container will have ready = true, the most recently started container will have startTime set. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-and-container-status
  public initContainerStatuses?: ContainerStatus[];

  // A human readable message indicating details about why the pod is in this condition.
  public message?: string;

  // nominatedNodeName is set only when this pod preempts other pods on the node, but it cannot be scheduled right away as preemption victims receive their graceful termination periods. This field does not guarantee that the pod will be scheduled on this node. Scheduler may decide to place the pod elsewhere if other nodes become available sooner. Scheduler may also decide to give the resources on this node to a higher priority pod that is created after preemption. As a result, this field may be different than PodSpec.nodeName when the pod is scheduled.
  public nominatedNodeName?: string;

  // The phase of a Pod is a simple, high-level summary of where the Pod is in its lifecycle. The conditions array, the reason and message fields, and the individual container status arrays contain more detail about the pod's status. There are five possible phase values:
  //
  // Pending: The pod has been accepted by the Kubernetes system, but one or more of the container images has not been created. This includes time before being scheduled as well as time spent downloading images over the network, which could take a while. Running: The pod has been bound to a node, and all of the containers have been created. At least one container is still running, or is in the process of starting or restarting. Succeeded: All containers in the pod have terminated in success, and will not be restarted. Failed: All containers in the pod have terminated, and at least one container has terminated in failure. The container either exited with non-zero status or was terminated by the system. Unknown: For some reason the state of the pod could not be obtained, typically due to an error in communicating with the host of the pod.
  //
  // More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-phase
  public phase?: string;

  // IP address allocated to the pod. Routable at least within the cluster. Empty if not yet allocated.
  public podIP?: string;

  // The Quality of Service (QOS) classification assigned to the pod based on resource requirements See PodQOSClass type for available QOS classes More info: https://git.k8s.io/community/contributors/design-proposals/node/resource-qos.md
  public qosClass?: string;

  // A brief CamelCase message indicating details about why the pod is in this state. e.g. 'Evicted'
  public reason?: string;

  // RFC 3339 date and time at which the object was acknowledged by the Kubelet. This is before the Kubelet pulled the container image(s) for the pod.
  public startTime?: apisMetaV1.Time;
}

// PodTemplate describes a template for creating copies of a predefined pod.
export class PodTemplate implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Template defines the pods that will be created from this pod template. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public template?: PodTemplateSpec;

  constructor(desc: PodTemplate.Interface) {
    this.apiVersion = PodTemplate.apiVersion;
    this.kind = PodTemplate.kind;
    this.metadata = desc.metadata;
    this.template = desc.template;
  }
}

export function isPodTemplate(o: any): o is PodTemplate {
  return (
    o && o.apiVersion === PodTemplate.apiVersion && o.kind === PodTemplate.kind
  );
}

export namespace PodTemplate {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "PodTemplate";

  // named constructs a PodTemplate with metadata.name set to name.
  export function named(name: string): PodTemplate {
    return new PodTemplate({ metadata: { name } });
  }
  // PodTemplate describes a template for creating copies of a predefined pod.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Template defines the pods that will be created from this pod template. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    template?: PodTemplateSpec;
  }
}

// PodTemplateList is a list of PodTemplates.
export class PodTemplateList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of pod templates
  public items: PodTemplate[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: PodTemplateList) {
    this.apiVersion = PodTemplateList.apiVersion;
    this.items = desc.items.map(i => new PodTemplate(i));
    this.kind = PodTemplateList.kind;
    this.metadata = desc.metadata;
  }
}

export function isPodTemplateList(o: any): o is PodTemplateList {
  return (
    o &&
    o.apiVersion === PodTemplateList.apiVersion &&
    o.kind === PodTemplateList.kind
  );
}

export namespace PodTemplateList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "PodTemplateList";

  // PodTemplateList is a list of PodTemplates.
  export interface Interface {
    // List of pod templates
    items: PodTemplate[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// PodTemplateSpec describes the data a pod should have when created from a template
export class PodTemplateSpec {
  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior of the pod. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: PodSpec;
}

// PortworxVolumeSource represents a Portworx volume resource.
export class PortworxVolumeSource {
  // FSType represents the filesystem type to mount Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs". Implicitly inferred to be "ext4" if unspecified.
  public fsType?: string;

  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // VolumeID uniquely identifies a Portworx volume
  public volumeID: string;

  constructor(desc: PortworxVolumeSource) {
    this.fsType = desc.fsType;
    this.readOnly = desc.readOnly;
    this.volumeID = desc.volumeID;
  }
}

// An empty preferred scheduling term matches all objects with implicit weight 0 (i.e. it's a no-op). A null preferred scheduling term matches no objects (i.e. is also a no-op).
export class PreferredSchedulingTerm {
  // A node selector term, associated with the corresponding weight.
  public preference: NodeSelectorTerm;

  // Weight associated with matching the corresponding nodeSelectorTerm, in the range 1-100.
  public weight: number;

  constructor(desc: PreferredSchedulingTerm) {
    this.preference = desc.preference;
    this.weight = desc.weight;
  }
}

// Probe describes a health check to be performed against a container to determine whether it is alive or ready to receive traffic.
export class Probe {
  // One and only one of the following should be specified. Exec specifies the action to take.
  public exec?: ExecAction;

  // Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3. Minimum value is 1.
  public failureThreshold?: number;

  // HTTPGet specifies the http request to perform.
  public httpGet?: HTTPGetAction;

  // Number of seconds after the container has started before liveness probes are initiated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
  public initialDelaySeconds?: number;

  // How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
  public periodSeconds?: number;

  // Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness. Minimum value is 1.
  public successThreshold?: number;

  // TCPSocket specifies an action involving a TCP port. TCP hooks not yet supported
  public tcpSocket?: TCPSocketAction;

  // Number of seconds after which the probe times out. Defaults to 1 second. Minimum value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
  public timeoutSeconds?: number;
}

// Represents a projected volume source
export class ProjectedVolumeSource {
  // Mode bits to use on created files by default. Must be a value between 0 and 0777. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.
  public defaultMode?: number;

  // list of volume projections
  public sources: VolumeProjection[];

  constructor(desc: ProjectedVolumeSource) {
    this.defaultMode = desc.defaultMode;
    this.sources = desc.sources;
  }
}

// Represents a Quobyte mount that lasts the lifetime of a pod. Quobyte volumes do not support ownership management or SELinux relabeling.
export class QuobyteVolumeSource {
  // Group to map volume access to Default is no group
  public group?: string;

  // ReadOnly here will force the Quobyte volume to be mounted with read-only permissions. Defaults to false.
  public readOnly?: boolean;

  // Registry represents a single or multiple Quobyte Registry services specified as a string as host:port pair (multiple entries are separated with commas) which acts as the central registry for volumes
  public registry: string;

  // Tenant owning the given Quobyte volume in the Backend Used with dynamically provisioned Quobyte volumes, value is set by the plugin
  public tenant?: string;

  // User to map volume access to Defaults to serivceaccount user
  public user?: string;

  // Volume is a string that references an already created Quobyte volume by name.
  public volume: string;

  constructor(desc: QuobyteVolumeSource) {
    this.group = desc.group;
    this.readOnly = desc.readOnly;
    this.registry = desc.registry;
    this.tenant = desc.tenant;
    this.user = desc.user;
    this.volume = desc.volume;
  }
}

// Represents a Rados Block Device mount that lasts the lifetime of a pod. RBD volumes support ownership management and SELinux relabeling.
export class RBDPersistentVolumeSource {
  // Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#rbd
  public fsType?: string;

  // The rados image name. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public image: string;

  // Keyring is the path to key ring for RBDUser. Default is /etc/ceph/keyring. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public keyring?: string;

  // A collection of Ceph monitors. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public monitors: string[];

  // The rados pool name. Default is rbd. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public pool?: string;

  // ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public readOnly?: boolean;

  // SecretRef is name of the authentication secret for RBDUser. If provided overrides keyring. Default is nil. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public secretRef?: SecretReference;

  // The rados user name. Default is admin. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public user?: string;

  constructor(desc: RBDPersistentVolumeSource) {
    this.fsType = desc.fsType;
    this.image = desc.image;
    this.keyring = desc.keyring;
    this.monitors = desc.monitors;
    this.pool = desc.pool;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.user = desc.user;
  }
}

// Represents a Rados Block Device mount that lasts the lifetime of a pod. RBD volumes support ownership management and SELinux relabeling.
export class RBDVolumeSource {
  // Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#rbd
  public fsType?: string;

  // The rados image name. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public image: string;

  // Keyring is the path to key ring for RBDUser. Default is /etc/ceph/keyring. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public keyring?: string;

  // A collection of Ceph monitors. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public monitors: string[];

  // The rados pool name. Default is rbd. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public pool?: string;

  // ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public readOnly?: boolean;

  // SecretRef is name of the authentication secret for RBDUser. If provided overrides keyring. Default is nil. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public secretRef?: LocalObjectReference;

  // The rados user name. Default is admin. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it
  public user?: string;

  constructor(desc: RBDVolumeSource) {
    this.fsType = desc.fsType;
    this.image = desc.image;
    this.keyring = desc.keyring;
    this.monitors = desc.monitors;
    this.pool = desc.pool;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.user = desc.user;
  }
}

// ReplicationController represents the configuration of a replication controller.
export class ReplicationController implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // If the Labels of a ReplicationController are empty, they are defaulted to be the same as the Pod(s) that the replication controller manages. Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the specification of the desired behavior of the replication controller. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: ReplicationControllerSpec;

  // Status is the most recently observed status of the replication controller. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: ReplicationControllerStatus;

  constructor(desc: ReplicationController.Interface) {
    this.apiVersion = ReplicationController.apiVersion;
    this.kind = ReplicationController.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isReplicationController(o: any): o is ReplicationController {
  return (
    o &&
    o.apiVersion === ReplicationController.apiVersion &&
    o.kind === ReplicationController.kind
  );
}

export namespace ReplicationController {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ReplicationController";

  // named constructs a ReplicationController with metadata.name set to name.
  export function named(name: string): ReplicationController {
    return new ReplicationController({ metadata: { name } });
  }
  // ReplicationController represents the configuration of a replication controller.
  export interface Interface {
    // If the Labels of a ReplicationController are empty, they are defaulted to be the same as the Pod(s) that the replication controller manages. Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the specification of the desired behavior of the replication controller. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: ReplicationControllerSpec;

    // Status is the most recently observed status of the replication controller. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: ReplicationControllerStatus;
  }
}

// ReplicationControllerCondition describes the state of a replication controller at a certain point.
export class ReplicationControllerCondition {
  // The last time the condition transitioned from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // A human readable message indicating details about the transition.
  public message?: string;

  // The reason for the condition's last transition.
  public reason?: string;

  // Status of the condition, one of True, False, Unknown.
  public status: string;

  // Type of replication controller condition.
  public type: string;

  constructor(desc: ReplicationControllerCondition) {
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// ReplicationControllerList is a collection of replication controllers.
export class ReplicationControllerList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of replication controllers. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller
  public items: ReplicationController[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ReplicationControllerList) {
    this.apiVersion = ReplicationControllerList.apiVersion;
    this.items = desc.items.map(i => new ReplicationController(i));
    this.kind = ReplicationControllerList.kind;
    this.metadata = desc.metadata;
  }
}

export function isReplicationControllerList(
  o: any
): o is ReplicationControllerList {
  return (
    o &&
    o.apiVersion === ReplicationControllerList.apiVersion &&
    o.kind === ReplicationControllerList.kind
  );
}

export namespace ReplicationControllerList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ReplicationControllerList";

  // ReplicationControllerList is a collection of replication controllers.
  export interface Interface {
    // List of replication controllers. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller
    items: ReplicationController[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// ReplicationControllerSpec is the specification of a replication controller.
export class ReplicationControllerSpec {
  // Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)
  public minReadySeconds?: number;

  // Replicas is the number of desired replicas. This is a pointer to distinguish between explicit zero and unspecified. Defaults to 1. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#what-is-a-replicationcontroller
  public replicas?: number;

  // Selector is a label query over pods that should match the Replicas count. If Selector is empty, it is defaulted to the labels present on the Pod template. Label keys and values that must match in order to be controlled by this replication controller, if empty defaulted to labels on Pod template. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public selector?: { [key: string]: string };

  // Template is the object that describes the pod that will be created if insufficient replicas are detected. This takes precedence over a TemplateRef. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template
  public template?: PodTemplateSpec;
}

// ReplicationControllerStatus represents the current status of a replication controller.
export class ReplicationControllerStatus {
  // The number of available replicas (ready for at least minReadySeconds) for this replication controller.
  public availableReplicas?: number;

  // Represents the latest available observations of a replication controller's current state.
  public conditions?: ReplicationControllerCondition[];

  // The number of pods that have labels matching the labels of the pod template of the replication controller.
  public fullyLabeledReplicas?: number;

  // ObservedGeneration reflects the generation of the most recently observed replication controller.
  public observedGeneration?: number;

  // The number of ready replicas for this replication controller.
  public readyReplicas?: number;

  // Replicas is the most recently oberved number of replicas. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#what-is-a-replicationcontroller
  public replicas: number;

  constructor(desc: ReplicationControllerStatus) {
    this.availableReplicas = desc.availableReplicas;
    this.conditions = desc.conditions;
    this.fullyLabeledReplicas = desc.fullyLabeledReplicas;
    this.observedGeneration = desc.observedGeneration;
    this.readyReplicas = desc.readyReplicas;
    this.replicas = desc.replicas;
  }
}

// ResourceFieldSelector represents container resources (cpu, memory) and their output format
export class ResourceFieldSelector {
  // Container name: required for volumes, optional for env vars
  public containerName?: string;

  // Specifies the output format of the exposed resources, defaults to "1"
  public divisor?: pkgApiResource.Quantity;

  // Required: resource to select
  public resource: string;

  constructor(desc: ResourceFieldSelector) {
    this.containerName = desc.containerName;
    this.divisor = desc.divisor;
    this.resource = desc.resource;
  }
}

// ResourceQuota sets aggregate quota restrictions enforced per namespace
export class ResourceQuota implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the desired quota. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: ResourceQuotaSpec;

  // Status defines the actual enforced quota and its current usage. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: ResourceQuotaStatus;

  constructor(desc: ResourceQuota.Interface) {
    this.apiVersion = ResourceQuota.apiVersion;
    this.kind = ResourceQuota.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isResourceQuota(o: any): o is ResourceQuota {
  return (
    o &&
    o.apiVersion === ResourceQuota.apiVersion &&
    o.kind === ResourceQuota.kind
  );
}

export namespace ResourceQuota {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ResourceQuota";

  // named constructs a ResourceQuota with metadata.name set to name.
  export function named(name: string): ResourceQuota {
    return new ResourceQuota({ metadata: { name } });
  }
  // ResourceQuota sets aggregate quota restrictions enforced per namespace
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the desired quota. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: ResourceQuotaSpec;

    // Status defines the actual enforced quota and its current usage. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: ResourceQuotaStatus;
  }
}

// ResourceQuotaList is a list of ResourceQuota items.
export class ResourceQuotaList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of ResourceQuota objects. More info: https://kubernetes.io/docs/concepts/policy/resource-quotas/
  public items: ResourceQuota[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ResourceQuotaList) {
    this.apiVersion = ResourceQuotaList.apiVersion;
    this.items = desc.items.map(i => new ResourceQuota(i));
    this.kind = ResourceQuotaList.kind;
    this.metadata = desc.metadata;
  }
}

export function isResourceQuotaList(o: any): o is ResourceQuotaList {
  return (
    o &&
    o.apiVersion === ResourceQuotaList.apiVersion &&
    o.kind === ResourceQuotaList.kind
  );
}

export namespace ResourceQuotaList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ResourceQuotaList";

  // ResourceQuotaList is a list of ResourceQuota items.
  export interface Interface {
    // Items is a list of ResourceQuota objects. More info: https://kubernetes.io/docs/concepts/policy/resource-quotas/
    items: ResourceQuota[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// ResourceQuotaSpec defines the desired hard limits to enforce for Quota.
export class ResourceQuotaSpec {
  // hard is the set of desired hard limits for each named resource. More info: https://kubernetes.io/docs/concepts/policy/resource-quotas/
  public hard?: { [key: string]: pkgApiResource.Quantity };

  // scopeSelector is also a collection of filters like scopes that must match each object tracked by a quota but expressed using ScopeSelectorOperator in combination with possible values. For a resource to match, both scopes AND scopeSelector (if specified in spec), must be matched.
  public scopeSelector?: ScopeSelector;

  // A collection of filters that must match each object tracked by a quota. If not specified, the quota matches all objects.
  public scopes?: string[];
}

// ResourceQuotaStatus defines the enforced hard limits and observed use.
export class ResourceQuotaStatus {
  // Hard is the set of enforced hard limits for each named resource. More info: https://kubernetes.io/docs/concepts/policy/resource-quotas/
  public hard?: { [key: string]: pkgApiResource.Quantity };

  // Used is the current observed total usage of the resource in the namespace.
  public used?: { [key: string]: pkgApiResource.Quantity };
}

// ResourceRequirements describes the compute resource requirements.
export class ResourceRequirements {
  // Limits describes the maximum amount of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  public limits?: { [key: string]: pkgApiResource.Quantity };

  // Requests describes the minimum amount of compute resources required. If Requests is omitted for a container, it defaults to Limits if that is explicitly specified, otherwise to an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  public requests?: { [key: string]: pkgApiResource.Quantity };
}

// SELinuxOptions are the labels to be applied to the container
export class SELinuxOptions {
  // Level is SELinux level label that applies to the container.
  public level?: string;

  // Role is a SELinux role label that applies to the container.
  public role?: string;

  // Type is a SELinux type label that applies to the container.
  public type?: string;

  // User is a SELinux user label that applies to the container.
  public user?: string;
}

// ScaleIOPersistentVolumeSource represents a persistent ScaleIO volume
export class ScaleIOPersistentVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Default is "xfs"
  public fsType?: string;

  // The host address of the ScaleIO API Gateway.
  public gateway: string;

  // The name of the ScaleIO Protection Domain for the configured storage.
  public protectionDomain?: string;

  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // SecretRef references to the secret for ScaleIO user and other sensitive information. If this is not provided, Login operation will fail.
  public secretRef: SecretReference;

  // Flag to enable/disable SSL communication with Gateway, default false
  public sslEnabled?: boolean;

  // Indicates whether the storage for a volume should be ThickProvisioned or ThinProvisioned. Default is ThinProvisioned.
  public storageMode?: string;

  // The ScaleIO Storage Pool associated with the protection domain.
  public storagePool?: string;

  // The name of the storage system as configured in ScaleIO.
  public system: string;

  // The name of a volume already created in the ScaleIO system that is associated with this volume source.
  public volumeName?: string;

  constructor(desc: ScaleIOPersistentVolumeSource) {
    this.fsType = desc.fsType;
    this.gateway = desc.gateway;
    this.protectionDomain = desc.protectionDomain;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.sslEnabled = desc.sslEnabled;
    this.storageMode = desc.storageMode;
    this.storagePool = desc.storagePool;
    this.system = desc.system;
    this.volumeName = desc.volumeName;
  }
}

// ScaleIOVolumeSource represents a persistent ScaleIO volume
export class ScaleIOVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Default is "xfs".
  public fsType?: string;

  // The host address of the ScaleIO API Gateway.
  public gateway: string;

  // The name of the ScaleIO Protection Domain for the configured storage.
  public protectionDomain?: string;

  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // SecretRef references to the secret for ScaleIO user and other sensitive information. If this is not provided, Login operation will fail.
  public secretRef: LocalObjectReference;

  // Flag to enable/disable SSL communication with Gateway, default false
  public sslEnabled?: boolean;

  // Indicates whether the storage for a volume should be ThickProvisioned or ThinProvisioned. Default is ThinProvisioned.
  public storageMode?: string;

  // The ScaleIO Storage Pool associated with the protection domain.
  public storagePool?: string;

  // The name of the storage system as configured in ScaleIO.
  public system: string;

  // The name of a volume already created in the ScaleIO system that is associated with this volume source.
  public volumeName?: string;

  constructor(desc: ScaleIOVolumeSource) {
    this.fsType = desc.fsType;
    this.gateway = desc.gateway;
    this.protectionDomain = desc.protectionDomain;
    this.readOnly = desc.readOnly;
    this.secretRef = desc.secretRef;
    this.sslEnabled = desc.sslEnabled;
    this.storageMode = desc.storageMode;
    this.storagePool = desc.storagePool;
    this.system = desc.system;
    this.volumeName = desc.volumeName;
  }
}

// A scope selector represents the AND of the selectors represented by the scoped-resource selector requirements.
export class ScopeSelector {
  // A list of scope selector requirements by scope of the resources.
  public matchExpressions?: ScopedResourceSelectorRequirement[];
}

// A scoped-resource selector requirement is a selector that contains values, a scope name, and an operator that relates the scope name and values.
export class ScopedResourceSelectorRequirement {
  // Represents a scope's relationship to a set of values. Valid operators are In, NotIn, Exists, DoesNotExist.
  public operator: string;

  // The name of the scope that the selector applies to.
  public scopeName: string;

  // An array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty. This array is replaced during a strategic merge patch.
  public values?: string[];

  constructor(desc: ScopedResourceSelectorRequirement) {
    this.operator = desc.operator;
    this.scopeName = desc.scopeName;
    this.values = desc.values;
  }
}

// Secret holds secret data of a certain type. The total bytes of the values in the Data field must be less than MaxSecretSize bytes.
export class Secret implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Data contains the secret data. Each key must consist of alphanumeric characters, '-', '_' or '.'. The serialized form of the secret data is a base64 encoded string, representing the arbitrary (possibly non-string) data value here. Described in https://tools.ietf.org/html/rfc4648#section-4
  public data?: { [key: string]: string };

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // stringData allows specifying non-binary secret data in string form. It is provided as a write-only convenience method. All keys and values are merged into the data field on write, overwriting any existing values. It is never output when reading from the API.
  public stringData?: { [key: string]: string };

  // Used to facilitate programmatic handling of secret data.
  public type?: string;

  constructor(desc: Secret.Interface) {
    this.apiVersion = Secret.apiVersion;
    this.data = desc.data;
    this.kind = Secret.kind;
    this.metadata = desc.metadata;
    this.stringData = desc.stringData;
    this.type = desc.type;
  }
}

export function isSecret(o: any): o is Secret {
  return o && o.apiVersion === Secret.apiVersion && o.kind === Secret.kind;
}

export namespace Secret {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Secret";

  // named constructs a Secret with metadata.name set to name.
  export function named(name: string): Secret {
    return new Secret({ metadata: { name } });
  }
  // Secret holds secret data of a certain type. The total bytes of the values in the Data field must be less than MaxSecretSize bytes.
  export interface Interface {
    // Data contains the secret data. Each key must consist of alphanumeric characters, '-', '_' or '.'. The serialized form of the secret data is a base64 encoded string, representing the arbitrary (possibly non-string) data value here. Described in https://tools.ietf.org/html/rfc4648#section-4
    data?: { [key: string]: string };

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // stringData allows specifying non-binary secret data in string form. It is provided as a write-only convenience method. All keys and values are merged into the data field on write, overwriting any existing values. It is never output when reading from the API.
    stringData?: { [key: string]: string };

    // Used to facilitate programmatic handling of secret data.
    type?: string;
  }
}

// SecretEnvSource selects a Secret to populate the environment variables with.
//
// The contents of the target Secret's Data field will represent the key-value pairs as environment variables.
export class SecretEnvSource {
  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Specify whether the Secret must be defined
  public optional?: boolean;
}

// SecretKeySelector selects a key of a Secret.
export class SecretKeySelector {
  // The key of the secret to select from.  Must be a valid secret key.
  public key: string;

  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Specify whether the Secret or it's key must be defined
  public optional?: boolean;

  constructor(desc: SecretKeySelector) {
    this.key = desc.key;
    this.name = desc.name;
    this.optional = desc.optional;
  }
}

// SecretList is a list of Secret.
export class SecretList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of secret objects. More info: https://kubernetes.io/docs/concepts/configuration/secret
  public items: Secret[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: SecretList) {
    this.apiVersion = SecretList.apiVersion;
    this.items = desc.items.map(i => new Secret(i));
    this.kind = SecretList.kind;
    this.metadata = desc.metadata;
  }
}

export function isSecretList(o: any): o is SecretList {
  return (
    o && o.apiVersion === SecretList.apiVersion && o.kind === SecretList.kind
  );
}

export namespace SecretList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "SecretList";

  // SecretList is a list of Secret.
  export interface Interface {
    // Items is a list of secret objects. More info: https://kubernetes.io/docs/concepts/configuration/secret
    items: Secret[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// Adapts a secret into a projected volume.
//
// The contents of the target Secret's Data field will be presented in a projected volume as files using the keys in the Data field as the file names. Note that this is identical to a secret volume source without the default mode.
export class SecretProjection {
  // If unspecified, each key-value pair in the Data field of the referenced Secret will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the Secret, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.
  public items?: KeyToPath[];

  // Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name?: string;

  // Specify whether the Secret or its key must be defined
  public optional?: boolean;
}

// SecretReference represents a Secret Reference. It has enough information to retrieve secret in any namespace
export class SecretReference {
  // Name is unique within a namespace to reference a secret resource.
  public name?: string;

  // Namespace defines the space within which the secret name must be unique.
  public namespace?: string;
}

// Adapts a Secret into a volume.
//
// The contents of the target Secret's Data field will be presented in a volume as files using the keys in the Data field as the file names. Secret volumes support ownership management and SELinux relabeling.
export class SecretVolumeSource {
  // Optional: mode bits to use on created files by default. Must be a value between 0 and 0777. Defaults to 0644. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.
  public defaultMode?: number;

  // If unspecified, each key-value pair in the Data field of the referenced Secret will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the Secret, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.
  public items?: KeyToPath[];

  // Specify whether the Secret or it's keys must be defined
  public optional?: boolean;

  // Name of the secret in the pod's namespace to use. More info: https://kubernetes.io/docs/concepts/storage/volumes#secret
  public secretName?: string;
}

// SecurityContext holds security configuration that will be applied to a container. Some fields are present in both SecurityContext and PodSecurityContext.  When both are set, the values in SecurityContext take precedence.
export class SecurityContext {
  // AllowPrivilegeEscalation controls whether a process can gain more privileges than its parent process. This bool directly controls if the no_new_privs flag will be set on the container process. AllowPrivilegeEscalation is true always when the container is: 1) run as Privileged 2) has CAP_SYS_ADMIN
  public allowPrivilegeEscalation?: boolean;

  // The capabilities to add/drop when running containers. Defaults to the default set of capabilities granted by the container runtime.
  public capabilities?: Capabilities;

  // Run container in privileged mode. Processes in privileged containers are essentially equivalent to root on the host. Defaults to false.
  public privileged?: boolean;

  // procMount denotes the type of proc mount to use for the containers. The default is DefaultProcMount which uses the container runtime defaults for readonly paths and masked paths. This requires the ProcMountType feature flag to be enabled.
  public procMount?: string;

  // Whether this container has a read-only root filesystem. Default is false.
  public readOnlyRootFilesystem?: boolean;

  // The GID to run the entrypoint of the container process. Uses runtime default if unset. May also be set in PodSecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.
  public runAsGroup?: number;

  // Indicates that the container must run as a non-root user. If true, the Kubelet will validate the image at runtime to ensure that it does not run as UID 0 (root) and fail to start the container if it does. If unset or false, no such validation will be performed. May also be set in PodSecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.
  public runAsNonRoot?: boolean;

  // The UID to run the entrypoint of the container process. Defaults to user specified in image metadata if unspecified. May also be set in PodSecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.
  public runAsUser?: number;

  // The SELinux context to be applied to the container. If unspecified, the container runtime will allocate a random SELinux context for each container.  May also be set in PodSecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.
  public seLinuxOptions?: SELinuxOptions;
}

// Service is a named abstraction of software service (for example, mysql) consisting of local port (for example 3306) that the proxy listens on, and the selector that determines which pods will answer requests sent through the proxy.
export class Service implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec defines the behavior of a service. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: ServiceSpec;

  // Most recently observed status of the service. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: ServiceStatus;

  constructor(desc: Service.Interface) {
    this.apiVersion = Service.apiVersion;
    this.kind = Service.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isService(o: any): o is Service {
  return o && o.apiVersion === Service.apiVersion && o.kind === Service.kind;
}

export namespace Service {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "Service";

  // named constructs a Service with metadata.name set to name.
  export function named(name: string): Service {
    return new Service({ metadata: { name } });
  }
  // Service is a named abstraction of software service (for example, mysql) consisting of local port (for example 3306) that the proxy listens on, and the selector that determines which pods will answer requests sent through the proxy.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec defines the behavior of a service. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: ServiceSpec;

    // Most recently observed status of the service. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: ServiceStatus;
  }
}

// ServiceAccount binds together: * a name, understood by users, and perhaps by peripheral systems, for an identity * a principal that can be authenticated and authorized * a set of secrets
export class ServiceAccount implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted. Can be overridden at the pod level.
  public automountServiceAccountToken?: boolean;

  // ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount. ImagePullSecrets are distinct from Secrets because Secrets can be mounted in the pod, but ImagePullSecrets are only accessed by the kubelet. More info: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
  public imagePullSecrets?: LocalObjectReference[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Secrets is the list of secrets allowed to be used by pods running using this ServiceAccount. More info: https://kubernetes.io/docs/concepts/configuration/secret
  public secrets?: ObjectReference[];

  constructor(desc: ServiceAccount.Interface) {
    this.apiVersion = ServiceAccount.apiVersion;
    this.automountServiceAccountToken = desc.automountServiceAccountToken;
    this.imagePullSecrets = desc.imagePullSecrets;
    this.kind = ServiceAccount.kind;
    this.metadata = desc.metadata;
    this.secrets = desc.secrets;
  }
}

export function isServiceAccount(o: any): o is ServiceAccount {
  return (
    o &&
    o.apiVersion === ServiceAccount.apiVersion &&
    o.kind === ServiceAccount.kind
  );
}

export namespace ServiceAccount {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ServiceAccount";

  // named constructs a ServiceAccount with metadata.name set to name.
  export function named(name: string): ServiceAccount {
    return new ServiceAccount({ metadata: { name } });
  }
  // ServiceAccount binds together: * a name, understood by users, and perhaps by peripheral systems, for an identity * a principal that can be authenticated and authorized * a set of secrets
  export interface Interface {
    // AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted. Can be overridden at the pod level.
    automountServiceAccountToken?: boolean;

    // ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount. ImagePullSecrets are distinct from Secrets because Secrets can be mounted in the pod, but ImagePullSecrets are only accessed by the kubelet. More info: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
    imagePullSecrets?: LocalObjectReference[];

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Secrets is the list of secrets allowed to be used by pods running using this ServiceAccount. More info: https://kubernetes.io/docs/concepts/configuration/secret
    secrets?: ObjectReference[];
  }
}

// ServiceAccountList is a list of ServiceAccount objects
export class ServiceAccountList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of ServiceAccounts. More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  public items: ServiceAccount[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ServiceAccountList) {
    this.apiVersion = ServiceAccountList.apiVersion;
    this.items = desc.items.map(i => new ServiceAccount(i));
    this.kind = ServiceAccountList.kind;
    this.metadata = desc.metadata;
  }
}

export function isServiceAccountList(o: any): o is ServiceAccountList {
  return (
    o &&
    o.apiVersion === ServiceAccountList.apiVersion &&
    o.kind === ServiceAccountList.kind
  );
}

export namespace ServiceAccountList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ServiceAccountList";

  // ServiceAccountList is a list of ServiceAccount objects
  export interface Interface {
    // List of ServiceAccounts. More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
    items: ServiceAccount[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// ServiceAccountTokenProjection represents a projected service account token volume. This projection can be used to insert a service account token into the pods runtime filesystem for use against APIs (Kubernetes API Server or otherwise).
export class ServiceAccountTokenProjection {
  // Audience is the intended audience of the token. A recipient of a token must identify itself with an identifier specified in the audience of the token, and otherwise should reject the token. The audience defaults to the identifier of the apiserver.
  public audience?: string;

  // ExpirationSeconds is the requested duration of validity of the service account token. As the token approaches expiration, the kubelet volume plugin will proactively rotate the service account token. The kubelet will start trying to rotate the token if the token is older than 80 percent of its time to live or if the token is older than 24 hours.Defaults to 1 hour and must be at least 10 minutes.
  public expirationSeconds?: number;

  // Path is the path relative to the mount point of the file to project the token into.
  public path: string;

  constructor(desc: ServiceAccountTokenProjection) {
    this.audience = desc.audience;
    this.expirationSeconds = desc.expirationSeconds;
    this.path = desc.path;
  }
}

// ServiceList holds a list of services.
export class ServiceList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // List of services
  public items: Service[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ServiceList) {
    this.apiVersion = ServiceList.apiVersion;
    this.items = desc.items.map(i => new Service(i));
    this.kind = ServiceList.kind;
    this.metadata = desc.metadata;
  }
}

export function isServiceList(o: any): o is ServiceList {
  return (
    o && o.apiVersion === ServiceList.apiVersion && o.kind === ServiceList.kind
  );
}

export namespace ServiceList {
  export const apiVersion = "v1";
  export const group = "";
  export const version = "v1";
  export const kind = "ServiceList";

  // ServiceList holds a list of services.
  export interface Interface {
    // List of services
    items: Service[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
    metadata?: apisMetaV1.ListMeta;
  }
}

// ServicePort contains information on service's port.
export class ServicePort {
  // The name of this port within the service. This must be a DNS_LABEL. All ports within a ServiceSpec must have unique names. This maps to the 'Name' field in EndpointPort objects. Optional if only one ServicePort is defined on this service.
  public name?: string;

  // The port on each node on which this service is exposed when type=NodePort or LoadBalancer. Usually assigned by the system. If specified, it will be allocated to the service if unused or else creation of the service will fail. Default is to auto-allocate a port if the ServiceType of this Service requires one. More info: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
  public nodePort?: number;

  // The port that will be exposed by this service.
  public port: number;

  // The IP protocol for this port. Supports "TCP", "UDP", and "SCTP". Default is TCP.
  public protocol?: string;

  // Number or name of the port to access on the pods targeted by the service. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME. If this is a string, it will be looked up as a named port in the target Pod's container ports. If this is not specified, the value of the 'port' field is used (an identity map). This field is ignored for services with clusterIP=None, and should be omitted or set equal to the 'port' field. More info: https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service
  public targetPort?: pkgUtilIntstr.IntOrString;

  constructor(desc: ServicePort) {
    this.name = desc.name;
    this.nodePort = desc.nodePort;
    this.port = desc.port;
    this.protocol = desc.protocol;
    this.targetPort = desc.targetPort;
  }
}

// ServiceSpec describes the attributes that a user creates on a service.
export class ServiceSpec {
  // clusterIP is the IP address of the service and is usually assigned randomly by the master. If an address is specified manually and is not in use by others, it will be allocated to the service; otherwise, creation of the service will fail. This field can not be changed through updates. Valid values are "None", empty string (""), or a valid IP address. "None" can be specified for headless services when proxying is not required. Only applies to types ClusterIP, NodePort, and LoadBalancer. Ignored if type is ExternalName. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
  public clusterIP?: string;

  // externalIPs is a list of IP addresses for which nodes in the cluster will also accept traffic for this service.  These IPs are not managed by Kubernetes.  The user is responsible for ensuring that traffic arrives at a node with this IP.  A common example is external load-balancers that are not part of the Kubernetes system.
  public externalIPs?: string[];

  // externalName is the external reference that kubedns or equivalent will return as a CNAME record for this service. No proxying will be involved. Must be a valid RFC-1123 hostname (https://tools.ietf.org/html/rfc1123) and requires Type to be ExternalName.
  public externalName?: string;

  // externalTrafficPolicy denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints. "Local" preserves the client source IP and avoids a second hop for LoadBalancer and Nodeport type services, but risks potentially imbalanced traffic spreading. "Cluster" obscures the client source IP and may cause a second hop to another node, but should have good overall load-spreading.
  public externalTrafficPolicy?: string;

  // healthCheckNodePort specifies the healthcheck nodePort for the service. If not specified, HealthCheckNodePort is created by the service api backend with the allocated nodePort. Will use user-specified nodePort value if specified by the client. Only effects when Type is set to LoadBalancer and ExternalTrafficPolicy is set to Local.
  public healthCheckNodePort?: number;

  // Only applies to Service Type: LoadBalancer LoadBalancer will get created with the IP specified in this field. This feature depends on whether the underlying cloud-provider supports specifying the loadBalancerIP when a load balancer is created. This field will be ignored if the cloud-provider does not support the feature.
  public loadBalancerIP?: string;

  // If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature." More info: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/
  public loadBalancerSourceRanges?: string[];

  // The list of ports that are exposed by this service. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
  public ports?: ServicePort[];

  // publishNotReadyAddresses, when set to true, indicates that DNS implementations must publish the notReadyAddresses of subsets for the Endpoints associated with the Service. The default value is false. The primary use case for setting this field is to use a StatefulSet's Headless Service to propagate SRV records for its Pods without respect to their readiness for purpose of peer discovery.
  public publishNotReadyAddresses?: boolean;

  // Route service traffic to pods with label keys and values matching this selector. If empty or not present, the service is assumed to have an external process managing its endpoints, which Kubernetes will not modify. Only applies to types ClusterIP, NodePort, and LoadBalancer. Ignored if type is ExternalName. More info: https://kubernetes.io/docs/concepts/services-networking/service/
  public selector?: { [key: string]: string };

  // Supports "ClientIP" and "None". Used to maintain session affinity. Enable client IP based session affinity. Must be ClientIP or None. Defaults to None. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
  public sessionAffinity?: string;

  // sessionAffinityConfig contains the configurations of session affinity.
  public sessionAffinityConfig?: SessionAffinityConfig;

  // type determines how the Service is exposed. Defaults to ClusterIP. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. "ExternalName" maps to the specified externalName. "ClusterIP" allocates a cluster-internal IP address for load-balancing to endpoints. Endpoints are determined by the selector or if that is not specified, by manual construction of an Endpoints object. If clusterIP is "None", no virtual IP is allocated and the endpoints are published as a set of endpoints rather than a stable IP. "NodePort" builds on ClusterIP and allocates a port on every node which routes to the clusterIP. "LoadBalancer" builds on NodePort and creates an external load-balancer (if supported in the current cloud) which routes to the clusterIP. More info: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  public type?: string;
}

// ServiceStatus represents the current status of a service.
export class ServiceStatus {
  // LoadBalancer contains the current status of the load-balancer, if one is present.
  public loadBalancer?: LoadBalancerStatus;
}

// SessionAffinityConfig represents the configurations of session affinity.
export class SessionAffinityConfig {
  // clientIP contains the configurations of Client IP based session affinity.
  public clientIP?: ClientIPConfig;
}

// Represents a StorageOS persistent volume resource.
export class StorageOSPersistentVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
  public fsType?: string;

  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // SecretRef specifies the secret to use for obtaining the StorageOS API credentials.  If not specified, default values will be attempted.
  public secretRef?: ObjectReference;

  // VolumeName is the human-readable name of the StorageOS volume.  Volume names are only unique within a namespace.
  public volumeName?: string;

  // VolumeNamespace specifies the scope of the volume within StorageOS.  If no namespace is specified then the Pod's namespace will be used.  This allows the Kubernetes name scoping to be mirrored within StorageOS for tighter integration. Set VolumeName to any name to override the default behaviour. Set to "default" if you are not using namespaces within StorageOS. Namespaces that do not pre-exist within StorageOS will be created.
  public volumeNamespace?: string;
}

// Represents a StorageOS persistent volume resource.
export class StorageOSVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
  public fsType?: string;

  // Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.
  public readOnly?: boolean;

  // SecretRef specifies the secret to use for obtaining the StorageOS API credentials.  If not specified, default values will be attempted.
  public secretRef?: LocalObjectReference;

  // VolumeName is the human-readable name of the StorageOS volume.  Volume names are only unique within a namespace.
  public volumeName?: string;

  // VolumeNamespace specifies the scope of the volume within StorageOS.  If no namespace is specified then the Pod's namespace will be used.  This allows the Kubernetes name scoping to be mirrored within StorageOS for tighter integration. Set VolumeName to any name to override the default behaviour. Set to "default" if you are not using namespaces within StorageOS. Namespaces that do not pre-exist within StorageOS will be created.
  public volumeNamespace?: string;
}

// Sysctl defines a kernel parameter to be set
export class Sysctl {
  // Name of a property to set
  public name: string;

  // Value of a property to set
  public value: string;

  constructor(desc: Sysctl) {
    this.name = desc.name;
    this.value = desc.value;
  }
}

// TCPSocketAction describes an action based on opening a socket
export class TCPSocketAction {
  // Optional: Host name to connect to, defaults to the pod IP.
  public host?: string;

  // Number or name of the port to access on the container. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.
  public port: pkgUtilIntstr.IntOrString;

  constructor(desc: TCPSocketAction) {
    this.host = desc.host;
    this.port = desc.port;
  }
}

// The node this Taint is attached to has the "effect" on any pod that does not tolerate the Taint.
export class Taint {
  // Required. The effect of the taint on pods that do not tolerate the taint. Valid effects are NoSchedule, PreferNoSchedule and NoExecute.
  public effect: string;

  // Required. The taint key to be applied to a node.
  public key: string;

  // TimeAdded represents the time at which the taint was added. It is only written for NoExecute taints.
  public timeAdded?: apisMetaV1.Time;

  // Required. The taint value corresponding to the taint key.
  public value?: string;

  constructor(desc: Taint) {
    this.effect = desc.effect;
    this.key = desc.key;
    this.timeAdded = desc.timeAdded;
    this.value = desc.value;
  }
}

// The pod this Toleration is attached to tolerates any taint that matches the triple <key,value,effect> using the matching operator <operator>.
export class Toleration {
  // Effect indicates the taint effect to match. Empty means match all taint effects. When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.
  public effect?: string;

  // Key is the taint key that the toleration applies to. Empty means match all taint keys. If the key is empty, operator must be Exists; this combination means to match all values and all keys.
  public key?: string;

  // Operator represents a key's relationship to the value. Valid operators are Exists and Equal. Defaults to Equal. Exists is equivalent to wildcard for value, so that a pod can tolerate all taints of a particular category.
  public operator?: string;

  // TolerationSeconds represents the period of time the toleration (which must be of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default, it is not set, which means tolerate the taint forever (do not evict). Zero and negative values will be treated as 0 (evict immediately) by the system.
  public tolerationSeconds?: number;

  // Value is the taint value the toleration matches to. If the operator is Exists, the value should be empty, otherwise just a regular string.
  public value?: string;
}

// A topology selector requirement is a selector that matches given label. This is an alpha feature and may change in the future.
export class TopologySelectorLabelRequirement {
  // The label key that the selector applies to.
  public key: string;

  // An array of string values. One value must match the label to be selected. Each entry in Values is ORed.
  public values: string[];

  constructor(desc: TopologySelectorLabelRequirement) {
    this.key = desc.key;
    this.values = desc.values;
  }
}

// A topology selector term represents the result of label queries. A null or empty topology selector term matches no objects. The requirements of them are ANDed. It provides a subset of functionality as NodeSelectorTerm. This is an alpha feature and may change in the future.
export class TopologySelectorTerm {
  // A list of topology selector requirements by labels.
  public matchLabelExpressions?: TopologySelectorLabelRequirement[];
}

// TypedLocalObjectReference contains enough information to let you locate the typed referenced object inside the same namespace.
export class TypedLocalObjectReference {
  // APIGroup is the group for the resource being referenced. If APIGroup is not specified, the specified Kind must be in the core API group. For any other third-party types, APIGroup is required.
  public apiGroup?: string;

  // Kind is the type of resource being referenced
  public kind: string;

  // Name is the name of resource being referenced
  public name: string;

  constructor(desc: TypedLocalObjectReference) {
    this.apiGroup = desc.apiGroup;
    this.kind = desc.kind;
    this.name = desc.name;
  }
}

// Volume represents a named volume in a pod that may be accessed by any container in the pod.
export class Volume {
  // AWSElasticBlockStore represents an AWS Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
  public awsElasticBlockStore?: AWSElasticBlockStoreVolumeSource;

  // AzureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
  public azureDisk?: AzureDiskVolumeSource;

  // AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
  public azureFile?: AzureFileVolumeSource;

  // CephFS represents a Ceph FS mount on the host that shares a pod's lifetime
  public cephfs?: CephFSVolumeSource;

  // Cinder represents a cinder volume attached and mounted on kubelets host machine More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md
  public cinder?: CinderVolumeSource;

  // ConfigMap represents a configMap that should populate this volume
  public configMap?: ConfigMapVolumeSource;

  // CSI (Container Storage Interface) represents storage that is handled by an external CSI driver (Alpha feature).
  public csi?: CSIVolumeSource;

  // DownwardAPI represents downward API about the pod that should populate this volume
  public downwardAPI?: DownwardAPIVolumeSource;

  // EmptyDir represents a temporary directory that shares a pod's lifetime. More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir
  public emptyDir?: EmptyDirVolumeSource;

  // FC represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod.
  public fc?: FCVolumeSource;

  // FlexVolume represents a generic volume resource that is provisioned/attached using an exec based plugin.
  public flexVolume?: FlexVolumeSource;

  // Flocker represents a Flocker volume attached to a kubelet's host machine. This depends on the Flocker control service being running
  public flocker?: FlockerVolumeSource;

  // GCEPersistentDisk represents a GCE Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
  public gcePersistentDisk?: GCEPersistentDiskVolumeSource;

  // GitRepo represents a git repository at a particular revision. DEPRECATED: GitRepo is deprecated. To provision a container with a git repo, mount an EmptyDir into an InitContainer that clones the repo using git, then mount the EmptyDir into the Pod's container.
  public gitRepo?: GitRepoVolumeSource;

  // Glusterfs represents a Glusterfs mount on the host that shares a pod's lifetime. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md
  public glusterfs?: GlusterfsVolumeSource;

  // HostPath represents a pre-existing file or directory on the host machine that is directly exposed to the container. This is generally used for system agents or other privileged things that are allowed to see the host machine. Most containers will NOT need this. More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
  public hostPath?: HostPathVolumeSource;

  // ISCSI represents an ISCSI Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://releases.k8s.io/HEAD/examples/volumes/iscsi/README.md
  public iscsi?: ISCSIVolumeSource;

  // Volume's name. Must be a DNS_LABEL and unique within the pod. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  public name: string;

  // NFS represents an NFS mount on the host that shares a pod's lifetime More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
  public nfs?: NFSVolumeSource;

  // PersistentVolumeClaimVolumeSource represents a reference to a PersistentVolumeClaim in the same namespace. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
  public persistentVolumeClaim?: PersistentVolumeClaimVolumeSource;

  // PhotonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine
  public photonPersistentDisk?: PhotonPersistentDiskVolumeSource;

  // PortworxVolume represents a portworx volume attached and mounted on kubelets host machine
  public portworxVolume?: PortworxVolumeSource;

  // Items for all in one resources secrets, configmaps, and downward API
  public projected?: ProjectedVolumeSource;

  // Quobyte represents a Quobyte mount on the host that shares a pod's lifetime
  public quobyte?: QuobyteVolumeSource;

  // RBD represents a Rados Block Device mount on the host that shares a pod's lifetime. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md
  public rbd?: RBDVolumeSource;

  // ScaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.
  public scaleIO?: ScaleIOVolumeSource;

  // Secret represents a secret that should populate this volume. More info: https://kubernetes.io/docs/concepts/storage/volumes#secret
  public secret?: SecretVolumeSource;

  // StorageOS represents a StorageOS volume attached and mounted on Kubernetes nodes.
  public storageos?: StorageOSVolumeSource;

  // VsphereVolume represents a vSphere volume attached and mounted on kubelets host machine
  public vsphereVolume?: VsphereVirtualDiskVolumeSource;

  constructor(desc: Volume) {
    this.awsElasticBlockStore = desc.awsElasticBlockStore;
    this.azureDisk = desc.azureDisk;
    this.azureFile = desc.azureFile;
    this.cephfs = desc.cephfs;
    this.cinder = desc.cinder;
    this.configMap = desc.configMap;
    this.csi = desc.csi;
    this.downwardAPI = desc.downwardAPI;
    this.emptyDir = desc.emptyDir;
    this.fc = desc.fc;
    this.flexVolume = desc.flexVolume;
    this.flocker = desc.flocker;
    this.gcePersistentDisk = desc.gcePersistentDisk;
    this.gitRepo = desc.gitRepo;
    this.glusterfs = desc.glusterfs;
    this.hostPath = desc.hostPath;
    this.iscsi = desc.iscsi;
    this.name = desc.name;
    this.nfs = desc.nfs;
    this.persistentVolumeClaim = desc.persistentVolumeClaim;
    this.photonPersistentDisk = desc.photonPersistentDisk;
    this.portworxVolume = desc.portworxVolume;
    this.projected = desc.projected;
    this.quobyte = desc.quobyte;
    this.rbd = desc.rbd;
    this.scaleIO = desc.scaleIO;
    this.secret = desc.secret;
    this.storageos = desc.storageos;
    this.vsphereVolume = desc.vsphereVolume;
  }
}

// volumeDevice describes a mapping of a raw block device within a container.
export class VolumeDevice {
  // devicePath is the path inside of the container that the device will be mapped to.
  public devicePath: string;

  // name must match the name of a persistentVolumeClaim in the pod
  public name: string;

  constructor(desc: VolumeDevice) {
    this.devicePath = desc.devicePath;
    this.name = desc.name;
  }
}

// VolumeMount describes a mounting of a Volume within a container.
export class VolumeMount {
  // Path within the container at which the volume should be mounted.  Must not contain ':'.
  public mountPath: string;

  // mountPropagation determines how mounts are propagated from the host to container and the other way around. When not set, MountPropagationNone is used. This field is beta in 1.10.
  public mountPropagation?: string;

  // This must match the Name of a Volume.
  public name: string;

  // Mounted read-only if true, read-write otherwise (false or unspecified). Defaults to false.
  public readOnly?: boolean;

  // Path within the volume from which the container's volume should be mounted. Defaults to "" (volume's root).
  public subPath?: string;

  // Expanded path within the volume from which the container's volume should be mounted. Behaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment. Defaults to "" (volume's root). SubPathExpr and SubPath are mutually exclusive. This field is alpha in 1.14.
  public subPathExpr?: string;

  constructor(desc: VolumeMount) {
    this.mountPath = desc.mountPath;
    this.mountPropagation = desc.mountPropagation;
    this.name = desc.name;
    this.readOnly = desc.readOnly;
    this.subPath = desc.subPath;
    this.subPathExpr = desc.subPathExpr;
  }
}

// VolumeNodeAffinity defines constraints that limit what nodes this volume can be accessed from.
export class VolumeNodeAffinity {
  // Required specifies hard node constraints that must be met.
  public required?: NodeSelector;
}

// Projection that may be projected along with other supported volume types
export class VolumeProjection {
  // information about the configMap data to project
  public configMap?: ConfigMapProjection;

  // information about the downwardAPI data to project
  public downwardAPI?: DownwardAPIProjection;

  // information about the secret data to project
  public secret?: SecretProjection;

  // information about the serviceAccountToken data to project
  public serviceAccountToken?: ServiceAccountTokenProjection;
}

// Represents a vSphere volume resource.
export class VsphereVirtualDiskVolumeSource {
  // Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
  public fsType?: string;

  // Storage Policy Based Management (SPBM) profile ID associated with the StoragePolicyName.
  public storagePolicyID?: string;

  // Storage Policy Based Management (SPBM) profile name.
  public storagePolicyName?: string;

  // Path that identifies vSphere volume vmdk
  public volumePath: string;

  constructor(desc: VsphereVirtualDiskVolumeSource) {
    this.fsType = desc.fsType;
    this.storagePolicyID = desc.storagePolicyID;
    this.storagePolicyName = desc.storagePolicyName;
    this.volumePath = desc.volumePath;
  }
}

// The weights of all of the matched WeightedPodAffinityTerm fields are added per-node to find the most preferred node(s)
export class WeightedPodAffinityTerm {
  // Required. A pod affinity term, associated with the corresponding weight.
  public podAffinityTerm: PodAffinityTerm;

  // weight associated with matching the corresponding podAffinityTerm, in the range 1-100.
  public weight: number;

  constructor(desc: WeightedPodAffinityTerm) {
    this.podAffinityTerm = desc.podAffinityTerm;
    this.weight = desc.weight;
  }
}
