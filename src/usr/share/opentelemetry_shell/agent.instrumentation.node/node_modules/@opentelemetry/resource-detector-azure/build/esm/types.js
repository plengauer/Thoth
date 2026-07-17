/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
export const AZURE_APP_SERVICE_STAMP_RESOURCE_ATTRIBUTE = 'azure.app.service.stamp';
export const CLOUD_RESOURCE_ID_RESOURCE_ATTRIBUTE = 'cloud.resource_id';
export const REGION_NAME = 'REGION_NAME';
export const WEBSITE_HOME_STAMPNAME = 'WEBSITE_HOME_STAMPNAME';
export const WEBSITE_HOSTNAME = 'WEBSITE_HOSTNAME';
export const WEBSITE_INSTANCE_ID = 'WEBSITE_INSTANCE_ID';
export const WEBSITE_OWNER_NAME = 'WEBSITE_OWNER_NAME';
export const WEBSITE_RESOURCE_GROUP = 'WEBSITE_RESOURCE_GROUP';
export const WEBSITE_SITE_NAME = 'WEBSITE_SITE_NAME';
export const WEBSITE_SLOT_NAME = 'WEBSITE_SLOT_NAME';
export const WEBSITE_SKU = 'WEBSITE_SKU';
export const FUNCTIONS_VERSION = 'FUNCTIONS_EXTENSION_VERSION';
export const FUNCTIONS_MEM_LIMIT = 'WEBSITE_MEMORY_LIMIT_MB';
export const AZURE_VM_METADATA_HOST = '169.254.169.254';
export const AZURE_VM_METADATA_PATH = '/metadata/instance/compute?api-version=2021-12-13&format=json';
export const AZURE_VM_SCALE_SET_NAME_ATTRIBUTE = 'azure.vm.scaleset.name';
export const AZURE_VM_SKU_ATTRIBUTE = 'azure.vm.sku';
export const AZURE_CONTAINER_APP_INSTANCE_ID = 'azure.container_app.instance.id';
export const AZURE_CONTAINER_APP_NAME = 'azure.container_app.name';
export const AZURE_CONTAINER_APP_VERSION = 'azure.container_app.version';
export const CONTAINER_APP_NAME = 'CONTAINER_APP_NAME';
export const CONTAINER_APP_REVISION = 'CONTAINER_APP_REVISION';
export const CONTAINER_APP_HOSTNAME = 'CONTAINER_APP_HOSTNAME';
export const CONTAINER_APP_ENV_DNS_SUFFIX = 'CONTAINER_APP_ENV_DNS_SUFFIX';
export const CONTAINER_APP_REPLICA_NAME = 'CONTAINER_APP_REPLICA_NAME';
export const CONTAINER_APP_PORT = 'CONTAINER_APP_PORT';
// AKS ConfigMap environment variables
// The native AKS ConfigMap is 'aks-cluster-metadata' in 'kube-public' namespace
// with a single key 'clusterResourceId'
export const AKS_CLUSTER_RESOURCE_ID = 'CLUSTER_RESOURCE_ID';
// AKS ConfigMap file path (mounted from aks-cluster-metadata ConfigMap in kube-public)
export const AKS_METADATA_FILE_PATH = '/etc/kubernetes/aks-cluster-metadata';
/**
 * Extracts the cluster name from an AKS ARM resource ID.
 * @param resourceId The full ARM resource ID, e.g.:
 *   /subscriptions/.../resourceGroups/.../providers/Microsoft.ContainerService/managedClusters/my-cluster
 * @returns The cluster name (last segment), or undefined if not found
 */
export function extractClusterNameFromResourceId(resourceId) {
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
//# sourceMappingURL=types.js.map