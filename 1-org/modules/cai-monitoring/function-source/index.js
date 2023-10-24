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

const {PubSub} = require('@google-cloud/pubsub');
const pubSubClient = new PubSub();

exports.caiBindingNotification = message => {
    var event = parseMessage(message)
    var bindings = getRoleBindings(event.asset)

    // If the list is not empty, search for the same member and role on the prior asset.
    // Get only the new bindings that is not on the prior asset and post on Pub/Sub.
    if (bindings.length > 0){
        bindingDiff(bindings, getRoleBindings(event.priorAsset)).forEach(postOnPubSub);
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
    var foundRoles = [];
    var bindings = asset.iamPolicy.bindings;
    var searchroles = process.env.ROLES.split(",")

    // Check for bindings that include the list of roles
    bindings.forEach(binding => {
        if (searchroles.includes(binding.role)) {
            binding.members.forEach(member => {
                foundRoles.push({member: member, role: binding.role});
            })
        }
    })

    return foundRoles.sort(sortBindingList);
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
    return bindings.filter(actual => !priorBindings.some(prior => (prior.member === actual.member && prior.role === actual.role)))
}

/**
 * Parse the message received on the Cloud Function to a JSON.
 *
 * @param {any} message  Message from Cloud Function
 * @returns {JSON} Json object from the message
 * @exception If some error happens while parsing, it will log the error and finish the execution
 */
function parseMessage(message) {
    try {
        // If message data is missing, log an error and exit.
        if (!(message && message.data)){
            throw new Error("Missing required fields (message or message.data): " + JSON.stringify(message))
        }

        // Extract the event data from the message
        var event = JSON.parse(Buffer.from(message.data, 'base64').toString())

        // if event asset data is missing, log an error and exit
        if (!(event.asset && event.asset.iamPolicy)){
            throw new Error("Missing required fields (asset or asset.iamPolicy): " + JSON.stringify(message))
        }

        return event
    } catch (e) {
        console.error("Error parsing message: " + JSON.stringify(e))
        process.exitCode = 1;
    }
}

/**
 * Log and post the bindin with email and role on a PubSub subscription
 *
 * @param {map} bindings  The binding object containing member email and role
 */
async function postOnPubSub(binding) {
    console.log("Found an address (" + binding.member + ") with role " + binding.role)
    var dataBuffer = Buffer.from(JSON.stringify(binding))
    try {
        const messageId = await pubSubClient
          .topic(process.env.TOPIC)
          .publishMessage({data: dataBuffer});
        console.log(`Message ${messageId} published.`);
    } catch (error) {
        console.error(`Error while publishing: ${error.message}`);
    }
}
