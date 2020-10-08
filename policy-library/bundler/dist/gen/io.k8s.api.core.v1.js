"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Represents a Persistent Disk resource in AWS.
//
// An AWS EBS disk must exist before mounting to a container. The disk must also be in the same AWS zone as the kubelet. An AWS EBS disk can only be mounted as read/write once. AWS EBS volumes support ownership management and SELinux relabeling.
class AWSElasticBlockStoreVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.partition = desc.partition;
        this.readOnly = desc.readOnly;
        this.volumeID = desc.volumeID;
    }
}
exports.AWSElasticBlockStoreVolumeSource = AWSElasticBlockStoreVolumeSource;
// Affinity is a group of affinity scheduling rules.
class Affinity {
}
exports.Affinity = Affinity;
// AttachedVolume describes a volume attached to a node
class AttachedVolume {
    constructor(desc) {
        this.devicePath = desc.devicePath;
        this.name = desc.name;
    }
}
exports.AttachedVolume = AttachedVolume;
// AzureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
class AzureDiskVolumeSource {
    constructor(desc) {
        this.cachingMode = desc.cachingMode;
        this.diskName = desc.diskName;
        this.diskURI = desc.diskURI;
        this.fsType = desc.fsType;
        this.kind = desc.kind;
        this.readOnly = desc.readOnly;
    }
}
exports.AzureDiskVolumeSource = AzureDiskVolumeSource;
// AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
class AzureFilePersistentVolumeSource {
    constructor(desc) {
        this.readOnly = desc.readOnly;
        this.secretName = desc.secretName;
        this.secretNamespace = desc.secretNamespace;
        this.shareName = desc.shareName;
    }
}
exports.AzureFilePersistentVolumeSource = AzureFilePersistentVolumeSource;
// AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
class AzureFileVolumeSource {
    constructor(desc) {
        this.readOnly = desc.readOnly;
        this.secretName = desc.secretName;
        this.shareName = desc.shareName;
    }
}
exports.AzureFileVolumeSource = AzureFileVolumeSource;
// Binding ties one object to another; for example, a pod is bound to a node by a scheduler. Deprecated in 1.7, please use the bindings subresource of pods instead.
class Binding {
    constructor(desc) {
        this.apiVersion = Binding.apiVersion;
        this.kind = Binding.kind;
        this.metadata = desc.metadata;
        this.target = desc.target;
    }
}
exports.Binding = Binding;
function isBinding(o) {
    return o && o.apiVersion === Binding.apiVersion && o.kind === Binding.kind;
}
exports.isBinding = isBinding;
(function (Binding) {
    Binding.apiVersion = "v1";
    Binding.group = "";
    Binding.version = "v1";
    Binding.kind = "Binding";
})(Binding = exports.Binding || (exports.Binding = {}));
// Represents storage that is managed by an external CSI volume driver (Beta feature)
class CSIPersistentVolumeSource {
    constructor(desc) {
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
exports.CSIPersistentVolumeSource = CSIPersistentVolumeSource;
// Represents a source location of a volume to mount, managed by an external CSI driver
class CSIVolumeSource {
    constructor(desc) {
        this.driver = desc.driver;
        this.fsType = desc.fsType;
        this.nodePublishSecretRef = desc.nodePublishSecretRef;
        this.readOnly = desc.readOnly;
        this.volumeAttributes = desc.volumeAttributes;
    }
}
exports.CSIVolumeSource = CSIVolumeSource;
// Adds and removes POSIX capabilities from running containers.
class Capabilities {
}
exports.Capabilities = Capabilities;
// Represents a Ceph Filesystem mount that lasts the lifetime of a pod Cephfs volumes do not support ownership management or SELinux relabeling.
class CephFSPersistentVolumeSource {
    constructor(desc) {
        this.monitors = desc.monitors;
        this.path = desc.path;
        this.readOnly = desc.readOnly;
        this.secretFile = desc.secretFile;
        this.secretRef = desc.secretRef;
        this.user = desc.user;
    }
}
exports.CephFSPersistentVolumeSource = CephFSPersistentVolumeSource;
// Represents a Ceph Filesystem mount that lasts the lifetime of a pod Cephfs volumes do not support ownership management or SELinux relabeling.
class CephFSVolumeSource {
    constructor(desc) {
        this.monitors = desc.monitors;
        this.path = desc.path;
        this.readOnly = desc.readOnly;
        this.secretFile = desc.secretFile;
        this.secretRef = desc.secretRef;
        this.user = desc.user;
    }
}
exports.CephFSVolumeSource = CephFSVolumeSource;
// Represents a cinder volume resource in Openstack. A Cinder volume must exist before mounting to a container. The volume must also be in the same region as the kubelet. Cinder volumes support ownership management and SELinux relabeling.
class CinderPersistentVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.readOnly = desc.readOnly;
        this.secretRef = desc.secretRef;
        this.volumeID = desc.volumeID;
    }
}
exports.CinderPersistentVolumeSource = CinderPersistentVolumeSource;
// Represents a cinder volume resource in Openstack. A Cinder volume must exist before mounting to a container. The volume must also be in the same region as the kubelet. Cinder volumes support ownership management and SELinux relabeling.
class CinderVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.readOnly = desc.readOnly;
        this.secretRef = desc.secretRef;
        this.volumeID = desc.volumeID;
    }
}
exports.CinderVolumeSource = CinderVolumeSource;
// ClientIPConfig represents the configurations of Client IP based session affinity.
class ClientIPConfig {
}
exports.ClientIPConfig = ClientIPConfig;
// Information about the condition of a component.
class ComponentCondition {
    constructor(desc) {
        this.error = desc.error;
        this.message = desc.message;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.ComponentCondition = ComponentCondition;
// ComponentStatus (and ComponentStatusList) holds the cluster validation info.
class ComponentStatus {
    constructor(desc) {
        this.apiVersion = ComponentStatus.apiVersion;
        this.conditions = desc.conditions;
        this.kind = ComponentStatus.kind;
        this.metadata = desc.metadata;
    }
}
exports.ComponentStatus = ComponentStatus;
function isComponentStatus(o) {
    return (o &&
        o.apiVersion === ComponentStatus.apiVersion &&
        o.kind === ComponentStatus.kind);
}
exports.isComponentStatus = isComponentStatus;
(function (ComponentStatus) {
    ComponentStatus.apiVersion = "v1";
    ComponentStatus.group = "";
    ComponentStatus.version = "v1";
    ComponentStatus.kind = "ComponentStatus";
    // named constructs a ComponentStatus with metadata.name set to name.
    function named(name) {
        return new ComponentStatus({ metadata: { name } });
    }
    ComponentStatus.named = named;
})(ComponentStatus = exports.ComponentStatus || (exports.ComponentStatus = {}));
// Status of all the conditions for the component as a list of ComponentStatus objects.
class ComponentStatusList {
    constructor(desc) {
        this.apiVersion = ComponentStatusList.apiVersion;
        this.items = desc.items.map(i => new ComponentStatus(i));
        this.kind = ComponentStatusList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ComponentStatusList = ComponentStatusList;
function isComponentStatusList(o) {
    return (o &&
        o.apiVersion === ComponentStatusList.apiVersion &&
        o.kind === ComponentStatusList.kind);
}
exports.isComponentStatusList = isComponentStatusList;
(function (ComponentStatusList) {
    ComponentStatusList.apiVersion = "v1";
    ComponentStatusList.group = "";
    ComponentStatusList.version = "v1";
    ComponentStatusList.kind = "ComponentStatusList";
})(ComponentStatusList = exports.ComponentStatusList || (exports.ComponentStatusList = {}));
// ConfigMap holds configuration data for pods to consume.
class ConfigMap {
    constructor(desc) {
        this.apiVersion = ConfigMap.apiVersion;
        this.binaryData = desc.binaryData;
        this.data = desc.data;
        this.kind = ConfigMap.kind;
        this.metadata = desc.metadata;
    }
}
exports.ConfigMap = ConfigMap;
function isConfigMap(o) {
    return (o && o.apiVersion === ConfigMap.apiVersion && o.kind === ConfigMap.kind);
}
exports.isConfigMap = isConfigMap;
(function (ConfigMap) {
    ConfigMap.apiVersion = "v1";
    ConfigMap.group = "";
    ConfigMap.version = "v1";
    ConfigMap.kind = "ConfigMap";
    // named constructs a ConfigMap with metadata.name set to name.
    function named(name) {
        return new ConfigMap({ metadata: { name } });
    }
    ConfigMap.named = named;
})(ConfigMap = exports.ConfigMap || (exports.ConfigMap = {}));
// ConfigMapEnvSource selects a ConfigMap to populate the environment variables with.
//
// The contents of the target ConfigMap's Data field will represent the key-value pairs as environment variables.
class ConfigMapEnvSource {
}
exports.ConfigMapEnvSource = ConfigMapEnvSource;
// Selects a key from a ConfigMap.
class ConfigMapKeySelector {
    constructor(desc) {
        this.key = desc.key;
        this.name = desc.name;
        this.optional = desc.optional;
    }
}
exports.ConfigMapKeySelector = ConfigMapKeySelector;
// ConfigMapList is a resource containing a list of ConfigMap objects.
class ConfigMapList {
    constructor(desc) {
        this.apiVersion = ConfigMapList.apiVersion;
        this.items = desc.items.map(i => new ConfigMap(i));
        this.kind = ConfigMapList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ConfigMapList = ConfigMapList;
function isConfigMapList(o) {
    return (o &&
        o.apiVersion === ConfigMapList.apiVersion &&
        o.kind === ConfigMapList.kind);
}
exports.isConfigMapList = isConfigMapList;
(function (ConfigMapList) {
    ConfigMapList.apiVersion = "v1";
    ConfigMapList.group = "";
    ConfigMapList.version = "v1";
    ConfigMapList.kind = "ConfigMapList";
})(ConfigMapList = exports.ConfigMapList || (exports.ConfigMapList = {}));
// ConfigMapNodeConfigSource contains the information to reference a ConfigMap as a config source for the Node.
class ConfigMapNodeConfigSource {
    constructor(desc) {
        this.kubeletConfigKey = desc.kubeletConfigKey;
        this.name = desc.name;
        this.namespace = desc.namespace;
        this.resourceVersion = desc.resourceVersion;
        this.uid = desc.uid;
    }
}
exports.ConfigMapNodeConfigSource = ConfigMapNodeConfigSource;
// Adapts a ConfigMap into a projected volume.
//
// The contents of the target ConfigMap's Data field will be presented in a projected volume as files using the keys in the Data field as the file names, unless the items element is populated with specific mappings of keys to paths. Note that this is identical to a configmap volume source without the default mode.
class ConfigMapProjection {
}
exports.ConfigMapProjection = ConfigMapProjection;
// Adapts a ConfigMap into a volume.
//
// The contents of the target ConfigMap's Data field will be presented in a volume as files using the keys in the Data field as the file names, unless the items element is populated with specific mappings of keys to paths. ConfigMap volumes support ownership management and SELinux relabeling.
class ConfigMapVolumeSource {
}
exports.ConfigMapVolumeSource = ConfigMapVolumeSource;
// A single application container that you want to run within a pod.
class Container {
    constructor(desc) {
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
exports.Container = Container;
// Describe a container image
class ContainerImage {
    constructor(desc) {
        this.names = desc.names;
        this.sizeBytes = desc.sizeBytes;
    }
}
exports.ContainerImage = ContainerImage;
// ContainerPort represents a network port in a single container.
class ContainerPort {
    constructor(desc) {
        this.containerPort = desc.containerPort;
        this.hostIP = desc.hostIP;
        this.hostPort = desc.hostPort;
        this.name = desc.name;
        this.protocol = desc.protocol;
    }
}
exports.ContainerPort = ContainerPort;
// ContainerState holds a possible state of container. Only one of its members may be specified. If none of them is specified, the default one is ContainerStateWaiting.
class ContainerState {
}
exports.ContainerState = ContainerState;
// ContainerStateRunning is a running state of a container.
class ContainerStateRunning {
}
exports.ContainerStateRunning = ContainerStateRunning;
// ContainerStateTerminated is a terminated state of a container.
class ContainerStateTerminated {
    constructor(desc) {
        this.containerID = desc.containerID;
        this.exitCode = desc.exitCode;
        this.finishedAt = desc.finishedAt;
        this.message = desc.message;
        this.reason = desc.reason;
        this.signal = desc.signal;
        this.startedAt = desc.startedAt;
    }
}
exports.ContainerStateTerminated = ContainerStateTerminated;
// ContainerStateWaiting is a waiting state of a container.
class ContainerStateWaiting {
}
exports.ContainerStateWaiting = ContainerStateWaiting;
// ContainerStatus contains details for the current status of this container.
class ContainerStatus {
    constructor(desc) {
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
exports.ContainerStatus = ContainerStatus;
// DaemonEndpoint contains information about a single Daemon endpoint.
class DaemonEndpoint {
    constructor(desc) {
        this.Port = desc.Port;
    }
}
exports.DaemonEndpoint = DaemonEndpoint;
// Represents downward API info for projecting into a projected volume. Note that this is identical to a downwardAPI volume source without the default mode.
class DownwardAPIProjection {
}
exports.DownwardAPIProjection = DownwardAPIProjection;
// DownwardAPIVolumeFile represents information to create the file containing the pod field
class DownwardAPIVolumeFile {
    constructor(desc) {
        this.fieldRef = desc.fieldRef;
        this.mode = desc.mode;
        this.path = desc.path;
        this.resourceFieldRef = desc.resourceFieldRef;
    }
}
exports.DownwardAPIVolumeFile = DownwardAPIVolumeFile;
// DownwardAPIVolumeSource represents a volume containing downward API info. Downward API volumes support ownership management and SELinux relabeling.
class DownwardAPIVolumeSource {
}
exports.DownwardAPIVolumeSource = DownwardAPIVolumeSource;
// Represents an empty directory for a pod. Empty directory volumes support ownership management and SELinux relabeling.
class EmptyDirVolumeSource {
}
exports.EmptyDirVolumeSource = EmptyDirVolumeSource;
// EndpointAddress is a tuple that describes single IP address.
class EndpointAddress {
    constructor(desc) {
        this.hostname = desc.hostname;
        this.ip = desc.ip;
        this.nodeName = desc.nodeName;
        this.targetRef = desc.targetRef;
    }
}
exports.EndpointAddress = EndpointAddress;
// EndpointPort is a tuple that describes a single port.
class EndpointPort {
    constructor(desc) {
        this.name = desc.name;
        this.port = desc.port;
        this.protocol = desc.protocol;
    }
}
exports.EndpointPort = EndpointPort;
// EndpointSubset is a group of addresses with a common set of ports. The expanded set of endpoints is the Cartesian product of Addresses x Ports. For example, given:
//   {
//     Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
//     Ports:     [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
//   }
// The resulting set of endpoints can be viewed as:
//     a: [ 10.10.1.1:8675, 10.10.2.2:8675 ],
//     b: [ 10.10.1.1:309, 10.10.2.2:309 ]
class EndpointSubset {
}
exports.EndpointSubset = EndpointSubset;
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
class Endpoints {
    constructor(desc) {
        this.apiVersion = Endpoints.apiVersion;
        this.kind = Endpoints.kind;
        this.metadata = desc.metadata;
        this.subsets = desc.subsets;
    }
}
exports.Endpoints = Endpoints;
function isEndpoints(o) {
    return (o && o.apiVersion === Endpoints.apiVersion && o.kind === Endpoints.kind);
}
exports.isEndpoints = isEndpoints;
(function (Endpoints) {
    Endpoints.apiVersion = "v1";
    Endpoints.group = "";
    Endpoints.version = "v1";
    Endpoints.kind = "Endpoints";
    // named constructs a Endpoints with metadata.name set to name.
    function named(name) {
        return new Endpoints({ metadata: { name } });
    }
    Endpoints.named = named;
})(Endpoints = exports.Endpoints || (exports.Endpoints = {}));
// EndpointsList is a list of endpoints.
class EndpointsList {
    constructor(desc) {
        this.apiVersion = EndpointsList.apiVersion;
        this.items = desc.items.map(i => new Endpoints(i));
        this.kind = EndpointsList.kind;
        this.metadata = desc.metadata;
    }
}
exports.EndpointsList = EndpointsList;
function isEndpointsList(o) {
    return (o &&
        o.apiVersion === EndpointsList.apiVersion &&
        o.kind === EndpointsList.kind);
}
exports.isEndpointsList = isEndpointsList;
(function (EndpointsList) {
    EndpointsList.apiVersion = "v1";
    EndpointsList.group = "";
    EndpointsList.version = "v1";
    EndpointsList.kind = "EndpointsList";
})(EndpointsList = exports.EndpointsList || (exports.EndpointsList = {}));
// EnvFromSource represents the source of a set of ConfigMaps
class EnvFromSource {
}
exports.EnvFromSource = EnvFromSource;
// EnvVar represents an environment variable present in a Container.
class EnvVar {
    constructor(desc) {
        this.name = desc.name;
        this.value = desc.value;
        this.valueFrom = desc.valueFrom;
    }
}
exports.EnvVar = EnvVar;
// EnvVarSource represents a source for the value of an EnvVar.
class EnvVarSource {
}
exports.EnvVarSource = EnvVarSource;
// Event is a report of an event somewhere in the cluster.
class Event {
    constructor(desc) {
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
exports.Event = Event;
function isEvent(o) {
    return o && o.apiVersion === Event.apiVersion && o.kind === Event.kind;
}
exports.isEvent = isEvent;
(function (Event) {
    Event.apiVersion = "v1";
    Event.group = "";
    Event.version = "v1";
    Event.kind = "Event";
})(Event = exports.Event || (exports.Event = {}));
// EventList is a list of events.
class EventList {
    constructor(desc) {
        this.apiVersion = EventList.apiVersion;
        this.items = desc.items.map(i => new Event(i));
        this.kind = EventList.kind;
        this.metadata = desc.metadata;
    }
}
exports.EventList = EventList;
function isEventList(o) {
    return (o && o.apiVersion === EventList.apiVersion && o.kind === EventList.kind);
}
exports.isEventList = isEventList;
(function (EventList) {
    EventList.apiVersion = "v1";
    EventList.group = "";
    EventList.version = "v1";
    EventList.kind = "EventList";
})(EventList = exports.EventList || (exports.EventList = {}));
// EventSeries contain information on series of events, i.e. thing that was/is happening continuously for some time.
class EventSeries {
}
exports.EventSeries = EventSeries;
// EventSource contains information for an event.
class EventSource {
}
exports.EventSource = EventSource;
// ExecAction describes a "run in container" action.
class ExecAction {
}
exports.ExecAction = ExecAction;
// Represents a Fibre Channel volume. Fibre Channel volumes can only be mounted as read/write once. Fibre Channel volumes support ownership management and SELinux relabeling.
class FCVolumeSource {
}
exports.FCVolumeSource = FCVolumeSource;
// FlexPersistentVolumeSource represents a generic persistent volume resource that is provisioned/attached using an exec based plugin.
class FlexPersistentVolumeSource {
    constructor(desc) {
        this.driver = desc.driver;
        this.fsType = desc.fsType;
        this.options = desc.options;
        this.readOnly = desc.readOnly;
        this.secretRef = desc.secretRef;
    }
}
exports.FlexPersistentVolumeSource = FlexPersistentVolumeSource;
// FlexVolume represents a generic volume resource that is provisioned/attached using an exec based plugin.
class FlexVolumeSource {
    constructor(desc) {
        this.driver = desc.driver;
        this.fsType = desc.fsType;
        this.options = desc.options;
        this.readOnly = desc.readOnly;
        this.secretRef = desc.secretRef;
    }
}
exports.FlexVolumeSource = FlexVolumeSource;
// Represents a Flocker volume mounted by the Flocker agent. One and only one of datasetName and datasetUUID should be set. Flocker volumes do not support ownership management or SELinux relabeling.
class FlockerVolumeSource {
}
exports.FlockerVolumeSource = FlockerVolumeSource;
// Represents a Persistent Disk resource in Google Compute Engine.
//
// A GCE PD must exist before mounting to a container. The disk must also be in the same GCE project and zone as the kubelet. A GCE PD can only be mounted as read/write once or read-only many times. GCE PDs support ownership management and SELinux relabeling.
class GCEPersistentDiskVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.partition = desc.partition;
        this.pdName = desc.pdName;
        this.readOnly = desc.readOnly;
    }
}
exports.GCEPersistentDiskVolumeSource = GCEPersistentDiskVolumeSource;
// Represents a volume that is populated with the contents of a git repository. Git repo volumes do not support ownership management. Git repo volumes support SELinux relabeling.
//
// DEPRECATED: GitRepo is deprecated. To provision a container with a git repo, mount an EmptyDir into an InitContainer that clones the repo using git, then mount the EmptyDir into the Pod's container.
class GitRepoVolumeSource {
    constructor(desc) {
        this.directory = desc.directory;
        this.repository = desc.repository;
        this.revision = desc.revision;
    }
}
exports.GitRepoVolumeSource = GitRepoVolumeSource;
// Represents a Glusterfs mount that lasts the lifetime of a pod. Glusterfs volumes do not support ownership management or SELinux relabeling.
class GlusterfsPersistentVolumeSource {
    constructor(desc) {
        this.endpoints = desc.endpoints;
        this.endpointsNamespace = desc.endpointsNamespace;
        this.path = desc.path;
        this.readOnly = desc.readOnly;
    }
}
exports.GlusterfsPersistentVolumeSource = GlusterfsPersistentVolumeSource;
// Represents a Glusterfs mount that lasts the lifetime of a pod. Glusterfs volumes do not support ownership management or SELinux relabeling.
class GlusterfsVolumeSource {
    constructor(desc) {
        this.endpoints = desc.endpoints;
        this.path = desc.path;
        this.readOnly = desc.readOnly;
    }
}
exports.GlusterfsVolumeSource = GlusterfsVolumeSource;
// HTTPGetAction describes an action based on HTTP Get requests.
class HTTPGetAction {
    constructor(desc) {
        this.host = desc.host;
        this.httpHeaders = desc.httpHeaders;
        this.path = desc.path;
        this.port = desc.port;
        this.scheme = desc.scheme;
    }
}
exports.HTTPGetAction = HTTPGetAction;
// HTTPHeader describes a custom header to be used in HTTP probes
class HTTPHeader {
    constructor(desc) {
        this.name = desc.name;
        this.value = desc.value;
    }
}
exports.HTTPHeader = HTTPHeader;
// Handler defines a specific action that should be taken
class Handler {
}
exports.Handler = Handler;
// HostAlias holds the mapping between IP and hostnames that will be injected as an entry in the pod's hosts file.
class HostAlias {
}
exports.HostAlias = HostAlias;
// Represents a host path mapped into a pod. Host path volumes do not support ownership management or SELinux relabeling.
class HostPathVolumeSource {
    constructor(desc) {
        this.path = desc.path;
        this.type = desc.type;
    }
}
exports.HostPathVolumeSource = HostPathVolumeSource;
// ISCSIPersistentVolumeSource represents an ISCSI disk. ISCSI volumes can only be mounted as read/write once. ISCSI volumes support ownership management and SELinux relabeling.
class ISCSIPersistentVolumeSource {
    constructor(desc) {
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
exports.ISCSIPersistentVolumeSource = ISCSIPersistentVolumeSource;
// Represents an ISCSI disk. ISCSI volumes can only be mounted as read/write once. ISCSI volumes support ownership management and SELinux relabeling.
class ISCSIVolumeSource {
    constructor(desc) {
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
exports.ISCSIVolumeSource = ISCSIVolumeSource;
// Maps a string key to a path within a volume.
class KeyToPath {
    constructor(desc) {
        this.key = desc.key;
        this.mode = desc.mode;
        this.path = desc.path;
    }
}
exports.KeyToPath = KeyToPath;
// Lifecycle describes actions that the management system should take in response to container lifecycle events. For the PostStart and PreStop lifecycle handlers, management of the container blocks until the action is complete, unless the container process fails, in which case the handler is aborted.
class Lifecycle {
}
exports.Lifecycle = Lifecycle;
// LimitRange sets resource usage limits for each kind of resource in a Namespace.
class LimitRange {
    constructor(desc) {
        this.apiVersion = LimitRange.apiVersion;
        this.kind = LimitRange.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
    }
}
exports.LimitRange = LimitRange;
function isLimitRange(o) {
    return (o && o.apiVersion === LimitRange.apiVersion && o.kind === LimitRange.kind);
}
exports.isLimitRange = isLimitRange;
(function (LimitRange) {
    LimitRange.apiVersion = "v1";
    LimitRange.group = "";
    LimitRange.version = "v1";
    LimitRange.kind = "LimitRange";
    // named constructs a LimitRange with metadata.name set to name.
    function named(name) {
        return new LimitRange({ metadata: { name } });
    }
    LimitRange.named = named;
})(LimitRange = exports.LimitRange || (exports.LimitRange = {}));
// LimitRangeItem defines a min/max usage limit for any resource that matches on kind.
class LimitRangeItem {
}
exports.LimitRangeItem = LimitRangeItem;
// LimitRangeList is a list of LimitRange items.
class LimitRangeList {
    constructor(desc) {
        this.apiVersion = LimitRangeList.apiVersion;
        this.items = desc.items.map(i => new LimitRange(i));
        this.kind = LimitRangeList.kind;
        this.metadata = desc.metadata;
    }
}
exports.LimitRangeList = LimitRangeList;
function isLimitRangeList(o) {
    return (o &&
        o.apiVersion === LimitRangeList.apiVersion &&
        o.kind === LimitRangeList.kind);
}
exports.isLimitRangeList = isLimitRangeList;
(function (LimitRangeList) {
    LimitRangeList.apiVersion = "v1";
    LimitRangeList.group = "";
    LimitRangeList.version = "v1";
    LimitRangeList.kind = "LimitRangeList";
})(LimitRangeList = exports.LimitRangeList || (exports.LimitRangeList = {}));
// LimitRangeSpec defines a min/max usage limit for resources that match on kind.
class LimitRangeSpec {
    constructor(desc) {
        this.limits = desc.limits;
    }
}
exports.LimitRangeSpec = LimitRangeSpec;
// LoadBalancerIngress represents the status of a load-balancer ingress point: traffic intended for the service should be sent to an ingress point.
class LoadBalancerIngress {
}
exports.LoadBalancerIngress = LoadBalancerIngress;
// LoadBalancerStatus represents the status of a load-balancer.
class LoadBalancerStatus {
}
exports.LoadBalancerStatus = LoadBalancerStatus;
// LocalObjectReference contains enough information to let you locate the referenced object inside the same namespace.
class LocalObjectReference {
}
exports.LocalObjectReference = LocalObjectReference;
// Local represents directly-attached storage with node affinity (Beta feature)
class LocalVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.path = desc.path;
    }
}
exports.LocalVolumeSource = LocalVolumeSource;
// Represents an NFS mount that lasts the lifetime of a pod. NFS volumes do not support ownership management or SELinux relabeling.
class NFSVolumeSource {
    constructor(desc) {
        this.path = desc.path;
        this.readOnly = desc.readOnly;
        this.server = desc.server;
    }
}
exports.NFSVolumeSource = NFSVolumeSource;
// Namespace provides a scope for Names. Use of multiple namespaces is optional.
class Namespace {
    constructor(desc) {
        this.apiVersion = Namespace.apiVersion;
        this.kind = Namespace.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Namespace = Namespace;
function isNamespace(o) {
    return (o && o.apiVersion === Namespace.apiVersion && o.kind === Namespace.kind);
}
exports.isNamespace = isNamespace;
(function (Namespace) {
    Namespace.apiVersion = "v1";
    Namespace.group = "";
    Namespace.version = "v1";
    Namespace.kind = "Namespace";
    // named constructs a Namespace with metadata.name set to name.
    function named(name) {
        return new Namespace({ metadata: { name } });
    }
    Namespace.named = named;
})(Namespace = exports.Namespace || (exports.Namespace = {}));
// NamespaceList is a list of Namespaces.
class NamespaceList {
    constructor(desc) {
        this.apiVersion = NamespaceList.apiVersion;
        this.items = desc.items.map(i => new Namespace(i));
        this.kind = NamespaceList.kind;
        this.metadata = desc.metadata;
    }
}
exports.NamespaceList = NamespaceList;
function isNamespaceList(o) {
    return (o &&
        o.apiVersion === NamespaceList.apiVersion &&
        o.kind === NamespaceList.kind);
}
exports.isNamespaceList = isNamespaceList;
(function (NamespaceList) {
    NamespaceList.apiVersion = "v1";
    NamespaceList.group = "";
    NamespaceList.version = "v1";
    NamespaceList.kind = "NamespaceList";
})(NamespaceList = exports.NamespaceList || (exports.NamespaceList = {}));
// NamespaceSpec describes the attributes on a Namespace.
class NamespaceSpec {
}
exports.NamespaceSpec = NamespaceSpec;
// NamespaceStatus is information about the current status of a Namespace.
class NamespaceStatus {
}
exports.NamespaceStatus = NamespaceStatus;
// Node is a worker node in Kubernetes. Each node will have a unique identifier in the cache (i.e. in etcd).
class Node {
    constructor(desc) {
        this.apiVersion = Node.apiVersion;
        this.kind = Node.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Node = Node;
function isNode(o) {
    return o && o.apiVersion === Node.apiVersion && o.kind === Node.kind;
}
exports.isNode = isNode;
(function (Node) {
    Node.apiVersion = "v1";
    Node.group = "";
    Node.version = "v1";
    Node.kind = "Node";
    // named constructs a Node with metadata.name set to name.
    function named(name) {
        return new Node({ metadata: { name } });
    }
    Node.named = named;
})(Node = exports.Node || (exports.Node = {}));
// NodeAddress contains information for the node's address.
class NodeAddress {
    constructor(desc) {
        this.address = desc.address;
        this.type = desc.type;
    }
}
exports.NodeAddress = NodeAddress;
// Node affinity is a group of node affinity scheduling rules.
class NodeAffinity {
}
exports.NodeAffinity = NodeAffinity;
// NodeCondition contains condition information for a node.
class NodeCondition {
    constructor(desc) {
        this.lastHeartbeatTime = desc.lastHeartbeatTime;
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.NodeCondition = NodeCondition;
// NodeConfigSource specifies a source of node configuration. Exactly one subfield (excluding metadata) must be non-nil.
class NodeConfigSource {
}
exports.NodeConfigSource = NodeConfigSource;
// NodeConfigStatus describes the status of the config assigned by Node.Spec.ConfigSource.
class NodeConfigStatus {
}
exports.NodeConfigStatus = NodeConfigStatus;
// NodeDaemonEndpoints lists ports opened by daemons running on the Node.
class NodeDaemonEndpoints {
}
exports.NodeDaemonEndpoints = NodeDaemonEndpoints;
// NodeList is the whole list of all Nodes which have been registered with master.
class NodeList {
    constructor(desc) {
        this.apiVersion = NodeList.apiVersion;
        this.items = desc.items.map(i => new Node(i));
        this.kind = NodeList.kind;
        this.metadata = desc.metadata;
    }
}
exports.NodeList = NodeList;
function isNodeList(o) {
    return o && o.apiVersion === NodeList.apiVersion && o.kind === NodeList.kind;
}
exports.isNodeList = isNodeList;
(function (NodeList) {
    NodeList.apiVersion = "v1";
    NodeList.group = "";
    NodeList.version = "v1";
    NodeList.kind = "NodeList";
})(NodeList = exports.NodeList || (exports.NodeList = {}));
// A node selector represents the union of the results of one or more label queries over a set of nodes; that is, it represents the OR of the selectors represented by the node selector terms.
class NodeSelector {
    constructor(desc) {
        this.nodeSelectorTerms = desc.nodeSelectorTerms;
    }
}
exports.NodeSelector = NodeSelector;
// A node selector requirement is a selector that contains values, a key, and an operator that relates the key and values.
class NodeSelectorRequirement {
    constructor(desc) {
        this.key = desc.key;
        this.operator = desc.operator;
        this.values = desc.values;
    }
}
exports.NodeSelectorRequirement = NodeSelectorRequirement;
// A null or empty node selector term matches no objects. The requirements of them are ANDed. The TopologySelectorTerm type implements a subset of the NodeSelectorTerm.
class NodeSelectorTerm {
}
exports.NodeSelectorTerm = NodeSelectorTerm;
// NodeSpec describes the attributes that a node is created with.
class NodeSpec {
}
exports.NodeSpec = NodeSpec;
// NodeStatus is information about the current status of a node.
class NodeStatus {
}
exports.NodeStatus = NodeStatus;
// NodeSystemInfo is a set of ids/uuids to uniquely identify the node.
class NodeSystemInfo {
    constructor(desc) {
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
exports.NodeSystemInfo = NodeSystemInfo;
// ObjectFieldSelector selects an APIVersioned field of an object.
class ObjectFieldSelector {
    constructor(desc) {
        this.apiVersion = desc.apiVersion;
        this.fieldPath = desc.fieldPath;
    }
}
exports.ObjectFieldSelector = ObjectFieldSelector;
// ObjectReference contains enough information to let you inspect or modify the referred object.
class ObjectReference {
}
exports.ObjectReference = ObjectReference;
// PersistentVolume (PV) is a storage resource provisioned by an administrator. It is analogous to a node. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes
class PersistentVolume {
    constructor(desc) {
        this.apiVersion = PersistentVolume.apiVersion;
        this.kind = PersistentVolume.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.PersistentVolume = PersistentVolume;
function isPersistentVolume(o) {
    return (o &&
        o.apiVersion === PersistentVolume.apiVersion &&
        o.kind === PersistentVolume.kind);
}
exports.isPersistentVolume = isPersistentVolume;
(function (PersistentVolume) {
    PersistentVolume.apiVersion = "v1";
    PersistentVolume.group = "";
    PersistentVolume.version = "v1";
    PersistentVolume.kind = "PersistentVolume";
    // named constructs a PersistentVolume with metadata.name set to name.
    function named(name) {
        return new PersistentVolume({ metadata: { name } });
    }
    PersistentVolume.named = named;
})(PersistentVolume = exports.PersistentVolume || (exports.PersistentVolume = {}));
// PersistentVolumeClaim is a user's request for and claim to a persistent volume
class PersistentVolumeClaim {
    constructor(desc) {
        this.apiVersion = PersistentVolumeClaim.apiVersion;
        this.kind = PersistentVolumeClaim.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.PersistentVolumeClaim = PersistentVolumeClaim;
function isPersistentVolumeClaim(o) {
    return (o &&
        o.apiVersion === PersistentVolumeClaim.apiVersion &&
        o.kind === PersistentVolumeClaim.kind);
}
exports.isPersistentVolumeClaim = isPersistentVolumeClaim;
(function (PersistentVolumeClaim) {
    PersistentVolumeClaim.apiVersion = "v1";
    PersistentVolumeClaim.group = "";
    PersistentVolumeClaim.version = "v1";
    PersistentVolumeClaim.kind = "PersistentVolumeClaim";
    // named constructs a PersistentVolumeClaim with metadata.name set to name.
    function named(name) {
        return new PersistentVolumeClaim({ metadata: { name } });
    }
    PersistentVolumeClaim.named = named;
})(PersistentVolumeClaim = exports.PersistentVolumeClaim || (exports.PersistentVolumeClaim = {}));
// PersistentVolumeClaimCondition contails details about state of pvc
class PersistentVolumeClaimCondition {
    constructor(desc) {
        this.lastProbeTime = desc.lastProbeTime;
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.PersistentVolumeClaimCondition = PersistentVolumeClaimCondition;
// PersistentVolumeClaimList is a list of PersistentVolumeClaim items.
class PersistentVolumeClaimList {
    constructor(desc) {
        this.apiVersion = PersistentVolumeClaimList.apiVersion;
        this.items = desc.items.map(i => new PersistentVolumeClaim(i));
        this.kind = PersistentVolumeClaimList.kind;
        this.metadata = desc.metadata;
    }
}
exports.PersistentVolumeClaimList = PersistentVolumeClaimList;
function isPersistentVolumeClaimList(o) {
    return (o &&
        o.apiVersion === PersistentVolumeClaimList.apiVersion &&
        o.kind === PersistentVolumeClaimList.kind);
}
exports.isPersistentVolumeClaimList = isPersistentVolumeClaimList;
(function (PersistentVolumeClaimList) {
    PersistentVolumeClaimList.apiVersion = "v1";
    PersistentVolumeClaimList.group = "";
    PersistentVolumeClaimList.version = "v1";
    PersistentVolumeClaimList.kind = "PersistentVolumeClaimList";
})(PersistentVolumeClaimList = exports.PersistentVolumeClaimList || (exports.PersistentVolumeClaimList = {}));
// PersistentVolumeClaimSpec describes the common attributes of storage devices and allows a Source for provider-specific attributes
class PersistentVolumeClaimSpec {
}
exports.PersistentVolumeClaimSpec = PersistentVolumeClaimSpec;
// PersistentVolumeClaimStatus is the current status of a persistent volume claim.
class PersistentVolumeClaimStatus {
}
exports.PersistentVolumeClaimStatus = PersistentVolumeClaimStatus;
// PersistentVolumeClaimVolumeSource references the user's PVC in the same namespace. This volume finds the bound PV and mounts that volume for the pod. A PersistentVolumeClaimVolumeSource is, essentially, a wrapper around another type of volume that is owned by someone else (the system).
class PersistentVolumeClaimVolumeSource {
    constructor(desc) {
        this.claimName = desc.claimName;
        this.readOnly = desc.readOnly;
    }
}
exports.PersistentVolumeClaimVolumeSource = PersistentVolumeClaimVolumeSource;
// PersistentVolumeList is a list of PersistentVolume items.
class PersistentVolumeList {
    constructor(desc) {
        this.apiVersion = PersistentVolumeList.apiVersion;
        this.items = desc.items.map(i => new PersistentVolume(i));
        this.kind = PersistentVolumeList.kind;
        this.metadata = desc.metadata;
    }
}
exports.PersistentVolumeList = PersistentVolumeList;
function isPersistentVolumeList(o) {
    return (o &&
        o.apiVersion === PersistentVolumeList.apiVersion &&
        o.kind === PersistentVolumeList.kind);
}
exports.isPersistentVolumeList = isPersistentVolumeList;
(function (PersistentVolumeList) {
    PersistentVolumeList.apiVersion = "v1";
    PersistentVolumeList.group = "";
    PersistentVolumeList.version = "v1";
    PersistentVolumeList.kind = "PersistentVolumeList";
})(PersistentVolumeList = exports.PersistentVolumeList || (exports.PersistentVolumeList = {}));
// PersistentVolumeSpec is the specification of a persistent volume.
class PersistentVolumeSpec {
}
exports.PersistentVolumeSpec = PersistentVolumeSpec;
// PersistentVolumeStatus is the current status of a persistent volume.
class PersistentVolumeStatus {
}
exports.PersistentVolumeStatus = PersistentVolumeStatus;
// Represents a Photon Controller persistent disk resource.
class PhotonPersistentDiskVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.pdID = desc.pdID;
    }
}
exports.PhotonPersistentDiskVolumeSource = PhotonPersistentDiskVolumeSource;
// Pod is a collection of containers that can run on a host. This resource is created by clients and scheduled onto hosts.
class Pod {
    constructor(desc) {
        this.apiVersion = Pod.apiVersion;
        this.kind = Pod.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Pod = Pod;
function isPod(o) {
    return o && o.apiVersion === Pod.apiVersion && o.kind === Pod.kind;
}
exports.isPod = isPod;
(function (Pod) {
    Pod.apiVersion = "v1";
    Pod.group = "";
    Pod.version = "v1";
    Pod.kind = "Pod";
    // named constructs a Pod with metadata.name set to name.
    function named(name) {
        return new Pod({ metadata: { name } });
    }
    Pod.named = named;
})(Pod = exports.Pod || (exports.Pod = {}));
// Pod affinity is a group of inter pod affinity scheduling rules.
class PodAffinity {
}
exports.PodAffinity = PodAffinity;
// Defines a set of pods (namely those matching the labelSelector relative to the given namespace(s)) that this pod should be co-located (affinity) or not co-located (anti-affinity) with, where co-located is defined as running on a node whose value of the label with key <topologyKey> matches that of any node on which a pod of the set of pods is running
class PodAffinityTerm {
    constructor(desc) {
        this.labelSelector = desc.labelSelector;
        this.namespaces = desc.namespaces;
        this.topologyKey = desc.topologyKey;
    }
}
exports.PodAffinityTerm = PodAffinityTerm;
// Pod anti affinity is a group of inter pod anti affinity scheduling rules.
class PodAntiAffinity {
}
exports.PodAntiAffinity = PodAntiAffinity;
// PodCondition contains details for the current condition of this pod.
class PodCondition {
    constructor(desc) {
        this.lastProbeTime = desc.lastProbeTime;
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.PodCondition = PodCondition;
// PodDNSConfig defines the DNS parameters of a pod in addition to those generated from DNSPolicy.
class PodDNSConfig {
}
exports.PodDNSConfig = PodDNSConfig;
// PodDNSConfigOption defines DNS resolver options of a pod.
class PodDNSConfigOption {
}
exports.PodDNSConfigOption = PodDNSConfigOption;
// PodList is a list of Pods.
class PodList {
    constructor(desc) {
        this.apiVersion = PodList.apiVersion;
        this.items = desc.items.map(i => new Pod(i));
        this.kind = PodList.kind;
        this.metadata = desc.metadata;
    }
}
exports.PodList = PodList;
function isPodList(o) {
    return o && o.apiVersion === PodList.apiVersion && o.kind === PodList.kind;
}
exports.isPodList = isPodList;
(function (PodList) {
    PodList.apiVersion = "v1";
    PodList.group = "";
    PodList.version = "v1";
    PodList.kind = "PodList";
})(PodList = exports.PodList || (exports.PodList = {}));
// PodReadinessGate contains the reference to a pod condition
class PodReadinessGate {
    constructor(desc) {
        this.conditionType = desc.conditionType;
    }
}
exports.PodReadinessGate = PodReadinessGate;
// PodSecurityContext holds pod-level security attributes and common container settings. Some fields are also present in container.securityContext.  Field values of container.securityContext take precedence over field values of PodSecurityContext.
class PodSecurityContext {
}
exports.PodSecurityContext = PodSecurityContext;
// PodSpec is a description of a pod.
class PodSpec {
    constructor(desc) {
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
exports.PodSpec = PodSpec;
// PodStatus represents information about the status of a pod. Status may trail the actual state of a system, especially if the node that hosts the pod cannot contact the control plane.
class PodStatus {
}
exports.PodStatus = PodStatus;
// PodTemplate describes a template for creating copies of a predefined pod.
class PodTemplate {
    constructor(desc) {
        this.apiVersion = PodTemplate.apiVersion;
        this.kind = PodTemplate.kind;
        this.metadata = desc.metadata;
        this.template = desc.template;
    }
}
exports.PodTemplate = PodTemplate;
function isPodTemplate(o) {
    return (o && o.apiVersion === PodTemplate.apiVersion && o.kind === PodTemplate.kind);
}
exports.isPodTemplate = isPodTemplate;
(function (PodTemplate) {
    PodTemplate.apiVersion = "v1";
    PodTemplate.group = "";
    PodTemplate.version = "v1";
    PodTemplate.kind = "PodTemplate";
    // named constructs a PodTemplate with metadata.name set to name.
    function named(name) {
        return new PodTemplate({ metadata: { name } });
    }
    PodTemplate.named = named;
})(PodTemplate = exports.PodTemplate || (exports.PodTemplate = {}));
// PodTemplateList is a list of PodTemplates.
class PodTemplateList {
    constructor(desc) {
        this.apiVersion = PodTemplateList.apiVersion;
        this.items = desc.items.map(i => new PodTemplate(i));
        this.kind = PodTemplateList.kind;
        this.metadata = desc.metadata;
    }
}
exports.PodTemplateList = PodTemplateList;
function isPodTemplateList(o) {
    return (o &&
        o.apiVersion === PodTemplateList.apiVersion &&
        o.kind === PodTemplateList.kind);
}
exports.isPodTemplateList = isPodTemplateList;
(function (PodTemplateList) {
    PodTemplateList.apiVersion = "v1";
    PodTemplateList.group = "";
    PodTemplateList.version = "v1";
    PodTemplateList.kind = "PodTemplateList";
})(PodTemplateList = exports.PodTemplateList || (exports.PodTemplateList = {}));
// PodTemplateSpec describes the data a pod should have when created from a template
class PodTemplateSpec {
}
exports.PodTemplateSpec = PodTemplateSpec;
// PortworxVolumeSource represents a Portworx volume resource.
class PortworxVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.readOnly = desc.readOnly;
        this.volumeID = desc.volumeID;
    }
}
exports.PortworxVolumeSource = PortworxVolumeSource;
// An empty preferred scheduling term matches all objects with implicit weight 0 (i.e. it's a no-op). A null preferred scheduling term matches no objects (i.e. is also a no-op).
class PreferredSchedulingTerm {
    constructor(desc) {
        this.preference = desc.preference;
        this.weight = desc.weight;
    }
}
exports.PreferredSchedulingTerm = PreferredSchedulingTerm;
// Probe describes a health check to be performed against a container to determine whether it is alive or ready to receive traffic.
class Probe {
}
exports.Probe = Probe;
// Represents a projected volume source
class ProjectedVolumeSource {
    constructor(desc) {
        this.defaultMode = desc.defaultMode;
        this.sources = desc.sources;
    }
}
exports.ProjectedVolumeSource = ProjectedVolumeSource;
// Represents a Quobyte mount that lasts the lifetime of a pod. Quobyte volumes do not support ownership management or SELinux relabeling.
class QuobyteVolumeSource {
    constructor(desc) {
        this.group = desc.group;
        this.readOnly = desc.readOnly;
        this.registry = desc.registry;
        this.tenant = desc.tenant;
        this.user = desc.user;
        this.volume = desc.volume;
    }
}
exports.QuobyteVolumeSource = QuobyteVolumeSource;
// Represents a Rados Block Device mount that lasts the lifetime of a pod. RBD volumes support ownership management and SELinux relabeling.
class RBDPersistentVolumeSource {
    constructor(desc) {
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
exports.RBDPersistentVolumeSource = RBDPersistentVolumeSource;
// Represents a Rados Block Device mount that lasts the lifetime of a pod. RBD volumes support ownership management and SELinux relabeling.
class RBDVolumeSource {
    constructor(desc) {
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
exports.RBDVolumeSource = RBDVolumeSource;
// ReplicationController represents the configuration of a replication controller.
class ReplicationController {
    constructor(desc) {
        this.apiVersion = ReplicationController.apiVersion;
        this.kind = ReplicationController.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.ReplicationController = ReplicationController;
function isReplicationController(o) {
    return (o &&
        o.apiVersion === ReplicationController.apiVersion &&
        o.kind === ReplicationController.kind);
}
exports.isReplicationController = isReplicationController;
(function (ReplicationController) {
    ReplicationController.apiVersion = "v1";
    ReplicationController.group = "";
    ReplicationController.version = "v1";
    ReplicationController.kind = "ReplicationController";
    // named constructs a ReplicationController with metadata.name set to name.
    function named(name) {
        return new ReplicationController({ metadata: { name } });
    }
    ReplicationController.named = named;
})(ReplicationController = exports.ReplicationController || (exports.ReplicationController = {}));
// ReplicationControllerCondition describes the state of a replication controller at a certain point.
class ReplicationControllerCondition {
    constructor(desc) {
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.ReplicationControllerCondition = ReplicationControllerCondition;
// ReplicationControllerList is a collection of replication controllers.
class ReplicationControllerList {
    constructor(desc) {
        this.apiVersion = ReplicationControllerList.apiVersion;
        this.items = desc.items.map(i => new ReplicationController(i));
        this.kind = ReplicationControllerList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ReplicationControllerList = ReplicationControllerList;
function isReplicationControllerList(o) {
    return (o &&
        o.apiVersion === ReplicationControllerList.apiVersion &&
        o.kind === ReplicationControllerList.kind);
}
exports.isReplicationControllerList = isReplicationControllerList;
(function (ReplicationControllerList) {
    ReplicationControllerList.apiVersion = "v1";
    ReplicationControllerList.group = "";
    ReplicationControllerList.version = "v1";
    ReplicationControllerList.kind = "ReplicationControllerList";
})(ReplicationControllerList = exports.ReplicationControllerList || (exports.ReplicationControllerList = {}));
// ReplicationControllerSpec is the specification of a replication controller.
class ReplicationControllerSpec {
}
exports.ReplicationControllerSpec = ReplicationControllerSpec;
// ReplicationControllerStatus represents the current status of a replication controller.
class ReplicationControllerStatus {
    constructor(desc) {
        this.availableReplicas = desc.availableReplicas;
        this.conditions = desc.conditions;
        this.fullyLabeledReplicas = desc.fullyLabeledReplicas;
        this.observedGeneration = desc.observedGeneration;
        this.readyReplicas = desc.readyReplicas;
        this.replicas = desc.replicas;
    }
}
exports.ReplicationControllerStatus = ReplicationControllerStatus;
// ResourceFieldSelector represents container resources (cpu, memory) and their output format
class ResourceFieldSelector {
    constructor(desc) {
        this.containerName = desc.containerName;
        this.divisor = desc.divisor;
        this.resource = desc.resource;
    }
}
exports.ResourceFieldSelector = ResourceFieldSelector;
// ResourceQuota sets aggregate quota restrictions enforced per namespace
class ResourceQuota {
    constructor(desc) {
        this.apiVersion = ResourceQuota.apiVersion;
        this.kind = ResourceQuota.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.ResourceQuota = ResourceQuota;
function isResourceQuota(o) {
    return (o &&
        o.apiVersion === ResourceQuota.apiVersion &&
        o.kind === ResourceQuota.kind);
}
exports.isResourceQuota = isResourceQuota;
(function (ResourceQuota) {
    ResourceQuota.apiVersion = "v1";
    ResourceQuota.group = "";
    ResourceQuota.version = "v1";
    ResourceQuota.kind = "ResourceQuota";
    // named constructs a ResourceQuota with metadata.name set to name.
    function named(name) {
        return new ResourceQuota({ metadata: { name } });
    }
    ResourceQuota.named = named;
})(ResourceQuota = exports.ResourceQuota || (exports.ResourceQuota = {}));
// ResourceQuotaList is a list of ResourceQuota items.
class ResourceQuotaList {
    constructor(desc) {
        this.apiVersion = ResourceQuotaList.apiVersion;
        this.items = desc.items.map(i => new ResourceQuota(i));
        this.kind = ResourceQuotaList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ResourceQuotaList = ResourceQuotaList;
function isResourceQuotaList(o) {
    return (o &&
        o.apiVersion === ResourceQuotaList.apiVersion &&
        o.kind === ResourceQuotaList.kind);
}
exports.isResourceQuotaList = isResourceQuotaList;
(function (ResourceQuotaList) {
    ResourceQuotaList.apiVersion = "v1";
    ResourceQuotaList.group = "";
    ResourceQuotaList.version = "v1";
    ResourceQuotaList.kind = "ResourceQuotaList";
})(ResourceQuotaList = exports.ResourceQuotaList || (exports.ResourceQuotaList = {}));
// ResourceQuotaSpec defines the desired hard limits to enforce for Quota.
class ResourceQuotaSpec {
}
exports.ResourceQuotaSpec = ResourceQuotaSpec;
// ResourceQuotaStatus defines the enforced hard limits and observed use.
class ResourceQuotaStatus {
}
exports.ResourceQuotaStatus = ResourceQuotaStatus;
// ResourceRequirements describes the compute resource requirements.
class ResourceRequirements {
}
exports.ResourceRequirements = ResourceRequirements;
// SELinuxOptions are the labels to be applied to the container
class SELinuxOptions {
}
exports.SELinuxOptions = SELinuxOptions;
// ScaleIOPersistentVolumeSource represents a persistent ScaleIO volume
class ScaleIOPersistentVolumeSource {
    constructor(desc) {
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
exports.ScaleIOPersistentVolumeSource = ScaleIOPersistentVolumeSource;
// ScaleIOVolumeSource represents a persistent ScaleIO volume
class ScaleIOVolumeSource {
    constructor(desc) {
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
exports.ScaleIOVolumeSource = ScaleIOVolumeSource;
// A scope selector represents the AND of the selectors represented by the scoped-resource selector requirements.
class ScopeSelector {
}
exports.ScopeSelector = ScopeSelector;
// A scoped-resource selector requirement is a selector that contains values, a scope name, and an operator that relates the scope name and values.
class ScopedResourceSelectorRequirement {
    constructor(desc) {
        this.operator = desc.operator;
        this.scopeName = desc.scopeName;
        this.values = desc.values;
    }
}
exports.ScopedResourceSelectorRequirement = ScopedResourceSelectorRequirement;
// Secret holds secret data of a certain type. The total bytes of the values in the Data field must be less than MaxSecretSize bytes.
class Secret {
    constructor(desc) {
        this.apiVersion = Secret.apiVersion;
        this.data = desc.data;
        this.kind = Secret.kind;
        this.metadata = desc.metadata;
        this.stringData = desc.stringData;
        this.type = desc.type;
    }
}
exports.Secret = Secret;
function isSecret(o) {
    return o && o.apiVersion === Secret.apiVersion && o.kind === Secret.kind;
}
exports.isSecret = isSecret;
(function (Secret) {
    Secret.apiVersion = "v1";
    Secret.group = "";
    Secret.version = "v1";
    Secret.kind = "Secret";
    // named constructs a Secret with metadata.name set to name.
    function named(name) {
        return new Secret({ metadata: { name } });
    }
    Secret.named = named;
})(Secret = exports.Secret || (exports.Secret = {}));
// SecretEnvSource selects a Secret to populate the environment variables with.
//
// The contents of the target Secret's Data field will represent the key-value pairs as environment variables.
class SecretEnvSource {
}
exports.SecretEnvSource = SecretEnvSource;
// SecretKeySelector selects a key of a Secret.
class SecretKeySelector {
    constructor(desc) {
        this.key = desc.key;
        this.name = desc.name;
        this.optional = desc.optional;
    }
}
exports.SecretKeySelector = SecretKeySelector;
// SecretList is a list of Secret.
class SecretList {
    constructor(desc) {
        this.apiVersion = SecretList.apiVersion;
        this.items = desc.items.map(i => new Secret(i));
        this.kind = SecretList.kind;
        this.metadata = desc.metadata;
    }
}
exports.SecretList = SecretList;
function isSecretList(o) {
    return (o && o.apiVersion === SecretList.apiVersion && o.kind === SecretList.kind);
}
exports.isSecretList = isSecretList;
(function (SecretList) {
    SecretList.apiVersion = "v1";
    SecretList.group = "";
    SecretList.version = "v1";
    SecretList.kind = "SecretList";
})(SecretList = exports.SecretList || (exports.SecretList = {}));
// Adapts a secret into a projected volume.
//
// The contents of the target Secret's Data field will be presented in a projected volume as files using the keys in the Data field as the file names. Note that this is identical to a secret volume source without the default mode.
class SecretProjection {
}
exports.SecretProjection = SecretProjection;
// SecretReference represents a Secret Reference. It has enough information to retrieve secret in any namespace
class SecretReference {
}
exports.SecretReference = SecretReference;
// Adapts a Secret into a volume.
//
// The contents of the target Secret's Data field will be presented in a volume as files using the keys in the Data field as the file names. Secret volumes support ownership management and SELinux relabeling.
class SecretVolumeSource {
}
exports.SecretVolumeSource = SecretVolumeSource;
// SecurityContext holds security configuration that will be applied to a container. Some fields are present in both SecurityContext and PodSecurityContext.  When both are set, the values in SecurityContext take precedence.
class SecurityContext {
}
exports.SecurityContext = SecurityContext;
// Service is a named abstraction of software service (for example, mysql) consisting of local port (for example 3306) that the proxy listens on, and the selector that determines which pods will answer requests sent through the proxy.
class Service {
    constructor(desc) {
        this.apiVersion = Service.apiVersion;
        this.kind = Service.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Service = Service;
function isService(o) {
    return o && o.apiVersion === Service.apiVersion && o.kind === Service.kind;
}
exports.isService = isService;
(function (Service) {
    Service.apiVersion = "v1";
    Service.group = "";
    Service.version = "v1";
    Service.kind = "Service";
    // named constructs a Service with metadata.name set to name.
    function named(name) {
        return new Service({ metadata: { name } });
    }
    Service.named = named;
})(Service = exports.Service || (exports.Service = {}));
// ServiceAccount binds together: * a name, understood by users, and perhaps by peripheral systems, for an identity * a principal that can be authenticated and authorized * a set of secrets
class ServiceAccount {
    constructor(desc) {
        this.apiVersion = ServiceAccount.apiVersion;
        this.automountServiceAccountToken = desc.automountServiceAccountToken;
        this.imagePullSecrets = desc.imagePullSecrets;
        this.kind = ServiceAccount.kind;
        this.metadata = desc.metadata;
        this.secrets = desc.secrets;
    }
}
exports.ServiceAccount = ServiceAccount;
function isServiceAccount(o) {
    return (o &&
        o.apiVersion === ServiceAccount.apiVersion &&
        o.kind === ServiceAccount.kind);
}
exports.isServiceAccount = isServiceAccount;
(function (ServiceAccount) {
    ServiceAccount.apiVersion = "v1";
    ServiceAccount.group = "";
    ServiceAccount.version = "v1";
    ServiceAccount.kind = "ServiceAccount";
    // named constructs a ServiceAccount with metadata.name set to name.
    function named(name) {
        return new ServiceAccount({ metadata: { name } });
    }
    ServiceAccount.named = named;
})(ServiceAccount = exports.ServiceAccount || (exports.ServiceAccount = {}));
// ServiceAccountList is a list of ServiceAccount objects
class ServiceAccountList {
    constructor(desc) {
        this.apiVersion = ServiceAccountList.apiVersion;
        this.items = desc.items.map(i => new ServiceAccount(i));
        this.kind = ServiceAccountList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ServiceAccountList = ServiceAccountList;
function isServiceAccountList(o) {
    return (o &&
        o.apiVersion === ServiceAccountList.apiVersion &&
        o.kind === ServiceAccountList.kind);
}
exports.isServiceAccountList = isServiceAccountList;
(function (ServiceAccountList) {
    ServiceAccountList.apiVersion = "v1";
    ServiceAccountList.group = "";
    ServiceAccountList.version = "v1";
    ServiceAccountList.kind = "ServiceAccountList";
})(ServiceAccountList = exports.ServiceAccountList || (exports.ServiceAccountList = {}));
// ServiceAccountTokenProjection represents a projected service account token volume. This projection can be used to insert a service account token into the pods runtime filesystem for use against APIs (Kubernetes API Server or otherwise).
class ServiceAccountTokenProjection {
    constructor(desc) {
        this.audience = desc.audience;
        this.expirationSeconds = desc.expirationSeconds;
        this.path = desc.path;
    }
}
exports.ServiceAccountTokenProjection = ServiceAccountTokenProjection;
// ServiceList holds a list of services.
class ServiceList {
    constructor(desc) {
        this.apiVersion = ServiceList.apiVersion;
        this.items = desc.items.map(i => new Service(i));
        this.kind = ServiceList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ServiceList = ServiceList;
function isServiceList(o) {
    return (o && o.apiVersion === ServiceList.apiVersion && o.kind === ServiceList.kind);
}
exports.isServiceList = isServiceList;
(function (ServiceList) {
    ServiceList.apiVersion = "v1";
    ServiceList.group = "";
    ServiceList.version = "v1";
    ServiceList.kind = "ServiceList";
})(ServiceList = exports.ServiceList || (exports.ServiceList = {}));
// ServicePort contains information on service's port.
class ServicePort {
    constructor(desc) {
        this.name = desc.name;
        this.nodePort = desc.nodePort;
        this.port = desc.port;
        this.protocol = desc.protocol;
        this.targetPort = desc.targetPort;
    }
}
exports.ServicePort = ServicePort;
// ServiceSpec describes the attributes that a user creates on a service.
class ServiceSpec {
}
exports.ServiceSpec = ServiceSpec;
// ServiceStatus represents the current status of a service.
class ServiceStatus {
}
exports.ServiceStatus = ServiceStatus;
// SessionAffinityConfig represents the configurations of session affinity.
class SessionAffinityConfig {
}
exports.SessionAffinityConfig = SessionAffinityConfig;
// Represents a StorageOS persistent volume resource.
class StorageOSPersistentVolumeSource {
}
exports.StorageOSPersistentVolumeSource = StorageOSPersistentVolumeSource;
// Represents a StorageOS persistent volume resource.
class StorageOSVolumeSource {
}
exports.StorageOSVolumeSource = StorageOSVolumeSource;
// Sysctl defines a kernel parameter to be set
class Sysctl {
    constructor(desc) {
        this.name = desc.name;
        this.value = desc.value;
    }
}
exports.Sysctl = Sysctl;
// TCPSocketAction describes an action based on opening a socket
class TCPSocketAction {
    constructor(desc) {
        this.host = desc.host;
        this.port = desc.port;
    }
}
exports.TCPSocketAction = TCPSocketAction;
// The node this Taint is attached to has the "effect" on any pod that does not tolerate the Taint.
class Taint {
    constructor(desc) {
        this.effect = desc.effect;
        this.key = desc.key;
        this.timeAdded = desc.timeAdded;
        this.value = desc.value;
    }
}
exports.Taint = Taint;
// The pod this Toleration is attached to tolerates any taint that matches the triple <key,value,effect> using the matching operator <operator>.
class Toleration {
}
exports.Toleration = Toleration;
// A topology selector requirement is a selector that matches given label. This is an alpha feature and may change in the future.
class TopologySelectorLabelRequirement {
    constructor(desc) {
        this.key = desc.key;
        this.values = desc.values;
    }
}
exports.TopologySelectorLabelRequirement = TopologySelectorLabelRequirement;
// A topology selector term represents the result of label queries. A null or empty topology selector term matches no objects. The requirements of them are ANDed. It provides a subset of functionality as NodeSelectorTerm. This is an alpha feature and may change in the future.
class TopologySelectorTerm {
}
exports.TopologySelectorTerm = TopologySelectorTerm;
// TypedLocalObjectReference contains enough information to let you locate the typed referenced object inside the same namespace.
class TypedLocalObjectReference {
    constructor(desc) {
        this.apiGroup = desc.apiGroup;
        this.kind = desc.kind;
        this.name = desc.name;
    }
}
exports.TypedLocalObjectReference = TypedLocalObjectReference;
// Volume represents a named volume in a pod that may be accessed by any container in the pod.
class Volume {
    constructor(desc) {
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
exports.Volume = Volume;
// volumeDevice describes a mapping of a raw block device within a container.
class VolumeDevice {
    constructor(desc) {
        this.devicePath = desc.devicePath;
        this.name = desc.name;
    }
}
exports.VolumeDevice = VolumeDevice;
// VolumeMount describes a mounting of a Volume within a container.
class VolumeMount {
    constructor(desc) {
        this.mountPath = desc.mountPath;
        this.mountPropagation = desc.mountPropagation;
        this.name = desc.name;
        this.readOnly = desc.readOnly;
        this.subPath = desc.subPath;
        this.subPathExpr = desc.subPathExpr;
    }
}
exports.VolumeMount = VolumeMount;
// VolumeNodeAffinity defines constraints that limit what nodes this volume can be accessed from.
class VolumeNodeAffinity {
}
exports.VolumeNodeAffinity = VolumeNodeAffinity;
// Projection that may be projected along with other supported volume types
class VolumeProjection {
}
exports.VolumeProjection = VolumeProjection;
// Represents a vSphere volume resource.
class VsphereVirtualDiskVolumeSource {
    constructor(desc) {
        this.fsType = desc.fsType;
        this.storagePolicyID = desc.storagePolicyID;
        this.storagePolicyName = desc.storagePolicyName;
        this.volumePath = desc.volumePath;
    }
}
exports.VsphereVirtualDiskVolumeSource = VsphereVirtualDiskVolumeSource;
// The weights of all of the matched WeightedPodAffinityTerm fields are added per-node to find the most preferred node(s)
class WeightedPodAffinityTerm {
    constructor(desc) {
        this.podAffinityTerm = desc.podAffinityTerm;
        this.weight = desc.weight;
    }
}
exports.WeightedPodAffinityTerm = WeightedPodAffinityTerm;
//# sourceMappingURL=io.k8s.api.core.v1.js.map