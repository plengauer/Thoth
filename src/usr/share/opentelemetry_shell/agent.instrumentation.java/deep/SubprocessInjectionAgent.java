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
               method.insertBefore("{ "
                   + "java.util.List command = $0.command();"
                   + "command.add(0, \"sh\");"
                   + "command.add(1, \"-c\");"
                   + "command.add(2, String.join(\" \", command.subList(3, command.size())));"
                   + "command.subList(3, command.size()).clear();"
                   + "}");
               return ctClass.toBytecode();
           } catch (Exception e) {
               e.printStackTrace();
           }
       });
       instrumentation.addTransformer((loader, className, classBeingRedefined, protectionDomain, classfileBuffer) -> {
           if (!"java/lang/Runtime".equals(className)) return null;
           try {
               CtClass ctClass = pool.get("java.lang.Runtime");

               // Instrumenting the exec(String) method
               CtMethod execMethod = ctClass.getDeclaredMethod("exec",
                       new CtClass[]{pool.get("java.lang.String")});

               execMethod.insertBefore(
                       "{ $1 = \"sh -c '\" + $1 + \"'\"; }");
                                      // Instrumenting exec(String[]) method
               CtMethod execArrayMethod = ctClass.getDeclaredMethod("exec",
                       new CtClass[]{pool.get("java.lang.String[]")});

               execArrayMethod.insertBefore(
                       "{ $1 = new String[] { \"sh\", \"-c\", String.join(\" \", $1) }; }");

               return ctClass.toBytecode();
           } catch (Exception e) {
               e.printStackTrace();
           }
       });
   }
}
