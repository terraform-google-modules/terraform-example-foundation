"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// RuntimeClass defines a class of container runtime supported in the cluster. The RuntimeClass is used to determine which container runtime is used to run all containers in a pod. RuntimeClasses are (currently) manually defined by a user or cluster provisioner, and referenced in the PodSpec. The Kubelet is responsible for resolving the RuntimeClassName reference before running the pod.  For more details, see https://git.k8s.io/enhancements/keps/sig-node/runtime-class.md
class RuntimeClass {
    constructor(desc) {
        this.apiVersion = RuntimeClass.apiVersion;
        this.handler = desc.handler;
        this.kind = RuntimeClass.kind;
        this.metadata = desc.metadata;
    }
}
exports.RuntimeClass = RuntimeClass;
function isRuntimeClass(o) {
    return (o &&
        o.apiVersion === RuntimeClass.apiVersion &&
        o.kind === RuntimeClass.kind);
}
exports.isRuntimeClass = isRuntimeClass;
(function (RuntimeClass) {
    RuntimeClass.apiVersion = "node.k8s.io/v1beta1";
    RuntimeClass.group = "node.k8s.io";
    RuntimeClass.version = "v1beta1";
    RuntimeClass.kind = "RuntimeClass";
})(RuntimeClass = exports.RuntimeClass || (exports.RuntimeClass = {}));
// RuntimeClassList is a list of RuntimeClass objects.
class RuntimeClassList {
    constructor(desc) {
        this.apiVersion = RuntimeClassList.apiVersion;
        this.items = desc.items.map(i => new RuntimeClass(i));
        this.kind = RuntimeClassList.kind;
        this.metadata = desc.metadata;
    }
}
exports.RuntimeClassList = RuntimeClassList;
function isRuntimeClassList(o) {
    return (o &&
        o.apiVersion === RuntimeClassList.apiVersion &&
        o.kind === RuntimeClassList.kind);
}
exports.isRuntimeClassList = isRuntimeClassList;
(function (RuntimeClassList) {
    RuntimeClassList.apiVersion = "node.k8s.io/v1beta1";
    RuntimeClassList.group = "node.k8s.io";
    RuntimeClassList.version = "v1beta1";
    RuntimeClassList.kind = "RuntimeClassList";
})(RuntimeClassList = exports.RuntimeClassList || (exports.RuntimeClassList = {}));
//# sourceMappingURL=io.k8s.api.node.v1beta1.js.map