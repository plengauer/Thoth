import { Tracer, Span, DiagLogger, Meter, HrTime } from '@opentelemetry/api';
import { SemconvStability } from '@opentelemetry/instrumentation';
import { ServiceExtension, RequestMetadata } from './ServiceExtension';
import { AwsSdkInstrumentationConfig, NormalizedRequest, NormalizedResponse } from '../types';
export declare class ServicesExtensions implements ServiceExtension {
    services: Map<string, ServiceExtension>;
    constructor();
    private registerServices;
    requestPreSpanHook(request: NormalizedRequest, config: AwsSdkInstrumentationConfig, diag: DiagLogger, dbSemconvStability?: SemconvStability): RequestMetadata;
    requestPostSpanHook(request: NormalizedRequest): void;
    responseHook(response: NormalizedResponse, span: Span, tracer: Tracer, config: AwsSdkInstrumentationConfig, startTime: HrTime): any;
    updateMetricInstruments(meter: Meter): void;
}
//# sourceMappingURL=ServicesExtensions.d.ts.map