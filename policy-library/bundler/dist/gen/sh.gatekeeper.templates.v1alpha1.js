"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// ConstraintTemplateList is a list of ConstraintTemplate
class ConstraintTemplateList {
    constructor(desc) {
        this.apiVersion = ConstraintTemplateList.apiVersion;
        this.items = desc.items;
        this.kind = ConstraintTemplateList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ConstraintTemplateList = ConstraintTemplateList;
function isConstraintTemplateList(o) {
    return o && o.apiVersion === ConstraintTemplateList.apiVersion && o.kind === ConstraintTemplateList.kind;
}
exports.isConstraintTemplateList = isConstraintTemplateList;
(function (ConstraintTemplateList) {
    ConstraintTemplateList.apiVersion = "templates.gatekeeper.sh/v1alpha1";
    ConstraintTemplateList.group = "templates.gatekeeper.sh";
    ConstraintTemplateList.version = "v1alpha1";
    ConstraintTemplateList.kind = "ConstraintTemplateList";
    // ListMeta describes metadata that synthetic resources must have, including lists and various status objects. A resource may have only one of {ObjectMeta, ListMeta}.
    class Metadata {
    }
    ConstraintTemplateList.Metadata = Metadata;
})(ConstraintTemplateList = exports.ConstraintTemplateList || (exports.ConstraintTemplateList = {}));
//# sourceMappingURL=sh.gatekeeper.templates.v1alpha1.js.map