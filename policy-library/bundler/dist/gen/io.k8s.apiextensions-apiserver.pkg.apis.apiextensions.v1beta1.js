"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// CustomResourceColumnDefinition specifies a column for server side printing.
class CustomResourceColumnDefinition {
    constructor(desc) {
        this.JSONPath = desc.JSONPath;
        this.description = desc.description;
        this.format = desc.format;
        this.name = desc.name;
        this.priority = desc.priority;
        this.type = desc.type;
    }
}
exports.CustomResourceColumnDefinition = CustomResourceColumnDefinition;
// CustomResourceConversion describes how to convert different versions of a CR.
class CustomResourceConversion {
    constructor(desc) {
        this.conversionReviewVersions = desc.conversionReviewVersions;
        this.strategy = desc.strategy;
        this.webhookClientConfig = desc.webhookClientConfig;
    }
}
exports.CustomResourceConversion = CustomResourceConversion;
// CustomResourceDefinition represents a resource that should be exposed on the API server.  Its name MUST be in the format <.spec.name>.<.spec.group>.
class CustomResourceDefinition {
    constructor(desc) {
        this.apiVersion = CustomResourceDefinition.apiVersion;
        this.kind = CustomResourceDefinition.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.CustomResourceDefinition = CustomResourceDefinition;
function isCustomResourceDefinition(o) {
    return (o &&
        o.apiVersion === CustomResourceDefinition.apiVersion &&
        o.kind === CustomResourceDefinition.kind);
}
exports.isCustomResourceDefinition = isCustomResourceDefinition;
(function (CustomResourceDefinition) {
    CustomResourceDefinition.apiVersion = "apiextensions.k8s.io/v1beta1";
    CustomResourceDefinition.group = "apiextensions.k8s.io";
    CustomResourceDefinition.version = "v1beta1";
    CustomResourceDefinition.kind = "CustomResourceDefinition";
})(CustomResourceDefinition = exports.CustomResourceDefinition || (exports.CustomResourceDefinition = {}));
// CustomResourceDefinitionCondition contains details for the current condition of this pod.
class CustomResourceDefinitionCondition {
    constructor(desc) {
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.CustomResourceDefinitionCondition = CustomResourceDefinitionCondition;
// CustomResourceDefinitionList is a list of CustomResourceDefinition objects.
class CustomResourceDefinitionList {
    constructor(desc) {
        this.apiVersion = CustomResourceDefinitionList.apiVersion;
        this.items = desc.items.map(i => new CustomResourceDefinition(i));
        this.kind = CustomResourceDefinitionList.kind;
        this.metadata = desc.metadata;
    }
}
exports.CustomResourceDefinitionList = CustomResourceDefinitionList;
function isCustomResourceDefinitionList(o) {
    return (o &&
        o.apiVersion === CustomResourceDefinitionList.apiVersion &&
        o.kind === CustomResourceDefinitionList.kind);
}
exports.isCustomResourceDefinitionList = isCustomResourceDefinitionList;
(function (CustomResourceDefinitionList) {
    CustomResourceDefinitionList.apiVersion = "apiextensions.k8s.io/v1beta1";
    CustomResourceDefinitionList.group = "apiextensions.k8s.io";
    CustomResourceDefinitionList.version = "v1beta1";
    CustomResourceDefinitionList.kind = "CustomResourceDefinitionList";
})(CustomResourceDefinitionList = exports.CustomResourceDefinitionList || (exports.CustomResourceDefinitionList = {}));
// CustomResourceDefinitionNames indicates the names to serve this CustomResourceDefinition
class CustomResourceDefinitionNames {
    constructor(desc) {
        this.categories = desc.categories;
        this.kind = desc.kind;
        this.listKind = desc.listKind;
        this.plural = desc.plural;
        this.shortNames = desc.shortNames;
        this.singular = desc.singular;
    }
}
exports.CustomResourceDefinitionNames = CustomResourceDefinitionNames;
// CustomResourceDefinitionSpec describes how a user wants their resource to appear
class CustomResourceDefinitionSpec {
    constructor(desc) {
        this.additionalPrinterColumns = desc.additionalPrinterColumns;
        this.conversion = desc.conversion;
        this.group = desc.group;
        this.names = desc.names;
        this.scope = desc.scope;
        this.subresources = desc.subresources;
        this.validation = desc.validation;
        this.version = desc.version;
        this.versions = desc.versions;
    }
}
exports.CustomResourceDefinitionSpec = CustomResourceDefinitionSpec;
// CustomResourceDefinitionStatus indicates the state of the CustomResourceDefinition
class CustomResourceDefinitionStatus {
    constructor(desc) {
        this.acceptedNames = desc.acceptedNames;
        this.conditions = desc.conditions;
        this.storedVersions = desc.storedVersions;
    }
}
exports.CustomResourceDefinitionStatus = CustomResourceDefinitionStatus;
// CustomResourceDefinitionVersion describes a version for CRD.
class CustomResourceDefinitionVersion {
    constructor(desc) {
        this.additionalPrinterColumns = desc.additionalPrinterColumns;
        this.name = desc.name;
        this.schema = desc.schema;
        this.served = desc.served;
        this.storage = desc.storage;
        this.subresources = desc.subresources;
    }
}
exports.CustomResourceDefinitionVersion = CustomResourceDefinitionVersion;
// CustomResourceSubresourceScale defines how to serve the scale subresource for CustomResources.
class CustomResourceSubresourceScale {
    constructor(desc) {
        this.labelSelectorPath = desc.labelSelectorPath;
        this.specReplicasPath = desc.specReplicasPath;
        this.statusReplicasPath = desc.statusReplicasPath;
    }
}
exports.CustomResourceSubresourceScale = CustomResourceSubresourceScale;
// CustomResourceSubresources defines the status and scale subresources for CustomResources.
class CustomResourceSubresources {
}
exports.CustomResourceSubresources = CustomResourceSubresources;
// CustomResourceValidation is a list of validation methods for CustomResources.
class CustomResourceValidation {
}
exports.CustomResourceValidation = CustomResourceValidation;
// ExternalDocumentation allows referencing an external resource for extended documentation.
class ExternalDocumentation {
}
exports.ExternalDocumentation = ExternalDocumentation;
// JSONSchemaProps is a JSON-Schema following Specification Draft 4 (http://json-schema.org/).
class JSONSchemaProps {
}
exports.JSONSchemaProps = JSONSchemaProps;
// ServiceReference holds a reference to Service.legacy.k8s.io
class ServiceReference {
    constructor(desc) {
        this.name = desc.name;
        this.namespace = desc.namespace;
        this.path = desc.path;
    }
}
exports.ServiceReference = ServiceReference;
// WebhookClientConfig contains the information to make a TLS connection with the webhook. It has the same field as admissionregistration.v1beta1.WebhookClientConfig.
class WebhookClientConfig {
}
exports.WebhookClientConfig = WebhookClientConfig;
//# sourceMappingURL=io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1beta1.js.map