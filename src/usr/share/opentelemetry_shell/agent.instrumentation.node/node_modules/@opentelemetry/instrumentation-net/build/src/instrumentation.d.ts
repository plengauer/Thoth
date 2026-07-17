import { InstrumentationBase, InstrumentationConfig, InstrumentationNodeModuleDefinition } from '@opentelemetry/instrumentation';
export declare class NetInstrumentation extends InstrumentationBase {
    private _netSemconvStability;
    constructor(config?: InstrumentationConfig);
    private _setSemconvStabilityFromEnv;
    init(): InstrumentationNodeModuleDefinition[];
    private _getPatchedConnect;
    private _startSpan;
    private _startTLSSpan;
    private _startGenericSpan;
    private _startIpcSpan;
    private _startTcpSpan;
}
//# sourceMappingURL=instrumentation.d.ts.map