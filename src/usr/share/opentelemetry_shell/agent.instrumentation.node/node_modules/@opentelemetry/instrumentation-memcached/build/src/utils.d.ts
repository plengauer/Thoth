import type * as Memcached from 'memcached';
import { SemconvStability } from '@opentelemetry/instrumentation';
import { Attributes } from '@opentelemetry/api';
export declare const getPeerAttributes: (client: any, server: string | undefined, query: Memcached.CommandData, netSemconvStability: SemconvStability) => Attributes;
//# sourceMappingURL=utils.d.ts.map