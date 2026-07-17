import { DiagLogger, Span, Tracer } from '@opentelemetry/api';
import { SemconvStability } from '@opentelemetry/instrumentation';
import { RequestMetadata, ServiceExtension } from './ServiceExtension';
import { AwsSdkInstrumentationConfig, NormalizedRequest, NormalizedResponse } from '../types';
export declare class DynamodbServiceExtension implements ServiceExtension {
    toArray<T>(values: T | T[]): T[];
    requestPreSpanHook(normalizedRequest: NormalizedRequest, config: AwsSdkInstrumentationConfig, diag: DiagLogger, dbSemconvStability?: SemconvStability): RequestMetadata;
    responseHook(response: NormalizedResponse, span: Span, _tracer: Tracer, _config: AwsSdkInstrumentationConfig): void;
}
//# sourceMappingURL=dynamodb.d.ts.map