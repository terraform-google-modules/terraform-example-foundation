"use strict";
/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const markdown_table_1 = __importDefault(require("markdown-table"));
const path = __importStar(require("path"));
const _ = __importStar(require("lodash"));
const common_1 = require("./common");
exports.SOURCE_DIR = "sink_dir";
exports.SINK_DIR = "sink_dir";
exports.BUNDLE_DIR = "bundles";
exports.OVERWRITE = "overwrite";
exports.INDEX_TEXT = "index";
exports.LIST_MODE = "template_list_mode";
exports.LIST_GROUPING = "template_list_grouping";
const FILE_PATTERN_MD = "/**/*.+(md)";
function generateDocs(configs) {
    return __awaiter(this, void 0, void 0, function* () {
        // Get the parameters
        const sinkDir = configs.getFunctionConfigValueOrThrow(exports.SINK_DIR);
        const overwrite = configs.getFunctionConfigValue(exports.OVERWRITE) === "true";
        const indexText = configs.getFunctionConfigValue(exports.INDEX_TEXT) || "";
        const listMode = (configs.getFunctionConfigValue(exports.LIST_MODE) || "samples");
        const listGrouping = (configs.getFunctionConfigValue(exports.LIST_GROUPING) || "all");
        // Create bundle dir and writer
        const fileWriter = new common_1.FileWriter(sinkDir, overwrite, FILE_PATTERN_MD, true, false);
        // Build the policy library
        const library = new common_1.PolicyLibrary(configs.getAll());
        // Document constraint templates and samples
        generateIndexDoc(indexText, fileWriter, library, sinkDir, listMode, listGrouping);
        // Document bundles
        const bundleDir = path.join(sinkDir, exports.BUNDLE_DIR);
        generateBundleDocs(bundleDir, fileWriter, library);
        // Remove old docs
        fileWriter.finish();
    });
}
exports.generateDocs = generateDocs;
var ListMode;
(function (ListMode) {
    ListMode["SAMPLES"] = "samples";
    ListMode["PROPS"] = "table";
    ListMode["DETAILS"] = "details";
})(ListMode || (ListMode = {}));
var ListGrouping;
(function (ListGrouping) {
    ListGrouping["ALL"] = "all";
    ListGrouping["DIRECTORY"] = "directory";
})(ListGrouping || (ListGrouping = {}));
function generateIndexDoc(indexText, fileWriter, library, sinkDir, listMode, listGrouping) {
    const header = listMode === ListMode.SAMPLES ?
        ["Template", "Samples"] :
        ["Template", "Description", "Parameters"];
    const templateSections = listGrouping === ListGrouping.ALL ? [{
            name: "Available Templates",
            templates: library.getTemplates().sort(common_1.PolicyConfig.compare),
            table: [header],
            markdown: [],
        }] : _.map(_.groupBy(library.getTemplates(), (o) => {
        return path.basename(path.dirname(path.dirname(common_1.PolicyConfig.getPath(o))));
    }), (templates, key) => {
        return {
            name: key,
            templates: templates.sort(common_1.PolicyConfig.compare),
            table: [header],
            markdown: [],
        };
    });
    // Template Sections
    _.each(templateSections, (section) => {
        section.templates.forEach(o => {
            const constraints = library.getOfKind(o.spec.crd.spec.names.kind);
            const name = common_1.PolicyConfig.getName(o);
            const description = common_1.PolicyConfig.getDescription(o);
            const templateLink = `[${name}](${common_1.PolicyConfig.getPath(o)})`;
            const samples = constraints
                .map(c => `[${common_1.PolicyConfig.getName(c)}](${common_1.PolicyConfig.getPath(c)})`)
                .join(", ");
            const props = common_1.PolicyConfig.getParams(o);
            const propDoc = (Object.keys(props).length === 0) ? undefined : [
                '<table>', '<thead>',
                '<th>Name</th>',
                '<th>Type</th>',
                '</thead>', '<tbody>',
                ..._.map(Object.keys(props), (name) => {
                    return `<tr><td>${name}</td><td>${props[name]}</td></tr>`;
                }),
                '</tbody>', '</table>',
            ].join("");
            if (listMode === ListMode.SAMPLES) {
                section.table.push([templateLink, samples]);
            }
            else if (listMode === ListMode.PROPS) {
                section.table.push([name, description, propDoc || ""]);
            }
            else {
                section.markdown.push(`### ${name}`);
                section.markdown.push(description);
                if (Object.keys(props).length >= 1) {
                    const propTable = [
                        ["Name", "Type"],
                        ..._.map(Object.keys(props), (name) => {
                            return [name, props[name]];
                        }),
                    ];
                    section.markdown.push(markdown_table_1.default(propTable));
                }
            }
        });
        if (listMode !== ListMode.DETAILS) {
            section.markdown.push(markdown_table_1.default(section.table));
        }
    });
    const docSections = [
        indexText,
        ...templateSections.map(section => `
## ${section.name}

${section.markdown.join("\n\n")}`),
    ];
    if (listMode === ListMode.SAMPLES) {
        // Samples
        const samples = [["Sample", "Template", "Description"]];
        library
            .getAll()
            .filter(o => {
            return o.kind !== common_1.CT_KIND;
        })
            .sort(common_1.PolicyConfig.compare)
            .forEach(o => {
            const name = `[${common_1.PolicyConfig.getName(o)}](${common_1.PolicyConfig.getPath(o)})`;
            const description = common_1.PolicyConfig.getDescription(o);
            const ct = library.getTemplate(o.kind);
            const ctName = ct ? `[Link](${common_1.PolicyConfig.getPath(ct)})` : "";
            samples.push([name, ctName, description]);
        });
        docSections.push(`## Sample Constraints

    The repo also contains a number of sample constraints:

    ${markdown_table_1.default(samples)}`);
    }
    const templateDoc = docSections.join("\n");
    const templateDocPath = path.join(sinkDir, "index.md");
    fileWriter.write(templateDocPath, templateDoc);
}
function generateBundleDocs(bundleDir, fileWriter, library) {
    library.bundles.forEach(bundle => {
        const constraints = [["Constraint", "Control", "Description"]];
        bundle
            .getConfigs()
            .sort(common_1.PolicyConfig.compare)
            .forEach(o => {
            const name = `[${common_1.PolicyConfig.getName(o)}](${common_1.PolicyConfig.getPath(o, "../../")})`;
            const control = bundle.getControl(o);
            const description = common_1.PolicyConfig.getDescription(o);
            constraints.push([name, control, description]);
        });
        const contents = `# ${bundle.getName()}

This bundle can be installed via kpt:

\`\`\`
export BUNDLE=${bundle.getName()}
kpt pkg get https://github.com/forseti-security/policy-library.git ./policy-library
kpt fn source policy-library/samples/ | \\
  kpt fn run --image gcr.io/config-validator/get-policy-bundle:latest -- bundle=$BUNDLE | \\
  kpt fn sink policy-library/policies/constraints/
\`\`\`

## Constraints

${markdown_table_1.default(constraints)}

`;
        const file = path.join(bundleDir, `${bundle.getKey()}.md`);
        fileWriter.write(file, contents);
    });
}
generateDocs.usage = `
Creates a directory of markdown documentation.

Configured using a ConfigMap with the following keys:
${exports.SINK_DIR}: Path to the config directory to write to.
${exports.OVERWRITE}: [Optional] If 'true', overwrite existing YAML files. Otherwise, fail if any YAML files exist.
Example:
apiVersion: v1
kind: ConfigMap
data:
  ${exports.SINK_DIR}: /path/to/sink/dir
  ${exports.OVERWRITE}: 'true'
metadata:
  name: my-config
`;
//# sourceMappingURL=generate_docs.js.map