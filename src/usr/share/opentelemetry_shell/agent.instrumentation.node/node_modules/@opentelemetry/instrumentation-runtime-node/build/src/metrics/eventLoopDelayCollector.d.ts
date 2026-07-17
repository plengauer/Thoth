import { Meter } from '@opentelemetry/api';
import type { RuntimeNodeInstrumentationConfig } from '../types';
import { BaseCollector } from './baseCollector';
export interface EventLoopLagInformation {
    min: number;
    max: number;
    mean: number;
    stddev: number;
    p50: number;
    p90: number;
    p99: number;
}
export declare class EventLoopDelayCollector extends BaseCollector {
    private _histogram;
    constructor(config?: RuntimeNodeInstrumentationConfig);
    updateMetricInstruments(meter: Meter): void;
    internalEnable(): void;
    internalDisable(): void;
    private scrape;
    private checkNan;
}
//# sourceMappingURL=eventLoopDelayCollector.d.ts.map