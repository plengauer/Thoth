"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.BasicTracerProvider = void 0;
const core_1 = require("@opentelemetry/core");
const config_1 = require("./config");
const utility_1 = require("./utility");
const sdk_trace_1 = require("@opentelemetry/sdk-trace");
/**
 * A TracerProvider implementation that reads configuration defaults from
 * OTEL_* environment variables per
 * https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
 */
class BasicTracerProvider extends sdk_trace_1.TracerProvider {
    constructor(config = {}) {
        const mergedConfig = (0, core_1.merge)({}, (0, config_1.loadDefaultConfig)(), (0, utility_1.reconfigureLimits)(config));
        delete mergedConfig.generalLimits;
        super(mergedConfig);
    }
}
exports.BasicTracerProvider = BasicTracerProvider;
//# sourceMappingURL=BasicTracerProvider-shim.js.map