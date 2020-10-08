"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Info contains versioning information. how we'll want to distribute that information.
class Info {
    constructor(desc) {
        this.buildDate = desc.buildDate;
        this.compiler = desc.compiler;
        this.gitCommit = desc.gitCommit;
        this.gitTreeState = desc.gitTreeState;
        this.gitVersion = desc.gitVersion;
        this.goVersion = desc.goVersion;
        this.major = desc.major;
        this.minor = desc.minor;
        this.platform = desc.platform;
    }
}
exports.Info = Info;
//# sourceMappingURL=io.k8s.apimachinery.pkg.version.js.map