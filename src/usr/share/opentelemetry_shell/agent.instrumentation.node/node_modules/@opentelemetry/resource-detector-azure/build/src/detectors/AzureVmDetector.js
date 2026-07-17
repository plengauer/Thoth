"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.azureVmDetector = void 0;
const http = require("http");
const api_1 = require("@opentelemetry/api");
const core_1 = require("@opentelemetry/core");
const semconv_1 = require("../semconv");
const types_1 = require("../types");
/**
 * The AzureVmDetector can be used to detect if a process is running in an Azure VM.
 * @returns a {@link Resource} populated with data about the environment or an empty Resource if detection fails.
 */
class AzureVmResourceDetector {
    detect() {
        const dataPromise = api_1.context.with((0, core_1.suppressTracing)(api_1.context.active()), () => this.getAzureVmMetadata());
        const attrNames = [
            types_1.AZURE_VM_SCALE_SET_NAME_ATTRIBUTE,
            types_1.AZURE_VM_SKU_ATTRIBUTE,
            semconv_1.ATTR_CLOUD_PLATFORM,
            semconv_1.ATTR_CLOUD_PROVIDER,
            semconv_1.ATTR_CLOUD_REGION,
            types_1.CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE,
            semconv_1.ATTR_HOST_ID,
            semconv_1.ATTR_HOST_NAME,
            semconv_1.ATTR_HOST_TYPE,
            semconv_1.ATTR_OS_VERSION,
        ];
        const attributes = {};
        attrNames.forEach(name => {
            // Each resource attribute is determined asynchronously in _gatherData().
            attributes[name] = dataPromise.then(data => data[name]);
        });
        return { attributes };
    }
    async getAzureVmMetadata() {
        try {
            const options = {
                host: types_1.AZURE_VM_METADATA_HOST,
                path: types_1.AZURE_VM_METADATA_PATH,
                method: 'GET',
                timeout: 5000,
                headers: {
                    Metadata: 'True',
                },
            };
            const metadata = await new Promise((resolve, reject) => {
                const timeoutId = setTimeout(() => {
                    req.destroy();
                    reject(new Error('Azure metadata service request timed out.'));
                }, 1000);
                const req = http.request(options, res => {
                    clearTimeout(timeoutId);
                    const { statusCode } = res;
                    res.setEncoding('utf8');
                    let rawData = '';
                    res.on('data', chunk => (rawData += chunk));
                    res.on('end', () => {
                        if (statusCode && statusCode >= 200 && statusCode < 300) {
                            try {
                                resolve(JSON.parse(rawData));
                            }
                            catch (error) {
                                reject(error);
                            }
                        }
                        else {
                            reject(new Error('Failed to load page, status code: ' + statusCode));
                        }
                    });
                });
                req.on('error', err => {
                    clearTimeout(timeoutId);
                    reject(err);
                });
                req.end();
            });
            const attributes = {
                [types_1.AZURE_VM_SCALE_SET_NAME_ATTRIBUTE]: metadata['vmScaleSetName'],
                [types_1.AZURE_VM_SKU_ATTRIBUTE]: metadata['sku'],
                [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_AZURE_VM,
                [semconv_1.ATTR_CLOUD_PROVIDER]: semconv_1.CLOUD_PROVIDER_VALUE_AZURE,
                [semconv_1.ATTR_CLOUD_REGION]: metadata['location'],
                [types_1.CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE]: metadata['resourceId'],
                [semconv_1.ATTR_HOST_ID]: metadata['vmId'],
                [semconv_1.ATTR_HOST_NAME]: metadata['name'],
                [semconv_1.ATTR_HOST_TYPE]: metadata['vmSize'],
                [semconv_1.ATTR_OS_VERSION]: metadata['version'],
            };
            return attributes;
        }
        catch (err) {
            api_1.diag.debug('AzureVmResourceDetector: not running in an Azure VM:', err.message);
            return {};
        }
    }
}
exports.azureVmDetector = new AzureVmResourceDetector();
//# sourceMappingURL=AzureVmDetector.js.map