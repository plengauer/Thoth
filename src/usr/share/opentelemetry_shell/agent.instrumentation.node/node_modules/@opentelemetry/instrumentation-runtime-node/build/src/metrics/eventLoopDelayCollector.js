"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventLoopDelayCollector = void 0;
const perf_hooks = require("node:perf_hooks");
const semconv_1 = require("../semconv");
const baseCollector_1 = require("./baseCollector");
class EventLoopDelayCollector extends baseCollector_1.BaseCollector {
    _histogram;
    constructor(config = {}) {
        super(config);
        this._histogram = perf_hooks.monitorEventLoopDelay({
            resolution: config.monitoringPrecision,
        });
    }
    updateMetricInstruments(meter) {
        const delayMin = meter.createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_DELAY_MIN, {
            description: 'Event loop minimum delay.',
            unit: 's',
        });
        const delayMax = meter.createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_DELAY_MAX, {
            description: 'Event loop maximum delay.',
            unit: 's',
        });
        const delayMean = meter.createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_DELAY_MEAN, {
            description: 'Event loop mean delay.',
            unit: 's',
        });
        const delayStddev = meter.createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_DELAY_STDDEV, {
            description: 'Event loop standard deviation delay.',
            unit: 's',
        });
        const delayp50 = meter.createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_DELAY_P50, {
            description: 'Event loop 50 percentile delay.',
            unit: 's',
        });
        const delayp90 = meter.createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_DELAY_P90, {
            description: 'Event loop 90 percentile delay.',
            unit: 's',
        });
        const delayp99 = meter.createObservableGauge(semconv_1.METRIC_NODEJS_EVENTLOOP_DELAY_P99, {
            description: 'Event loop 99 percentile delay.',
            unit: 's',
        });
        meter.addBatchObservableCallback(async (observableResult) => {
            if (!this._config.enabled)
                return;
            const data = this.scrape();
            if (data === undefined)
                return;
            if (this._histogram.count < 5)
                return; // Don't return histogram data if we have less than 5 samples
            observableResult.observe(delayMin, data.min);
            observableResult.observe(delayMax, data.max);
            observableResult.observe(delayMean, data.mean);
            observableResult.observe(delayStddev, data.stddev);
            observableResult.observe(delayp50, data.p50);
            observableResult.observe(delayp90, data.p90);
            observableResult.observe(delayp99, data.p99);
            this._histogram.reset();
        }, [delayMin, delayMax, delayMean, delayStddev, delayp50, delayp90, delayp99]);
    }
    internalEnable() {
        this._histogram.enable();
    }
    internalDisable() {
        this._histogram.disable();
    }
    scrape() {
        return {
            min: this.checkNan(this._histogram.min / 1e9),
            max: this.checkNan(this._histogram.max / 1e9),
            mean: this.checkNan(this._histogram.mean / 1e9),
            stddev: this.checkNan(this._histogram.stddev / 1e9),
            p50: this.checkNan(this._histogram.percentile(50) / 1e9),
            p90: this.checkNan(this._histogram.percentile(90) / 1e9),
            p99: this.checkNan(this._histogram.percentile(99) / 1e9),
        };
    }
    checkNan(value) {
        return isNaN(value) ? 0 : value;
    }
}
exports.EventLoopDelayCollector = EventLoopDelayCollector;
//# sourceMappingURL=eventLoopDelayCollector.js.map