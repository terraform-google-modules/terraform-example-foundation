import { KubernetesObject } from 'kpt-functions';
import * as apiCoreV1 from './io.k8s.api.core.v1';
import * as apisMetaV1 from './io.k8s.apimachinery.pkg.apis.meta.v1';

// Endpoint represents a single logical "backend" implementing a service.
export class Endpoint {
  // addresses of this endpoint. The contents of this field are interpreted according to the corresponding EndpointSlice addressType field. Consumers must handle different types of addresses in the context of their own capabilities. This must contain at least one address but no more than 100.
  public addresses: string[];

  // conditions contains information about the current status of the endpoint.
  public conditions?: EndpointConditions;

  // hostname of this endpoint. This field may be used by consumers of endpoints to distinguish endpoints from each other (e.g. in DNS names). Multiple endpoints which use the same hostname should be considered fungible (e.g. multiple A values in DNS). Must pass DNS Label (RFC 1123) validation.
  public hostname?: string;

  // targetRef is a reference to a Kubernetes object that represents this endpoint.
  public targetRef?: apiCoreV1.ObjectReference;

  // topology contains arbitrary topology information associated with the endpoint. These key/value pairs must conform with the label format. https://kubernetes.io/docs/concepts/overview/working-with-objects/labels Topology may include a maximum of 16 key/value pairs. This includes, but is not limited to the following well known keys: * kubernetes.io/hostname: the value indicates the hostname of the node
  //   where the endpoint is located. This should match the corresponding
  //   node label.
  // * topology.kubernetes.io/zone: the value indicates the zone where the
  //   endpoint is located. This should match the corresponding node label.
  // * topology.kubernetes.io/region: the value indicates the region where the
  //   endpoint is located. This should match the corresponding node label.
  public topology?: {[key: string]: string};

  constructor(desc: Endpoint) {
    this.addresses = desc.addresses;
    this.conditions = desc.conditions;
    this.hostname = desc.hostname;
    this.targetRef = desc.targetRef;
    this.topology = desc.topology;
  }
}

// EndpointConditions represents the current condition of an endpoint.
export class EndpointConditions {
  // ready indicates that this endpoint is prepared to receive traffic, according to whatever system is managing the endpoint. A nil value indicates an unknown state. In most cases consumers should interpret this unknown state as ready.
  public ready?: boolean;
}

// EndpointPort represents a Port used by an EndpointSlice
export class EndpointPort {
  // The application protocol for this port. This field follows standard Kubernetes label syntax. Un-prefixed names are reserved for IANA standard service names (as per RFC-6335 and http://www.iana.org/assignments/service-names). Non-standard protocols should use prefixed names. Default is empty string.
  public appProtocol?: string;

  // The name of this port. All ports in an EndpointSlice must have a unique name. If the EndpointSlice is dervied from a Kubernetes service, this corresponds to the Service.ports[].name. Name must either be an empty string or pass DNS_LABEL validation: * must be no more than 63 characters long. * must consist of lower case alphanumeric characters or '-'. * must start and end with an alphanumeric character. Default is empty string.
  public name?: string;

  // The port number of the endpoint. If this is not specified, ports are not restricted and must be interpreted in the context of the specific consumer.
  public port?: number;

  // The IP protocol for this port. Must be UDP, TCP, or SCTP. Default is TCP.
  public protocol?: string;
}

// EndpointSlice represents a subset of the endpoints that implement a service. For a given service there may be multiple EndpointSlice objects, selected by labels, which must be joined to produce the full set of endpoints.
export class EndpointSlice implements KubernetesObject {
  // addressType specifies the type of address carried by this EndpointSlice. All addresses in this slice must be the same type. This field is immutable after creation. The following address types are currently supported: * IPv4: Represents an IPv4 Address. * IPv6: Represents an IPv6 Address. * FQDN: Represents a Fully Qualified Domain Name.
  public addressType: string;

  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
  public apiVersion: string;

  // endpoints is a list of unique endpoints in this slice. Each slice may include a maximum of 1000 endpoints.
  public endpoints: Endpoint[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // ports specifies the list of network ports exposed by each endpoint in this slice. Each port must have a unique name. When ports is empty, it indicates that there are no defined ports. When a port is defined with a nil port value, it indicates "all ports". Each slice may include a maximum of 100 ports.
  public ports?: EndpointPort[];

  constructor(desc: EndpointSlice.Interface) {
    this.addressType = desc.addressType;
    this.apiVersion = EndpointSlice.apiVersion;
    this.endpoints = desc.endpoints;
    this.kind = EndpointSlice.kind;
    this.metadata = desc.metadata;
    this.ports = desc.ports;
  }
}

export function isEndpointSlice(o: any): o is EndpointSlice {
  return o && o.apiVersion === EndpointSlice.apiVersion && o.kind === EndpointSlice.kind;
}

export namespace EndpointSlice {
  export const apiVersion = "discovery.k8s.io/v1beta1";
  export const group = "discovery.k8s.io";
  export const version = "v1beta1";
  export const kind = "EndpointSlice";

  // EndpointSlice represents a subset of the endpoints that implement a service. For a given service there may be multiple EndpointSlice objects, selected by labels, which must be joined to produce the full set of endpoints.
  export interface Interface {
    // addressType specifies the type of address carried by this EndpointSlice. All addresses in this slice must be the same type. This field is immutable after creation. The following address types are currently supported: * IPv4: Represents an IPv4 Address. * IPv6: Represents an IPv6 Address. * FQDN: Represents a Fully Qualified Domain Name.
    addressType: string;

    // endpoints is a list of unique endpoints in this slice. Each slice may include a maximum of 1000 endpoints.
    endpoints: Endpoint[];

    // Standard object's metadata.
    metadata: apisMetaV1.ObjectMeta;

    // ports specifies the list of network ports exposed by each endpoint in this slice. Each port must have a unique name. When ports is empty, it indicates that there are no defined ports. When a port is defined with a nil port value, it indicates "all ports". Each slice may include a maximum of 100 ports.
    ports?: EndpointPort[];
  }
}

// EndpointSliceList represents a list of endpoint slices
export class EndpointSliceList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
  public apiVersion: string;

  // List of endpoint slices
  public items: EndpointSlice[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata.
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: EndpointSliceList) {
    this.apiVersion = EndpointSliceList.apiVersion;
    this.items = desc.items.map((i) => new EndpointSlice(i));
    this.kind = EndpointSliceList.kind;
    this.metadata = desc.metadata;
  }
}

export function isEndpointSliceList(o: any): o is EndpointSliceList {
  return o && o.apiVersion === EndpointSliceList.apiVersion && o.kind === EndpointSliceList.kind;
}

export namespace EndpointSliceList {
  export const apiVersion = "discovery.k8s.io/v1beta1";
  export const group = "discovery.k8s.io";
  export const version = "v1beta1";
  export const kind = "EndpointSliceList";

  // EndpointSliceList represents a list of endpoint slices
  export interface Interface {
    // List of endpoint slices
    items: EndpointSlice[];

    // Standard list metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}