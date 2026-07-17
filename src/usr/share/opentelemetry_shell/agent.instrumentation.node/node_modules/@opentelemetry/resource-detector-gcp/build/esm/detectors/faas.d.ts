export declare function onCloudRun(): Promise<boolean>;
export declare function onCloudFunctions(): Promise<boolean>;
/**
 * The name of the Cloud Run or Cloud Function. Check that {@link onCloudRun()} or {@link
 * onCloudFunctions()} is true before calling this, or it may throw exceptions.
 */
export declare function faasName(): Promise<string>;
/**
 * The version/revision of the Cloud Run or Cloud Function. Check that {@link onCloudRun()} or
 * {@link onCloudFunctions()} is true before calling this, or it may throw exceptions.
 */
export declare function faasVersion(): Promise<string>;
/**
 * The ID for the running instance of a Cloud Run or Cloud Function. Check that {@link
 * onCloudRun()} or {@link onCloudFunctions()} is true before calling this, or it may throw
 * exceptions.
 */
export declare function faasInstance(): Promise<string>;
/**
 * The cloud region where the running instance of a Cloud Run or Cloud Function is located.
 * Check that {@link onCloudRun()} or {@link onCloudFunctions()} is true before calling this,
 * or it may throw exceptions.
 */
export declare function faasCloudRegion(): Promise<string>;
//# sourceMappingURL=faas.d.ts.map