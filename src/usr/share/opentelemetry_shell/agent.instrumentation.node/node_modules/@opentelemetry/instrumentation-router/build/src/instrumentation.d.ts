import { InstrumentationConfig, InstrumentationBase, InstrumentationNodeModuleDefinition } from '@opentelemetry/instrumentation';
export declare class RouterInstrumentation extends InstrumentationBase {
    constructor(config?: InstrumentationConfig);
    private _moduleVersion?;
    private _constants?;
    init(): InstrumentationNodeModuleDefinition;
    private _requestHandlerPatcher;
    private _errorHandlerPatcher;
    private _setupSpan;
}
//# sourceMappingURL=instrumentation.d.ts.map