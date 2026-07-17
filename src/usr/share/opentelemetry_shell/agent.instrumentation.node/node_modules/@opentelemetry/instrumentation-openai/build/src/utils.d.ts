import type { Attributes, DiagLogger } from '@opentelemetry/api';
/**
 * Read a boolean from an environment variable.
 *
 * https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#boolean
 *
 * @param {string} name
 * @returns {boolean | undefined}
 *    - Returns `undefined` if the envvar is not set on `process.env` or is
 *      the empty string. This indicates that no explicit value was given,
 *      which may be a useful distinction from an explicit `false` for callers.
 *    - Returns `true` iff the envvar value is the string "true" (case-insensitive).
 *    - Returns `false`, iff the envvar value is the string "false" (case-insensitive).
 *    - Otherwise, it `diag.warn()`s about the invalid value and returns
 *      `undefined` as a (falsey) fallback.
 * @throws if the envvar value is set and is not a string
 */
export declare function getEnvBool(name: string, diag_?: DiagLogger): boolean | undefined;
/**
 * Return span/metric attributes from the given OpenAI client baseURL.
 */
export declare function getAttrsFromBaseURL(baseURL: string | undefined, diag_?: DiagLogger): Attributes | undefined;
//# sourceMappingURL=utils.d.ts.map