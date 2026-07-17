import { InstrumentationBase } from '@opentelemetry/instrumentation';
import type { LoggerProvider } from '@opentelemetry/api-logs';
import { RuntimeNodeInstrumentationConfig } from './types';
export declare class RuntimeNodeInstrumentation extends InstrumentationBase<RuntimeNodeInstrumentationConfig> {
    private readonly _collectors;
    private _loggerProvider?;
    private _onUncaughtExceptionHandler?;
    constructor(config?: RuntimeNodeInstrumentationConfig);
    _updateMetricInstruments(): void;
    init(): void;
    enable(): void;
    disable(): void;
    setLoggerProvider(loggerProvider: LoggerProvider): void;
    private _registerExceptionHandlers;
    private _unregisterExceptionHandlers;
    private _handleUncaughtException;
    private _emitExceptionLog;
    private _forceFlushLogs;
}
//# sourceMappingURL=instrumentation.d.ts.map