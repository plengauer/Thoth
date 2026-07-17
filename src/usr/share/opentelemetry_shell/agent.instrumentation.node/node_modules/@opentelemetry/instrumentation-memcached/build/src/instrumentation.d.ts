import * as api from '@opentelemetry/api';
import { InstrumentationBase, InstrumentationNodeModuleDefinition } from '@opentelemetry/instrumentation';
import type * as Memcached from 'memcached';
import { InstrumentationConfig } from './types';
export declare class MemcachedInstrumentation extends InstrumentationBase<InstrumentationConfig> {
    static readonly COMPONENT = "memcached";
    static readonly DEFAULT_CONFIG: InstrumentationConfig;
    private _netSemconvStability;
    private _dbSemconvStability;
    constructor(config?: InstrumentationConfig);
    private _setSemconvStabilityFromEnv;
    setConfig(config?: InstrumentationConfig): void;
    init(): InstrumentationNodeModuleDefinition[];
    wrapCommand(moduleVersion: undefined | string, original: (queryCompiler: () => Memcached.CommandData, server?: string) => any): (this: Memcached, queryCompiler: () => Memcached.CommandData, server?: string) => any;
    wrapQueryCompiler(original: () => Memcached.CommandData, client: Memcached, server: undefined | string, callbackContext: api.Context, span: api.Span): (this: Memcached) => Memcached.CommandData;
    private ensureWrapped;
}
//# sourceMappingURL=instrumentation.d.ts.map