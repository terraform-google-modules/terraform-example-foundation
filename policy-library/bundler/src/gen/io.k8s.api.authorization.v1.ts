import { KubernetesObject } from "kpt-functions";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// LocalSubjectAccessReview checks whether or not a user or group can perform an action in a given namespace. Having a namespace scoped resource makes it much easier to grant namespace scoped policy that includes permissions checking.
export class LocalSubjectAccessReview implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Spec holds information about the request being evaluated.  spec.namespace must be equal to the namespace you made the request against.  If empty, it is defaulted.
  public spec: SubjectAccessReviewSpec;

  // Status is filled in by the server and indicates whether the request is allowed or not
  public status?: SubjectAccessReviewStatus;

  constructor(desc: LocalSubjectAccessReview.Interface) {
    this.apiVersion = LocalSubjectAccessReview.apiVersion;
    this.kind = LocalSubjectAccessReview.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isLocalSubjectAccessReview(
  o: any
): o is LocalSubjectAccessReview {
  return (
    o &&
    o.apiVersion === LocalSubjectAccessReview.apiVersion &&
    o.kind === LocalSubjectAccessReview.kind
  );
}

export namespace LocalSubjectAccessReview {
  export const apiVersion = "authorization.k8s.io/v1";
  export const group = "authorization.k8s.io";
  export const version = "v1";
  export const kind = "LocalSubjectAccessReview";

  // LocalSubjectAccessReview checks whether or not a user or group can perform an action in a given namespace. Having a namespace scoped resource makes it much easier to grant namespace scoped policy that includes permissions checking.
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Spec holds information about the request being evaluated.  spec.namespace must be equal to the namespace you made the request against.  If empty, it is defaulted.
    spec: SubjectAccessReviewSpec;

    // Status is filled in by the server and indicates whether the request is allowed or not
    status?: SubjectAccessReviewStatus;
  }
}

// NonResourceAttributes includes the authorization attributes available for non-resource requests to the Authorizer interface
export class NonResourceAttributes {
  // Path is the URL path of the request
  public path?: string;

  // Verb is the standard HTTP verb
  public verb?: string;
}

// NonResourceRule holds information that describes a rule for the non-resource
export class NonResourceRule {
  // NonResourceURLs is a set of partial urls that a user should have access to.  *s are allowed, but only as the full, final step in the path.  "*" means all.
  public nonResourceURLs?: string[];

  // Verb is a list of kubernetes non-resource API verbs, like: get, post, put, delete, patch, head, options.  "*" means all.
  public verbs: string[];

  constructor(desc: NonResourceRule) {
    this.nonResourceURLs = desc.nonResourceURLs;
    this.verbs = desc.verbs;
  }
}

// ResourceAttributes includes the authorization attributes available for resource requests to the Authorizer interface
export class ResourceAttributes {
  // Group is the API Group of the Resource.  "*" means all.
  public group?: string;

  // Name is the name of the resource being requested for a "get" or deleted for a "delete". "" (empty) means all.
  public name?: string;

  // Namespace is the namespace of the action being requested.  Currently, there is no distinction between no namespace and all namespaces "" (empty) is defaulted for LocalSubjectAccessReviews "" (empty) is empty for cluster-scoped resources "" (empty) means "all" for namespace scoped resources from a SubjectAccessReview or SelfSubjectAccessReview
  public namespace?: string;

  // Resource is one of the existing resource types.  "*" means all.
  public resource?: string;

  // Subresource is one of the existing resource types.  "" means none.
  public subresource?: string;

  // Verb is a kubernetes resource API verb, like: get, list, watch, create, update, delete, proxy.  "*" means all.
  public verb?: string;

  // Version is the API Version of the Resource.  "*" means all.
  public version?: string;
}

// ResourceRule is the list of actions the subject is allowed to perform on resources. The list ordering isn't significant, may contain duplicates, and possibly be incomplete.
export class ResourceRule {
  // APIGroups is the name of the APIGroup that contains the resources.  If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.  "*" means all.
  public apiGroups?: string[];

  // ResourceNames is an optional white list of names that the rule applies to.  An empty set means that everything is allowed.  "*" means all.
  public resourceNames?: string[];

  // Resources is a list of resources this rule applies to.  "*" means all in the specified apiGroups.
  //  "*/foo" represents the subresource 'foo' for all resources in the specified apiGroups.
  public resources?: string[];

  // Verb is a list of kubernetes resource API verbs, like: get, list, watch, create, update, delete, proxy.  "*" means all.
  public verbs: string[];

