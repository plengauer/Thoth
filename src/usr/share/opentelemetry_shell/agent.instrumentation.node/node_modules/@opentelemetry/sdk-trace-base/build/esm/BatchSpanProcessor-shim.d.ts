import type { SpanExporter } from '@opentelemetry/sdk-trace';
import { BatchSpanProcessor as BatchSpanProcessNoEnvConfig } from '@opentelemetry/sdk-trace';
import type { BatchSpanProcessorBrowserConfig, BufferConfig } from './types-shim';
/**
 * A BatchSpanProcessor that applies `OTEL_*` environment variable fallbacks per
 * https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
 */
export declare class BatchSpanProcessor extends BatchSpanProcessNoEnvConfig {
    constructor(exporter: SpanExporter, config?: BufferConfig | BatchSpanProcessorBrowserConfig);
}
//# sourceMappingURL=BatchSpanProcessor-shim.d.ts.map