"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// CrossVersionObjectReference contains enough information to let you identify the referred resource.
class CrossVersionObjectReference {
    constructor(desc) {
        this.apiVersion = desc.apiVersion;
        this.kind = desc.kind;
        this.name = desc.name;
    }
}
exports.CrossVersionObjectReference = CrossVersionObjectReference;
// configuration of a horizontal pod autoscaler.
class HorizontalPodAutoscaler {
    constructor(desc) {
        this.apiVersion = HorizontalPodAutoscaler.apiVersion;
        this.kind = HorizontalPodAutoscaler.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.HorizontalPodAutoscaler = HorizontalPodAutoscaler;
function isHorizontalPodAutoscaler(o) {
    return (o &&
        o.apiVersion === HorizontalPodAutoscaler.apiVersion &&
        o.kind === HorizontalPodAutoscaler.kind);
}
exports.isHorizontalPodAutoscaler = isHorizontalPodAutoscaler;
(function (HorizontalPodAutoscaler) {
    HorizontalPodAutoscaler.apiVersion = "autoscaling/v1";
    HorizontalPodAutoscaler.group = "autoscaling";
    HorizontalPodAutoscaler.version = "v1";
    HorizontalPodAutoscaler.kind = "HorizontalPodAutoscaler";
    // named constructs a HorizontalPodAutoscaler with metadata.name set to name.
    function named(name) {
        return new HorizontalPodAutoscaler({ metadata: { name } });
    }
    HorizontalPodAutoscaler.named = named;
})(HorizontalPodAutoscaler = exports.HorizontalPodAutoscaler || (exports.HorizontalPodAutoscaler = {}));
// list of horizontal pod autoscaler objects.
class HorizontalPodAutoscalerList {
    constructor(desc) {
        this.apiVersion = HorizontalPodAutoscalerList.apiVersion;
        this.items = desc.items.map(i => new HorizontalPodAutoscaler(i));
        this.kind = HorizontalPodAutoscalerList.kind;
        this.metadata = desc.metadata;
    }
}
exports.HorizontalPodAutoscalerList = HorizontalPodAutoscalerList;
function isHorizontalPodAutoscalerList(o) {
    return (o &&
        o.apiVersion === HorizontalPodAutoscalerList.apiVersion &&
        o.kind === HorizontalPodAutoscalerList.kind);
}
exports.isHorizontalPodAutoscalerList = isHorizontalPodAutoscalerList;
(function (HorizontalPodAutoscalerList) {
    HorizontalPodAutoscalerList.apiVersion = "autoscaling/v1";
    HorizontalPodAutoscalerList.group = "autoscaling";
    HorizontalPodAutoscalerList.version = "v1";
    HorizontalPodAutoscalerList.kind = "HorizontalPodAutoscalerList";
})(HorizontalPodAutoscalerList = exports.HorizontalPodAutoscalerList || (exports.HorizontalPodAutoscalerList = {}));
// specification of a horizontal pod autoscaler.
class HorizontalPodAutoscalerSpec {
    constructor(desc) {
        this.maxReplicas = desc.maxReplicas;
        this.minReplicas = desc.minReplicas;
        this.scaleTargetRef = desc.scaleTargetRef;
        this.targetCPUUtilizationPercentage = desc.targetCPUUtilizationPercentage;
    }
}
exports.HorizontalPodAutoscalerSpec = HorizontalPodAutoscalerSpec;
// current status of a horizontal pod autoscaler
class HorizontalPodAutoscalerStatus {
    constructor(desc) {
        this.currentCPUUtilizationPercentage = desc.currentCPUUtilizationPercentage;
        this.currentReplicas = desc.currentReplicas;
        this.desiredReplicas = desc.desiredReplicas;
        this.lastScaleTime = desc.lastScaleTime;
        this.observedGeneration = desc.observedGeneration;
    }
}
exports.HorizontalPodAutoscalerStatus = HorizontalPodAutoscalerStatus;
// Scale represents a scaling request for a resource.
class Scale {
    constructor(desc) {
        this.apiVersion = Scale.apiVersion;
        this.kind = Scale.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Scale = Scale;
function isScale(o) {
    return o && o.apiVersion === Scale.apiVersion && o.kind === Scale.kind;
}
exports.isScale = isScale;
(function (Scale) {
    Scale.apiVersion = "autoscaling/v1";
    Scale.group = "autoscaling";
    Scale.version = "v1";
    Scale.kind = "Scale";
    // named constructs a Scale with metadata.name set to name.
    function named(name) {
        return new Scale({ metadata: { name } });
    }
    Scale.named = named;
})(Scale = exports.Scale || (exports.Scale = {}));
// ScaleSpec describes the attributes of a scale subresource.
class ScaleSpec {
}
exports.ScaleSpec = ScaleSpec;
// ScaleStatus represents the current status of a scale subresource.
class ScaleStatus {
    constructor(desc) {
        this.replicas = desc.replicas;
        this.selector = desc.selector;
    }
}
exports.ScaleStatus = ScaleStatus;
//# sourceMappingURL=io.k8s.api.autoscaling.v1.js.map