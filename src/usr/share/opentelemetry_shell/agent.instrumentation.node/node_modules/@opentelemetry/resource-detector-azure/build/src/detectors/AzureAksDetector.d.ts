import { ResourceDetector, DetectedResource } from '@opentelemetry/resources';
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
declare class AzureAksDetector implements ResourceDetector {
    detect(): DetectedResource;
    private getAksMetadata;
    private getAksMetadataFromFile;
}
export declare const azureAksDetector: AzureAksDetector;
export {};
//# sourceMappingURL=AzureAksDetector.d.ts.map