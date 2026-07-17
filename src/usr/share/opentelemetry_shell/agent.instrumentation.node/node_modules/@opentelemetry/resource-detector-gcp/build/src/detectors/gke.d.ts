export declare function onGke(): Promise<boolean>;
/**
 * The instance ID of the instance on which this program is running. Check that {@link onGke()}
 * is true before calling this, or it may throw exceptions.
 */
export declare function hostId(): Promise<string>;
/**
 * The name of the GKE cluster in which this program is running. Check that {@link onGke()} is
 * true before calling this, or it may throw exceptions.
 */
export declare function clusterName(): Promise<string>;
/**
 * The location of the cluster and whether the cluster is zonal or regional. Check that {@link
 * onGke()} is true before calling this, or it may throw exceptions.
 */
export declare function availabilityZoneOrRegion(): Promise<{
    type: 'zone' | 'region';
    value: string;
}>;
//# sourceMappingURL=gke.d.ts.map