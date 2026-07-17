"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractClusterNameFromResourceId = exports.AKS_METADATA_FILE_PATH = exports.AKS_CLUSTER_RESOURCE_ID = exports.CONTAINER_APP_PORT = exports.CONTAINER_APP_REPLICA_NAME = exports.CONTAINER_APP_ENV_DNS_SUFFIX = exports.CONTAINER_APP_HOSTNAME = exports.CONTAINER_APP_REVISION = exports.CONTAINER_APP_NAME = exports.AZURE_CONTAINER_APP_VERSION = exports.AZURE_CONTAINER_APP_NAME = exports.AZURE_CONTAINER_APP_INSTANCE_ID = exports.AZURE_VM_SKU_ATTRIBUTE = exports.AZURE_VM_SCALE_SET_NAME_ATTRIBUTE = exports.AZURE_VM_METADATA_PATH = exports.AZURE_VM_METADATA_HOST = exports.FUNCTIONS_MEM_LIMIT = exports.FUNCTIONS_VERSION = exports.WEBSITE_SKU = exports.WEBSITE_SLOT_NAME = exports.WEBSITE_SITE_NAME = exports.WEBSITE_RESOURCE_GROUP = exports.WEBSITE_OWNER_NAME = exports.WEBSITE_INSTANCE_ID = exports.WEBSITE_HOSTNAME = exports.WEBSITE_HOME_STAMPNAME = exports.REGION_NAME = exports.CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE = exports.AZURE_APP_SERVICE_STAMP_RESOURCE_ATTRIBUTE = void 0;
exports.AZURE_APP_SERVICE_STAMP_RESOURCE_ATTRIBUTE = 'azure.app.service.stamp';
exports.CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE = 'cloud.resource_id';
exports.REGION_NAME = 'REGION_NAME';
exports.WEBSITE_HOME_STAMPNAME = 'WEBSITE_HOME_STAMPNAME';
exports.WEBSITE_HOSTNAME = 'WEBSITE_HOSTNAME';
exports.WEBSITE_INSTANCE_ID = 'WEBSITE_INSTANCE_ID';
exports.WEBSITE_OWNER_NAME = 'WEBSITE_OWNER_NAME';
exports.WEBSITE_RESOURCE_GROUP = 'WEBSITE_RESOURCE_GROUP';
exports.WEBSITE_SITE_NAME = 'WEBSITE_SITE_NAME';
exports.WEBSITE_SLOT_NAME = 'WEBSITE_SLOT_NAME';
exports.WEBSITE_SKU = 'WEBSITE_SKU';
exports.FUNCTIONS_VERSION = 'FUNCTIONS_EXTENSION_VERSION';
exports.FUNCTIONS_MEM_LIMIT = 'WEBSITE_MEMORY_LIMIT_MB';
exports.AZURE_VM_METADATA_HOST = '169.254.169.254';
exports.AZURE_VM_METADATA_PATH = '/metadata/instance/compute?api-version=2021-12-13&format=json';
exports.AZURE_VM_SCALE_SET_NAME_ATTRIBUTE = 'azure.vm.scaleset.name';
exports.AZURE_VM_SKU_ATTRIBUTE = 'azure.vm.sku';
exports.AZURE_CONTAINER_APP_INSTANCE_ID = 'azure.container_app.instance.id';
exports.AZURE_CONTAINER_APP_NAME = 'azure.container_app.name';
exports.AZURE_CONTAINER_APP_VERSION = 'azure.container_app.version';
exports.CONTAINER_APP_NAME = 'CONTAINER_APP_NAME';
exports.CONTAINER_APP_REVISION = 'CONTAINER_APP_REVISION';
exports.CONTAINER_APP_HOSTNAME = 'CONTAINER_APP_HOSTNAME';
exports.CONTAINER_APP_ENV_DNS_SUFFIX = 'CONTAINER_APP_ENV_DNS_SUFFIX';
exports.CONTAINER_APP_REPLICA_NAME = 'CONTAINER_APP_REPLICA_NAME';
exports.CONTAINER_APP_PORT = 'CONTAINER_APP_PORT';
// AKS ConfigMap environment variables
// The native AKS ConfigMap is 'aks-cluster-metadata' in 'kube-public' namespace
// with a single key 'clusterResourceId'
exports.AKS_CLUSTER_RESOURCE_ID = 'CLUSTER_RESOURCE_ID';
// AKS ConfigMap file path (mounted from aks-cluster-metadata ConfigMap in kube-public)
exports.AKS_METADATA_FILE_PATH = '/etc/kubernetes/aks-cluster-metadata';
/**
 * Extracts the cluster name from an AKS ARM resource ID.
 * @param resourceId The full ARM resource ID, e.g.:
 *   /subscriptions/.../resourceGroups/.../providers/Microsoft.ContainerService/managedClusters/my-cluster
 * @returns The cluster name (last segment), or undefined if not found
 */
function extractClusterNameFromResourceId(resourceId) {
    if (!resourceId)
        return undefined;
    const segments = resourceId.split('/');
    // The cluster name is the last segment after 'managedClusters'
    const managedClustersIndex = segments.findIndex(s => s.toLowerCase() === 'managedclusters');
    if (managedClustersIndex !== -1 &&
        managedClustersIndex < segments.length - 1) {
        return segments[managedClustersIndex + 1];
    }
    // Fallback: just return the last segment
    return segments[segments.length - 1] || undefined;
}
exports.extractClusterNameFromResourceId = extractClusterNameFromResourceId;
//# sourceMappingURL=types.js.map