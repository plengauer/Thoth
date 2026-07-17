"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.endSpan = void 0;
const api_1 = require("@opentelemetry/api");
const endSpan = (span, err) => {
    if (err) {
        span.recordException(err);
        span.setStatus({
            code: api_1.SpanStatusCode.ERROR,
            message: err.message,
        });
    }
    span.end();
};
exports.endSpan = endSpan;
//# sourceMappingURL=utils.js.map