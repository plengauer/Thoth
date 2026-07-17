import { Meter } from '@opentelemetry/api';
import { BaseCollector } from './baseCollector';
export declare class EventLoopUtilizationCollector extends BaseCollector {
    private _lastValue;
    updateMetricInstruments(meter: Meter): void;
    protected internalDisable(): void;
    protected internalEnable(): void;
}
//# sourceMappingURL=eventLoopUtilizationCollector.d.ts.map