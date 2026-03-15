import java.lang.instrument.Instrumentation;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.Span;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.SpanContext;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.TraceFlags;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.TraceState;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.context.Context;

public class GradleHttpPropagationAgent {
    public static void premain(String args, Instrumentation instrumentation) {
        String traceparent = System.getProperty("otel.gradle.traceparent");
        if (traceparent != null && !traceparent.isEmpty()) {
            String[] parts = traceparent.split("-");
            if (parts.length >= 4) {
                try {
                    SpanContext parentContext = SpanContext.create(
                        parts[1],
                        parts[2],
                        TraceFlags.fromHex(parts[3], 0),
                        TraceState.getDefault()
                    );
                    Context.current().with(Span.wrap(parentContext)).makeCurrent();
                } catch (Exception e) {
                }
            }
        }
    }
}
