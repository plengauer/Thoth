import { Meter } from '@opentelemetry/api';
import { BaseCollector } from './baseCollector';
export declare class EventLoopTimeCollector extends BaseCollector {
    updateMetricInstruments(meter: Meter): void;
    protected internalDisable(): void;
    protected internalEnable(): void;
    private scrape;
}
//# sourceMappingURL=eventLoopTimeCollector.d.ts.map