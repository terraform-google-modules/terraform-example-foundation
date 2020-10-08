"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// AggregationRule describes how to locate ClusterRoles to aggregate into the ClusterRole
class AggregationRule {
}
exports.AggregationRule = AggregationRule;
// ClusterRole is a cluster level, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding or ClusterRoleBinding.
class ClusterRole {
    constructor(desc) {
        this.aggregationRule = desc.aggregationRule;
        this.apiVersion = ClusterRole.apiVersion;
        this.kind = ClusterRole.kind;
        this.metadata = desc.metadata;
        this.rules = desc.rules;
    }
}
exports.ClusterRole = ClusterRole;
function isClusterRole(o) {
    return (o && o.apiVersion === ClusterRole.apiVersion && o.kind === ClusterRole.kind);
}
exports.isClusterRole = isClusterRole;
(function (ClusterRole) {
    ClusterRole.apiVersion = "rbac.authorization.k8s.io/v1";
    ClusterRole.group = "rbac.authorization.k8s.io";
    ClusterRole.version = "v1";
    ClusterRole.kind = "ClusterRole";
    // named constructs a ClusterRole with metadata.name set to name.
    function named(name) {
        return new ClusterRole({ metadata: { name } });
    }
    ClusterRole.named = named;
})(ClusterRole = exports.ClusterRole || (exports.ClusterRole = {}));
// ClusterRoleBinding references a ClusterRole, but not contain it.  It can reference a ClusterRole in the global namespace, and adds who information via Subject.
class ClusterRoleBinding {
    constructor(desc) {
        this.apiVersion = ClusterRoleBinding.apiVersion;
        this.kind = ClusterRoleBinding.kind;
        this.metadata = desc.metadata;
        this.roleRef = desc.roleRef;
        this.subjects = desc.subjects;
    }
}
exports.ClusterRoleBinding = ClusterRoleBinding;
function isClusterRoleBinding(o) {
    return (o &&
        o.apiVersion === ClusterRoleBinding.apiVersion &&
        o.kind === ClusterRoleBinding.kind);
}
exports.isClusterRoleBinding = isClusterRoleBinding;
(function (ClusterRoleBinding) {
    ClusterRoleBinding.apiVersion = "rbac.authorization.k8s.io/v1";
    ClusterRoleBinding.group = "rbac.authorization.k8s.io";
    ClusterRoleBinding.version = "v1";
    ClusterRoleBinding.kind = "ClusterRoleBinding";
})(ClusterRoleBinding = exports.ClusterRoleBinding || (exports.ClusterRoleBinding = {}));
// ClusterRoleBindingList is a collection of ClusterRoleBindings
class ClusterRoleBindingList {
    constructor(desc) {
        this.apiVersion = ClusterRoleBindingList.apiVersion;
        this.items = desc.items.map(i => new ClusterRoleBinding(i));
        this.kind = ClusterRoleBindingList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ClusterRoleBindingList = ClusterRoleBindingList;
function isClusterRoleBindingList(o) {
    return (o &&
        o.apiVersion === ClusterRoleBindingList.apiVersion &&
        o.kind === ClusterRoleBindingList.kind);
}
exports.isClusterRoleBindingList = isClusterRoleBindingList;
(function (ClusterRoleBindingList) {
    ClusterRoleBindingList.apiVersion = "rbac.authorization.k8s.io/v1";
    ClusterRoleBindingList.group = "rbac.authorization.k8s.io";
    ClusterRoleBindingList.version = "v1";
    ClusterRoleBindingList.kind = "ClusterRoleBindingList";
})(ClusterRoleBindingList = exports.ClusterRoleBindingList || (exports.ClusterRoleBindingList = {}));
// ClusterRoleList is a collection of ClusterRoles
class ClusterRoleList {
    constructor(desc) {
        this.apiVersion = ClusterRoleList.apiVersion;
        this.items = desc.items.map(i => new ClusterRole(i));
        this.kind = ClusterRoleList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ClusterRoleList = ClusterRoleList;
function isClusterRoleList(o) {
    return (o &&
        o.apiVersion === ClusterRoleList.apiVersion &&
        o.kind === ClusterRoleList.kind);
}
exports.isClusterRoleList = isClusterRoleList;
(function (ClusterRoleList) {
    ClusterRoleList.apiVersion = "rbac.authorization.k8s.io/v1";
    ClusterRoleList.group = "rbac.authorization.k8s.io";
    ClusterRoleList.version = "v1";
    ClusterRoleList.kind = "ClusterRoleList";
})(ClusterRoleList = exports.ClusterRoleList || (exports.ClusterRoleList = {}));
// PolicyRule holds information that describes a policy rule, but does not contain information about who the rule applies to or which namespace the rule applies to.
class PolicyRule {
    constructor(desc) {
        this.apiGroups = desc.apiGroups;
        this.nonResourceURLs = desc.nonResourceURLs;
        this.resourceNames = desc.resourceNames;
        this.resources = desc.resources;
        this.verbs = desc.verbs;
    }
}
exports.PolicyRule = PolicyRule;
// Role is a namespaced, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding.
class Role {
    constructor(desc) {
        this.apiVersion = Role.apiVersion;
        this.kind = Role.kind;
        this.metadata = desc.metadata;
        this.rules = desc.rules;
    }
}
exports.Role = Role;
function isRole(o) {
    return o && o.apiVersion === Role.apiVersion && o.kind === Role.kind;
}
exports.isRole = isRole;
(function (Role) {
    Role.apiVersion = "rbac.authorization.k8s.io/v1";
    Role.group = "rbac.authorization.k8s.io";
    Role.version = "v1";
    Role.kind = "Role";
    // named constructs a Role with metadata.name set to name.
    function named(name) {
        return new Role({ metadata: { name } });
    }
    Role.named = named;
})(Role = exports.Role || (exports.Role = {}));
// RoleBinding references a role, but does not contain it.  It can reference a Role in the same namespace or a ClusterRole in the global namespace. It adds who information via Subjects and namespace information by which namespace it exists in.  RoleBindings in a given namespace only have effect in that namespace.
class RoleBinding {
    constructor(desc) {
        this.apiVersion = RoleBinding.apiVersion;
        this.kind = RoleBinding.kind;
        this.metadata = desc.metadata;
        this.roleRef = desc.roleRef;
        this.subjects = desc.subjects;
    }
}
exports.RoleBinding = RoleBinding;
function isRoleBinding(o) {
    return (o && o.apiVersion === RoleBinding.apiVersion && o.kind === RoleBinding.kind);
}
exports.isRoleBinding = isRoleBinding;
(function (RoleBinding) {
    RoleBinding.apiVersion = "rbac.authorization.k8s.io/v1";
    RoleBinding.group = "rbac.authorization.k8s.io";
    RoleBinding.version = "v1";
    RoleBinding.kind = "RoleBinding";
})(RoleBinding = exports.RoleBinding || (exports.RoleBinding = {}));
// RoleBindingList is a collection of RoleBindings
class RoleBindingList {
    constructor(desc) {
        this.apiVersion = RoleBindingList.apiVersion;
        this.items = desc.items.map(i => new RoleBinding(i));
        this.kind = RoleBindingList.kind;
        this.metadata = desc.metadata;
    }
}
exports.RoleBindingList = RoleBindingList;
function isRoleBindingList(o) {
    return (o &&
        o.apiVersion === RoleBindingList.apiVersion &&
        o.kind === RoleBindingList.kind);
}
exports.isRoleBindingList = isRoleBindingList;
(function (RoleBindingList) {
    RoleBindingList.apiVersion = "rbac.authorization.k8s.io/v1";
    RoleBindingList.group = "rbac.authorization.k8s.io";
    RoleBindingList.version = "v1";
    RoleBindingList.kind = "RoleBindingList";
})(RoleBindingList = exports.RoleBindingList || (exports.RoleBindingList = {}));
// RoleList is a collection of Roles
class RoleList {
    constructor(desc) {
        this.apiVersion = RoleList.apiVersion;
        this.items = desc.items.map(i => new Role(i));
        this.kind = RoleList.kind;
        this.metadata = desc.metadata;
    }
}
exports.RoleList = RoleList;
function isRoleList(o) {
    return o && o.apiVersion === RoleList.apiVersion && o.kind === RoleList.kind;
}
exports.isRoleList = isRoleList;
(function (RoleList) {
    RoleList.apiVersion = "rbac.authorization.k8s.io/v1";
    RoleList.group = "rbac.authorization.k8s.io";
    RoleList.version = "v1";
    RoleList.kind = "RoleList";
})(RoleList = exports.RoleList || (exports.RoleList = {}));
// RoleRef contains information that points to the role being used
class RoleRef {
    constructor(desc) {
        this.apiGroup = desc.apiGroup;
        this.kind = desc.kind;
        this.name = desc.name;
    }
}
exports.RoleRef = RoleRef;
// Subject contains a reference to the object or user identities a role binding applies to.  This can either hold a direct API object reference, or a value for non-objects such as user and group names.
class Subject {
    constructor(desc) {
        this.apiGroup = desc.apiGroup;
        this.kind = desc.kind;
        this.name = desc.name;
        this.namespace = desc.namespace;
    }
}
exports.Subject = Subject;
//# sourceMappingURL=io.k8s.api.rbac.v1.js.map