import * as types from '../../types';
import { wrap, unwrap, massWrap, massUnwrap } from 'shimmer';
import { InstrumentationAbstract } from '../../instrumentation';
/**
 * Base abstract class for instrumenting node plugins
 */
export declare abstract class InstrumentationBase<T = any> extends InstrumentationAbstract implements types.Instrumentation {
    private _modules;
    private _hooks;
    private _requireInTheMiddleSingleton;
    private _enabled;
    constructor(instrumentationName: string, instrumentationVersion: string, config?: types.InstrumentationConfig);
    protected _wrap: typeof wrap;
    protected _unwrap: typeof unwrap;
    protected _massWrap: typeof massWrap;
    protected _massUnwrap: typeof massUnwrap;
    private _warnOnPreloadedModules;
    private _extractPackageVersion;
    private _onRequire;
    enable(): void;
    disable(): void;
    isEnabled(): boolean;
}
//# sourceMappingURL=instrumentation.d.ts.map