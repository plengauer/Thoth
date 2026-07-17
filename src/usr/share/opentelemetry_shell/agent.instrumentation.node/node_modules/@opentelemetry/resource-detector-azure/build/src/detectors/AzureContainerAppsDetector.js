"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.azureContainerAppsDetector = void 0;
const semconv_1 = require("../semconv");
const utils_1 = require("../utils");
const types_1 = require("../types");
const CONTAINER_APP_ATTRIBUTE_ENV_VARS = {
    [semconv_1.ATTR_HOST_NAME]: types_1.CONTAINER_APP_HOSTNAME,
    [types_1.AZURE_CONTAINER_APP_INSTANCE_ID]: types_1.CONTAINER_APP_REPLICA_NAME,
    [types_1.AZURE_CONTAINER_APP_NAME]: types_1.CONTAINER_APP_NAME,
    [types_1.AZURE_CONTAINER_APP_VERSION]: types_1.CONTAINER_APP_REVISION,
};
class AzureContainerAppsDetector {
    detect() {
        let attributes = {};
        if ((0, utils_1.isAzureContainerApps)()) {
            attributes = {
                [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_AZURE_CONTAINER_APPS,
                [semconv_1.ATTR_CLOUD_PROVIDER]: semconv_1.CLOUD_PROVIDER_VALUE_AZURE,
            };
            for (const [key, value] of Object.entries(CONTAINER_APP_ATTRIBUTE_ENV_VARS)) {
                const envVar = process.env[value];
                if (envVar) {
                    attributes = { ...attributes, ...{ [key]: envVar } };
                }
            }
        }
        return { attributes };
    }
}
exports.azureContainerAppsDetector = new AzureContainerAppsDetector();
//# sourceMappingURL=AzureContainerAppsDetector.js.map