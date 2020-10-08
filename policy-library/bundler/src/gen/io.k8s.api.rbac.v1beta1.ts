import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// AggregationRule describes how to locate ClusterRoles to aggregate into the ClusterRole
export class AggregationRule {
  // ClusterRoleSelectors holds a list of selectors which will be used to find ClusterRoles and create the rules. If any of the selectors match, then the ClusterRole's permissions will be added
  public clusterRoleSelectors?: apisMetaV1.LabelSelector[];
}

// ClusterRole is a cluster level, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding or ClusterRoleBinding.
export class ClusterRole implements KubernetesObject {
  // AggregationRule is an optional field that describes how to build the Rules for this ClusterRole. If AggregationRule is set, then the Rules are controller managed and direct changes to Rules will be stomped by the controller.
  public aggregationRule?: AggregationRule;

  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // Rules holds all the PolicyRules for this ClusterRole
  public rules?: PolicyRule[];

  constructor(desc: ClusterRole.Interface) {
    this.aggregationRule = desc.aggregationRule;
    this.apiVersion = ClusterRole.apiVersion;
    this.kind = ClusterRole.kind;
    this.metadata = desc.metadata;
    this.rules = desc.rules;
  }
}

export function isClusterRole(o: any): o is ClusterRole {
  return (
    o && o.apiVersion === ClusterRole.apiVersion && o.kind === ClusterRole.kind
  );
}

export namespace ClusterRole {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "ClusterRole";

  // named constructs a ClusterRole with metadata.name set to name.
  export function named(name: string): ClusterRole {
    return new ClusterRole({ metadata: { name } });
  }
  // ClusterRole is a cluster level, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding or ClusterRoleBinding.
  export interface Interface {
    // AggregationRule is an optional field that describes how to build the Rules for this ClusterRole. If AggregationRule is set, then the Rules are controller managed and direct changes to Rules will be stomped by the controller.
    aggregationRule?: AggregationRule;

    // Standard object's metadata.
    metadata: apisMetaV1.ObjectMeta;

    // Rules holds all the PolicyRules for this ClusterRole
    rules?: PolicyRule[];
  }
}

// ClusterRoleBinding references a ClusterRole, but not contain it.  It can reference a ClusterRole in the global namespace, and adds who information via Subject.
export class ClusterRoleBinding implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // RoleRef can only reference a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.
  public roleRef: RoleRef;

  // Subjects holds references to the objects the role applies to.
  public subjects?: Subject[];

  constructor(desc: ClusterRoleBinding.Interface) {
    this.apiVersion = ClusterRoleBinding.apiVersion;
    this.kind = ClusterRoleBinding.kind;
    this.metadata = desc.metadata;
    this.roleRef = desc.roleRef;
    this.subjects = desc.subjects;
  }
}

export function isClusterRoleBinding(o: any): o is ClusterRoleBinding {
  return (
    o &&
    o.apiVersion === ClusterRoleBinding.apiVersion &&
    o.kind === ClusterRoleBinding.kind
  );
}

export namespace ClusterRoleBinding {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "ClusterRoleBinding";

  // ClusterRoleBinding references a ClusterRole, but not contain it.  It can reference a ClusterRole in the global namespace, and adds who information via Subject.
  export interface Interface {
    // Standard object's metadata.
    metadata: apisMetaV1.ObjectMeta;

    // RoleRef can only reference a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.
    roleRef: RoleRef;

    // Subjects holds references to the objects the role applies to.
    subjects?: Subject[];
  }
}

// ClusterRoleBindingList is a collection of ClusterRoleBindings
export class ClusterRoleBindingList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of ClusterRoleBindings
  public items: ClusterRoleBinding[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ClusterRoleBindingList) {
    this.apiVersion = ClusterRoleBindingList.apiVersion;
    this.items = desc.items.map(i => new ClusterRoleBinding(i));
    this.kind = ClusterRoleBindingList.kind;
    this.metadata = desc.metadata;
  }
}

export function isClusterRoleBindingList(o: any): o is ClusterRoleBindingList {
  return (
    o &&
    o.apiVersion === ClusterRoleBindingList.apiVersion &&
    o.kind === ClusterRoleBindingList.kind
  );
}

