/**
 * Copyright 2023 Google LLC
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

'use strict'

// Import
const uuid4 = require('uuid4')
const moment = require('moment')

// SCC client
const { SecurityCenterClient } = require('@google-cloud/security-center');
const client = new SecurityCenterClient();

// Environment variables
const sourceId = process.env.SOURCE_ID;
const searchroles = process.env.ROLES.split(",");

// Variables
const sccConfig = {
    category: 'PRIVILEGED_ROLE_GRANTED',
    findingClass: 'VULNERABILITY',
    severity: 'MEDIUM'
};

// Exported function
exports.caiMonitoring = message => {
    try {
        var event = parseMessage(message);

        // This validate is specific for the CAI Monitoring scenario.
        // If you want to use this Cloud Function for other purpose, please change this validate function.
        validateEvent(event);

        // From this part of the code until the end of the function is specific for the CAI Monitoring scenario
        var bindings = getRoleBindings(event.asset);

        // If the list is not empty, search for the same member and role on the prior asset.
        // Get only the new bindings that is not on the prior asset and create a new finding.
        if (bindings.length > 0) {
            var delta = bindingDiff(bindings, getRoleBindings(event.priorAsset));

            if (delta.length > 0) {
                // Map of extra properties to save on the finding with field name and value
                var extraProperties = {
                    iamBindings: delta
                };

                createFinding(
                    event.asset.updateTime,
                    event.asset.name,
                    extraProperties
                );
            }
        }
    } catch (error) {
        console.warn(`Skipping executing with message: ${error.message}`);
    }
}

/**
 * Parse the message received on the Cloud Function to a JSON.
 *
 * @param {any} message  Message from Cloud Function
 * @returns {JSON} Json object from the message
 * @exception If some error happens while parsing, it will log the error and finish the execution
 */
function parseMessage(message) {
    // If message data is missing, log a warning and exit.
    if (!(message && message.data)) {
        throw new Error(`Missing required fields (message or message.data)`);
    }

    // Extract the event data from the message
    var event = JSON.parse(Buffer.from(message.data, 'base64').toString());

    return event;
}

/**
 * Validate if the asset is from Organizations and have the iamPolicy and bindings field.
 *
 * @param {any} asset  Asset JSON.
 * @exception If the asset is not valid it will throw the corresponding error.
 */
function validateEvent(event) {
    // If the asset is not present, throw an error.
    if (!(event.asset && event.asset.iamPolicy && event.asset.iamPolicy.bindings)) {
        throw new Error(`Missing required fields (asset or asset.iamPolicy or asset.iamPolicy.bindings)`);
    }

    // If event priorAsset is missing and assetType is Project, is a new project creation, log a warning and exit
    if (!(event.priorAsset && event.priorAsset.iamPolicy) && event.asset.assetType === "cloudresourcemanager.googleapis.com/Project") {
        var name = event.asset.name.split("/");
        throw new Error(`Creating project ${name[name.length - 1]}, prior asset is empty`);
    }
}

/**
 * Return an array of all members that have overprivileged roles.
 * If there's no member, it will return an empty array.
 *
 * @param {Asset} asset  The asset to find members with selected permissions
 * @returns {Array} The array of found bindings ({member: String, role: String, action: String('ADD')}) sorted by role
 */
function getRoleBindings(asset) {
    try {
        var foundRoles = [];
        var bindings = asset.iamPolicy.bindings;

        // Check for bindings that include the list of roles
        bindings.forEach(binding => {
            if (searchroles.includes(binding.role)) {
                binding.members.forEach(member => {
                    foundRoles.push({
                        member: member,
                        role: binding.role,
                        action: 'ADD'
                    });
                });
            }
        });

        return foundRoles;
    } catch (error) {
        console.warn(`Returning empty bindings with message: ${error.message}`);
        return [];
    }
}

/**
 * Return an array of the members difference between the actual and the prior bindings.
 * If there's no member, it will return an empty array.
 *
 * @param {Array} bindings  Array of the actual binding
 * @param {Array} priorBindings  Array of the prior binding
 * @returns {Array} The difference array between actual and prior bindings
 */
function bindingDiff(bindings, priorBindings) {
    return bindings.filter(actual => !priorBindings.some(prior => (prior.member === actual.member && prior.role === actual.role)));
}

/**
 * Convert string date to google.protobuf.Timestamp format
 *
 * @param {string} dateTimeStr date time format as a String. (e.g. 2019-02-15T10:23:13Z)
 */
function parseStrTime(dateTimeStr) {
    const dateTimeStrInMillis = moment.utc(dateTimeStr).valueOf()
    return {
        seconds: Math.trunc(dateTimeStrInMillis / 1000),
        nanos: Math.trunc((dateTimeStrInMillis % 1000) * 1000000)
    }
}

/**
 * Create the new SCC finding
 *
 * @param {string} updateTime The time that the asset was changed.
 * @param {string} resourceName The resource where the role was given.
 * @param {Any} extraProperties A key/value map with properties to save on the finding ({fieldName: fieldValue})
 */
async function createFinding(updateTime, resourceName, extraProperties) {
    const [newFinding] = await client.createFinding(
        {
            parent: sourceId,
            findingId: uuid4().replace(/-/g, ''),
            finding: {
                ... {
                    state: 'ACTIVE',
                    resourceName: resourceName,
                    category: sccConfig.category,
                    eventTime: parseStrTime(updateTime),
                    findingClass: sccConfig.findingClass,
                    severity: sccConfig.severity
                },
                ...extraProperties
            }
        }
    );

    console.log('New finding created: %j', newFinding);
}
