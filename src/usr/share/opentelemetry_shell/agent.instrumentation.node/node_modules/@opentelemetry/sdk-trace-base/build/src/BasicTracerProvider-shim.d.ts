import type { TracerConfig } from './types-shim';
import { TracerProvider } from '@opentelemetry/sdk-trace';
/**
 * A TracerProvider implementation that reads configuration defaults from
 * OTEL_* environment variables per
 * https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
 */
export declare class BasicTracerProvider extends TracerProvider {
    constructor(config?: TracerConfig);
}
//# sourceMappingURL=BasicTracerProvider-shim.d.ts.map