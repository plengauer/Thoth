"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventLoopUtilizationCollector = void 0;
const node_perf_hooks_1 = require("node:perf_hooks");
const baseCollector_1 = require("./baseCollector");
const semconv_1 = require("../semconv");
const { eventLoopUtilization: eventLoopUtilizationCollector } = node_perf_hooks_1.performance;
class EventLoopUtilizationCollector extends baseCollector_1.BaseCollector {
    // Value needs to be initialized the first time otherwise the first measurement would always be 1
    // See https://github.com/open-telemetry/opentelemetry-js-contrib/pull/3118#issuecomment-3429737955
    _lastValue = eventLoopUtilizationCollector();
    updateMetricInstruments(meter) {
        meter
            .createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_UTILIZATION, {
            description: 'Event loop utilization',
            unit: '1',
        })
            .addCallback(async (observableResult) => {
            if (!this._config.enabled)
                return;
            const currentELU = eventLoopUtilizationCollector();
            const deltaELU = eventLoopUtilizationCollector(currentELU, this._lastValue);
            this._lastValue = currentELU;
            observableResult.observe(deltaELU.utilization);
        });
    }
    internalDisable() { }
    internalEnable() { }
}
exports.EventLoopUtilizationCollector = EventLoopUtilizationCollector;
//# sourceMappingURL=eventLoopUtilizationCollector.js.map