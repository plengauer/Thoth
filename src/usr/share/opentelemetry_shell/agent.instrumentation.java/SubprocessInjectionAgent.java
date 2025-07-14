import net.bytebuddy.agent.builder.AgentBuilder;
import net.bytebuddy.asm.Advice;
import net.bytebuddy.matcher.ElementMatchers;
import java.lang.instrument.*;
import java.io.*;
import java.util.*;

public class SubprocessInjectionAgent {
    public static void premain(String args, Instrumentation instrumentation) throws Exception {
        new AgentBuilder.Default()
            .type(ElementMatchers.named("java.lang.ProcessImpl"))
            .transform((builder, typeDescription, classLoader, module, protectionDomain) ->
                builder.method(ElementMatchers.named("start").and(ElementMatchers.takesArguments(String[].class, Map.class, String.class, java.lang.ProcessBuilder.Redirect[].class, boolean.class)))
                    .intercept(Advice.to(InjectCommandAdvice.class))
            ).installOn(instrumentation);
    }

    public static class InjectCommandAdvice {
        @Advice.OnMethodEnter
        public static void onEnter(@Advice.Argument(value = 0, readOnly = false) String[] cmdarray) {
            String[] oldcmdarray = cmdarray;
            cmdarray = new String[3 + oldcmdarray.length];
            cmdarray[0] = "/bin/sh";
            cmdarray[1] = "-c";
            cmdarray[2] = ". otel.sh\n_otel_inject \"" + oldcmdarray[0] + "\" \"$@\"";
            System.arraycopy(oldcmdarray, 0, cmdarray, 3, cmdarray.length);
        }
    }
}
