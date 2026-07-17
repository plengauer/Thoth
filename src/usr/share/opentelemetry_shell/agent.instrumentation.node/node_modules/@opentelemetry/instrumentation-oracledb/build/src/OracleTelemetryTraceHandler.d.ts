import { SpanContext } from '@opentelemetry/api';
import type * as oracleDBTypes from 'oracledb';
export declare function buildTraceparent(spanContext: SpanContext): string | undefined;
export declare function getOracleTelemetryTraceHandlerClass(obj: typeof oracleDBTypes): any;
//# sourceMappingURL=OracleTelemetryTraceHandler.d.ts.map