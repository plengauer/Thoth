/**
 * Inlined from @smithy/core/config to avoid circular dependency.
 *
 * @internal
 */
type LoadedConfigSelectors<T> = {
    environmentVariableSelector: (env: Record<string, string | undefined>) => T | undefined;
    configFileSelector: (profile: Record<string, string | undefined>, configFile?: Record<string, Record<string, string | undefined>>) => T | undefined;
    default: T | (() => T);
};
export declare const getEndpointUrlConfig: (serviceId: string) => LoadedConfigSelectors<string | undefined>;
export {};