export namespace ClusterRoleBindingList {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "ClusterRoleBindingList";

  // ClusterRoleBindingList is a collection of ClusterRoleBindings
  export interface Interface {
    // Items is a list of ClusterRoleBindings
    items: ClusterRoleBinding[];

    // Standard object's metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}

// ClusterRoleList is a collection of ClusterRoles
export class ClusterRoleList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of ClusterRoles
  public items: ClusterRole[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: ClusterRoleList) {
    this.apiVersion = ClusterRoleList.apiVersion;
    this.items = desc.items.map(i => new ClusterRole(i));
    this.kind = ClusterRoleList.kind;
    this.metadata = desc.metadata;
  }
}

export function isClusterRoleList(o: any): o is ClusterRoleList {
  return (
    o &&
    o.apiVersion === ClusterRoleList.apiVersion &&
    o.kind === ClusterRoleList.kind
  );
}

export namespace ClusterRoleList {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "ClusterRoleList";

  // ClusterRoleList is a collection of ClusterRoles
  export interface Interface {
    // Items is a list of ClusterRoles
    items: ClusterRole[];

    // Standard object's metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}

// PolicyRule holds information that describes a policy rule, but does not contain information about who the rule applies to or which namespace the rule applies to.
export class PolicyRule {
  // APIGroups is the name of the APIGroup that contains the resources.  If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.
  public apiGroups?: string[];

  // NonResourceURLs is a set of partial urls that a user should have access to.  *s are allowed, but only as the full, final step in the path Since non-resource URLs are not namespaced, this field is only applicable for ClusterRoles referenced from a ClusterRoleBinding. Rules can either apply to API resources (such as "pods" or "secrets") or non-resource URL paths (such as "/api"),  but not both.
  public nonResourceURLs?: string[];

  // ResourceNames is an optional white list of names that the rule applies to.  An empty set means that everything is allowed.
  public resourceNames?: string[];

  // Resources is a list of resources this rule applies to.  '*' represents all resources in the specified apiGroups. '*/foo' represents the subresource 'foo' for all resources in the specified apiGroups.
  public resources?: string[];

  // Verbs is a list of Verbs that apply to ALL the ResourceKinds and AttributeRestrictions contained in this rule.  VerbAll represents all kinds.
  public verbs: string[];

  constructor(desc: PolicyRule) {
    this.apiGroups = desc.apiGroups;
    this.nonResourceURLs = desc.nonResourceURLs;
    this.resourceNames = desc.resourceNames;
    this.resources = desc.resources;
    this.verbs = desc.verbs;
  }
}

// Role is a namespaced, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding.
export class Role implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // Rules holds all the PolicyRules for this Role
  public rules?: PolicyRule[];

  constructor(desc: Role.Interface) {
    this.apiVersion = Role.apiVersion;
    this.kind = Role.kind;
    this.metadata = desc.metadata;
    this.rules = desc.rules;
  }
}

export function isRole(o: any): o is Role {
  return o && o.apiVersion === Role.apiVersion && o.kind === Role.kind;
}

export namespace Role {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "Role";

  // named constructs a Role with metadata.name set to name.
  export function named(name: string): Role {
    return new Role({ metadata: { name } });
  }
  // Role is a namespaced, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding.
  export interface Interface {
    // Standard object's metadata.
    metadata: apisMetaV1.ObjectMeta;

    // Rules holds all the PolicyRules for this Role
    rules?: PolicyRule[];
  }
}

// RoleBinding references a role, but does not contain it.  It can reference a Role in the same namespace or a ClusterRole in the global namespace. It adds who information via Subjects and namespace information by which namespace it exists in.  RoleBindings in a given namespace only have effect in that namespace.
export class RoleBinding implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata: apisMetaV1.ObjectMeta;

  // RoleRef can reference a Role in the current namespace or a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.
  public roleRef: RoleRef;

  // Subjects holds references to the objects the role applies to.
  public subjects?: Subject[];

