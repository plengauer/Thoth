"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SimpleSpanProcessor = void 0;
const sdk_trace_1 = require("@opentelemetry/sdk-trace");
/**
 * A SimpleSpanProcessor with the old constructor call signature that
 * takes just a single exporter argument. This version does not support
 * the additional options that the SimpleSpanProcessor in sdk-trace does.
 */
class SimpleSpanProcessor extends sdk_trace_1.SimpleSpanProcessor {
    constructor(exporter) {
        super({ exporter });
    }
}
exports.SimpleSpanProcessor = SimpleSpanProcessor;
//# sourceMappingURL=SimpleSpanProcessor-shim.js.map