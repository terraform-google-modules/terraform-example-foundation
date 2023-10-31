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

// Exported function
exports.caiMonitoring = message => {
    try {
        var event = parseMessage(message);
        var bindings = getRoleBindings(event.asset);

        // If the list is not empty, search for the same member and role on the prior asset.
        // Get only the new bindings that is not on the prior asset and post on Pub/Sub.
        if (bindings.length > 0){
            var priorBindings = getRoleBindings(event.priorAsset);
            var delta = bindingDiff(bindings, priorBindings);

            if (delta.length > 0){
                createFinding(delta, event.asset.updateTime, event.asset.name);
            }
        }
    } catch (error) {
        console.warn(`Skipping executing with message: ${error.message}`);
    }
}

/**
 * Return an array of all members that have overprivileged roles.
 * If there's no member, it will return an empty array.
 *
 * @param {Asset} asset  The asset to find members with selected permissions
 * @returns {Array} The array of found bindings ({member: String, role: String}) sorted by role
 */
function getRoleBindings(asset){
    try {
        validateAsset(asset);

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

        return foundRoles.sort(sortBindingList);
    } catch (error) {
        console.warn(`Returning empty bindings with message: ${error.message}`);
        return [];
    }
}

/**
 * Validate if the asset is from Organizations and have the iamPolicy and bindings field.
 *
 * @param {any} asset  Asset JSON.
 * @exception If the asset is not valid it will throw the corresponding error.
 */
function validateAsset(asset) {
    // If the asset is not present, throw an error.
    if (!asset) {
        throw new Error(`Missing asset`);
    }

    // If iamPolicy is missing, throw an error.
    if (!asset.iamPolicy) {
        throw new Error(`Missing iamPolicy`);
    }

    // If iamPolicy.bindings is missing, throw an error.
    if (!asset.iamPolicy.bindings) {
        throw new Error(`Missing iamPolicy.bindings`);
    }
}

/**
 * Sort an array of bindings by role.
 *
 * @param {object} actual  The actual value to compare
 * @param {object} next  The next value to compare
 * @returns {number} A negative value if first argument is less than second argument, zero if they're equal and a positive value otherwise.
 */
function sortBindingList(actual, next) {
    if (actual.role === next.role) return 0;
    return actual.role > next.role ? 1 : -1;
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
 * Parse the message received on the Cloud Function to a JSON.
 *
 * @param {any} message  Message from Cloud Function
 * @returns {JSON} Json object from the message
 * @exception If some error happens while parsing, it will log the error and finish the execution
 */
function parseMessage(message) {
    // If message data is missing, log a warning and exit.
    if (!(message && message.data)){
        throw new Error(`Missing required fields (message or message.data)`);
    }

    // Extract the event data from the message
    var event = JSON.parse(Buffer.from(message.data, 'base64').toString());

    // If event asset is missing, log a warning and exit
    if (!(event.asset && event.asset.iamPolicy)){
        throw new Error(`Missing required fields (asset or asset.iamPolicy)`);
    }

    // If event priorAsset is missing and assetType is Project, is a new project creation, log a warning and exit
    if (!(event.priorAsset && event.priorAsset.iamPolicy) && event.asset.assetType === "cloudresourcemanager.googleapis.com/Project"){
        throw new Error(`Project creation, prior asset is empty`);
    }

    return event
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
 * @param {Array} bindings The bindings list to be created on the finding with the role, member and org.
 * @param {string} updateTime The time that the asset was changed.
 * @param {string} resourceName The resource where the role was given.
 */
async function createFinding(bindings, updateTime, resourceName) {
    const [newFinding] = await client.createFinding({
        parent: sourceId,
        findingId: uuid4().replace(/-/g, ''),
        finding: {
            state: 'ACTIVE',
            resourceName: resourceName,
            category: 'PRIVILEGED_ROLE_GRANTED',
            eventTime: parseStrTime(updateTime),
            findingClass: 'VULNERABILITY',
            severity: 'MEDIUM',
            iamBindings: bindings
        }
    });

    console.log('New finding created: %j', newFinding);
}
