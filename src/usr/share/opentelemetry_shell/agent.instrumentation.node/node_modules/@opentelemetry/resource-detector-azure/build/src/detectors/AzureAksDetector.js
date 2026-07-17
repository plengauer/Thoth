"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.azureAksDetector = void 0;
const fs = require("fs");
const api_1 = require("@opentelemetry/api");
const semconv_1 = require("../semconv");
const types_1 = require("../types");
/**
 * The AzureAksDetector can be used to detect if a process is running in an Azure Kubernetes Service (AKS) cluster.
 * It reads cluster metadata from environment variables populated from the aks-cluster-metadata ConfigMap
 * in the kube-public namespace, or from the ConfigMap file if mounted.
 *
 * The ConfigMap contains a single key 'clusterResourceId' with the full ARM resource ID.
 * The cluster name is extracted from this resource ID.
 *
 * @returns a {@link Resource} populated with data about the AKS environment or an empty Resource if detection fails.
 */
class AzureAksDetector {
    detect() {
        let attributes = {};
        const metadata = this.getAksMetadata();
        if (metadata && (metadata.name || metadata.resourceId)) {
            attributes = {
                [semconv_1.ATTR_CLOUD_PROVIDER]: semconv_1.CLOUD_PROVIDER_VALUE_AZURE,
                [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_AZURE_AKS,
            };
            if (metadata.name) {
                attributes = {
                    ...attributes,
                    [semconv_1.ATTR_K8S_CLUSTER_NAME]: metadata.name,
                };
            }
            if (metadata.resourceId) {
                attributes = {
                    ...attributes,
                    [types_1.CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE]: metadata.resourceId,
                };
            }
            api_1.diag.debug('AzureAksDetector: detected AKS cluster:', metadata);
        }
        return { attributes };
    }
    getAksMetadata() {
        // Try environment variable first (populated from aks-cluster-metadata ConfigMap)
        const clusterResourceId = process.env[types_1.AKS_CLUSTER_RESOURCE_ID];
        if (clusterResourceId) {
            return {
                name: (0, types_1.extractClusterNameFromResourceId)(clusterResourceId),
                resourceId: clusterResourceId,
            };
        }
        // Fall back to reading from mounted ConfigMap file
        return this.getAksMetadataFromFile();
    }
    getAksMetadataFromFile() {
        try {
            if (!fs.existsSync(types_1.AKS_METADATA_FILE_PATH)) {
                return undefined;
            }
            const content = fs.readFileSync(types_1.AKS_METADATA_FILE_PATH, 'utf8');
            const metadata = {};
            // Parse the ConfigMap file content (key=value format)
            // The native aks-cluster-metadata ConfigMap has a single key: clusterResourceId
            const lines = content.split('\n');
            for (const line of lines) {
                const trimmedLine = line.trim();
                if (!trimmedLine || trimmedLine.startsWith('#')) {
                    continue;
                }
                const [key, ...valueParts] = trimmedLine.split('=');
                const value = valueParts.join('=').trim();
                if (key === 'clusterResourceId' && value) {
                    metadata.resourceId = value;
                    metadata.name = (0, types_1.extractClusterNameFromResourceId)(value);
                }
            }
            if (metadata.resourceId) {
                return metadata;
            }
        }
        catch (err) {
            api_1.diag.debug('AzureAksDetector: failed to read AKS metadata file:', err.message);
        }
        return undefined;
    }
}
exports.azureAksDetector = new AzureAksDetector();
//# sourceMappingURL=AzureAksDetector.js.map