"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAttrsFromBaseURL = exports.getEnvBool = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
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
function getEnvBool(name, diag_ = api_1.diag) {
    const val = process.env[name];
    if (val === undefined || val === '') {
        return undefined;
    }
    else if (typeof val !== 'string') {
        throw new Error(`invalid type for environment variable: ${typeof val} (${name}=${val})`);
    }
    else {
        const valLower = val.toLowerCase();
        if (valLower === 'true') {
            return true;
        }
        else if (valLower === 'false') {
            return false;
        }
        else {
            diag_.warn(`invalid boolean value for environment variable: ${name}=${val}; ignoring`);
            return undefined;
        }
    }
}
exports.getEnvBool = getEnvBool;
const SERVER_PORT_FROM_URL_PROTOCOL = {
    'https:': 443,
    'http:': 80,
};
/**
 * Return span/metric attributes from the given OpenAI client baseURL.
 */
function getAttrsFromBaseURL(baseURL, diag_ = api_1.diag) {
    if (!baseURL) {
        return;
    }
    // TODO: would be nice to LRU cache this, but probably not significant perf
    let u;
    try {
        u = new URL(baseURL);
    }
    catch (ex) {
        // Note: We should never get to this point as openai should crash prior to this.
        // Even if it did, instrumentation will still work except lacking these attributes.
        diag_.debug(`could not determine server.{address,port} from baseURL: ${ex}`);
        return;
    }
    return {
        [semantic_conventions_1.ATTR_SERVER_ADDRESS]: u.hostname,
        [semantic_conventions_1.ATTR_SERVER_PORT]: u.port
            ? Number(u.port)
            : SERVER_PORT_FROM_URL_PROTOCOL[u.protocol],
    };
}
exports.getAttrsFromBaseURL = getAttrsFromBaseURL;
//# sourceMappingURL=utils.js.map