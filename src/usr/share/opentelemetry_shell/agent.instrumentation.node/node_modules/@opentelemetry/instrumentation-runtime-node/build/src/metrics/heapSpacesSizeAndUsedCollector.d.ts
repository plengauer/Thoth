import { Meter } from '@opentelemetry/api';
import { BaseCollector } from './baseCollector';
export declare class HeapSpacesSizeAndUsedCollector extends BaseCollector {
    updateMetricInstruments(meter: Meter): void;
    internalEnable(): void;
    internalDisable(): void;
    private scrape;
}
//# sourceMappingURL=heapSpacesSizeAndUsedCollector.d.ts.map