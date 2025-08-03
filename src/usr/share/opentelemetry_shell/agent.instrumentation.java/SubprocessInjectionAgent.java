import net.bytebuddy.agent.builder.AgentBuilder;
import net.bytebuddy.asm.Advice;
import net.bytebuddy.matcher.ElementMatchers;
import net.bytebuddy.implementation.bind.annotation.RuntimeType;
import net.bytebuddy.implementation.bind.annotation.AllArguments;
import net.bytebuddy.implementation.bind.annotation.Origin;
import net.bytebuddy.implementation.MethodDelegation;
import java.lang.instrument.Instrumentation;
import java.util.Map;
import java.lang.reflect.Method;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.Span;
import io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.SpanContext;

public class SubprocessInjectionAgent {
    public static void premain(String args, Instrumentation instrumentation) throws Exception {
        instrumentation.appendToBootstrapClassLoaderSearch(new java.util.jar.JarFile("/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar"));
        new AgentBuilder.Default()
            .with(AgentBuilder.RedefinitionStrategy.RETRANSFORMATION)
            .with(AgentBuilder.InitializationStrategy.NoOp.INSTANCE)
            .with(AgentBuilder.TypeStrategy.Default.REDEFINE)
            .assureReadEdgeFromAndTo(instrumentation, InjectCommandAdvice.class)
            .ignore(ElementMatchers.none())
            .type(ElementMatchers.named("java.lang.ProcessImpl"))
            .transform((builder, typeDescription, classLoader, module, protectionDomain) -> builder.visit(Advice.to(InjectCommandAdvice.class).on(ElementMatchers.named("start"))))
            .installOn(instrumentation);
    }

    public static class InjectCommandAdvice {
        @Advice.OnMethodEnter
        public static void onEnter(@Advice.Argument(value = 0, readOnly = false) String[] cmdarray, @Advice.Argument(value = 1, readOnly = false) Map<String, String> environment) {
            SpanContext spanContext = Span.current().getSpanContext();
            environment.put("TRACEPARENT", String.format("%s-%s-%s-%s", "00", spanContext.getTraceId(), spanContext.getSpanId(), spanContext.getTraceFlags().asHex()));
            environment.put("OTEL_SHELL_AUTO_INJECTED", "FALSE");
            String[] oldcmdarray = cmdarray;
            cmdarray = new String[3 + oldcmdarray.length];
            cmdarray[0] = "/bin/sh";
            cmdarray[1] = "-c";
            cmdarray[2] = ". otel.sh\n_otel_inject \"" + oldcmdarray[0] + "\" \"$@\"";
            System.arraycopy(oldcmdarray, 0, cmdarray, 3, oldcmdarray.length);
        }
    }
}
