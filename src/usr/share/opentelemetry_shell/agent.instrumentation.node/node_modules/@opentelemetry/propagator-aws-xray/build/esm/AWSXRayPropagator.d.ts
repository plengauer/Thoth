import { Context, TextMapPropagator, TextMapSetter, TextMapGetter } from '@opentelemetry/api';
export declare const AWSXRAY_TRACE_ID_HEADER = "x-amzn-trace-id";
/**
 * Implementation of the AWS X-Ray Trace Header propagation protocol. See <a href=
 * https://https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-tracingheader>AWS
 * Tracing header spec</a>
 *
 * An example AWS Xray Tracing Header is shown below:
 * X-Amzn-Trace-Id: Root=1-5759e988-bd862e3fe1be46a994272793;Parent=53995c3f42cd8ad8;Sampled=1
 */
export declare class AWSXRayPropagator implements TextMapPropagator {
    inject(context: Context, carrier: unknown, setter: TextMapSetter): void;
    extract(context: Context, carrier: unknown, getter: TextMapGetter): Context;
    fields(): string[];
    private getSpanContextFromHeader;
    private static _parseTraceId;
    private static _parseSpanId;
    private static _parseTraceFlag;
}
//# sourceMappingURL=AWSXRayPropagator.d.ts.map