  constructor(desc: ResourceRule) {
    this.apiGroups = desc.apiGroups;
    this.resourceNames = desc.resourceNames;
    this.resources = desc.resources;
    this.verbs = desc.verbs;
  }
}

// SelfSubjectAccessReview checks whether or the current user can perform an action.  Not filling in a spec.namespace means "in all namespaces".  Self is a special case, because users should always be able to check whether they can perform an action
export class SelfSubjectAccessReview implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Spec holds information about the request being evaluated.  user and groups must be empty
  public spec: SelfSubjectAccessReviewSpec;

  // Status is filled in by the server and indicates whether the request is allowed or not
  public status?: SubjectAccessReviewStatus;

  constructor(desc: SelfSubjectAccessReview.Interface) {
    this.apiVersion = SelfSubjectAccessReview.apiVersion;
    this.kind = SelfSubjectAccessReview.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isSelfSubjectAccessReview(
  o: any
): o is SelfSubjectAccessReview {
  return (
    o &&
    o.apiVersion === SelfSubjectAccessReview.apiVersion &&
    o.kind === SelfSubjectAccessReview.kind
  );
}

export namespace SelfSubjectAccessReview {
  export const apiVersion = "authorization.k8s.io/v1";
  export const group = "authorization.k8s.io";
  export const version = "v1";
  export const kind = "SelfSubjectAccessReview";

  // SelfSubjectAccessReview checks whether or the current user can perform an action.  Not filling in a spec.namespace means "in all namespaces".  Self is a special case, because users should always be able to check whether they can perform an action
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Spec holds information about the request being evaluated.  user and groups must be empty
    spec: SelfSubjectAccessReviewSpec;

    // Status is filled in by the server and indicates whether the request is allowed or not
    status?: SubjectAccessReviewStatus;
  }
}

// SelfSubjectAccessReviewSpec is a description of the access request.  Exactly one of ResourceAuthorizationAttributes and NonResourceAuthorizationAttributes must be set
export class SelfSubjectAccessReviewSpec {
  // NonResourceAttributes describes information for a non-resource access request
  public nonResourceAttributes?: NonResourceAttributes;

  // ResourceAuthorizationAttributes describes information for a resource access request
  public resourceAttributes?: ResourceAttributes;
}

// SelfSubjectRulesReview enumerates the set of actions the current user can perform within a namespace. The returned list of actions may be incomplete depending on the server's authorization mode, and any errors experienced during the evaluation. SelfSubjectRulesReview should be used by UIs to show/hide actions, or to quickly let an end user reason about their permissions. It should NOT Be used by external systems to drive authorization decisions as this raises confused deputy, cache lifetime/revocation, and correctness concerns. SubjectAccessReview, and LocalAccessReview are the correct way to defer authorization decisions to the API server.
export class SelfSubjectRulesReview implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Spec holds information about the request being evaluated.
  public spec: SelfSubjectRulesReviewSpec;

  // Status is filled in by the server and indicates the set of actions a user can perform.
  public status?: SubjectRulesReviewStatus;

  constructor(desc: SelfSubjectRulesReview.Interface) {
    this.apiVersion = SelfSubjectRulesReview.apiVersion;
    this.kind = SelfSubjectRulesReview.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isSelfSubjectRulesReview(o: any): o is SelfSubjectRulesReview {
  return (
    o &&
    o.apiVersion === SelfSubjectRulesReview.apiVersion &&
    o.kind === SelfSubjectRulesReview.kind
  );
}

export namespace SelfSubjectRulesReview {
  export const apiVersion = "authorization.k8s.io/v1";
  export const group = "authorization.k8s.io";
  export const version = "v1";
  export const kind = "SelfSubjectRulesReview";

  // SelfSubjectRulesReview enumerates the set of actions the current user can perform within a namespace. The returned list of actions may be incomplete depending on the server's authorization mode, and any errors experienced during the evaluation. SelfSubjectRulesReview should be used by UIs to show/hide actions, or to quickly let an end user reason about their permissions. It should NOT Be used by external systems to drive authorization decisions as this raises confused deputy, cache lifetime/revocation, and correctness concerns. SubjectAccessReview, and LocalAccessReview are the correct way to defer authorization decisions to the API server.
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Spec holds information about the request being evaluated.
    spec: SelfSubjectRulesReviewSpec;

    // Status is filled in by the server and indicates the set of actions a user can perform.
    status?: SubjectRulesReviewStatus;
  }
}

export class SelfSubjectRulesReviewSpec {
  // Namespace to evaluate rules for. Required.
  public namespace?: string;
}

