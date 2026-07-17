"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.isAzureContainerApps = exports.isAzureFunction = exports.getAzureResourceUri = void 0;
const types_1 = require("./types");
function getAzureResourceUri(websiteSiteName) {
    const websiteResourceGroup = process.env[types_1.WEBSITE_RESOURCE_GROUP];
    const websiteOwnerName = process.env[types_1.WEBSITE_OWNER_NAME];
    let subscriptionId = websiteOwnerName;
    if (websiteOwnerName && websiteOwnerName.indexOf('+') !== -1) {
        subscriptionId = websiteOwnerName.split('+')[0];
    }
    if (!subscriptionId && !websiteOwnerName) {
        return undefined;
    }
    return `/subscriptions/${subscriptionId}/resourceGroups/${websiteResourceGroup}/providers/Microsoft.Web/sites/${websiteSiteName}`;
}
exports.getAzureResourceUri = getAzureResourceUri;
function isAzureFunction() {
    return !!(process.env[types_1.FUNCTIONS_VERSION] ||
        process.env[types_1.WEBSITE_SKU] === 'FlexConsumption');
}
exports.isAzureFunction = isAzureFunction;
function isAzureContainerApps() {
    return !!(process.env[types_1.CONTAINER_APP_NAME] &&
        process.env[types_1.CONTAINER_APP_REVISION] &&
        process.env[types_1.CONTAINER_APP_HOSTNAME] &&
        process.env[types_1.CONTAINER_APP_ENV_DNS_SUFFIX] &&
        process.env[types_1.CONTAINER_APP_PORT] &&
        process.env[types_1.CONTAINER_APP_REPLICA_NAME]);
}
exports.isAzureContainerApps = isAzureContainerApps;
//# sourceMappingURL=utils.js.map