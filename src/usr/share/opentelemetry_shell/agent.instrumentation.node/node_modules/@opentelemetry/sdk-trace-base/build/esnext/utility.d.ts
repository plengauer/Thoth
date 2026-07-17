import type { TracerConfig } from './types-shim';
export declare const DEFAULT_ATTRIBUTE_COUNT_LIMIT = 128;
export declare const DEFAULT_ATTRIBUTE_VALUE_LENGTH_LIMIT: number;
/**
 * When general limits are provided and model specific limits are not,
 * configures the model specific limits by using the values from the general ones.
 * @param userConfig User provided tracer configuration
 */
export declare function reconfigureLimits(userConfig: TracerConfig): TracerConfig;
//# sourceMappingURL=utility.d.ts.map