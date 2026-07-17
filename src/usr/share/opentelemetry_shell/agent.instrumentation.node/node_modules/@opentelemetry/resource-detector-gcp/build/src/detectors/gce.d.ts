export declare function onGce(): Promise<boolean>;
/**
 * The machine type of the instance on which this program is running. Check that {@link
 * onGce()} is true before calling this, or it may throw exceptions.
 */
export declare function hostType(): Promise<string>;
/**
 * The instance ID of the instance on which this program is running. Check that {@link onGce()}
 * is true before calling this, or it may throw exceptions.
 */
export declare function hostId(): Promise<string>;
/**
 * The instance ID of the instance on which this program is running. Check that {@link onGce()}
 * is true before calling this, or it may throw exceptions.
 */
export declare function hostName(): Promise<string>;
/**
 * The zone and region in which this program is running. Check that {@link onGce()} is true
 * before calling this, or it may throw exceptions.
 */
export declare function availabilityZoneAndRegion(): Promise<{
    zone: string;
    region: string;
}>;
//# sourceMappingURL=gce.d.ts.map