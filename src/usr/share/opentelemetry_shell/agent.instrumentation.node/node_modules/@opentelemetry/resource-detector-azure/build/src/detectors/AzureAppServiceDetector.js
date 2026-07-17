"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.azureAppServiceDetector = void 0;
const types_1 = require("../types");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
const semconv_1 = require("../semconv");
const utils_1 = require("../utils");
const APP_SERVICE_ATTRIBUTE_ENV_VARS = {
    [semconv_1.ATTR_CLOUD_REGION]: types_1.REGION_NAME,
    [semconv_1.ATTR_DEPLOYMENT_ENVIRONMENT_NAME]: types_1.WEBSITE_SLOT_NAME,
    [semconv_1.ATTR_HOST_ID]: types_1.WEBSITE_HOSTNAME,
    [semconv_1.ATTR_SERVICE_INSTANCE_ID]: types_1.WEBSITE_INSTANCE_ID,
    [types_1.AZURE_APP_SERVICE_STAMP_RESOURCE_ATTRIBUTE]: types_1.WEBSITE_HOME_STAMPNAME,
};
/**
 * The AzureAppServiceDetector can be used to detect if a process is running in an Azure App Service
 * @returns a {@link Resource} populated with data about the environment or an empty Resource if detection fails.
 */
class AzureAppServiceDetector {
    detect() {
        let attributes = {};
        const websiteSiteName = process.env[types_1.WEBSITE_SITE_NAME];
        if (websiteSiteName && !(0, utils_1.isAzureFunction)() && !(0, utils_1.isAzureContainerApps)()) {
            attributes = {
                ...attributes,
                [semantic_conventions_1.ATTR_SERVICE_NAME]: websiteSiteName,
            };
            attributes = {
                ...attributes,
                [semconv_1.ATTR_CLOUD_PROVIDER]: semconv_1.CLOUD_PROVIDER_VALUE_AZURE,
            };
            attributes = {
                ...attributes,
                [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_AZURE_APP_SERVICE,
            };
            const azureResourceUri = (0, utils_1.getAzureResourceUri)(websiteSiteName);
            if (azureResourceUri) {
                attributes = {
                    ...attributes,
                    ...{ [types_1.CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE]: azureResourceUri },
                };
            }
            for (const [key, value] of Object.entries(APP_SERVICE_ATTRIBUTE_ENV_VARS)) {
                const envVar = process.env[value];
                if (envVar) {
                    attributes = { ...attributes, ...{ [key]: envVar } };
                }
            }
        }
        return { attributes };
    }
}
exports.azureAppServiceDetector = new AzureAppServiceDetector();
//# sourceMappingURL=AzureAppServiceDetector.js.map