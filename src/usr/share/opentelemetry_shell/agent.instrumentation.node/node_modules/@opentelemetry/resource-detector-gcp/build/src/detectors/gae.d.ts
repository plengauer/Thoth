export declare function onAppEngineStandard(): Promise<boolean>;
export declare function onAppEngine(): Promise<boolean>;
/**
 * The service name of the app engine service. Check that {@link onAppEngine()} is true before
 * calling this, or it may throw exceptions.
 */
export declare function serviceName(): Promise<string>;
/**
 * The service version of the app engine service. Check that {@link onAppEngine()} is true
 * before calling this, or it may throw exceptions.
 */
export declare function serviceVersion(): Promise<string>;
/**
 * The service instance of the app engine service. Check that {@link onAppEngine()} is true
 * before calling this, or it may throw exceptions.
 */
export declare function serviceInstance(): Promise<string>;
/**
 * The zone and region in which this program is running. Check that {@link onAppEngine()} is
 * true before calling this, or it may throw exceptions.
 */
export declare function flexAvailabilityZoneAndRegion(): Promise<{
    zone: string;
    region: string;
}>;
/**
 * The zone the app engine service is running in. Check that {@link onAppEngineStandard()} is
 * true before calling this, or it may throw exceptions.
 */
export declare function standardAvailabilityZone(): Promise<string>;
/**
 * The region the app engine service is running in. Check that {@link onAppEngineStandard()} is
 * true before calling this, or it may throw exceptions.
 */
export declare function standardCloudRegion(): Promise<string>;
//# sourceMappingURL=gae.d.ts.map