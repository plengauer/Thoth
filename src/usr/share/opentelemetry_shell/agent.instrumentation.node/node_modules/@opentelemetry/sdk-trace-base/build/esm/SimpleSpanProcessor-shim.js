/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
import { SimpleSpanProcessor as SdkTraceSimpleSpanProcessor } from '@opentelemetry/sdk-trace';
/**
 * A SimpleSpanProcessor with the old constructor call signature that
 * takes just a single exporter argument. This version does not support
 * the additional options that the SimpleSpanProcessor in sdk-trace does.
 */
export class SimpleSpanProcessor extends SdkTraceSimpleSpanProcessor {
    constructor(exporter) {
        super({ exporter });
    }
}
//# sourceMappingURL=SimpleSpanProcessor-shim.js.map