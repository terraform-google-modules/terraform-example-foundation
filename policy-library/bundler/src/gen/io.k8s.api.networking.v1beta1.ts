import { KubernetesObject } from "kpt-functions";
import * as apiCoreV1 from "./io.k8s.api.core.v1";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";
import * as pkgUtilIntstr from "./io.k8s.apimachinery.pkg.util.intstr";

// HTTPIngressPath associates a path regex with a backend. Incoming urls matching the path are forwarded to the backend.
export class HTTPIngressPath {
  // Backend defines the referenced service endpoint to which the traffic will be forwarded to.
  public backend: IngressBackend;

  // Path is an extended POSIX regex as defined by IEEE Std 1003.1, (i.e this follows the egrep/unix syntax, not the perl syntax) matched against the path of an incoming request. Currently it can contain characters disallowed from the conventional "path" part of a URL as defined by RFC 3986. Paths must begin with a '/'. If unspecified, the path defaults to a catch all sending traffic to the backend.
  public path?: string;

  constructor(desc: HTTPIngressPath) {
    this.backend = desc.backend;
    this.path = desc.path;
  }
}

// HTTPIngressRuleValue is a list of http selectors pointing to backends. In the example: http://<host>/<path>?<searchpart> -> backend where where parts of the url correspond to RFC 3986, this resource will be used to match against everything after the last '/' and before the first '?' or '#'.
export class HTTPIngressRuleValue {
  // A collection of paths that map requests to backends.
  public paths: HTTPIngressPath[];

  constructor(desc: HTTPIngressRuleValue) {
    this.paths = desc.paths;
  }
}

// Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc.
export class Ingress implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Spec is the desired state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: IngressSpec;

  // Status is the current state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: IngressStatus;

  constructor(desc: Ingress.Interface) {
    this.apiVersion = Ingress.apiVersion;
    this.kind = Ingress.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isIngress(o: any): o is Ingress {
  return o && o.apiVersion === Ingress.apiVersion && o.kind === Ingress.kind;
}

export namespace Ingress {
  export const apiVersion = "networking.k8s.io/v1beta1";
  export const group = "networking.k8s.io";
  export const version = "v1beta1";
  export const kind = "Ingress";

  // named constructs a Ingress with metadata.name set to name.
  export function named(name: string): Ingress {
    return new Ingress({ metadata: { name } });
  }
  // Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Spec is the desired state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: IngressSpec;

    // Status is the current state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: IngressStatus;
  }
}

// IngressBackend describes all endpoints for a given service and port.
export class IngressBackend {
  // Specifies the name of the referenced service.
  public serviceName: string;

  // Specifies the port of the referenced service.
  public servicePort: pkgUtilIntstr.IntOrString;

  constructor(desc: IngressBackend) {
    this.serviceName = desc.serviceName;
    this.servicePort = desc.servicePort;
  }
}

// IngressList is a collection of Ingress.
export class IngressList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is the list of Ingress.
  public items: Ingress[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: IngressList) {
    this.apiVersion = IngressList.apiVersion;
    this.items = desc.items.map(i => new Ingress(i));
    this.kind = IngressList.kind;
    this.metadata = desc.metadata;
  }
}

export function isIngressList(o: any): o is IngressList {
  return (
    o && o.apiVersion === IngressList.apiVersion && o.kind === IngressList.kind
  );
}

export namespace IngressList {
  export const apiVersion = "networking.k8s.io/v1beta1";
  export const group = "networking.k8s.io";
  export const version = "v1beta1";
  export const kind = "IngressList";

  // IngressList is a collection of Ingress.
  export interface Interface {
    // Items is the list of Ingress.
    items: Ingress[];

    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// IngressRule represents the rules mapping the paths under a specified host to the related backend services. Incoming requests are first evaluated for a host match, then routed to the backend associated with the matching IngressRuleValue.
export class IngressRule {
  // Host is the fully qualified domain name of a network host, as defined by RFC 3986. Note the following deviations from the "host" part of the URI as defined in the RFC: 1. IPs are not allowed. Currently an IngressRuleValue can only apply to the
  // 	  IP in the Spec of the parent Ingress.
  // 2. The `:` delimiter is not respected because ports are not allowed.
  // 	  Currently the port of an Ingress is implicitly :80 for http and
  // 	  :443 for https.
  // Both these may change in the future. Incoming requests are matched against the host before the IngressRuleValue. If the host is unspecified, the Ingress routes all traffic based on the specified IngressRuleValue.
  public host?: string;

  public http?: HTTPIngressRuleValue;
}

// IngressSpec describes the Ingress the user wishes to exist.
export class IngressSpec {
  // A default backend capable of servicing requests that don't match any rule. At least one of 'backend' or 'rules' must be specified. This field is optional to allow the loadbalancer controller or defaulting logic to specify a global default.
  public backend?: IngressBackend;

  // A list of host rules used to configure the Ingress. If unspecified, or no rule matches, all traffic is sent to the default backend.
  public rules?: IngressRule[];

  // TLS configuration. Currently the Ingress only supports a single TLS port, 443. If multiple members of this list specify different hosts, they will be multiplexed on the same port according to the hostname specified through the SNI TLS extension, if the ingress controller fulfilling the ingress supports SNI.
  public tls?: IngressTLS[];
}

// IngressStatus describe the current state of the Ingress.
export class IngressStatus {
  // LoadBalancer contains the current status of the load-balancer.
  public loadBalancer?: apiCoreV1.LoadBalancerStatus;
}

// IngressTLS describes the transport layer security associated with an Ingress.
export class IngressTLS {
  // Hosts are a list of hosts included in the TLS certificate. The values in this list must match the name/s used in the tlsSecret. Defaults to the wildcard host setting for the loadbalancer controller fulfilling this Ingress, if left unspecified.
  public hosts?: string[];

  // SecretName is the name of the secret used to terminate SSL traffic on 443. Field is left optional to allow SSL routing based on SNI hostname alone. If the SNI host in a listener conflicts with the "Host" header field used by an IngressRule, the SNI host is used for termination and value of the Host header is used for routing.
  public secretName?: string;
}
