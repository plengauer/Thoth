import javassist.*;
import java.lang.instrument.*;
import java.io.*;

public class SubprocessInjectionAgent {
    public static void premain(String args, Instrumentation instrumentation) throws Exception {
        instrumentation.addTransformer(new ClassFileTransformer() {
            public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined, java.security.ProtectionDomain protectionDomain, byte[] classfileBuffer) {
                if (!"java/lang/ProcessBuilder".equals(className)) return null;
                try {
                    ClassPool pool = ClassPool.getDefault();                    
                    CtClass ctClass = pool.makeClass(new ByteArrayInputStream(classfileBuffer));
                    CtMethod method = ctClass.getDeclaredMethod("start");
                    method.insertBefore(
                      "{"
                      + "java.util.List command = $0.command();" // echo hello world
                      + "command.add(0, \"sh\");" // sh echo hello world
                      + "command.add(1, \"-c\");" // sh -c echo hello world
                      + "command.add(2, \". otel.sh\\n\" + command.remove(2) + \" \\\"$@\\\"\");" // sh -c '. otel.sh \n echo "$@"' hello world
                      + "command.add(3, \"java\");" // sh -c '. otel.sh \n echo "$@"' java hello world
                      + "}"
                      // TODO modify env
                      // optionally add otel_inject
                    );
                    return ctClass.toBytecode();
                } catch (Exception e) {
                    e.printStackTrace();
                    return classfileBuffer;
                }
            }
        }, true);
        //instrumentation.retransformClasses(ProcessBuilder.class);
    }
}
