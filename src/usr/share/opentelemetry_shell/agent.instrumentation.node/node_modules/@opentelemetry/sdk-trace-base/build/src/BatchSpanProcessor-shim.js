"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.BatchSpanProcessor = void 0;
const core_1 = require("@opentelemetry/core");
const sdk_trace_1 = require("@opentelemetry/sdk-trace");
/**
 * A BatchSpanProcessor that applies `OTEL_*` environment variable fallbacks per
 * https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
 */
class BatchSpanProcessor extends sdk_trace_1.BatchSpanProcessor {
    constructor(exporter, config) {
        if (!config) {
            config = {};
        }
        const envFallbacks = [
            ['maxExportBatchSize', 'OTEL_BSP_MAX_EXPORT_BATCH_SIZE'],
            ['maxQueueSize', 'OTEL_BSP_MAX_QUEUE_SIZE'],
            ['scheduledDelayMillis', 'OTEL_BSP_SCHEDULE_DELAY'],
            ['exportTimeoutMillis', 'OTEL_BSP_EXPORT_TIMEOUT'],
        ];
        for (const [configName, envName] of envFallbacks) {
            if (config[configName] === undefined) {
                const envFallback = (0, core_1.getNumberFromEnv)(envName);
                if (envFallback !== undefined) {
                    config[configName] = envFallback;
                }
            }
        }
        super({ exporter, ...config });
    }
}
exports.BatchSpanProcessor = BatchSpanProcessor;
//# sourceMappingURL=BatchSpanProcessor-shim.js.map