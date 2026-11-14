// The class is started by its plain name from the class path
@SuppressWarnings("PMD.NoPackage")
public class SystemPropertiesPrinter {
    public static void main(String[] args) {
       System.getProperties().list(System.out);
    }
}
