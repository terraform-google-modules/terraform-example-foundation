"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// LocalSubjectAccessReview checks whether or not a user or group can perform an action in a given namespace. Having a namespace scoped resource makes it much easier to grant namespace scoped policy that includes permissions checking.
class LocalSubjectAccessReview {
    constructor(desc) {
        this.apiVersion = LocalSubjectAccessReview.apiVersion;
        this.kind = LocalSubjectAccessReview.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.LocalSubjectAccessReview = LocalSubjectAccessReview;
function isLocalSubjectAccessReview(o) {
    return (o &&
        o.apiVersion === LocalSubjectAccessReview.apiVersion &&
        o.kind === LocalSubjectAccessReview.kind);
}
exports.isLocalSubjectAccessReview = isLocalSubjectAccessReview;
(function (LocalSubjectAccessReview) {
    LocalSubjectAccessReview.apiVersion = "authorization.k8s.io/v1";
    LocalSubjectAccessReview.group = "authorization.k8s.io";
    LocalSubjectAccessReview.version = "v1";
    LocalSubjectAccessReview.kind = "LocalSubjectAccessReview";
})(LocalSubjectAccessReview = exports.LocalSubjectAccessReview || (exports.LocalSubjectAccessReview = {}));
// NonResourceAttributes includes the authorization attributes available for non-resource requests to the Authorizer interface
class NonResourceAttributes {
}
exports.NonResourceAttributes = NonResourceAttributes;
// NonResourceRule holds information that describes a rule for the non-resource
class NonResourceRule {
    constructor(desc) {
        this.nonResourceURLs = desc.nonResourceURLs;
        this.verbs = desc.verbs;
    }
}
exports.NonResourceRule = NonResourceRule;
// ResourceAttributes includes the authorization attributes available for resource requests to the Authorizer interface
class ResourceAttributes {
}
exports.ResourceAttributes = ResourceAttributes;
// ResourceRule is the list of actions the subject is allowed to perform on resources. The list ordering isn't significant, may contain duplicates, and possibly be incomplete.
class ResourceRule {
    constructor(desc) {
        this.apiGroups = desc.apiGroups;
        this.resourceNames = desc.resourceNames;
        this.resources = desc.resources;
        this.verbs = desc.verbs;
    }
}
exports.ResourceRule = ResourceRule;
// SelfSubjectAccessReview checks whether or the current user can perform an action.  Not filling in a spec.namespace means "in all namespaces".  Self is a special case, because users should always be able to check whether they can perform an action
class SelfSubjectAccessReview {
    constructor(desc) {
        this.apiVersion = SelfSubjectAccessReview.apiVersion;
        this.kind = SelfSubjectAccessReview.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.SelfSubjectAccessReview = SelfSubjectAccessReview;
function isSelfSubjectAccessReview(o) {
    return (o &&
        o.apiVersion === SelfSubjectAccessReview.apiVersion &&
        o.kind === SelfSubjectAccessReview.kind);
}
exports.isSelfSubjectAccessReview = isSelfSubjectAccessReview;
(function (SelfSubjectAccessReview) {
    SelfSubjectAccessReview.apiVersion = "authorization.k8s.io/v1";
    SelfSubjectAccessReview.group = "authorization.k8s.io";
    SelfSubjectAccessReview.version = "v1";
    SelfSubjectAccessReview.kind = "SelfSubjectAccessReview";
})(SelfSubjectAccessReview = exports.SelfSubjectAccessReview || (exports.SelfSubjectAccessReview = {}));
// SelfSubjectAccessReviewSpec is a description of the access request.  Exactly one of ResourceAuthorizationAttributes and NonResourceAuthorizationAttributes must be set
class SelfSubjectAccessReviewSpec {
}
exports.SelfSubjectAccessReviewSpec = SelfSubjectAccessReviewSpec;
// SelfSubjectRulesReview enumerates the set of actions the current user can perform within a namespace. The returned list of actions may be incomplete depending on the server's authorization mode, and any errors experienced during the evaluation. SelfSubjectRulesReview should be used by UIs to show/hide actions, or to quickly let an end user reason about their permissions. It should NOT Be used by external systems to drive authorization decisions as this raises confused deputy, cache lifetime/revocation, and correctness concerns. SubjectAccessReview, and LocalAccessReview are the correct way to defer authorization decisions to the API server.
class SelfSubjectRulesReview {
    constructor(desc) {
        this.apiVersion = SelfSubjectRulesReview.apiVersion;
        this.kind = SelfSubjectRulesReview.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.SelfSubjectRulesReview = SelfSubjectRulesReview;
function isSelfSubjectRulesReview(o) {
    return (o &&
        o.apiVersion === SelfSubjectRulesReview.apiVersion &&
        o.kind === SelfSubjectRulesReview.kind);
}
exports.isSelfSubjectRulesReview = isSelfSubjectRulesReview;
(function (SelfSubjectRulesReview) {
    SelfSubjectRulesReview.apiVersion = "authorization.k8s.io/v1";
    SelfSubjectRulesReview.group = "authorization.k8s.io";
    SelfSubjectRulesReview.version = "v1";
    SelfSubjectRulesReview.kind = "SelfSubjectRulesReview";
})(SelfSubjectRulesReview = exports.SelfSubjectRulesReview || (exports.SelfSubjectRulesReview = {}));
class SelfSubjectRulesReviewSpec {
}
exports.SelfSubjectRulesReviewSpec = SelfSubjectRulesReviewSpec;
// SubjectAccessReview checks whether or not a user or group can perform an action.
class SubjectAccessReview {
    constructor(desc) {
        this.apiVersion = SubjectAccessReview.apiVersion;
        this.kind = SubjectAccessReview.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.SubjectAccessReview = SubjectAccessReview;
function isSubjectAccessReview(o) {
    return (o &&
        o.apiVersion === SubjectAccessReview.apiVersion &&
        o.kind === SubjectAccessReview.kind);
}
exports.isSubjectAccessReview = isSubjectAccessReview;
(function (SubjectAccessReview) {
    SubjectAccessReview.apiVersion = "authorization.k8s.io/v1";
    SubjectAccessReview.group = "authorization.k8s.io";
    SubjectAccessReview.version = "v1";
    SubjectAccessReview.kind = "SubjectAccessReview";
})(SubjectAccessReview = exports.SubjectAccessReview || (exports.SubjectAccessReview = {}));
// SubjectAccessReviewSpec is a description of the access request.  Exactly one of ResourceAuthorizationAttributes and NonResourceAuthorizationAttributes must be set
class SubjectAccessReviewSpec {
}
exports.SubjectAccessReviewSpec = SubjectAccessReviewSpec;
// SubjectAccessReviewStatus
class SubjectAccessReviewStatus {
    constructor(desc) {
        this.allowed = desc.allowed;
        this.denied = desc.denied;
        this.evaluationError = desc.evaluationError;
        this.reason = desc.reason;
    }
}
exports.SubjectAccessReviewStatus = SubjectAccessReviewStatus;
// SubjectRulesReviewStatus contains the result of a rules check. This check can be incomplete depending on the set of authorizers the server is configured with and any errors experienced during evaluation. Because authorization rules are additive, if a rule appears in a list it's safe to assume the subject has that permission, even if that list is incomplete.
class SubjectRulesReviewStatus {
    constructor(desc) {
        this.evaluationError = desc.evaluationError;
        this.incomplete = desc.incomplete;
        this.nonResourceRules = desc.nonResourceRules;
        this.resourceRules = desc.resourceRules;
    }
}
exports.SubjectRulesReviewStatus = SubjectRulesReviewStatus;
//# sourceMappingURL=io.k8s.api.authorization.v1.js.map