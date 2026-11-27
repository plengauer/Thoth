import java.lang.instrument.Instrumentation;
import java.util.Locale;
import java.util.Map;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.baggage.propagation.W3CBaggagePropagator;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.Span;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.SpanContext;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.TraceFlags;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.TraceState;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.context.Context;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.context.propagation.TextMapGetter;

// The agent manifest names this class without a package
// Making every local variable final is noise without a safety benefit
@SuppressWarnings({"PMD.NoPackage", "PMD.LocalVariableCouldBeFinal"})
public final class RootContextAgent {
    private RootContextAgent() {
    }

    public static void premain(String args, Instrumentation instrumentation) {
        for (String propagator : System.getenv().getOrDefault("OTEL_PROPAGATORS", "tracecontext,baggage").replaceFirst("(?i)^(?!(.*,)?\\s*(tracecontext|b3)\\s*(,|$))(?!(\\s*(none|baggage)?\\s*(,|$))*$).+$", "$0,tracecontext").split(",")) {
            String name = propagator.trim();
            String traceparent = System.getenv("TRACEPARENT");
            String b3 = System.getenv("B3");
            if ("tracecontext".equalsIgnoreCase(name) && traceparent != null) {
                String[] parts = traceparent.split("-");
                if (parts.length >= 4) {
                    attach(parts[1], parts[2], TraceFlags.fromHex(parts[3], 0));
                }
            } else if ("b3".equalsIgnoreCase(name) && b3 != null) {
                String[] parts = b3.split("-");
                if (parts.length >= 2) {
                    String traceId = parts[0].length() == 16 ? "0000000000000000" + parts[0] : parts[0];
                    boolean sampled = parts.length < 3 || "1".equals(parts[2]) || "d".equals(parts[2]);
                    attach(traceId, parts[1], sampled ? TraceFlags.getSampled() : TraceFlags.getDefault());
                }
            } else if ("baggage".equalsIgnoreCase(name)) {
                W3CBaggagePropagator.getInstance().extract(Context.current(), System.getenv(), new EnvironmentGetter()).makeCurrent();
            }
        }
    }

    private static void attach(String traceId, String spanId, TraceFlags flags) {
        SpanContext spanContext = SpanContext.create(traceId, spanId, flags, TraceState.getDefault());
        if (spanContext.isValid()) {
            Context.current().with(Span.wrap(spanContext)).makeCurrent();
        }
    }

    private static final class EnvironmentGetter implements TextMapGetter<Map<String, String>> {
        @Override
        public Iterable<String> keys(Map<String, String> environment) {
            return environment.keySet();
        }

        @Override
        public String get(Map<String, String> environment, String key) {
            return environment.get(key.toUpperCase(Locale.ROOT));
        }
    }
}
