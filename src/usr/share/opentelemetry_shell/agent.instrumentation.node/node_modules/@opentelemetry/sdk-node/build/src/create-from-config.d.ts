/**
 * Create SDK components from parsed declarative config.
 * https://opentelemetry.io/docs/specs/otel/configuration/sdk/#create
 */
import type { AttributeLimitsConfigModel, SpanLimitsConfigModel } from '@opentelemetry/configuration';
import type { SpanLimits } from '@opentelemetry/sdk-trace';
export declare function createSpanLimitsFromConfig(limits?: SpanLimitsConfigModel, attribute_limits?: AttributeLimitsConfigModel): SpanLimits | undefined;
//# sourceMappingURL=create-from-config.d.ts.map