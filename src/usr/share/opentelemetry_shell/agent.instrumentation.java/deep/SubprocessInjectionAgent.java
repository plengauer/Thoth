import javassist.*;
import java.lang.instrument.Instrumentation;

public class SubprocessInjectionAgent {

   public static void premain(String args, Instrumentation instrumentation) throws Exception {
       ClassPool pool = ClassPool.getDefault();
       instrumentation.addTransformer((loader, className, classBeingRedefined, protectionDomain, classfileBuffer) -> {
           if (!"java/lang/ProcessBuilder".equals(className)) return null;
           try {
               CtClass ctClass = pool.get("java.lang.ProcessBuilder");
               CtMethod method = ctClass.getDeclaredMethod("start");
               method.insertBefore(
                  "{"
                   + "java.util.List command = $0.command();"
                   + "command.add(0, \"sh\");"
                   + "command.add(1, \"-c\");"
                   + "command.add(2, \".otel.sh\\n\" + command.remove(2));"
                   + "command.add(3, \"java\");"
                   + "}"
                  // TODO modify env
                  // optionally add otel_inject
               );
               return ctClass.toBytecode();
           } catch (Exception e) {
               e.printStackTrace();
           }
       });
   }
}
