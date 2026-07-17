"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.addSqlCommenterComment = exports.buildTraceparent = void 0;
const api_1 = require("@opentelemetry/api");
const core_1 = require("@opentelemetry/core");
const propagator = new core_1.W3CTraceContextPropagator();
const TRACE_PARENT_HEADER = 'traceparent';
/**
 * Builds a W3C traceparent string from a span.
 * Returns undefined if the span context is invalid or tracing is suppressed.
 *
 * Format: "00-{traceId}-{spanId}-{flags}"
 * See: https://www.w3.org/TR/trace-context/#traceparent-header
 */
function buildTraceparent(span) {
    const carrier = {};
    propagator.inject(api_1.trace.setSpan(api_1.ROOT_CONTEXT, span), carrier, api_1.defaultTextMapSetter);
    return carrier[TRACE_PARENT_HEADER];
}
exports.buildTraceparent = buildTraceparent;
// NOTE: This function currently is returning false-positives
// in cases where comment characters appear in string literals
// ("SELECT '-- not a comment';" would return true, although has no comment)
function hasValidSqlComment(query) {
    const indexOpeningDashDashComment = query.indexOf('--');
    if (indexOpeningDashDashComment >= 0) {
        return true;
    }
    const indexOpeningSlashComment = query.indexOf('/*');
    if (indexOpeningSlashComment < 0) {
        return false;
    }
    const indexClosingSlashComment = query.indexOf('*/');
    return indexOpeningDashDashComment < indexClosingSlashComment;
}
// sqlcommenter specification (https://google.github.io/sqlcommenter/spec/#value-serialization)
// expects us to URL encode based on the RFC 3986 spec (https://en.wikipedia.org/wiki/Percent-encoding),
// but encodeURIComponent does not handle some characters correctly (! ' ( ) *),
// which means we need special handling for this
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
function fixedEncodeURIComponent(str) {
    return encodeURIComponent(str).replace(/[!'()*]/g, c => `%${c.charCodeAt(0).toString(16).toUpperCase()}`);
}
function addSqlCommenterComment(span, query) {
    if (typeof query !== 'string' || query.length === 0) {
        return query;
    }
    // As per sqlcommenter spec we shall not add a comment if there already is a comment
    // in the query
    if (hasValidSqlComment(query)) {
        return query;
    }
    const headers = {};
    propagator.inject(api_1.trace.setSpan(api_1.ROOT_CONTEXT, span), headers, api_1.defaultTextMapSetter);
    // sqlcommenter spec requires keys in the comment to be sorted lexicographically
    const sortedKeys = Object.keys(headers).sort();
    if (sortedKeys.length === 0) {
        return query;
    }
    const commentString = sortedKeys
        .map(key => {
        const encodedValue = fixedEncodeURIComponent(headers[key]);
        return `${key}='${encodedValue}'`;
    })
        .join(',');
    return `${query} /*${commentString}*/`;
}
exports.addSqlCommenterComment = addSqlCommenterComment;
//# sourceMappingURL=index.js.map