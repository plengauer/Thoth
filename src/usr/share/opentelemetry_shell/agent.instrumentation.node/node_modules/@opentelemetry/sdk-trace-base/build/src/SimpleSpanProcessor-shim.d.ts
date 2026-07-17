import type { SpanExporter } from '@opentelemetry/sdk-trace';
import { SimpleSpanProcessor as SdkTraceSimpleSpanProcessor } from '@opentelemetry/sdk-trace';
/**
 * A SimpleSpanProcessor with the old constructor call signature that
 * takes just a single exporter argument. This version does not support
 * the additional options that the SimpleSpanProcessor in sdk-trace does.
 */
export declare class SimpleSpanProcessor extends SdkTraceSimpleSpanProcessor {
    constructor(exporter: SpanExporter);
}
//# sourceMappingURL=SimpleSpanProcessor-shim.d.ts.map