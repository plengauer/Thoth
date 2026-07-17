import type { Attributes } from '@opentelemetry/api';
import type { InstrumentationConfig } from '@opentelemetry/instrumentation';
export interface RuntimeNodeInstrumentationConfig extends InstrumentationConfig {
    monitoringPrecision?: number;
    /**
     * Capture uncaught exceptions via process 'uncaughtExceptionMonitor' event.
     * Disabled by default.
     * @experimental
     */
    captureUncaughtException?: boolean;
    /**
     * Add custom attributes to the emitted exception log records.
     * @experimental
     */
    applyCustomExceptionAttributes?: (error: unknown, eventType: 'uncaughtException') => Attributes;
}
//# sourceMappingURL=types.d.ts.map