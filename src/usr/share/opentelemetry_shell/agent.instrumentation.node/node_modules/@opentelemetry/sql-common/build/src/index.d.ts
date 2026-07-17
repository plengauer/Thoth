import { Span } from '@opentelemetry/api';
/**
 * Builds a W3C traceparent string from a span.
 * Returns undefined if the span context is invalid or tracing is suppressed.
 *
 * Format: "00-{traceId}-{spanId}-{flags}"
 * See: https://www.w3.org/TR/trace-context/#traceparent-header
 */
export declare function buildTraceparent(span: Span): string | undefined;
export declare function addSqlCommenterComment(span: Span, query: string): string;
//# sourceMappingURL=index.d.ts.map