"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.HeapSpacesSizeAndUsedCollector = void 0;
const v8 = require("node:v8");
const baseCollector_1 = require("./baseCollector");
const semconv_1 = require("../semconv");
class HeapSpacesSizeAndUsedCollector extends baseCollector_1.BaseCollector {
    updateMetricInstruments(meter) {
        const heapLimit = meter.createObservableUpDownCounter(semconv_1.METRIC_V8JS_MEMORY_HEAP_LIMIT, {
            description: 'Maximum heap size allowed by the V8 engine, as set by --max-old-space-size or V8 defaults.',
            unit: 'By',
        });
        const heapSpaceSize = meter.createObservableUpDownCounter(semconv_1.METRIC_V8JS_MEMORY_HEAP_SPACE_SIZE, {
            description: 'Total heap memory size pre-allocated for a heap space.',
            unit: 'By',
        });
        const heapSpaceUsed = meter.createObservableGauge(semconv_1.METRIC_V8JS_MEMORY_HEAP_USED, {
            description: 'Heap Memory size allocated.',
            unit: 'By',
        });
        const heapSpaceAvailable = meter.createObservableGauge(semconv_1.METRIC_V8JS_MEMORY_HEAP_SPACE_AVAILABLE_SIZE, {
            description: 'Heap space available size.',
            unit: 'By',
        });
        const heapSpacePhysical = meter.createObservableGauge(semconv_1.METRIC_V8JS_MEMORY_HEAP_SPACE_PHYSICAL_SIZE, {
            description: 'Committed size of a heap space.',
            unit: 'By',
        });
        meter.addBatchObservableCallback(observableResult => {
            if (!this._config.enabled)
                return;
            const heapStats = v8.getHeapStatistics();
            observableResult.observe(heapLimit, heapStats.heap_size_limit);
            const data = this.scrape();
            if (data === undefined)
                return;
            for (const space of data) {
                const spaceName = space.space_name;
                observableResult.observe(heapSpaceSize, space.space_size, {
                    [semconv_1.ATTR_V8JS_HEAP_SPACE_NAME]: spaceName,
                });
                observableResult.observe(heapSpaceUsed, space.space_used_size, {
                    [semconv_1.ATTR_V8JS_HEAP_SPACE_NAME]: spaceName,
                });
                observableResult.observe(heapSpaceAvailable, space.space_available_size, {
                    [semconv_1.ATTR_V8JS_HEAP_SPACE_NAME]: spaceName,
                });
                observableResult.observe(heapSpacePhysical, space.physical_space_size, {
                    [semconv_1.ATTR_V8JS_HEAP_SPACE_NAME]: spaceName,
                });
            }
        }, [
            heapLimit,
            heapSpaceSize,
            heapSpaceUsed,
            heapSpaceAvailable,
            heapSpacePhysical,
        ]);
    }
    internalEnable() { }
    internalDisable() { }
    scrape() {
        return v8.getHeapSpaceStatistics();
    }
}
exports.HeapSpacesSizeAndUsedCollector = HeapSpacesSizeAndUsedCollector;
//# sourceMappingURL=heapSpacesSizeAndUsedCollector.js.map