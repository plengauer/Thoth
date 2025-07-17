import net.bytebuddy.agent.builder.AgentBuilder;
import net.bytebuddy.asm.Advice;
import net.bytebuddy.matcher.ElementMatchers;
import net.bytebuddy.implementation.bind.annotation.RuntimeType;
import net.bytebuddy.implementation.bind.annotation.AllArguments;
import net.bytebuddy.implementation.bind.annotation.Origin;
import net.bytebuddy.implementation.MethodDlegation;
import java.lang.instrument.Instrumentation;
import java.util.Map;
import java.lang.reflect.Method;

public class SubprocessInjectionAgent {
    public static void premain(String args, Instrumentation instrumentation) throws Exception {
        instrumentation.appendToBootstrapClassLoaderSearch(new java.util.jar.JarFile("/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar"));
        new AgentBuilder.Default()
            .with(AgentBuilder.RedefinitionStrategy.RETRANSFORMATION)
            .with(AgentBuilder.InitializationStrategy.NoOp.INSTANCE)
            .with(AgentBuilder.TypeStrategy.Default.REDEFINE)
            //.with(AgentBuilder.Listener.StreamWriting.toSystemError())
            .ignore(ElementMatchers.none())
            .type(ElementMatchers.named("java.lang.ProcessImpl"))
            // .transform((builder, typeDescription, classLoader, module, protectionDomain) -> builder.visit(Advice.to(InjectCommandAdvice.class).on(ElementMatchers.named("start"))))
            .transform((builder, typeDescription, classLoader, module, protectionDomain) -> builder.method(ElementMatchers.named("start")).intercept(MethodDelegation.to(InjectCommandInterceptor.class)))
            .installOn(instrumentation);
    }

    public static class InjectCommandInterceptor {
        @RuntimeType
        public static Object intercept(@AllArguments Object[] args, @Origin Method method) throws Exception {
            String[] oldcmdarray = args[0];
            String[] cmdarray = args[0] = new String[3 + oldcmdarray.length];
            cmdarray[0] = "/bin/sh";
            cmdarray[1] = "-c";
            cmdarray[2] = ". otel.sh\n_otel_inject \"" + oldcmdarray[0] + "\" \"$@\"";
            System.arraycopy(oldcmdarray, 0, cmdarray, 3, oldcmdarray.length);
            return method.invoke(null, args);
        }
    }

    public static class InjectCommandAdvice {
        @Advice.OnMethodEnter
        public static void onEnter(@Advice.Argument(value = 0, readOnly = false) String[] cmdarray) {
            String[] oldcmdarray = cmdarray;
            cmdarray = new String[3 + oldcmdarray.length];
            cmdarray[0] = "/bin/sh";
            cmdarray[1] = "-c";
            cmdarray[2] = ". otel.sh\n_otel_inject \"" + oldcmdarray[0] + "\" \"$@\"";
            System.arraycopy(oldcmdarray, 0, cmdarray, 3, oldcmdarray.length);
            System.err.println("DEBUG DEBUG DEBUG");
        }
    }
}
