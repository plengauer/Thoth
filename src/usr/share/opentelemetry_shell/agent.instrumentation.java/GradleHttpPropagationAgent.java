import net.bytebuddy.agent.builder.AgentBuilder;
import net.bytebuddy.asm.Advice;
import net.bytebuddy.matcher.ElementMatchers;
import net.bytebuddy.description.type.TypeDescription;
import net.bytebuddy.dynamic.DynamicType;
import net.bytebuddy.utility.JavaModule;
import java.lang.instrument.Instrumentation;
import java.lang.reflect.Method;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.Span;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.SpanKind;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.SpanContext;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.TraceFlags;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.TraceState;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.context.Context;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.context.Scope;

public class GradleHttpPropagationAgent {
    private static final ThreadLocal<Span> clientSpan = new ThreadLocal<>();
    private static final ThreadLocal<Scope> clientScope = new ThreadLocal<>();
    private static final ThreadLocal<Span> serverSpan = new ThreadLocal<>();
    private static final ThreadLocal<Scope> serverScope = new ThreadLocal<>();

    public static void premain(String args, Instrumentation instrumentation) throws Exception {
        instrumentation.appendToBootstrapClassLoaderSearch(new java.util.jar.JarFile("/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar"));
        new AgentBuilder.Default()
            .with(AgentBuilder.RedefinitionStrategy.RETRANSFORMATION)
            .with(AgentBuilder.InitializationStrategy.NoOp.INSTANCE)
            .with(AgentBuilder.TypeStrategy.Default.REDEFINE)
            .assureReadEdgeFromAndTo(instrumentation, ClientConnectionAdvice.class)
            .assureReadEdgeFromAndTo(instrumentation, DaemonConnectionAdvice.class)
            .ignore(ElementMatchers.nameStartsWith("net.bytebuddy.").or(ElementMatchers.nameStartsWith("java.")).or(ElementMatchers.nameStartsWith("sun.")).or(ElementMatchers.nameStartsWith("com.sun.")).or(ElementMatchers.nameStartsWith("jdk.")))
            .type(ElementMatchers.nameContains("DaemonClientConnection").or(ElementMatchers.nameContains("DaemonClient")).and(ElementMatchers.not(ElementMatchers.isInterface())))
            .transform(new AgentBuilder.Transformer() {
                public DynamicType.Builder<?> transform(DynamicType.Builder<?> builder, TypeDescription typeDescription, ClassLoader classLoader, JavaModule module) {
                    return builder.visit(Advice.to(ClientConnectionAdvice.class).on(ElementMatchers.named("execute").or(ElementMatchers.named("dispatch"))));
                }
            })
            .type(ElementMatchers.nameContains("DaemonConnection").or(ElementMatchers.nameContains("DaemonRequestHandler")).and(ElementMatchers.not(ElementMatchers.isInterface())))
            .transform(new AgentBuilder.Transformer() {
                public DynamicType.Builder<?> transform(DynamicType.Builder<?> builder, TypeDescription typeDescription, ClassLoader classLoader, JavaModule module) {
                    return builder.visit(Advice.to(DaemonConnectionAdvice.class).on(ElementMatchers.named("receive").or(ElementMatchers.named("handle"))));
                }
            })
            .installOn(instrumentation);
    }

    public static class ClientConnectionAdvice {
        @Advice.OnMethodEnter
        public static void onEnter(@Advice.Origin String method, @Advice.AllArguments Object[] args) {
            try {
                Tracer tracer = GlobalOpenTelemetry.getTracer("opentelemetry-shell");
                Span span = tracer.spanBuilder("gradle daemon request")
                    .setSpanKind(SpanKind.CLIENT)
                    .setAttribute("rpc.system", "gradle")
                    .setAttribute("rpc.service", "daemon")
                    .startSpan();
                clientSpan.set(span);
                clientScope.set(span.makeCurrent());
                String traceparent = String.format("%s-%s-%s-%s",
                    "00",
                    span.getSpanContext().getTraceId(),
                    span.getSpanContext().getSpanId(),
                    span.getSpanContext().getTraceFlags().asHex());
                if (args != null && args.length > 0 && args[0] != null) {
                    try {
                        Class<?> clazz = args[0].getClass();
                        Method addHeader = null;
                        for (Method m : clazz.getMethods()) {
                            if (m.getName().equals("addHeader") || m.getName().equals("setHeader") || m.getName().equals("withHeader")) {
                                addHeader = m;
                                break;
                            }
                        }
                        if (addHeader != null) {
                            addHeader.invoke(args[0], "traceparent", traceparent);
                        }
                    } catch (Exception e) {
                    }
                }
            } catch (Exception e) {
            }
        }

        @Advice.OnMethodExit(onThrowable = Throwable.class)
        public static void onExit(@Advice.Thrown Throwable throwable) {
            try {
                System.clearProperty("otel.gradle.client.traceparent");
                Scope scope = clientScope.get();
                if (scope != null) {
                    scope.close();
                    clientScope.remove();
                }
                Span span = clientSpan.get();
                if (span != null) {
                    if (throwable != null) {
                        span.recordException(throwable);
                    }
                    span.end();
                    clientSpan.remove();
                }
            } catch (Exception e) {
            }
        }
    }

    public static class DaemonConnectionAdvice {
        @Advice.OnMethodEnter
        public static void onEnter(@Advice.Origin String method, @Advice.AllArguments Object[] args) {
            try {
                String traceparent = System.getProperty("otel.gradle.client.traceparent");
                if (traceparent == null && args != null && args.length > 0 && args[0] != null) {
                    try {
                        Class<?> clazz = args[0].getClass();
                        Method getHeader = null;
                        for (Method m : clazz.getMethods()) {
                            if (m.getName().equals("getHeader") || m.getName().equals("header")) {
                                getHeader = m;
                                break;
                            }
                        }
                        if (getHeader != null) {
                            Object headerValue = getHeader.invoke(args[0], "traceparent");
                            if (headerValue != null) {
                                traceparent = headerValue.toString();
                            }
                        }
                    } catch (Exception e) {
                    }
                }
                if (traceparent != null && !traceparent.isEmpty()) {
                    String[] parts = traceparent.split("-");
                    if (parts.length >= 4) {
                        SpanContext parentContext = SpanContext.create(
                            parts[1],
                            parts[2],
                            TraceFlags.fromHex(parts[3], 0),
                            TraceState.getDefault()
                        );
                        Tracer tracer = GlobalOpenTelemetry.getTracer("opentelemetry-shell");
                        Span span = tracer.spanBuilder("gradle daemon execute")
                            .setSpanKind(SpanKind.SERVER)
                            .setParent(Context.current().with(Span.wrap(parentContext)))
                            .setAttribute("rpc.system", "gradle")
                            .setAttribute("rpc.service", "daemon")
                            .startSpan();
                        Scope scope = span.makeCurrent();
                        serverSpan.set(span);
                        serverScope.set(scope);
                    }
                }
            } catch (Exception e) {
            }
        }

        @Advice.OnMethodExit(onThrowable = Throwable.class)
        public static void onExit(@Advice.Thrown Throwable throwable) {
            try {
                Scope scope = serverScope.get();
                if (scope != null) {
                    scope.close();
                    serverScope.remove();
                }
                Span span = serverSpan.get();
                if (span != null) {
                    if (throwable != null) {
                        span.recordException(throwable);
                    }
                    span.end();
                    serverSpan.remove();
                }
            } catch (Exception e) {
            }
        }
    }
}
