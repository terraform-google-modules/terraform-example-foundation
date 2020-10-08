"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// MutatingWebhook describes an admission webhook and the resources and operations it applies to.
class MutatingWebhook {
    constructor(desc) {
        this.admissionReviewVersions = desc.admissionReviewVersions;
        this.clientConfig = desc.clientConfig;
        this.failurePolicy = desc.failurePolicy;
        this.matchPolicy = desc.matchPolicy;
        this.name = desc.name;
        this.namespaceSelector = desc.namespaceSelector;
        this.objectSelector = desc.objectSelector;
        this.reinvocationPolicy = desc.reinvocationPolicy;
        this.rules = desc.rules;
        this.sideEffects = desc.sideEffects;
        this.timeoutSeconds = desc.timeoutSeconds;
    }
}
exports.MutatingWebhook = MutatingWebhook;
// MutatingWebhookConfiguration describes the configuration of and admission webhook that accept or reject and may change the object.
class MutatingWebhookConfiguration {
    constructor(desc) {
        this.apiVersion = MutatingWebhookConfiguration.apiVersion;
        this.kind = MutatingWebhookConfiguration.kind;
        this.metadata = desc.metadata;
        this.webhooks = desc.webhooks;
    }
}
exports.MutatingWebhookConfiguration = MutatingWebhookConfiguration;
function isMutatingWebhookConfiguration(o) {
    return o && o.apiVersion === MutatingWebhookConfiguration.apiVersion && o.kind === MutatingWebhookConfiguration.kind;
}
exports.isMutatingWebhookConfiguration = isMutatingWebhookConfiguration;
(function (MutatingWebhookConfiguration) {
    MutatingWebhookConfiguration.apiVersion = "admissionregistration.k8s.io/v1";
    MutatingWebhookConfiguration.group = "admissionregistration.k8s.io";
    MutatingWebhookConfiguration.version = "v1";
    MutatingWebhookConfiguration.kind = "MutatingWebhookConfiguration";
    // named constructs a MutatingWebhookConfiguration with metadata.name set to name.
    function named(name) {
        return new MutatingWebhookConfiguration({ metadata: { name } });
    }
    MutatingWebhookConfiguration.named = named;
})(MutatingWebhookConfiguration = exports.MutatingWebhookConfiguration || (exports.MutatingWebhookConfiguration = {}));
// MutatingWebhookConfigurationList is a list of MutatingWebhookConfiguration.
class MutatingWebhookConfigurationList {
    constructor(desc) {
        this.apiVersion = MutatingWebhookConfigurationList.apiVersion;
        this.items = desc.items.map((i) => new MutatingWebhookConfiguration(i));
        this.kind = MutatingWebhookConfigurationList.kind;
        this.metadata = desc.metadata;
    }
}
exports.MutatingWebhookConfigurationList = MutatingWebhookConfigurationList;
function isMutatingWebhookConfigurationList(o) {
    return o && o.apiVersion === MutatingWebhookConfigurationList.apiVersion && o.kind === MutatingWebhookConfigurationList.kind;
}
exports.isMutatingWebhookConfigurationList = isMutatingWebhookConfigurationList;
(function (MutatingWebhookConfigurationList) {
    MutatingWebhookConfigurationList.apiVersion = "admissionregistration.k8s.io/v1";
    MutatingWebhookConfigurationList.group = "admissionregistration.k8s.io";
    MutatingWebhookConfigurationList.version = "v1";
    MutatingWebhookConfigurationList.kind = "MutatingWebhookConfigurationList";
})(MutatingWebhookConfigurationList = exports.MutatingWebhookConfigurationList || (exports.MutatingWebhookConfigurationList = {}));
// RuleWithOperations is a tuple of Operations and Resources. It is recommended to make sure that all the tuple expansions are valid.
class RuleWithOperations {
}
exports.RuleWithOperations = RuleWithOperations;
// ServiceReference holds a reference to Service.legacy.k8s.io
class ServiceReference {
    constructor(desc) {
        this.name = desc.name;
        this.namespace = desc.namespace;
        this.path = desc.path;
        this.port = desc.port;
    }
}
exports.ServiceReference = ServiceReference;
// ValidatingWebhook describes an admission webhook and the resources and operations it applies to.
class ValidatingWebhook {
    constructor(desc) {
        this.admissionReviewVersions = desc.admissionReviewVersions;
        this.clientConfig = desc.clientConfig;
        this.failurePolicy = desc.failurePolicy;
        this.matchPolicy = desc.matchPolicy;
        this.name = desc.name;
        this.namespaceSelector = desc.namespaceSelector;
        this.objectSelector = desc.objectSelector;
        this.rules = desc.rules;
        this.sideEffects = desc.sideEffects;
        this.timeoutSeconds = desc.timeoutSeconds;
    }
}
exports.ValidatingWebhook = ValidatingWebhook;
// ValidatingWebhookConfiguration describes the configuration of and admission webhook that accept or reject and object without changing it.
class ValidatingWebhookConfiguration {
    constructor(desc) {
        this.apiVersion = ValidatingWebhookConfiguration.apiVersion;
        this.kind = ValidatingWebhookConfiguration.kind;
        this.metadata = desc.metadata;
        this.webhooks = desc.webhooks;
    }
}
exports.ValidatingWebhookConfiguration = ValidatingWebhookConfiguration;
function isValidatingWebhookConfiguration(o) {
    return o && o.apiVersion === ValidatingWebhookConfiguration.apiVersion && o.kind === ValidatingWebhookConfiguration.kind;
}
exports.isValidatingWebhookConfiguration = isValidatingWebhookConfiguration;
(function (ValidatingWebhookConfiguration) {
    ValidatingWebhookConfiguration.apiVersion = "admissionregistration.k8s.io/v1";
    ValidatingWebhookConfiguration.group = "admissionregistration.k8s.io";
    ValidatingWebhookConfiguration.version = "v1";
    ValidatingWebhookConfiguration.kind = "ValidatingWebhookConfiguration";
    // named constructs a ValidatingWebhookConfiguration with metadata.name set to name.
    function named(name) {
        return new ValidatingWebhookConfiguration({ metadata: { name } });
    }
    ValidatingWebhookConfiguration.named = named;
})(ValidatingWebhookConfiguration = exports.ValidatingWebhookConfiguration || (exports.ValidatingWebhookConfiguration = {}));
// ValidatingWebhookConfigurationList is a list of ValidatingWebhookConfiguration.
class ValidatingWebhookConfigurationList {
    constructor(desc) {
        this.apiVersion = ValidatingWebhookConfigurationList.apiVersion;
        this.items = desc.items.map((i) => new ValidatingWebhookConfiguration(i));
        this.kind = ValidatingWebhookConfigurationList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ValidatingWebhookConfigurationList = ValidatingWebhookConfigurationList;
function isValidatingWebhookConfigurationList(o) {
    return o && o.apiVersion === ValidatingWebhookConfigurationList.apiVersion && o.kind === ValidatingWebhookConfigurationList.kind;
}
exports.isValidatingWebhookConfigurationList = isValidatingWebhookConfigurationList;
(function (ValidatingWebhookConfigurationList) {
    ValidatingWebhookConfigurationList.apiVersion = "admissionregistration.k8s.io/v1";
    ValidatingWebhookConfigurationList.group = "admissionregistration.k8s.io";
    ValidatingWebhookConfigurationList.version = "v1";
    ValidatingWebhookConfigurationList.kind = "ValidatingWebhookConfigurationList";
})(ValidatingWebhookConfigurationList = exports.ValidatingWebhookConfigurationList || (exports.ValidatingWebhookConfigurationList = {}));
// WebhookClientConfig contains the information to make a TLS connection with the webhook
class WebhookClientConfig {
}
exports.WebhookClientConfig = WebhookClientConfig;
//# sourceMappingURL=io.k8s.api.admissionregistration.v1.js.map