"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.azureFunctionsDetector = void 0;
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
const semconv_1 = require("../semconv");
const types_1 = require("../types");
const utils_1 = require("../utils");
const AZURE_FUNCTIONS_ATTRIBUTE_ENV_VARS = {
    [semantic_conventions_1.ATTR_SERVICE_NAME]: types_1.WEBSITE_SITE_NAME,
    [semconv_1.ATTR_FAAS_INSTANCE]: types_1.WEBSITE_INSTANCE_ID,
    [semconv_1.ATTR_FAAS_MAX_MEMORY]: types_1.FUNCTIONS_MEM_LIMIT,
};
/**
 * The AzureFunctionsDetector can be used to detect if a process is running in Azure Functions
 * @returns a {@link Resource} populated with data about the environment or an empty Resource if detection fails.
 */
class AzureFunctionsDetector {
    detect() {
        let attributes = {};
        const serviceName = process.env[types_1.WEBSITE_SITE_NAME];
        /**
         * Checks that we are operating within an Azure Function using the function version since WEBSITE_SITE_NAME
         * will exist in Azure App Service as well and detectors should be mutually exclusive.
         * If the function version is not present, we check for the website sku to determine if it is a function.
         */
        if (serviceName && (0, utils_1.isAzureFunction)()) {
            const functionInstance = process.env[types_1.WEBSITE_INSTANCE_ID];
            const functionMemLimit = process.env[types_1.FUNCTIONS_MEM_LIMIT];
            attributes = {
                [semconv_1.ATTR_CLOUD_PROVIDER]: semconv_1.CLOUD_PROVIDER_VALUE_AZURE,
                [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_AZURE_FUNCTIONS,
                [semconv_1.ATTR_CLOUD_REGION]: process.env[types_1.REGION_NAME],
                [semconv_1.ATTR_PROCESS_PID]: process.pid,
            };
            if (serviceName) {
                attributes = {
                    ...attributes,
                    [semantic_conventions_1.ATTR_SERVICE_NAME]: serviceName,
                };
            }
            if (functionInstance) {
                attributes = {
                    ...attributes,
                    [semconv_1.ATTR_FAAS_INSTANCE]: functionInstance,
                };
            }
            if (functionMemLimit) {
                attributes = {
                    ...attributes,
                    [semconv_1.ATTR_FAAS_MAX_MEMORY]: functionMemLimit,
                };
            }
            const azureResourceUri = (0, utils_1.getAzureResourceUri)(serviceName);
            if (azureResourceUri) {
                attributes = {
                    ...attributes,
                    ...{ [types_1.CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE]: azureResourceUri },
                };
            }
            for (const [key, value] of Object.entries(AZURE_FUNCTIONS_ATTRIBUTE_ENV_VARS)) {
                const envVar = process.env[value];
                if (envVar) {
                    attributes = { ...attributes, ...{ [key]: envVar } };
                }
            }
        }
        return { attributes };
    }
}
exports.azureFunctionsDetector = new AzureFunctionsDetector();
//# sourceMappingURL=AzureFunctionsDetector.js.map