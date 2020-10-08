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

import { Configs } from "kpt-functions";
import mdTable from "markdown-table";
import * as path from "path";
import * as _ from 'lodash';
import { CT_KIND, FileWriter, PolicyLibrary, PolicyConfig } from "./common";

export const SOURCE_DIR = "sink_dir";
export const SINK_DIR = "sink_dir";
export const BUNDLE_DIR = "bundles";
export const OVERWRITE = "overwrite";
export const INDEX_TEXT = "index";
export const LIST_MODE = "template_list_mode";
export const LIST_GROUPING = "template_list_grouping";

const FILE_PATTERN_MD = "/**/*.+(md)";

export async function generateDocs(configs: Configs) {
  // Get the parameters
  const sinkDir = configs.getFunctionConfigValueOrThrow(SINK_DIR);
  const overwrite = configs.getFunctionConfigValue(OVERWRITE) === "true";
  const indexText = configs.getFunctionConfigValue(INDEX_TEXT) || "";
  const listMode = (configs.getFunctionConfigValue(LIST_MODE) || "samples") as unknown as ListMode;
  const listGrouping = (configs.getFunctionConfigValue(LIST_GROUPING) || "all") as unknown as ListGrouping;

  // Create bundle dir and writer
  const fileWriter = new FileWriter(sinkDir, overwrite, FILE_PATTERN_MD, true, false);

  // Build the policy library
  const library = new PolicyLibrary(configs.getAll());

  // Document constraint templates and samples
  generateIndexDoc(indexText, fileWriter, library, sinkDir, listMode, listGrouping);

  // Document bundles
  const bundleDir = path.join(sinkDir, BUNDLE_DIR);
  generateBundleDocs(bundleDir, fileWriter, library);

  // Remove old docs
  fileWriter.finish();
}

enum ListMode {
  SAMPLES = "samples",
  PROPS = "table",
  DETAILS = "details",
}

enum ListGrouping {
  ALL = "all",
  DIRECTORY = "directory",
}

function generateIndexDoc(
  indexText: string,
  fileWriter: FileWriter,
  library: PolicyLibrary,
  sinkDir: string,
  listMode: ListMode,
  listGrouping: ListGrouping
) {
  const header = listMode === ListMode.SAMPLES ?
    ["Template", "Samples"] :
    ["Template", "Description", "Parameters"];
  const templateSections = listGrouping === ListGrouping.ALL ? [{
    name: "Available Templates",
    templates: library.getTemplates().sort(PolicyConfig.compare),
    table: [header],
    markdown: [] as string[],
  }] : _.map(_.groupBy(library.getTemplates(), (o) => {
    return path.basename(path.dirname(path.dirname(PolicyConfig.getPath(o))));
  }), (templates, key) => {
    return {
      name: key,
      templates: templates.sort(PolicyConfig.compare),
      table: [header],
      markdown: [] as string[],
    };
  });

  // Template Sections
  _.each(templateSections, (section) => {
    section.templates.forEach(o => {
      const constraints = library.getOfKind(
        (o as any).spec.crd.spec.names.kind
      );
      const name = PolicyConfig.getName(o);
      const description = PolicyConfig.getDescription(o);
      const templateLink = `[${name}](${PolicyConfig.getPath(o)})`;
      const samples = constraints
        .map(c => `[${PolicyConfig.getName(c)}](${PolicyConfig.getPath(c)})`)
        .join(", ");
      const props = PolicyConfig.getParams(o);
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
      } else if (listMode === ListMode.PROPS) {
        section.table.push([name, description, propDoc || ""]);
      } else {
        section.markdown.push(`### ${name}`);
        section.markdown.push(description);
        if (Object.keys(props).length >= 1) {
          const propTable = [
            ["Name", "Type"],
            ..._.map(Object.keys(props), (name) => {
              return [name, props[name]];
            }),
          ];
          section.markdown.push(mdTable(propTable));
        }
      }
    });
    if (listMode !== ListMode.DETAILS) {
      section.markdown.push(mdTable(section.table));
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
        return o.kind !== CT_KIND;
      })
      .sort(PolicyConfig.compare)
      .forEach(o => {
        const name = `[${PolicyConfig.getName(o)}](${PolicyConfig.getPath(o)})`;
        const description = PolicyConfig.getDescription(o);
        const ct = library.getTemplate(o.kind);
        const ctName = ct ? `[Link](${PolicyConfig.getPath(ct)})` : "";

        samples.push([name, ctName, description]);
      });
    docSections.push(`## Sample Constraints

    The repo also contains a number of sample constraints:

    ${mdTable(samples)}`);
  }

  const templateDoc = docSections.join("\n");

  const templateDocPath = path.join(sinkDir, "index.md");
  fileWriter.write(templateDocPath, templateDoc);
}

function generateBundleDocs(
  bundleDir: string,
  fileWriter: FileWriter,
  library: PolicyLibrary
) {
  library.bundles.forEach(bundle => {
    const constraints = [["Constraint", "Control", "Description"]];
    bundle
      .getConfigs()
      .sort(PolicyConfig.compare)
      .forEach(o => {
        const name = `[${PolicyConfig.getName(o)}](${PolicyConfig.getPath(
          o,
          "../../"
        )})`;
        const control = bundle.getControl(o);
        const description = PolicyConfig.getDescription(o);

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

${mdTable(constraints)}

`;

    const file = path.join(bundleDir, `${bundle.getKey()}.md`);
    fileWriter.write(file, contents);
  });
}

generateDocs.usage = `
Creates a directory of markdown documentation.

Configured using a ConfigMap with the following keys:
${SINK_DIR}: Path to the config directory to write to.
${OVERWRITE}: [Optional] If 'true', overwrite existing YAML files. Otherwise, fail if any YAML files exist.
Example:
apiVersion: v1
kind: ConfigMap
data:
  ${SINK_DIR}: /path/to/sink/dir
  ${OVERWRITE}: 'true'
metadata:
  name: my-config
`;