  constructor(desc: RoleBinding.Interface) {
    this.apiVersion = RoleBinding.apiVersion;
    this.kind = RoleBinding.kind;
    this.metadata = desc.metadata;
    this.roleRef = desc.roleRef;
    this.subjects = desc.subjects;
  }
}

export function isRoleBinding(o: any): o is RoleBinding {
  return (
    o && o.apiVersion === RoleBinding.apiVersion && o.kind === RoleBinding.kind
  );
}

export namespace RoleBinding {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "RoleBinding";

  // RoleBinding references a role, but does not contain it.  It can reference a Role in the same namespace or a ClusterRole in the global namespace. It adds who information via Subjects and namespace information by which namespace it exists in.  RoleBindings in a given namespace only have effect in that namespace.
  export interface Interface {
    // Standard object's metadata.
    metadata: apisMetaV1.ObjectMeta;

    // RoleRef can reference a Role in the current namespace or a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.
    roleRef: RoleRef;

    // Subjects holds references to the objects the role applies to.
    subjects?: Subject[];
  }
}

// RoleBindingList is a collection of RoleBindings
export class RoleBindingList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of RoleBindings
  public items: RoleBinding[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: RoleBindingList) {
    this.apiVersion = RoleBindingList.apiVersion;
    this.items = desc.items.map(i => new RoleBinding(i));
    this.kind = RoleBindingList.kind;
    this.metadata = desc.metadata;
  }
}

export function isRoleBindingList(o: any): o is RoleBindingList {
  return (
    o &&
    o.apiVersion === RoleBindingList.apiVersion &&
    o.kind === RoleBindingList.kind
  );
}

export namespace RoleBindingList {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "RoleBindingList";

  // RoleBindingList is a collection of RoleBindings
  export interface Interface {
    // Items is a list of RoleBindings
    items: RoleBinding[];

    // Standard object's metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}

// RoleList is a collection of Roles
export class RoleList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of Roles
  public items: Role[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata.
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: RoleList) {
    this.apiVersion = RoleList.apiVersion;
    this.items = desc.items.map(i => new Role(i));
    this.kind = RoleList.kind;
    this.metadata = desc.metadata;
  }
}

export function isRoleList(o: any): o is RoleList {
  return o && o.apiVersion === RoleList.apiVersion && o.kind === RoleList.kind;
}

export namespace RoleList {
  export const apiVersion = "rbac.authorization.k8s.io/v1beta1";
  export const group = "rbac.authorization.k8s.io";
  export const version = "v1beta1";
  export const kind = "RoleList";

  // RoleList is a collection of Roles
  export interface Interface {
    // Items is a list of Roles
    items: Role[];

    // Standard object's metadata.
    metadata?: apisMetaV1.ListMeta;
  }
}

// RoleRef contains information that points to the role being used
export class RoleRef {
  // APIGroup is the group for the resource being referenced
  public apiGroup: string;

  // Kind is the type of resource being referenced
  public kind: string;

  // Name is the name of resource being referenced
  public name: string;

  constructor(desc: RoleRef) {
    this.apiGroup = desc.apiGroup;
    this.kind = desc.kind;
    this.name = desc.name;
  }
}

// Subject contains a reference to the object or user identities a role binding applies to.  This can either hold a direct API object reference, or a value for non-objects such as user and group names.
export class Subject {
  // APIGroup holds the API group of the referenced subject. Defaults to "" for ServiceAccount subjects. Defaults to "rbac.authorization.k8s.io" for User and Group subjects.
  public apiGroup?: string;

  // Kind of object being referenced. Values defined by this API group are "User", "Group", and "ServiceAccount". If the Authorizer does not recognized the kind value, the Authorizer should report an error.
  public kind: string;

  // Name of the object being referenced.
  public name: string;

  // Namespace of the referenced object.  If the object kind is non-namespace, such as "User" or "Group", and this value is not empty the Authorizer should report an error.
  public namespace?: string;

  constructor(desc: Subject) {
    this.apiGroup = desc.apiGroup;
    this.kind = desc.kind;
    this.name = desc.name;
    this.namespace = desc.namespace;
  }
}
