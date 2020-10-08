"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// PriorityClass defines mapping from a priority class name to the priority integer value. The value can be any valid integer.
class PriorityClass {
    constructor(desc) {
        this.apiVersion = PriorityClass.apiVersion;
        this.description = desc.description;
        this.globalDefault = desc.globalDefault;
        this.kind = PriorityClass.kind;
        this.metadata = desc.metadata;
        this.value = desc.value;
    }
}
exports.PriorityClass = PriorityClass;
function isPriorityClass(o) {
    return (o &&
        o.apiVersion === PriorityClass.apiVersion &&
        o.kind === PriorityClass.kind);
}
exports.isPriorityClass = isPriorityClass;
(function (PriorityClass) {
    PriorityClass.apiVersion = "scheduling.k8s.io/v1";
    PriorityClass.group = "scheduling.k8s.io";
    PriorityClass.version = "v1";
    PriorityClass.kind = "PriorityClass";
})(PriorityClass = exports.PriorityClass || (exports.PriorityClass = {}));
// PriorityClassList is a collection of priority classes.
class PriorityClassList {
    constructor(desc) {
        this.apiVersion = PriorityClassList.apiVersion;
        this.items = desc.items.map(i => new PriorityClass(i));
        this.kind = PriorityClassList.kind;
        this.metadata = desc.metadata;
    }
}
exports.PriorityClassList = PriorityClassList;
function isPriorityClassList(o) {
    return (o &&
        o.apiVersion === PriorityClassList.apiVersion &&
        o.kind === PriorityClassList.kind);
}
exports.isPriorityClassList = isPriorityClassList;
(function (PriorityClassList) {
    PriorityClassList.apiVersion = "scheduling.k8s.io/v1";
    PriorityClassList.group = "scheduling.k8s.io";
    PriorityClassList.version = "v1";
    PriorityClassList.kind = "PriorityClassList";
})(PriorityClassList = exports.PriorityClassList || (exports.PriorityClassList = {}));
//# sourceMappingURL=io.k8s.api.scheduling.v1.js.map