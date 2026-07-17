"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventLoopTimeCollector = void 0;
const node_perf_hooks_1 = require("node:perf_hooks");
const baseCollector_1 = require("./baseCollector");
const semconv_1 = require("../semconv");
const { eventLoopUtilization: eventLoopUtilizationCollector } = node_perf_hooks_1.performance;
class EventLoopTimeCollector extends baseCollector_1.BaseCollector {
    updateMetricInstruments(meter) {
        const timeCounter = meter.createObservableCounter(semconv_1.METRIC_NODEJS_EVENTLOOP_TIME, {
            description: 'Cumulative duration of time the event loop has been in each state.',
            unit: 's',
        });
        meter.addBatchObservableCallback(async (observableResult) => {
            if (!this._config.enabled)
                return;
            const data = this.scrape();
            if (data === undefined)
                return;
            observableResult.observe(timeCounter, data.active / 1000, {
                [semconv_1.ATTR_NODEJS_EVENTLOOP_STATE]: semconv_1.NODEJS_EVENTLOOP_STATE_VALUE_ACTIVE,
            });
            observableResult.observe(timeCounter, data.idle / 1000, {
                [semconv_1.ATTR_NODEJS_EVENTLOOP_STATE]: semconv_1.NODEJS_EVENTLOOP_STATE_VALUE_IDLE,
            });
        }, [timeCounter]);
    }
    internalDisable() { }
    internalEnable() { }
    scrape() {
        return eventLoopUtilizationCollector();
    }
}
exports.EventLoopTimeCollector = EventLoopTimeCollector;
//# sourceMappingURL=eventLoopTimeCollector.js.map