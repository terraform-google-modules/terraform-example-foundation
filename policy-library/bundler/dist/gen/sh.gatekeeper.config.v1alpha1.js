"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// ConfigList is a list of Config
class ConfigList {
    constructor(desc) {
        this.apiVersion = ConfigList.apiVersion;
        this.items = desc.items;
        this.kind = ConfigList.kind;
        this.metadata = desc.metadata;
    }
}
exports.ConfigList = ConfigList;
function isConfigList(o) {
    return o && o.apiVersion === ConfigList.apiVersion && o.kind === ConfigList.kind;
}
exports.isConfigList = isConfigList;
(function (ConfigList) {
    ConfigList.apiVersion = "config.gatekeeper.sh/v1alpha1";
    ConfigList.group = "config.gatekeeper.sh";
    ConfigList.version = "v1alpha1";
    ConfigList.kind = "ConfigList";
    // ListMeta describes metadata that synthetic resources must have, including lists and various status objects. A resource may have only one of {ObjectMeta, ListMeta}.
    class Metadata {
    }
    ConfigList.Metadata = Metadata;
})(ConfigList = exports.ConfigList || (exports.ConfigList = {}));
//# sourceMappingURL=sh.gatekeeper.config.v1alpha1.js.map