// SubjectAccessReview checks whether or not a user or group can perform an action.
export class SubjectAccessReview implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Spec holds information about the request being evaluated
  public spec: SubjectAccessReviewSpec;

  // Status is filled in by the server and indicates whether the request is allowed or not
  public status?: SubjectAccessReviewStatus;

  constructor(desc: SubjectAccessReview.Interface) {
    this.apiVersion = SubjectAccessReview.apiVersion;
    this.kind = SubjectAccessReview.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isSubjectAccessReview(o: any): o is SubjectAccessReview {
  return (
    o &&
    o.apiVersion === SubjectAccessReview.apiVersion &&
    o.kind === SubjectAccessReview.kind
  );
}

export namespace SubjectAccessReview {
  export const apiVersion = "authorization.k8s.io/v1";
  export const group = "authorization.k8s.io";
  export const version = "v1";
  export const kind = "SubjectAccessReview";

  // SubjectAccessReview checks whether or not a user or group can perform an action.
  export interface Interface {
    metadata: apisMetaV1.ObjectMeta;

    // Spec holds information about the request being evaluated
    spec: SubjectAccessReviewSpec;

    // Status is filled in by the server and indicates whether the request is allowed or not
    status?: SubjectAccessReviewStatus;
  }
}

// SubjectAccessReviewSpec is a description of the access request.  Exactly one of ResourceAuthorizationAttributes and NonResourceAuthorizationAttributes must be set
export class SubjectAccessReviewSpec {
  // Extra corresponds to the user.Info.GetExtra() method from the authenticator.  Since that is input to the authorizer it needs a reflection here.
  public extra?: { [key: string]: string[] };

  // Groups is the groups you're testing for.
  public groups?: string[];

  // NonResourceAttributes describes information for a non-resource access request
  public nonResourceAttributes?: NonResourceAttributes;

  // ResourceAuthorizationAttributes describes information for a resource access request
  public resourceAttributes?: ResourceAttributes;

  // UID information about the requesting user.
  public uid?: string;

  // User is the user you're testing for. If you specify "User" but not "Groups", then is it interpreted as "What if User were not a member of any groups
  public user?: string;
}

// SubjectAccessReviewStatus
export class SubjectAccessReviewStatus {
  // Allowed is required. True if the action would be allowed, false otherwise.
  public allowed: boolean;

  // Denied is optional. True if the action would be denied, otherwise false. If both allowed is false and denied is false, then the authorizer has no opinion on whether to authorize the action. Denied may not be true if Allowed is true.
  public denied?: boolean;

  // EvaluationError is an indication that some error occurred during the authorization check. It is entirely possible to get an error and be able to continue determine authorization status in spite of it. For instance, RBAC can be missing a role, but enough roles are still present and bound to reason about the request.
  public evaluationError?: string;

  // Reason is optional.  It indicates why a request was allowed or denied.
  public reason?: string;

  constructor(desc: SubjectAccessReviewStatus) {
    this.allowed = desc.allowed;
    this.denied = desc.denied;
    this.evaluationError = desc.evaluationError;
    this.reason = desc.reason;
  }
}

// SubjectRulesReviewStatus contains the result of a rules check. This check can be incomplete depending on the set of authorizers the server is configured with and any errors experienced during evaluation. Because authorization rules are additive, if a rule appears in a list it's safe to assume the subject has that permission, even if that list is incomplete.
export class SubjectRulesReviewStatus {
  // EvaluationError can appear in combination with Rules. It indicates an error occurred during rule evaluation, such as an authorizer that doesn't support rule evaluation, and that ResourceRules and/or NonResourceRules may be incomplete.
  public evaluationError?: string;

  // Incomplete is true when the rules returned by this call are incomplete. This is most commonly encountered when an authorizer, such as an external authorizer, doesn't support rules evaluation.
  public incomplete: boolean;

  // NonResourceRules is the list of actions the subject is allowed to perform on non-resources. The list ordering isn't significant, may contain duplicates, and possibly be incomplete.
  public nonResourceRules: NonResourceRule[];

  // ResourceRules is the list of actions the subject is allowed to perform on resources. The list ordering isn't significant, may contain duplicates, and possibly be incomplete.
  public resourceRules: ResourceRule[];

  constructor(desc: SubjectRulesReviewStatus) {
    this.evaluationError = desc.evaluationError;
    this.incomplete = desc.incomplete;
    this.nonResourceRules = desc.nonResourceRules;
    this.resourceRules = desc.resourceRules;
  }
}
